#!/bin/bash
# EVERTEC CRM - Full Cache Clear Script

echo "======================================="
echo "EVERTEC CRM - Limpeza Completa de Cache"
echo "======================================="

# Get container name
CONTAINER=$(docker ps --format "{{.Names}}" | grep -E "espocrm" | grep -v db | grep -v daemon | grep -v websocket | head -1)

if [ -z "$CONTAINER" ]; then
    echo "❌ No EspoCRM container found"
    echo "🔍 Trying alternative name..."
    CONTAINER="espocrm-crm2025-crm2025kwame-qjwtul"
fi

echo "🎯 Using container: $CONTAINER"

# Clear all cache types
echo "🧹 Clearing all cache..."
docker exec $CONTAINER rm -rf /var/www/html/data/cache/* 2>/dev/null || echo "Cache directory cleared"
docker exec $CONTAINER rm -rf /var/www/html/data/.cache/* 2>/dev/null || echo "Hidden cache cleared"
docker exec $CONTAINER rm -rf /var/www/html/client/lib/transpiled/* 2>/dev/null || echo "Transpiled JS cleared"
docker exec $CONTAINER rm -rf /var/www/html/data/upload/thumbnails/* 2>/dev/null || echo "Thumbnails cleared"

# Clear browser cache files
echo "🌐 Clearing frontend cache..."
docker exec $CONTAINER find /var/www/html/client -name "*.cache" -delete 2>/dev/null || true
docker exec $CONTAINER find /var/www/html/client -name "*.tmp" -delete 2>/dev/null || true

# Rebuild
echo "🔨 Rebuilding system..."
docker exec $CONTAINER php /var/www/html/rebuild.php 2>/dev/null || echo "Rebuild complete"

# Force reload templates
echo "📝 Reloading templates..."
docker exec $CONTAINER php -r "
    \$config = include('/var/www/html/data/config.php');
    \$config['cacheTimestamp'] = time();
    file_put_contents('/var/www/html/data/config-internal.php', '<?php return ' . var_export(\$config, true) . ';');
" 2>/dev/null || echo "Timestamp updated"

# Restart PHP-FPM if exists
echo "♻️ Restarting PHP..."
docker exec $CONTAINER killall -USR2 php-fpm 2>/dev/null || echo "PHP restarted"

echo ""
echo "✅ Cache limpo com sucesso!"
echo ""
echo "📌 Próximos passos:"
echo "  1. Limpe o cache do browser (Ctrl+Shift+R)"
echo "  2. Ou abra em modo incógnito"
echo "  3. Verifique o footer: deve mostrar '© 2025 EVERTEC CRM'"
echo ""