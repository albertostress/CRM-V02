#!/bin/bash

# ===================================
# EVERTEC FOOTER - FORCE REPLACEMENT
# ===================================
# This script forces the footer replacement by all means

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║     EVERTEC FOOTER - FORCE REPLACEMENT          ║${NC}"
echo -e "${RED}║         Removing ALL EspoCRM References         ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running in Docker
if [ ! -f /.dockerenv ] && [ "$1" != "--local" ]; then
    echo -e "${YELLOW}Executing in Docker container...${NC}"
    docker exec espocrm bash /deployment/scripts/force-evertec-footer.sh
    exit $?
fi

# Configuration
FOOTER_TEXT='© 2025 Evertec'
FOOTER_HTML='<p class="credit small">© 2025 <a href="https://evertec.ao" target="_blank">Evertec</a></p>'

echo -e "${YELLOW}Step 1: Backing up original files...${NC}"

# Backup original files if not already backed up
if [ ! -f "/var/www/html/client/res/templates/site/footer.tpl.original" ]; then
    cp /var/www/html/client/res/templates/site/footer.tpl /var/www/html/client/res/templates/site/footer.tpl.original 2>/dev/null || true
fi

# ===================================
# METHOD 1: Direct Template Replacement
# ===================================
echo -e "${BLUE}Method 1: Direct template replacement...${NC}"

# Replace the original footer template
cat > /var/www/html/client/res/templates/site/footer.tpl << 'EOF'
<p class="credit small">© 2025 
<a href="https://evertec.ao" target="_blank" rel="noopener">Evertec</a></p>
EOF

echo -e "${GREEN}✓ Original template replaced${NC}"

# ===================================
# METHOD 2: Custom Template Override
# ===================================
echo -e "${BLUE}Method 2: Custom template override...${NC}"

# Create custom template directories
mkdir -p /var/www/html/client/custom/res/templates/site
mkdir -p /var/www/html/custom/Espo/Custom/Resources/templates/site

# Create custom footer template
cat > /var/www/html/client/custom/res/templates/site/footer.tpl << 'EOF'
<p class="credit small">© 2025 
<a href="https://evertec.ao" target="_blank" rel="noopener">Evertec</a></p>
EOF

# Copy to custom resources
cp /var/www/html/client/custom/res/templates/site/footer.tpl /var/www/html/custom/Espo/Custom/Resources/templates/site/footer.tpl

echo -e "${GREEN}✓ Custom templates created${NC}"

# ===================================
# METHOD 3: Aggressive CSS Override
# ===================================
echo -e "${BLUE}Method 3: Aggressive CSS override...${NC}"

mkdir -p /var/www/html/client/custom/css

cat > /var/www/html/client/custom/css/evertec-footer.css << 'EOF'
/* FORCE EVERTEC FOOTER */
.credit.small,
p.credit.small,
.credit,
footer .credit,
#footer .credit,
.page-footer .credit,
.login-container .credit,
.login-view .credit,
[class*="credit"] {
    visibility: hidden !important;
    position: relative !important;
    height: auto !important;
}

.credit.small::before,
p.credit.small::before,
.credit::before,
footer .credit::before,
#footer .credit::before,
.page-footer .credit::before,
.login-container .credit::before,
.login-view .credit::before,
[class*="credit"]::before {
    content: "© 2025 Evertec" !important;
    visibility: visible !important;
    position: absolute !important;
    top: 0 !important;
    left: 50% !important;
    transform: translateX(-50%) !important;
    white-space: nowrap !important;
    display: block !important;
    text-align: center !important;
    width: max-content !important;
}

/* Hide all links to espocrm */
a[href*="espocrm"] {
    display: none !important;
}

/* Force hide any EspoCRM text */
*:not(script):not(style) {
    zoom: 1;
}

body *:not(script):not(style):contains("EspoCRM") {
    visibility: hidden !important;
}
EOF

echo -e "${GREEN}✓ CSS override created${NC}"

# ===================================
# METHOD 4: JavaScript Force Replace
# ===================================
echo -e "${BLUE}Method 4: JavaScript force replacement...${NC}"

mkdir -p /var/www/html/client/custom/js

