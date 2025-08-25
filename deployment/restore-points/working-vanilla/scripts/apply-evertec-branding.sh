#!/bin/bash

# ===================================
# EVERTEC CRM - Complete Branding System
# ===================================
# 3-Layer Permanent Footer Customization
# © 2025 Evertec - evertec.ao

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         EVERTEC CRM BRANDING SYSTEM             ║${NC}"
echo -e "${BLUE}║           Permanent Footer Solution              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running in Docker
if [ ! -f /.dockerenv ] && [ "$1" != "--local" ]; then
    echo -e "${YELLOW}This script should be run inside the Docker container${NC}"
    echo -e "${YELLOW}Attempting to execute in container...${NC}"
    docker exec espocrm bash /deployment/scripts/apply-evertec-branding.sh
    exit $?
fi

# Configuration
COMPANY_NAME="Evertec"
COMPANY_URL="https://evertec.ao"
FOOTER_TEXT="© 2025 Evertec"

echo -e "${YELLOW}═══ Starting 3-Layer Branding Implementation ═══${NC}"
echo ""

# ===================================
# LAYER 1: CSS CUSTOMIZATION
# ===================================
echo -e "${BLUE}[Layer 1/3] Applying CSS Customization...${NC}"

mkdir -p /var/www/html/client/custom/res/css

cat > /var/www/html/client/custom/res/css/custom.css << 'CSSEOF'
/* ============================================
   EVERTEC CRM - Footer Customization
   © 2025 Evertec - evertec.ao
   ============================================ */

/* Remove completamente o watermark EspoCRM em TODOS os lugares */

/* Página de login - esconde o link original */
.credit.small a,
p.credit.small a,
.credit a,
footer .credit a,
#footer .credit a {
    display: none !important;
    visibility: hidden !important;
}

/* Página de login - adiciona texto da Evertec */
.credit.small::after,
p.credit.small::after,
.credit::after {
    content: "© 2025 Evertec" !important;
    display: block !important;
    text-align: center !important;
    visibility: visible !important;
}

/* Remove texto original do EspoCRM */
.credit.small,
p.credit.small,
.credit {
    font-size: 0 !important;
    line-height: 0 !important;
}

/* Restaura tamanho para o novo conteúdo */
.credit.small::after,
p.credit.small::after,
.credit::after {
    font-size: 13px !important;
    line-height: 1.5 !important;
    opacity: 0.8;
}

/* Sidebar após login - esconde original */
.layout__sidebar .credit,
.layout__sidebar .copyright,
.sidebar .credit,
.sidebar .copyright,
.navbar-footer .credit,
.navbar-footer .copyright {
    display: none !important;
    visibility: hidden !important;
}

/* Adiciona texto da Evertec no sidebar */
.layout__sidebar::after,
.sidebar::after {
    content: "© 2025 Evertec";
    display: block;
    text-align: center;
    opacity: .8;
    padding: 10px 0;
    font-size: 13px;
    color: #bbb;
}

/* Modal About - esconde referências ao EspoCRM */
.modal .about-text a[href*="espocrm"] {
    display: none !important;
}

/* Footer em todas as páginas */
body .credit.small a,
body p.credit.small a,
body .credit a {
    display: none !important;
}

body .credit.small::after,
body p.credit.small::after,
body .credit::after {
    content: "© 2025 Evertec" !important;
}
CSSEOF

echo -e "${GREEN}✓ CSS layer applied${NC}"

# ===================================
# LAYER 2: JAVASCRIPT REPLACEMENT
# ===================================
echo -e "${BLUE}[Layer 2/3] Applying JavaScript Dynamic Replacement...${NC}"

mkdir -p /var/www/html/client/custom/lib

cat > /var/www/html/client/custom/lib/custom-footer.js << 'JSEOF'
/**
 * EVERTEC CRM - Footer Replacement System
 * © 2025 Evertec - evertec.ao
 */

(function() {
    'use strict';
    
    const COMPANY_NAME = 'Evertec';
    const COMPANY_URL = 'https://evertec.ao';
    const FOOTER_TEXT = '© 2025 Evertec';
    const FOOTER_HTML = '<a href="' + COMPANY_URL + '" target="_blank" style="color: inherit; text-decoration: none;">' + FOOTER_TEXT + '</a>';
    
    function replaceFooter() {
        const selectors = [
            '.credit.small', '.credit', 'p.credit', '#footer .credit',
            'footer .credit', '.navbar-footer .credit', '.sidebar .credit',
            '.layout__sidebar .credit', '.login-view .credit', '.page-footer .credit',
            '[class*="credit"]', '[class*="copyright"]'
        ];
        
        selectors.forEach(selector => {
            const elements = document.querySelectorAll(selector);
            elements.forEach(element => {
                if (element && (
                    element.textContent.includes('EspoCRM') || 
                    element.textContent.includes('Espo') ||
                    element.innerHTML.includes('espocrm')
                )) {
                    element.innerHTML = FOOTER_HTML;
                    element.style.textAlign = 'center';
                    element.style.opacity = '0.8';
                    element.style.fontSize = '13px';
                }
            });
        });
        
        // Replace in page title
        if (document.title.includes('EspoCRM')) {
            document.title = document.title.replace(/EspoCRM/g, COMPANY_NAME);
        }
    }
    
    function init() {
        replaceFooter();
        setInterval(replaceFooter, 500);
        
        const observer = new MutationObserver(replaceFooter);
        if (document.body) {
            observer.observe(document.body, {
                childList: true,
                subtree: true,
                attributes: true,
                characterData: true
            });
        }
    }
    
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
    
    window.addEventListener('load', function() {
        setTimeout(init, 100);
    });
    
    console.log('Evertec Footer System Active');
})();
JSEOF

