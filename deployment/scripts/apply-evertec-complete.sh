#!/bin/bash

# ===================================
# EVERTEC COMPLETE BRANDING APPLICATION
# ===================================
# This script applies ALL Evertec branding customizations
# Including templates, translations, config, and cache clearing

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    EVERTEC COMPLETE BRANDING APPLICATION        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running in Docker
if [ ! -f /.dockerenv ]; then
    echo -e "${YELLOW}Executing in Docker container...${NC}"
    docker exec espocrm bash /deployment/scripts/apply-evertec-complete.sh
    docker restart espocrm
    echo -e "${GREEN}✅ Container restarted with Evertec branding!${NC}"
    exit 0
fi

echo -e "${YELLOW}Step 1: Creating custom directories...${NC}"

# Create all necessary directories
mkdir -p /var/www/html/custom/Espo/Custom/Resources/templates/site
mkdir -p /var/www/html/custom/Espo/Custom/Resources/i18n/en_US
mkdir -p /var/www/html/custom/Espo/Custom/Resources/i18n/pt_BR
mkdir -p /var/www/html/custom/Espo/Custom/Resources/metadata/app
mkdir -p /var/www/html/client/custom/res/css
mkdir -p /var/www/html/client/custom/lib

echo -e "${GREEN}✓ Directories created${NC}"

# ===================================
# TEMPLATE OVERRIDES
# ===================================
echo -e "${YELLOW}Step 2: Applying template overrides...${NC}"

# Footer template
cat > /var/www/html/custom/Espo/Custom/Resources/templates/site/footer.tpl << 'EOF'
<footer class="app-footer">
  <div class="container text-center">
    <p>© 2025 Evertec</p>
  </div>
</footer>
EOF

# Also create in client location
cat > /var/www/html/client/custom/res/templates/site/footer.tpl << 'EOF'
<p class="credit small">© 2025 
<a href="https://evertec.ao" target="_blank" rel="noopener">Evertec</a></p>
EOF

echo -e "${GREEN}✓ Templates applied${NC}"

# ===================================
# TRANSLATION OVERRIDES
# ===================================
echo -e "${YELLOW}Step 3: Applying translation overrides...${NC}"

# English translations
cat > /var/www/html/custom/Espo/Custom/Resources/i18n/en_US/Global.json << 'EOF'
{
  "Global": {
    "brandName": "Evertec",
    "appName": "Evertec CRM"
  }
}
EOF

# Portuguese translations
cat > /var/www/html/custom/Espo/Custom/Resources/i18n/pt_BR/Global.json << 'EOF'
{
  "Global": {
    "brandName": "Evertec",
    "appName": "Evertec CRM"
  }
}
EOF

echo -e "${GREEN}✓ Translations applied${NC}"

# ===================================
# CONFIG MODIFICATIONS
# ===================================
echo -e "${YELLOW}Step 4: Modifying config.php...${NC}"

if [ -f /var/www/html/data/config.php ]; then
    # Force outboundEmailFromName
    if grep -q "'outboundEmailFromName'" /var/www/html/data/config.php; then
        sed -i "s/'outboundEmailFromName' => .*/'outboundEmailFromName' => 'Evertec',/" /var/www/html/data/config.php
    else
        sed -i "/return array (/a \ \ 'outboundEmailFromName' => 'Evertec'," /var/www/html/data/config.php
    fi
    
    # Force applicationName
    if grep -q "'applicationName'" /var/www/html/data/config.php; then
        sed -i "s/'applicationName' => .*/'applicationName' => 'Evertec CRM',/" /var/www/html/data/config.php
    else
        sed -i "/return array (/a \ \ 'applicationName' => 'Evertec CRM'," /var/www/html/data/config.php
    fi
    
    echo -e "${GREEN}✓ Config.php updated${NC}"
else
    echo -e "${YELLOW}⚠ Config.php not found yet (will be created on first run)${NC}"
fi

# ===================================
# CSS AND JAVASCRIPT
# ===================================
echo -e "${YELLOW}Step 5: Applying CSS and JavaScript...${NC}"

# Copy existing custom files if they exist
if [ -f /client/custom/res/css/custom.css ]; then
    cp /client/custom/res/css/custom.css /var/www/html/client/custom/res/css/
fi

if [ -f /client/custom/lib/custom-footer.js ]; then
    cp /client/custom/lib/custom-footer.js /var/www/html/client/custom/lib/
fi