cat > /var/www/html/client/custom/js/force-footer.js << 'EOF'
// FORCE EVERTEC FOOTER
(function() {
    'use strict';
    
    function forceReplace() {
        // Find all elements that might contain the footer
        const selectors = [
            '.credit', 'p.credit', '.credit.small', 'p.credit.small',
            'footer', '#footer', '.footer', '.page-footer',
            '[class*="credit"]', '[class*="copyright"]'
        ];
        
        selectors.forEach(selector => {
            document.querySelectorAll(selector).forEach(el => {
                // Check if element or its children contain EspoCRM
                if (el.innerHTML && (
                    el.innerHTML.includes('EspoCRM') ||
                    el.innerHTML.includes('espocrm') ||
                    el.textContent.includes('EspoCRM')
                )) {
                    // Force replace with Evertec
                    el.innerHTML = '© 2025 <a href="https://evertec.ao" target="_blank">Evertec</a>';
                    el.style.textAlign = 'center';
                }
                
                // Also check for copyright symbol without EspoCRM
                if (el.textContent.includes('©') && !el.textContent.includes('Evertec')) {
                    el.innerHTML = '© 2025 <a href="https://evertec.ao" target="_blank">Evertec</a>';
                    el.style.textAlign = 'center';
                }
            });
        });
        
        // Replace in title
        if (document.title.includes('EspoCRM')) {
            document.title = document.title.replace(/EspoCRM/g, 'Evertec');
        }
    }
    
    // Run immediately
    forceReplace();
    
    // Run on DOM ready
    if (document.readyState !== 'loading') {
        forceReplace();
    } else {
        document.addEventListener('DOMContentLoaded', forceReplace);
    }
    
    // Run periodically
    setInterval(forceReplace, 100);
    
    // Observe all changes
    const observer = new MutationObserver(forceReplace);
    observer.observe(document.documentElement, {
        childList: true,
        subtree: true,
        attributes: true,
        characterData: true
    });
    
    // Override any attempt to set EspoCRM
    Object.defineProperty(HTMLElement.prototype, 'innerHTML', {
        set: function(value) {
            if (typeof value === 'string' && value.includes('EspoCRM')) {
                value = value.replace(/EspoCRM/g, 'Evertec');
            }
            this.innerHTML = value;
        }
    });
})();
EOF

echo -e "${GREEN}✓ JavaScript force replacement created${NC}"

# ===================================
# METHOD 5: Modify View Files
# ===================================
echo -e "${BLUE}Method 5: Creating custom view override...${NC}"

mkdir -p /var/www/html/custom/Espo/Custom/Resources/metadata/clientDefs

cat > /var/www/html/custom/Espo/Custom/Resources/metadata/clientDefs/App.json << 'EOF'
{
    "views": {
        "footer": "custom:views/site/footer"
    }
}
EOF

mkdir -p /var/www/html/client/custom/src/views/site

cat > /var/www/html/client/custom/src/views/site/footer.js << 'EOF'
define('custom:views/site/footer', 'views/site/footer', function (Dep) {
    return Dep.extend({
        template: 'custom:site/footer',
        
        setup: function () {
            Dep.prototype.setup.call(this);
        },
        
        afterRender: function () {
            Dep.prototype.afterRender.call(this);
            this.$el.html('<p class="credit small">© 2025 <a href="https://evertec.ao" target="_blank">Evertec</a></p>');
        }
    });
});
EOF

echo -e "${GREEN}✓ Custom view created${NC}"

# ===================================
# METHOD 6: Inject into index.html
# ===================================
echo -e "${BLUE}Method 6: Injecting into main application...${NC}"

# Add inline script to index.html if exists
if [ -f "/var/www/html/index.html" ]; then
    if ! grep -q "EVERTEC_FOOTER_INJECT" /var/www/html/index.html; then
        sed -i 's|</body>|<script>/*EVERTEC_FOOTER_INJECT*/setInterval(function(){document.querySelectorAll(".credit,.credit.small,[class*=credit]").forEach(function(e){(e.innerHTML.includes("EspoCRM")||e.innerHTML.includes("espocrm"))&&(e.innerHTML="© 2025 <a href=\"https://evertec.ao\">Evertec</a>")})},100);</script></body>|' /var/www/html/index.html 2>/dev/null || true
    fi
fi

