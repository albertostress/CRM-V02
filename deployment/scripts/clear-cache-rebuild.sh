#!/bin/bash

echo "======================================"
echo "Clear Cache and Rebuild EspoCRM"
echo "======================================"

# Find the EspoCRM container name
CONTAINER_NAME=$(docker ps --format "{{.Names}}" | grep -E "(espocrm|crm)" | grep -v db | grep -v daemon | grep -v websocket | head -1)

if [ -z "$CONTAINER_NAME" ]; then
    echo "❌ No EspoCRM container found running"
    echo ""
    echo "Please start your container first with:"
    echo "docker-compose up -d"
    exit 1
fi

echo "✅ Found container: $CONTAINER_NAME"
echo ""

echo "1. Clearing cache..."
docker exec $CONTAINER_NAME rm -rf /var/www/html/data/cache/* 2>/dev/null || true
docker exec $CONTAINER_NAME rm -rf /var/www/html/client/custom/build/* 2>/dev/null || true

echo "2. Running rebuild..."
docker exec $CONTAINER_NAME php /var/www/html/rebuild.php 2>/dev/null || true

echo "3. Clearing cache again..."
docker exec $CONTAINER_NAME php /var/www/html/clear_cache.php 2>/dev/null || true

echo "4. Restarting container..."
docker restart $CONTAINER_NAME

echo ""
echo "✅ Cache cleared and rebuilt successfully!"
echo ""
echo "🔄 Please refresh your browser with Ctrl+F5 to see changes"
echo "📍 Access About page: Menu → About"