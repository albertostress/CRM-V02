#!/bin/bash

# ===================================
# ROLLBACK TO WORKING CONFIGURATION
# ===================================
# This script reverts to basic working EspoCRM setup

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ROLLING BACK TO WORKING CONFIGURATION       ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Stop all containers
echo -e "${YELLOW}Step 1: Stopping all containers...${NC}"
docker-compose down
sleep 2

# Step 2: Remove any override files
echo -e "${YELLOW}Step 2: Cleaning up override files...${NC}"
rm -f docker-compose.override.yml
echo -e "${GREEN}✓ Cleaned${NC}"

# Step 3: Ensure directories exist
echo -e "${YELLOW}Step 3: Ensuring directories exist...${NC}"
mkdir -p ../files/espocrm-data
mkdir -p ../files/espocrm-custom
mkdir -p ../files/espocrm-uploads
mkdir -p ../files/espocrm-db
mkdir -p ../files/espocrm-redis
echo -e "${GREEN}✓ Directories ready${NC}"

# Step 4: Start services in order
echo -e "${YELLOW}Step 4: Starting database...${NC}"
docker-compose up -d espocrm-db
echo -e "${YELLOW}Waiting for database to be ready...${NC}"
sleep 15

# Step 5: Start Redis
echo -e "${YELLOW}Step 5: Starting Redis...${NC}"
docker-compose up -d espocrm-redis
sleep 5

# Step 6: Start main application WITHOUT custom commands
echo -e "${YELLOW}Step 6: Starting EspoCRM (vanilla configuration)...${NC}"
docker-compose up -d espocrm
echo -e "${YELLOW}Waiting for application to initialize...${NC}"
sleep 20

# Step 7: Start daemon and websocket
echo -e "${YELLOW}Step 7: Starting auxiliary services...${NC}"
docker-compose up -d espocrm-daemon espocrm-websocket
sleep 5

# Step 8: Check status
echo -e "${YELLOW}Step 8: Checking service status...${NC}"
docker-compose ps

# Step 9: Test connectivity
echo -e "${YELLOW}Step 9: Testing application...${NC}"
if docker exec espocrm curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null | grep -q "200\|302"; then
    echo -e "${GREEN}✓ Application is responding!${NC}"
else
    echo -e "${YELLOW}⚠ Application may still be starting up${NC}"
    echo -e "${YELLOW}  Wait 1-2 minutes and check again${NC}"
fi

# Step 10: Display info
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ROLLBACK COMPLETE - VANILLA ESPOCRM         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}The system is now running with:${NC}"
echo -e "• Default EspoCRM configuration"
echo -e "• No custom branding applied"
echo -e "• Basic Docker setup"
echo ""
echo -e "${YELLOW}To apply branding later (after confirming it works):${NC}"
echo -e "1. Access the CRM and verify it's working"
echo -e "2. Run: docker exec espocrm bash /deployment/scripts/apply-evertec-complete.sh"
echo ""
echo -e "${BLUE}Access your CRM at:${NC}"
if [ -f .env ]; then
    DOMAIN=$(grep "^DOMAIN=" .env | cut -d'=' -f2)
    echo -e "  https://$DOMAIN"
else
    echo -e "  https://your-domain.com"
fi
echo ""
echo -e "${YELLOW}If you see 404 or Bad Gateway:${NC}"
echo -e "• Run: bash deployment/scripts/diagnose-404.sh"
echo -e "• Run: bash deployment/scripts/diagnose-bad-gateway.sh"
echo ""

exit 0