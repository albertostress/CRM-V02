#!/bin/bash

# ===================================
# APPLY EVERTEC FOOTER IN DOCKER
# ===================================
# This script applies the footer changes from outside the container

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     APPLYING EVERTEC FOOTER IN DOCKER           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Docker container is running
if ! docker ps | grep -q espocrm; then
    echo -e "${RED}Error: EspoCRM container is not running${NC}"
    echo -e "${YELLOW}Start the container first with: docker-compose up -d${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1: Copying customization files to container...${NC}"

# Copy custom CSS
docker exec espocrm mkdir -p /var/www/html/client/custom/res/css
docker cp client/custom/res/css/custom.css espocrm:/var/www/html/client/custom/res/css/

# Copy custom JavaScript
docker exec espocrm mkdir -p /var/www/html/client/custom/lib
docker cp client/custom/lib/custom-footer.js espocrm:/var/www/html/client/custom/lib/

# Copy metadata
docker exec espocrm mkdir -p /var/www/html/custom/Espo/Custom/Resources/metadata/app
docker cp custom/Espo/Custom/Resources/metadata/app/client.json espocrm:/var/www/html/custom/Espo/Custom/Resources/metadata/app/

# Copy custom template
docker exec espocrm mkdir -p /var/www/html/custom/Espo/Custom/Resources/templates/site
docker cp custom/Espo/Custom/Resources/templates/site/footer.tpl espocrm:/var/www/html/custom/Espo/Custom/Resources/templates/site/

# Copy original template override
docker cp client/res/templates/site/footer.tpl espocrm:/var/www/html/client/res/templates/site/

echo -e "${GREEN}✓ Files copied${NC}"

echo -e "${YELLOW}Step 2: Setting permissions...${NC}"
docker exec espocrm bash -c "
    chown -R www-data:www-data /var/www/html/client/
    chown -R www-data:www-data /var/www/html/custom/
    chmod -R 755 /var/www/html/client/custom/
    chmod -R 755 /var/www/html/custom/
"
echo -e "${GREEN}✓ Permissions set${NC}"

echo -e "${YELLOW}Step 3: Clearing cache and rebuilding...${NC}"
docker exec espocrm bash -c "
    rm -rf /var/www/html/data/cache/*
    rm -f /var/www/html/client/lib/templates.tpl
    php /var/www/html/rebuild.php 2>/dev/null || true
    php /var/www/html/clear_cache.php 2>/dev/null || true
"
echo -e "${GREEN}✓ Cache cleared and rebuilt${NC}"

echo -e "${YELLOW}Step 4: Applying force script...${NC}"
docker exec espocrm bash /deployment/scripts/force-evertec-footer.sh
echo -e "${GREEN}✓ Force script applied${NC}"

echo -e "${YELLOW}Step 5: Restarting container...${NC}"
docker restart espocrm
echo -e "${GREEN}✓ Container restarted${NC}"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ EVERTEC FOOTER APPLIED SUCCESSFULLY      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Clear your browser cache (Ctrl+Shift+F5)"
echo -e "2. Open the CRM in an incognito window"
echo -e "3. The footer should now show: © 2025 Evertec"
echo ""
echo -e "${BLUE}If the watermark still shows, run:${NC}"
echo -e "docker exec espocrm bash /deployment/scripts/force-evertec-footer.sh"
echo -e "docker restart espocrm"

exit 0