#!/bin/bash

# ===================================
# BAD GATEWAY DIAGNOSTIC TOOL
# ===================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        BAD GATEWAY DIAGNOSTIC TOOL              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

ERRORS=0
WARNINGS=0

# 1. Check if containers are running
echo -e "${YELLOW}1. Checking Docker containers...${NC}"
if docker ps | grep -q espocrm; then
    echo -e "${GREEN}✓ EspoCRM container is running${NC}"
    
    # Check container health
    HEALTH=$(docker inspect espocrm --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")
    if [ "$HEALTH" = "healthy" ]; then
        echo -e "${GREEN}✓ Container is healthy${NC}"
    else
        echo -e "${YELLOW}⚠ Container health: $HEALTH${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${RED}✗ EspoCRM container is NOT running${NC}"
    ERRORS=$((ERRORS + 1))
    
    # Check if container exists but stopped
    if docker ps -a | grep -q espocrm; then
        echo -e "${YELLOW}Container exists but is stopped. Checking logs...${NC}"
        docker logs espocrm --tail 20
    fi
fi

# 2. Check database
echo -e "${YELLOW}2. Checking database...${NC}"
if docker ps | grep -q espocrm-db; then
    echo -e "${GREEN}✓ Database container is running${NC}"
    
    # Test database connection
    if docker exec espocrm-db mysql -u${DB_USER:-espocrm} -p${DB_PASSWORD:-espocrm_password} -e "SELECT 1" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Database connection successful${NC}"
    else
        echo -e "${RED}✗ Cannot connect to database${NC}"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${RED}✗ Database container is NOT running${NC}"
    ERRORS=$((ERRORS + 1))
fi

# 3. Check PHP-FPM
echo -e "${YELLOW}3. Checking PHP-FPM...${NC}"
if docker exec espocrm pgrep php-fpm >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PHP-FPM is running${NC}"
else
    echo -e "${RED}✗ PHP-FPM is NOT running${NC}"
    ERRORS=$((ERRORS + 1))
    
    echo -e "${YELLOW}Attempting to start PHP-FPM...${NC}"
    docker exec espocrm php-fpm -D 2>/dev/null || true
fi

# 4. Check Apache/Nginx
echo -e "${YELLOW}4. Checking web server...${NC}"
if docker exec espocrm pgrep apache2 >/dev/null 2>&1 || docker exec espocrm pgrep nginx >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Web server is running${NC}"
else
    echo -e "${RED}✗ Web server is NOT running${NC}"
    ERRORS=$((ERRORS + 1))
fi

# 5. Check port 80
echo -e "${YELLOW}5. Checking port 80...${NC}"
if docker exec espocrm netstat -tuln | grep -q ":80 " 2>/dev/null; then
    echo -e "${GREEN}✓ Port 80 is listening${NC}"
else
    echo -e "${RED}✗ Port 80 is NOT listening${NC}"
    ERRORS=$((ERRORS + 1))
fi

# 6. Check application files
echo -e "${YELLOW}6. Checking application files...${NC}"
if docker exec espocrm test -f /var/www/html/index.php 2>/dev/null; then
    echo -e "${GREEN}✓ Application files exist${NC}"
else
    echo -e "${RED}✗ Application files missing${NC}"
    ERRORS=$((ERRORS + 1))
fi

# 7. Check config.php
echo -e "${YELLOW}7. Checking configuration...${NC}"
if docker exec espocrm test -f /var/www/html/data/config.php 2>/dev/null; then
    echo -e "${GREEN}✓ Config.php exists${NC}"
else
    echo -e "${YELLOW}⚠ Config.php missing (first run?)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# 8. Check permissions
echo -e "${YELLOW}8. Checking file permissions...${NC}"
if docker exec espocrm stat -c %U /var/www/html 2>/dev/null | grep -q www-data; then
    echo -e "${GREEN}✓ Correct file ownership${NC}"
else
    echo -e "${YELLOW}⚠ File ownership may be incorrect${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# 9. Check Traefik labels
echo -e "${YELLOW}9. Checking Traefik configuration...${NC}"
if docker inspect espocrm | grep -q "traefik.enable=true"; then
    echo -e "${GREEN}✓ Traefik labels configured${NC}"
    
    # Get domain from labels
    DOMAIN=$(docker inspect espocrm --format='{{range $k, $v := .Config.Labels}}{{if eq $k "traefik.http.routers.espocrm.rule"}}{{$v}}{{end}}{{end}}' | sed 's/Host(`\(.*\)`)/\1/')
    echo -e "${BLUE}  Domain: $DOMAIN${NC}"
else
    echo -e "${YELLOW}⚠ Traefik labels not found${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# 10. Check recent errors
echo -e "${YELLOW}10. Checking recent errors...${NC}"
ERROR_COUNT=$(docker logs espocrm 2>&1 | grep -i error | tail -5 | wc -l)
if [ $ERROR_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found $ERROR_COUNT recent errors:${NC}"
    docker logs espocrm 2>&1 | grep -i error | tail -5
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓ No recent errors in logs${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     ✅ ALL CHECKS PASSED                        ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
elif [ $ERRORS -gt 0 ]; then
    echo -e "${RED}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║     ⚠️  ERRORS FOUND: $ERRORS                          ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Suggested fixes:${NC}"
    echo -e "1. Restart containers: docker-compose restart"
    echo -e "2. Check logs: docker logs espocrm"
    echo -e "3. Run fix script: bash deployment/scripts/fix-bad-gateway.sh"
else
    echo -e "${YELLOW}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║     ⚠️  WARNINGS: $WARNINGS                             ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════╝${NC}"
fi

echo ""
exit $ERRORS