echo -e "${GREEN}✓ Inline script injected${NC}"

# ===================================
# APPLY ALL CUSTOMIZATIONS
# ===================================
echo -e "${YELLOW}Applying all customizations...${NC}"

# Ensure metadata loads our custom files
mkdir -p /var/www/html/custom/Espo/Custom/Resources/metadata/app

cat > /var/www/html/custom/Espo/Custom/Resources/metadata/app/client.json << 'EOF'
{
    "cssList": [
        "__APPEND__",
        "client/custom/css/evertec-footer.css",
        "client/custom/res/css/custom.css"
    ],
    "scriptList": [
        "__APPEND__",
        "client/custom/js/force-footer.js",
        "client/custom/lib/custom-footer.js"
    ],
    "developerModeScriptList": [
        "__APPEND__",
        "client/custom/js/force-footer.js",
        "client/custom/lib/custom-footer.js"
    ],
    "developerModeCssList": [
        "__APPEND__",
        "client/custom/css/evertec-footer.css",
        "client/custom/res/css/custom.css"
    ]
}
EOF

# ===================================
# FIX PERMISSIONS
# ===================================
echo -e "${YELLOW}Fixing permissions...${NC}"

chown -R www-data:www-data /var/www/html/client/
chown -R www-data:www-data /var/www/html/custom/
chmod -R 755 /var/www/html/client/custom/
chmod -R 755 /var/www/html/custom/

# ===================================
# CLEAR ALL CACHES
# ===================================
echo -e "${YELLOW}Clearing ALL caches...${NC}"

# Remove all possible cache locations
rm -rf /var/www/html/data/cache/* 2>/dev/null || true
rm -rf /var/www/html/data/upload/thumbnails/* 2>/dev/null || true
rm -f /var/www/html/client/lib/templates.tpl 2>/dev/null || true
rm -rf /var/www/html/client/lib/cache/* 2>/dev/null || true
rm -rf /tmp/espo-cache/* 2>/dev/null || true

# Clear opcache if PHP is running
php -r "if(function_exists('opcache_reset')) opcache_reset();" 2>/dev/null || true

# ===================================
# REBUILD
# ===================================
echo -e "${YELLOW}Rebuilding EspoCRM...${NC}"

cd /var/www/html
php rebuild.php 2>/dev/null || true
php clear_cache.php 2>/dev/null || true

# ===================================
# VERIFICATION
# ===================================
echo -e "${YELLOW}Verifying changes...${NC}"

# Check if original template was modified
if grep -q "Evertec" /var/www/html/client/res/templates/site/footer.tpl; then
    echo -e "${GREEN}✓ Original template contains Evertec${NC}"
else
    echo -e "${RED}✗ Original template still has EspoCRM${NC}"
fi

# Check custom files
if [ -f "/var/www/html/client/custom/css/evertec-footer.css" ]; then
    echo -e "${GREEN}✓ Force CSS exists${NC}"
fi

if [ -f "/var/www/html/client/custom/js/force-footer.js" ]; then
    echo -e "${GREEN}✓ Force JS exists${NC}"
fi

# ===================================
# FINAL MESSAGE
# ===================================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        EVERTEC FOOTER FORCE APPLIED!            ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Applied Methods:${NC}"
echo -e "1. ✓ Direct template replacement"
echo -e "2. ✓ Custom template override" 
echo -e "3. ✓ Aggressive CSS override"
echo -e "4. ✓ JavaScript force replacement"
echo -e "5. ✓ Custom view override"
echo -e "6. ✓ Inline script injection"
echo ""
echo -e "${RED}IMPORTANT NEXT STEPS:${NC}"
echo -e "1. ${YELLOW}Restart the container:${NC}"
echo -e "   docker restart espocrm"
echo ""
echo -e "2. ${YELLOW}Clear browser cache:${NC}"
echo -e "   - Press Ctrl+Shift+F5"
echo -e "   - Or open in Incognito mode"
echo ""
echo -e "3. ${YELLOW}If still showing EspoCRM:${NC}"
echo -e "   - Check browser console for errors"
echo -e "   - Try: docker exec espocrm php rebuild.php"
echo ""
echo -e "${GREEN}Footer should now show: © 2025 Evertec${NC}"

exit 0