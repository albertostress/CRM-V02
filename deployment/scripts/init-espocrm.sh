#!/bin/bash

# ===================================
# ESPOCRM INITIALIZATION SCRIPT
# ===================================
# Safe initialization for Dokploy deployment

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        INITIALIZING ESPOCRM ON DOKPLOY          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check environment
echo -e "${YELLOW}Step 1: Checking environment...${NC}"

# Ensure we're in the right directory
cd /mnt/d/Projecto/CRM-V02/espocrm || cd $(dirname $0)/../..

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env from example...${NC}"
    cp .env.example .env
    echo -e "${RED}⚠️  Please edit .env file with your settings!${NC}"
    exit 1
fi

# Step 2: Create necessary directories
echo -e "${YELLOW}Step 2: Creating directories...${NC}"
mkdir -p ../files/espocrm-data
mkdir -p ../files/espocrm-custom
mkdir -p ../files/espocrm-uploads
mkdir -p ../files/espocrm-db
mkdir -p ../files/espocrm-redis

echo -e "${GREEN}✓ Directories created${NC}"

# Step 3: Start services in correct order
echo -e "${YELLOW}Step 3: Starting database...${NC}"
docker-compose up -d espocrm-db
sleep 10

echo -e "${YELLOW}Step 4: Starting Redis...${NC}"
docker-compose up -d espocrm-redis
sleep 5

echo -e "${YELLOW}Step 5: Starting EspoCRM...${NC}"
docker-compose up -d espocrm
sleep 15

echo -e "${YELLOW}Step 6: Starting daemon and websocket...${NC}"
docker-compose up -d espocrm-daemon espocrm-websocket
sleep 5

# Step 4: Check status
echo -e "${YELLOW}Step 7: Checking status...${NC}"
docker-compose ps

# Step 5: Apply branding (after container is healthy)
echo -e "${YELLOW}Step 8: Waiting for container to be ready...${NC}"
COUNTER=0
MAX_TRIES=30

while [ $COUNTER -lt $MAX_TRIES ]; do
    if docker exec espocrm curl -f http://localhost >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Container is ready!${NC}"
        
        # Apply branding
        echo -e "${YELLOW}Applying Evertec branding...${NC}"
        docker exec espocrm bash /deployment/scripts/apply-evertec-complete.sh 2>/dev/null || true
        break
    fi
    
    echo -n "."
    sleep 2
    COUNTER=$((COUNTER + 1))
done

if [ $COUNTER -eq $MAX_TRIES ]; then
    echo -e "${RED}✗ Container did not become ready in time${NC}"
    echo -e "${YELLOW}Checking logs...${NC}"
    docker logs espocrm --tail 20
fi

# Step 6: Final status
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     INITIALIZATION COMPLETE                     ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Access your CRM at: https://\${DOMAIN}${NC}"
echo -e "${BLUE}Default credentials:${NC}"
echo -e "  Username: admin"
echo -e "  Password: (check your .env file)"
echo ""
echo -e "${YELLOW}If you see Bad Gateway:${NC}"
echo -e "1. Wait 1-2 minutes for services to fully start"
echo -e "2. Run: bash deployment/scripts/diagnose-bad-gateway.sh"
echo -e "3. Run: bash deployment/scripts/fix-bad-gateway.sh"
echo ""

exit 0