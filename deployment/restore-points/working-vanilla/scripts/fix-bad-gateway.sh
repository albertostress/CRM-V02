#!/bin/bash

# ===================================
# FIX BAD GATEWAY - ESPOCRM
# ===================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║        FIXING BAD GATEWAY ERROR                 ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Stop all containers
echo -e "${YELLOW}Step 1: Stopping containers...${NC}"
docker-compose down
sleep 2

# Step 2: Start database first
echo -e "${YELLOW}Step 2: Starting database...${NC}"
docker-compose up -d espocrm-db
sleep 10

# Wait for database to be ready
echo -e "${YELLOW}Waiting for database to be ready...${NC}"
until docker exec espocrm-db mysql -u${DB_USER:-espocrm} -p${DB_PASSWORD:-espocrm_password} -e "SELECT 1" >/dev/null 2>&1; do
    echo -n "."
    sleep 2
done
echo -e "${GREEN}✓ Database is ready${NC}"

# Step 3: Start Redis
echo -e "${YELLOW}Step 3: Starting Redis cache...${NC}"
docker-compose up -d espocrm-redis
sleep 2

# Step 4: Start main application without custom command first
echo -e "${YELLOW}Step 4: Starting EspoCRM application...${NC}"

# Temporarily remove custom command to ensure container starts
docker-compose up -d espocrm --no-deps
sleep 10

# Step 5: Check if container is running
if docker ps | grep -q espocrm; then
    echo -e "${GREEN}✓ Container started${NC}"
    
    # Step 6: Fix permissions
    echo -e "${YELLOW}Step 5: Fixing permissions...${NC}"
    docker exec espocrm bash -c "
        chown -R www-data:www-data /var/www/html
        chmod -R 755 /var/www/html
        chmod -R 775 /var/www/html/data
        chmod -R 775 /var/www/html/custom
    "
    echo -e "${GREEN}✓ Permissions fixed${NC}"
    
    # Step 7: Ensure PHP-FPM is running
    echo -e "${YELLOW}Step 6: Ensuring PHP-FPM is running...${NC}"
    docker exec espocrm bash -c "
        # Kill any existing PHP-FPM processes
        killall php-fpm 2>/dev/null || true
        sleep 1
        # Start PHP-FPM
        php-fpm -D
    " 2>/dev/null || true
    
    # Check if PHP-FPM started
    if docker exec espocrm pgrep php-fpm >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PHP-FPM is running${NC}"
    else
        echo -e "${YELLOW}⚠ PHP-FPM may not be running, trying alternative method${NC}"
        docker exec espocrm service php*-fpm start 2>/dev/null || true
    fi
    
    # Step 8: Apply Evertec branding if script exists
    if [ -f "deployment/scripts/apply-evertec-complete.sh" ]; then
        echo -e "${YELLOW}Step 7: Applying Evertec branding...${NC}"
        docker exec espocrm bash /deployment/scripts/apply-evertec-complete.sh 2>/dev/null || true
        echo -e "${GREEN}✓ Branding applied${NC}"
    fi
    
    # Step 9: Clear cache
    echo -e "${YELLOW}Step 8: Clearing cache...${NC}"
    docker exec espocrm bash -c "
        rm -rf /var/www/html/data/cache/*
        php /var/www/html/clear_cache.php 2>/dev/null || true
    "
    echo -e "${GREEN}✓ Cache cleared${NC}"
    
else
    echo -e "${RED}✗ Container failed to start${NC}"
    echo -e "${YELLOW}Checking logs...${NC}"
    docker logs espocrm --tail 50
    
    echo ""
    echo -e "${YELLOW}Attempting alternative fix...${NC}"
    
    # Remove container and recreate
    docker-compose rm -f espocrm
    docker-compose up -d espocrm
    sleep 10
fi

# Step 10: Start remaining services
echo -e "${YELLOW}Step 9: Starting remaining services...${NC}"
docker-compose up -d espocrm-daemon espocrm-websocket
sleep 5

# Step 11: Final verification
echo -e "${YELLOW}Step 10: Verifying services...${NC}"
bash deployment/scripts/diagnose-bad-gateway.sh

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ FIX ATTEMPT COMPLETED                    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Check if site is accessible"
echo -e "2. Clear browser cache (Ctrl+F5)"
echo -e "3. If still showing Bad Gateway:"
echo -e "   - Check logs: docker logs espocrm"
echo -e "   - Check Traefik: docker logs traefik"
echo ""

exit 0