echo -e "${GREEN}✓ JavaScript layer applied${NC}"

# ===================================
# LAYER 3: METADATA CONFIGURATION
# ===================================
echo -e "${BLUE}[Layer 3/3] Applying Metadata Configuration...${NC}"

mkdir -p /var/www/html/custom/Espo/Custom/Resources/metadata/app

cat > /var/www/html/custom/Espo/Custom/Resources/metadata/app/client.json << 'METAEOF'
{
    "cssList": [
        "__APPEND__",
        "client/custom/res/css/custom.css"
    ],
    "scriptList": [
        "__APPEND__",
        "client/custom/lib/custom-footer.js"
    ],
    "developerModeScriptList": [
        "__APPEND__",
        "client/custom/lib/custom-footer.js"
    ],
    "developerModeCssList": [
        "__APPEND__",
        "client/custom/res/css/custom.css"
    ]
}
METAEOF

echo -e "${GREEN}✓ Metadata configuration applied${NC}"

# ===================================
# FIX PERMISSIONS
# ===================================
echo -e "${YELLOW}Setting correct permissions...${NC}"

chown -R www-data:www-data /var/www/html/client/custom/
chown -R www-data:www-data /var/www/html/custom/
chmod -R 755 /var/www/html/client/custom/
chmod -R 755 /var/www/html/custom/

echo -e "${GREEN}✓ Permissions fixed${NC}"

# ===================================
# CLEAR CACHE AND REBUILD
# ===================================
echo -e "${YELLOW}Clearing cache and rebuilding...${NC}"

# Clear all possible caches
rm -rf /var/www/html/data/cache/* 2>/dev/null || true
rm -f /var/www/html/client/lib/templates.tpl 2>/dev/null || true
rm -rf /var/www/html/data/upload/thumbnails/* 2>/dev/null || true

# Touch template file to force regeneration
touch /var/www/html/client/lib/templates.tpl
chown www-data:www-data /var/www/html/client/lib/templates.tpl

# Rebuild EspoCRM
php /var/www/html/rebuild.php 2>/dev/null || true
php /var/www/html/clear_cache.php 2>/dev/null || true

echo -e "${GREEN}✓ Cache cleared and system rebuilt${NC}"

# ===================================
# CREATE BACKUP
# ===================================
echo -e "${YELLOW}Creating backup of customization...${NC}"

BACKUP_DIR="/backups/footer-customization"
mkdir -p ${BACKUP_DIR}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/evertec-footer-${TIMESTAMP}.tar.gz"

tar -czf ${BACKUP_FILE} \
    -C /var/www/html \
    client/custom/res/css/custom.css \
    client/custom/lib/custom-footer.js \
    custom/Espo/Custom/Resources/metadata/app/client.json \
    2>/dev/null || true

echo -e "${GREEN}✓ Backup created: ${BACKUP_FILE}${NC}"

# ===================================
# VERIFICATION
# ===================================
echo -e "${YELLOW}Verifying installation...${NC}"

ERRORS=0

# Check CSS file
if [ -f "/var/www/html/client/custom/res/css/custom.css" ]; then
    echo -e "${GREEN}✓ CSS file exists${NC}"
else
    echo -e "${RED}✗ CSS file missing${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check JavaScript file
if [ -f "/var/www/html/client/custom/lib/custom-footer.js" ]; then
    echo -e "${GREEN}✓ JavaScript file exists${NC}"
else
    echo -e "${RED}✗ JavaScript file missing${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check Metadata file
if [ -f "/var/www/html/custom/Espo/Custom/Resources/metadata/app/client.json" ]; then
    echo -e "${GREEN}✓ Metadata file exists${NC}"
else
    echo -e "${RED}✗ Metadata file missing${NC}"
    ERRORS=$((ERRORS + 1))
fi

# ===================================
# FINAL STATUS
# ===================================
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}║     ✅ EVERTEC BRANDING APPLIED SUCCESSFULLY    ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Footer customization is now PERMANENT and will show:${NC}"
    echo -e "${GREEN}→ © 2025 Evertec${NC}"
    echo ""
    echo -e "${YELLOW}The system uses 3 layers of protection:${NC}"
    echo -e "1. CSS - Visual replacement"
    echo -e "2. JavaScript - Active monitoring and replacement"
    echo -e "3. Metadata - Ensures files are loaded"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "1. Clear browser cache (Ctrl+F5)"
    echo -e "2. If needed, restart container: docker restart espocrm"
    echo ""
    echo -e "${GREEN}Backup saved to: ${BACKUP_FILE}${NC}"
else
    echo -e "${RED}║     ⚠️  SOME ISSUES DETECTED                     ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Please check the errors above and try again${NC}"
    echo -e "${YELLOW}You can restore from backup using:${NC}"
    echo -e "bash /deployment/scripts/restore-footer.sh"
fi

exit $ERRORS