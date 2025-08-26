#!/bin/bash
# EVERTEC CRM - Fix Deployment Script

echo "======================================="
echo "EVERTEC CRM - Fixing Deployment Issues"
echo "======================================="

# Container name
CONTAINER="espocrm"

echo "🔍 Checking container status..."
docker ps | grep espocrm

echo ""
echo "🧹 Clearing all cache..."
docker exec $CONTAINER rm -rf /var/www/html/data/cache/* 2>/dev/null
docker exec $CONTAINER rm -rf /var/www/html/client/lib/transpiled/* 2>/dev/null

echo "🔨 Running rebuild..."
docker exec $CONTAINER php /var/www/html/rebuild.php 2>/dev/null

echo "📂 Checking file permissions..."
docker exec $CONTAINER chown -R www-data:www-data /var/www/html/
docker exec $CONTAINER chmod -R 755 /var/www/html/

echo "🔄 Restarting PHP-FPM..."
docker exec $CONTAINER killall -USR2 php-fpm 2>/dev/null || true

echo "📊 Checking web server status..."
docker exec $CONTAINER curl -I http://localhost 2>/dev/null | head -5

echo ""
echo "✅ Commands to run on your server:"
echo ""
echo "1. Clear cache:"
echo "   docker exec espocrm rm -rf /var/www/html/data/cache/*"
echo ""
echo "2. Rebuild:"
echo "   docker exec espocrm php /var/www/html/rebuild.php"
echo ""
echo "3. Fix permissions:"
echo "   docker exec espocrm chown -R www-data:www-data /var/www/html/"
echo ""
echo "4. Check logs:"
echo "   docker logs espocrm --tail 50"
echo ""
echo "5. Restart containers:"
echo "   docker restart espocrm espocrm-daemon espocrm-websocket"
echo ""