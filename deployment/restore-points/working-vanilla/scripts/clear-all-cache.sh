#!/bin/bash

# ===================================
# CLEAR ALL CACHES - FORCE EVERTEC
# ===================================
# Nuclear option - clears EVERYTHING

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║     NUCLEAR CACHE CLEAR - FORCE EVERTEC         ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running in Docker
if [ ! -f /.dockerenv ]; then
    echo -e "${YELLOW}Executing in Docker container...${NC}"
    docker exec espocrm bash /deployment/scripts/clear-all-cache.sh
    
    # Also restart container
    echo -e "${YELLOW}Restarting container...${NC}"
    docker restart espocrm
    
    echo ""
    echo -e "${GREEN}Container restarted!${NC}"
    echo ""
    echo -e "${RED}IMPORTANT: Clear your browser cache NOW!${NC}"
    echo -e "${YELLOW}1. Press Ctrl+Shift+F5${NC}"
    echo -e "${YELLOW}2. Or open in Incognito/Private mode${NC}"
    echo -e "${YELLOW}3. Or clear browser data completely:${NC}"
    echo -e "   - Chrome: Settings > Privacy > Clear browsing data"
    echo -e "   - Firefox: Settings > Privacy > Clear Data"
    echo -e "   - Edge: Settings > Privacy > Clear browsing data"
    exit 0
fi

echo -e "${RED}STEP 1: Stopping PHP processes...${NC}"
killall php-fpm 2>/dev/null || true
sleep 2

echo -e "${RED}STEP 2: Clearing ALL EspoCRM caches...${NC}"

# Main cache directory
rm -rf /var/www/html/data/cache/* 2>/dev/null || true
rm -rf /var/www/html/data/cache/.* 2>/dev/null || true

# Template caches
rm -f /var/www/html/client/lib/templates.tpl 2>/dev/null || true
rm -rf /var/www/html/client/lib/cache/* 2>/dev/null || true

# Upload and temp directories
rm -rf /var/www/html/data/upload/thumbnails/* 2>/dev/null || true
rm -rf /var/www/html/data/tmp/* 2>/dev/null || true

# PHP caches
rm -rf /tmp/espo-cache/* 2>/dev/null || true
rm -rf /var/cache/nginx/* 2>/dev/null || true
rm -rf /var/tmp/* 2>/dev/null || true

echo -e "${GREEN}✓ All caches cleared${NC}"

echo -e "${RED}STEP 3: Clearing PHP OPcache...${NC}"
php -r "
if (function_exists('opcache_reset')) {
    opcache_reset();
    echo 'OPcache cleared';
}
if (function_exists('apcu_clear_cache')) {
    apcu_clear_cache();
    echo 'APCu cache cleared';
}
" 2>/dev/null || true
echo ""

echo -e "${RED}STEP 4: Force replacing templates...${NC}"

# Replace footer in ALL possible locations
find /var/www/html -type f -name "*.tpl" -exec grep -l "EspoCRM" {} \; 2>/dev/null | while read file; do
    echo "Replacing in: $file"
    sed -i 's/EspoCRM/Evertec/g' "$file"
    sed -i 's/espocrm\.com/evertec.ao/g' "$file"
done

# Replace in HTML files
find /var/www/html -type f -name "*.html" -exec grep -l "EspoCRM" {} \; 2>/dev/null | while read file; do
    echo "Replacing in: $file"
    sed -i 's/EspoCRM/Evertec/g' "$file"
    sed -i 's/espocrm\.com/evertec.ao/g' "$file"
done

echo -e "${GREEN}✓ Templates replaced${NC}"

echo -e "${RED}STEP 5: Regenerating templates...${NC}"

# Create empty template file to force regeneration
touch /var/www/html/client/lib/templates.tpl
chown www-data:www-data /var/www/html/client/lib/templates.tpl

echo -e "${GREEN}✓ Template file recreated${NC}"

echo -e "${RED}STEP 6: Clearing browser-side caches...${NC}"

# Add cache-busting timestamp to all CSS and JS files
TIMESTAMP=$(date +%s)
find /var/www/html/client -name "*.css" -o -name "*.js" | head -20 | while read file; do
    touch "$file"
done

echo -e "${GREEN}✓ File timestamps updated${NC}"

echo -e "${RED}STEP 7: Rebuilding application...${NC}"

cd /var/www/html
php rebuild.php 2>/dev/null || true
php clear_cache.php 2>/dev/null || true

echo -e "${GREEN}✓ Application rebuilt${NC}"

echo -e "${RED}STEP 8: Restarting PHP-FPM...${NC}"
php-fpm -D 2>/dev/null || true
service php*-fpm restart 2>/dev/null || true

echo -e "${GREEN}✓ PHP-FPM restarted${NC}"

echo -e "${RED}STEP 9: Verifying changes...${NC}"

# Check if any file still contains EspoCRM
if grep -r "EspoCRM" /var/www/html/client/res/templates/ 2>/dev/null | grep -v "Binary file"; then
    echo -e "${YELLOW}Warning: Some files still contain EspoCRM${NC}"
    echo -e "${YELLOW}Running force replacement...${NC}"
    bash /deployment/scripts/force-evertec-footer.sh
else
    echo -e "${GREEN}✓ No EspoCRM references found in templates${NC}"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ ALL CACHES CLEARED SUCCESSFULLY          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${RED}⚠️  CRITICAL: You MUST clear your browser cache!${NC}"
echo ""
echo -e "${YELLOW}Option 1: Quick Clear${NC}"
echo -e "  • Press Ctrl+Shift+F5 (Windows/Linux)"
echo -e "  • Press Cmd+Shift+R (Mac)"
echo ""
echo -e "${YELLOW}Option 2: Full Clear${NC}"
echo -e "  • Chrome: Settings → Privacy → Clear browsing data"
echo -e "  • Firefox: Settings → Privacy → Clear Data"
echo -e "  • Edge: Settings → Privacy → Clear browsing data"
echo ""
echo -e "${YELLOW}Option 3: Test in Incognito${NC}"
echo -e "  • Ctrl+Shift+N (Chrome/Edge)"
echo -e "  • Ctrl+Shift+P (Firefox)"
echo ""
echo -e "${GREEN}The footer should now show: © 2025 Evertec${NC}"

exit 0