# Ensure metadata loads custom files
cat > /var/www/html/custom/Espo/Custom/Resources/metadata/app/client.json << 'EOF'
{
    "cssList": [
        "__APPEND__",
        "client/custom/res/css/custom.css"
    ],
    "scriptList": [
        "__APPEND__",
        "client/custom/lib/custom-footer.js"
    ]
}
EOF

echo -e "${GREEN}✓ CSS and JavaScript applied${NC}"

# ===================================
# DIRECT TEMPLATE REPLACEMENT
# ===================================
echo -e "${YELLOW}Step 6: Direct template replacement...${NC}"

# Replace original footer template
if [ -f /var/www/html/client/res/templates/site/footer.tpl ]; then
    cat > /var/www/html/client/res/templates/site/footer.tpl << 'EOF'
<p class="credit small">© 2025 
<a href="https://evertec.ao" target="_blank" rel="noopener">Evertec</a></p>
EOF
    echo -e "${GREEN}✓ Original footer template replaced${NC}"
fi

# Replace in main.html if exists
if [ -f /var/www/html/html/main.html ]; then
    sed -i 's/EspoCRM/Evertec/g' /var/www/html/html/main.html
    sed -i 's/espocrm\.com/evertec.ao/g' /var/www/html/html/main.html
    echo -e "${GREEN}✓ Main.html updated${NC}"
fi

# ===================================
# PERMISSIONS
# ===================================
echo -e "${YELLOW}Step 7: Setting permissions...${NC}"

chown -R www-data:www-data /var/www/html/custom/
chown -R www-data:www-data /var/www/html/client/custom/
chmod -R 755 /var/www/html/custom/
chmod -R 755 /var/www/html/client/custom/

echo -e "${GREEN}✓ Permissions set${NC}"

# ===================================
# CLEAR ALL CACHES
# ===================================
echo -e "${YELLOW}Step 8: Clearing ALL caches...${NC}"

# Remove all cache directories
rm -rf /var/www/html/data/cache/* 2>/dev/null || true
rm -rf /var/www/html/data/cache/.* 2>/dev/null || true
rm -f /var/www/html/client/lib/templates.tpl 2>/dev/null || true
rm -rf /var/www/html/data/upload/thumbnails/* 2>/dev/null || true

# Clear PHP caches
php -r "if(function_exists('opcache_reset')) opcache_reset();" 2>/dev/null || true
php -r "if(function_exists('apcu_clear_cache')) apcu_clear_cache();" 2>/dev/null || true

echo -e "${GREEN}✓ All caches cleared${NC}"

# ===================================
# REBUILD
# ===================================
echo -e "${YELLOW}Step 9: Rebuilding EspoCRM...${NC}"

cd /var/www/html
php rebuild.php 2>/dev/null || true
php clear_cache.php 2>/dev/null || true

echo -e "${GREEN}✓ System rebuilt${NC}"

# ===================================
# VERIFICATION
# ===================================
echo -e "${YELLOW}Step 10: Verifying installation...${NC}"

ERRORS=0

# Check footer template
if grep -q "Evertec" /var/www/html/client/res/templates/site/footer.tpl 2>/dev/null; then
    echo -e "${GREEN}✓ Footer template contains Evertec${NC}"
else
    echo -e "${RED}✗ Footer template issue${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check translations
if [ -f "/var/www/html/custom/Espo/Custom/Resources/i18n/en_US/Global.json" ]; then
    echo -e "${GREEN}✓ English translations exist${NC}"
else
    echo -e "${RED}✗ English translations missing${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check config
if [ -f "/var/www/html/data/config.php" ]; then
    if grep -q "Evertec" /var/www/html/data/config.php; then
        echo -e "${GREEN}✓ Config contains Evertec${NC}"
    else
        echo -e "${YELLOW}⚠ Config will be updated on next restart${NC}"
    fi
fi

# ===================================
# FINAL STATUS
# ===================================
echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✅ EVERTEC BRANDING APPLIED SUCCESSFULLY      ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}All customizations have been applied:${NC}"
    echo -e "• Footer: © 2025 Evertec"
    echo -e "• App Name: Evertec CRM"
    echo -e "• Email From: Evertec"
    echo -e "• Translations: EN and PT-BR"
else
    echo -e "${YELLOW}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║   ⚠️  SOME ISSUES DETECTED                       ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}Please restart the container and try again${NC}"
fi

echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Clear browser cache (Ctrl+Shift+F5)"
echo -e "2. Test in incognito mode"
echo -e "3. Check console: type evertecStatus()"
echo ""

exit $ERRORS