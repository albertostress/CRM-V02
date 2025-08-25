#!/bin/bash

# ===================================
# FIX 404 ERROR - TRAEFIK ROUTING
# ===================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║        FIXING 404 ERROR - TRAEFIK               ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check .env
echo -e "${YELLOW}Step 1: Checking .env configuration...${NC}"
if [ ! -f .env ]; then
    echo -e "${RED}✗ .env file not found!${NC}"
    echo -e "${YELLOW}Creating from example...${NC}"
    cp .env.example .env
    echo -e "${RED}IMPORTANT: Edit .env and set your DOMAIN!${NC}"
    exit 1
fi

DOMAIN=$(grep "^DOMAIN=" .env | cut -d'=' -f2)
if [ -z "$DOMAIN" ]; then
    echo -e "${RED}✗ DOMAIN not set in .env!${NC}"
    echo -e "${YELLOW}Please edit .env and set DOMAIN=your-domain.com${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Domain configured: $DOMAIN${NC}"

# Step 2: Stop and remove container
echo -e "${YELLOW}Step 2: Recreating container with correct labels...${NC}"
docker-compose stop espocrm
docker-compose rm -f espocrm

# Step 3: Ensure network exists
echo -e "${YELLOW}Step 3: Checking dokploy-network...${NC}"
if ! docker network ls | grep -q dokploy-network; then
    echo -e "${YELLOW}Creating dokploy-network...${NC}"
    docker network create dokploy-network
fi
echo -e "${GREEN}✓ Network ready${NC}"

# Step 4: Start with minimal config first
echo -e "${YELLOW}Step 4: Starting EspoCRM with correct routing...${NC}"

# Create a temporary override file
cat > docker-compose.override.yml << EOF
version: "3.8"

services:
  espocrm:
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=dokploy-network"
      - "traefik.http.routers.espocrm.rule=Host(\`${DOMAIN}\`)"
      - "traefik.http.routers.espocrm.entrypoints=web,websecure"
      - "traefik.http.routers.espocrm.tls=true"
      - "traefik.http.routers.espocrm.tls.certresolver=letsencrypt"
      - "traefik.http.services.espocrm.loadbalancer.server.port=80"
      - "traefik.http.routers.espocrm-http.rule=Host(\`${DOMAIN}\`)"
      - "traefik.http.routers.espocrm-http.entrypoints=web"
      - "traefik.http.routers.espocrm-http.middlewares=redirect-to-https"
      - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
EOF

echo -e "${GREEN}✓ Override file created${NC}"

# Step 5: Start services
echo -e "${YELLOW}Step 5: Starting services...${NC}"
docker-compose up -d espocrm-db espocrm-redis
sleep 5
docker-compose up -d espocrm
sleep 10

# Step 6: Verify container is in network
echo -e "${YELLOW}Step 6: Verifying network connection...${NC}"
if ! docker inspect espocrm --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' | grep -q dokploy-network; then
    echo -e "${YELLOW}Manually connecting to dokploy-network...${NC}"
    docker network connect dokploy-network espocrm
fi
echo -e "${GREEN}✓ Connected to dokploy-network${NC}"

# Step 7: Test internal connectivity
echo -e "${YELLOW}Step 7: Testing internal connectivity...${NC}"
COUNTER=0
MAX_TRIES=30

while [ $COUNTER -lt $MAX_TRIES ]; do
    if docker exec espocrm curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null | grep -q "200\|302"; then
        echo -e "${GREEN}✓ Application is responding!${NC}"
        break
    fi
    echo -n "."
    sleep 2
    COUNTER=$((COUNTER + 1))
done

if [ $COUNTER -eq $MAX_TRIES ]; then
    echo -e "${RED}✗ Application not responding internally${NC}"
    echo -e "${YELLOW}Checking logs...${NC}"
    docker logs espocrm --tail 20
fi

# Step 8: Force Traefik to refresh
echo -e "${YELLOW}Step 8: Refreshing Traefik configuration...${NC}"
if docker ps | grep -q traefik; then
    # Restart Traefik to force refresh
    docker restart traefik 2>/dev/null || true
    sleep 5
    echo -e "${GREEN}✓ Traefik refreshed${NC}"
else
    echo -e "${YELLOW}⚠ Traefik not found - make sure it's running in Dokploy${NC}"
fi

# Step 9: Display current labels
echo -e "${YELLOW}Step 9: Current Traefik labels:${NC}"
docker inspect espocrm --format='{{json .Config.Labels}}' | grep -o '"traefik[^"]*":"[^"]*"' | sed 's/"//g'

# Step 10: Test routes
echo -e "${YELLOW}Step 10: Testing routes...${NC}"
echo -e "${BLUE}Routes configured:${NC}"
echo "  - http://$DOMAIN -> redirects to HTTPS"
echo "  - https://$DOMAIN -> EspoCRM"
echo ""

# Final message
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     FIX APPLIED - TEST YOUR DOMAIN              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Try accessing:${NC}"
echo -e "  ${YELLOW}https://$DOMAIN${NC}"
echo ""
echo -e "${YELLOW}If still showing 404:${NC}"
echo -e "1. Verify DNS: nslookup $DOMAIN"
echo -e "2. Check Traefik dashboard in Dokploy"
echo -e "3. Try without HTTPS: http://$DOMAIN"
echo -e "4. Check Traefik logs: docker logs traefik | grep espocrm"
echo ""
echo -e "${BLUE}To see all routes in Traefik:${NC}"
echo -e "  docker exec traefik wget -qO- http://localhost:8080/api/http/routers | python3 -m json.tool"
echo ""

exit 0