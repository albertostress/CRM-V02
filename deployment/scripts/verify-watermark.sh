#!/bin/bash

# ===================================
# VERIFY WATERMARK REPLACEMENT
# ===================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      WATERMARK VERIFICATION TOOL                ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running in Docker
if [ ! -f /.dockerenv ]; then
    echo -e "${YELLOW}Running verification in Docker container...${NC}"
    docker exec espocrm bash /deployment/scripts/verify-watermark.sh
    exit $?
fi

ERRORS=0
WARNINGS=0

echo -e "${YELLOW}Checking for EspoCRM references...${NC}"
echo ""

# Check template files
echo -e "${BLUE}1. Checking template files...${NC}"
if grep -r "EspoCRM" /var/www/html/client/res/templates/ 2>/dev/null | grep -v "Binary file"; then
    echo -e "${RED}✗ Found EspoCRM in templates${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ No EspoCRM in templates${NC}"
fi

# Check HTML files
echo -e "${BLUE}2. Checking HTML files...${NC}"
if grep -r "EspoCRM" /var/www/html/html/ 2>/dev/null | grep -v "Binary file"; then
    echo -e "${RED}✗ Found EspoCRM in HTML files${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ No EspoCRM in HTML files${NC}"
fi

# Check custom files
echo -e "${BLUE}3. Checking custom files...${NC}"
if [ -f "/var/www/html/client/custom/lib/custom-footer.js" ]; then
    echo -e "${GREEN}✓ Custom footer JavaScript exists${NC}"
else
    echo -e "${RED}✗ Custom footer JavaScript missing${NC}"
    ERRORS=$((ERRORS + 1))
fi

if [ -f "/var/www/html/client/custom/res/css/custom.css" ]; then
    echo -e "${GREEN}✓ Custom CSS exists${NC}"
else
    echo -e "${RED}✗ Custom CSS missing${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check if Evertec is present
echo -e "${BLUE}4. Checking for Evertec branding...${NC}"
if grep -q "Evertec" /var/www/html/client/res/templates/site/footer.tpl 2>/dev/null; then
    echo -e "${GREEN}✓ Evertec found in footer template${NC}"
else
    echo -e "${RED}✗ Evertec NOT found in footer template${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check cache status
echo -e "${BLUE}5. Checking cache directories...${NC}"
if [ -d "/var/www/html/data/cache" ] && [ "$(ls -A /var/www/html/data/cache 2>/dev/null)" ]; then
    echo -e "${YELLOW}⚠ Cache directory not empty - may need clearing${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓ Cache directory is clean${NC}"
fi

# Check running processes
echo -e "${BLUE}6. Checking PHP processes...${NC}"
if pgrep php-fpm > /dev/null; then
    echo -e "${GREEN}✓ PHP-FPM is running${NC}"
else
    echo -e "${YELLOW}⚠ PHP-FPM not running${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Summary
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     ✅ ALL CHECKS PASSED!                       ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Watermark replacement is configured correctly.${NC}"
    echo -e "${GREEN}Footer should show: © 2025 Evertec${NC}"
elif [ $ERRORS -gt 0 ]; then
    echo -e "${RED}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║     ⚠️  ERRORS DETECTED: $ERRORS                        ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Run these commands to fix:${NC}"
    echo -e "1. bash /deployment/scripts/force-evertec-footer.sh"
    echo -e "2. bash /deployment/scripts/clear-all-cache.sh"
    echo -e "3. docker restart espocrm"
else
    echo -e "${YELLOW}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║     ⚠️  WARNINGS: $WARNINGS                             ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Consider clearing cache:${NC}"
    echo -e "bash /deployment/scripts/clear-all-cache.sh"
fi

echo ""
echo -e "${BLUE}Browser Console Check:${NC}"
echo -e "Open browser console (F12) and type: ${YELLOW}evertecStatus()${NC}"
echo -e "This will show the replacement counter if JS is active."
echo ""

exit $ERRORS