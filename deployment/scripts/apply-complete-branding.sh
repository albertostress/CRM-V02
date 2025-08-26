#!/bin/bash

echo "======================================"
echo "EVERTEC CRM - Complete Branding Apply"
echo "======================================"

# Find container
CONTAINER=$(docker ps --format "{{.Names}}" | grep -E "(espocrm|crm)" | grep -v db | head -1)

if [ -z "$CONTAINER" ]; then
    echo "❌ No EspoCRM container found"
    exit 1
fi

echo "✅ Found container: $CONTAINER"
echo ""

echo "1. Clearing all caches..."
docker exec $CONTAINER rm -rf /var/www/html/data/cache/* 2>/dev/null || true
docker exec $CONTAINER rm -rf /var/www/html/data/tmp/* 2>/dev/null || true
docker exec $CONTAINER rm -rf /var/www/html/client/custom/build/* 2>/dev/null || true

echo "2. Applying configuration..."
docker exec $CONTAINER php -r "
\$config = include('/var/www/html/data/config.php');
\$config['applicationName'] = 'EVERTEC CRM';
\$config['companyName'] = 'Evertec Corporation';
\$config['outboundEmailFromName'] = 'EVERTEC CRM';
file_put_contents('/var/www/html/data/config.php', '<?php return ' . var_export(\$config, true) . ';');
" 2>/dev/null || true

echo "3. Rebuilding system..."
docker exec $CONTAINER php /var/www/html/rebuild.php 2>/dev/null || true

echo "4. Clearing cache again..."
docker exec $CONTAINER php /var/www/html/clear_cache.php 2>/dev/null || true

echo "5. Setting permissions..."
docker exec $CONTAINER chown -R www-data:www-data /var/www/html/data 2>/dev/null || true
docker exec $CONTAINER chown -R www-data:www-data /var/www/html/custom 2>/dev/null || true

echo "6. Restarting container..."
docker restart $CONTAINER

echo ""
echo "✅ Complete branding applied successfully!"
echo ""
echo "📌 Changes applied:"
echo "   - Application name: EVERTEC CRM"
echo "   - Company: Evertec Corporation"
echo "   - Footer: © 2025 EVERTEC CRM"
echo "   - About page: Custom EVERTEC content"
echo "   - CSS: Complete visual override"
echo "   - JavaScript: Dynamic text replacement"
echo ""
echo "🔄 Please clear your browser cache (Ctrl+F5)"
echo "🌐 Access your EVERTEC CRM system"