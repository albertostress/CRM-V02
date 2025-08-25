#!/bin/bash

# ===================================
# 404 ERROR DIAGNOSTIC - TRAEFIK/DOKPLOY
# ===================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        404 ERROR DIAGNOSTIC TOOL                ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

ERRORS=0

# 1. Check if container is running
echo -e "${YELLOW}1. Checking if EspoCRM container is running...${NC}"
if docker ps | grep -q espocrm; then
    echo -e "${GREEN}✓ Container is running${NC}"
    CONTAINER_ID=$(docker ps -q -f name=espocrm)
    echo -e "${BLUE}  Container ID: $CONTAINER_ID${NC}"
else
    echo -e "${RED}✗ Container is NOT running${NC}"
    ERRORS=$((ERRORS + 1))
    
    # Try to start it
    echo -e "${YELLOW}Attempting to start container...${NC}"
    docker-compose up -d espocrm
    sleep 5
fi

# 2. Check Traefik labels
echo -e "${YELLOW}2. Checking Traefik labels...${NC}"
if docker inspect espocrm >/dev/null 2>&1; then
    LABELS=$(docker inspect espocrm --format='{{json .Config.Labels}}' | python3 -m json.tool 2>/dev/null || docker inspect espocrm --format='{{json .Config.Labels}}')
    
    echo -e "${BLUE}Current labels:${NC}"
    echo "$LABELS" | grep traefik || echo "No Traefik labels found!"
    
    # Check specific required labels
    if echo "$LABELS" | grep -q "traefik.enable.*true"; then
        echo -e "${GREEN}✓ Traefik is enabled${NC}"
    else
        echo -e "${RED}✗ Traefik is NOT enabled${NC}"
        ERRORS=$((ERRORS + 1))
    fi
    
    # Extract domain
    DOMAIN=$(echo "$LABELS" | grep -oP 'traefik\.http\.routers\.\w+\.rule.*Host\(`\K[^`]+' | head -1)
    if [ -n "$DOMAIN" ]; then
        echo -e "${GREEN}✓ Domain configured: $DOMAIN${NC}"
    else
        echo -e "${RED}✗ No domain configured in labels${NC}"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${RED}✗ Cannot inspect container${NC}"
    ERRORS=$((ERRORS + 1))
fi

# 3. Check if container is in dokploy-network
echo -e "${YELLOW}3. Checking network connectivity...${NC}"
if docker inspect espocrm --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' | grep -q dokploy-network; then
    echo -e "${GREEN}✓ Connected to dokploy-network${NC}"
    
    # Get IP in network
    IP=$(docker inspect espocrm --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
    echo -e "${BLUE}  Container IP: $IP${NC}"
else
    echo -e "${RED}✗ NOT connected to dokploy-network${NC}"
    ERRORS=$((ERRORS + 1))
    
    # Try to connect
    echo -e "${YELLOW}Connecting to dokploy-network...${NC}"
    docker network connect dokploy-network espocrm 2>/dev/null || true
fi

# 4. Check if Traefik can see the container
echo -e "${YELLOW}4. Checking Traefik discovery...${NC}"
if docker ps | grep -q traefik; then
    echo -e "${GREEN}✓ Traefik is running${NC}"
    
    # Check Traefik logs for our container
    echo -e "${BLUE}Recent Traefik logs mentioning espocrm:${NC}"
    docker logs traefik 2>&1 | grep -i espocrm | tail -5 || echo "No mentions found"
else
    echo -e "${RED}✗ Traefik is NOT running${NC}"
    ERRORS=$((ERRORS + 1))
fi

# 5. Check if port 80 is exposed
echo -e "${YELLOW}5. Checking exposed ports...${NC}"
PORTS=$(docker inspect espocrm --format='{{range $p, $conf := .Config.ExposedPorts}}{{$p}} {{end}}')
if echo "$PORTS" | grep -q "80"; then
    echo -e "${GREEN}✓ Port 80 is exposed${NC}"
else
    echo -e "${YELLOW}⚠ Port 80 may not be exposed${NC}"
fi

# 6. Test internal connectivity
echo -e "${YELLOW}6. Testing internal connectivity...${NC}"
if docker exec espocrm curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null | grep -q "200\|302"; then
    echo -e "${GREEN}✓ Application responds on localhost${NC}"
else
    echo -e "${RED}✗ Application NOT responding on localhost${NC}"
    ERRORS=$((ERRORS + 1))
    
    # Check if Apache/Nginx is running
    if docker exec espocrm pgrep apache2 >/dev/null 2>&1 || docker exec espocrm pgrep nginx >/dev/null 2>&1; then
        echo -e "${YELLOW}  Web server is running but not responding${NC}"
    else
        echo -e "${RED}  Web server is NOT running${NC}"
    fi
fi

# 7. Check .env file
echo -e "${YELLOW}7. Checking .env configuration...${NC}"
if [ -f .env ]; then
    CONFIGURED_DOMAIN=$(grep "^DOMAIN=" .env | cut -d'=' -f2)
    if [ -n "$CONFIGURED_DOMAIN" ]; then
        echo -e "${GREEN}✓ Domain in .env: $CONFIGURED_DOMAIN${NC}"
    else
        echo -e "${RED}✗ No DOMAIN configured in .env${NC}"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${RED}✗ .env file not found${NC}"
    ERRORS=$((ERRORS + 1))
fi

# 8. Check Dokploy configuration
echo -e "${YELLOW}8. Checking Dokploy setup...${NC}"
if [ -d "../files" ]; then
    echo -e "${GREEN}✓ Dokploy files directory exists${NC}"
else
    echo -e "${YELLOW}⚠ Dokploy files directory not found (expected: ../files)${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Configuration looks correct!                ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}If still getting 404:${NC}"
    echo -e "1. Verify domain DNS points to server"
    echo -e "2. Check Traefik dashboard for routes"
    echo -e "3. Try accessing: http://$CONFIGURED_DOMAIN (without HTTPS)"
else
    echo -e "${RED}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║     ERRORS FOUND: $ERRORS                              ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}To fix:${NC}"
    echo -e "1. Run: bash deployment/scripts/fix-404.sh"
    echo -e "2. Check your .env file has correct DOMAIN"
    echo -e "3. Ensure Traefik is running in Dokploy"
fi

echo ""
exit $ERRORS