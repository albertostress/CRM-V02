#!/bin/bash
# Script to apply branding to Dokploy containers

echo "======================================"
echo "APPLYING EVERTEC BRANDING TO DOKPLOY"
echo "======================================"

# Get container name
CONTAINER=$(docker ps --format "{{.Names}}" | grep -E "espocrm" | grep -v db | grep -v daemon | grep -v websocket | head -1)

if [ -z "$CONTAINER" ]; then
    echo "❌ No EspoCRM container found"
    exit 1
fi

echo "✅ Found container: $CONTAINER"

# Copy modified files into running container
echo "📦 Copying branding files..."

# Footer templates
docker cp client/res/templates/site/footer.tpl $CONTAINER:/var/www/html/client/res/templates/site/footer.tpl
docker cp client/res/templates/login.tpl $CONTAINER:/var/www/html/client/res/templates/login.tpl

# About content
docker cp application/Espo/Resources/texts/about.md $CONTAINER:/var/www/html/application/Espo/Resources/texts/about.md

# Install templates
docker cp install/core/tpl/footer.tpl $CONTAINER:/var/www/html/install/core/tpl/footer.tpl
docker cp install/core/tpl/finish.tpl $CONTAINER:/var/www/html/install/core/tpl/finish.tpl

# Main HTML
docker cp html/main.html $CONTAINER:/var/www/html/html/main.html

# Custom CSS and JS
docker cp -r client/custom $CONTAINER:/var/www/html/client/
docker cp -r custom $CONTAINER:/var/www/html/

echo "🔧 Setting permissions..."
docker exec $CONTAINER chown -R www-data:www-data /var/www/html/

echo "🧹 Clearing cache..."
docker exec $CONTAINER rm -rf /var/www/html/data/cache/*
docker exec $CONTAINER php /var/www/html/rebuild.php 2>/dev/null || true

echo "🔄 Restarting container..."
docker restart $CONTAINER

echo ""
echo "✅ BRANDING APPLIED SUCCESSFULLY!"
echo ""
echo "📌 Changes:"
echo "  - Footer: © 2025 EVERTEC CRM"
echo "  - About page: EVERTEC content"
echo "  - Login page: EVERTEC branding"
echo "  - Installer: EVERTEC messages"
echo ""
echo "🌐 Clear browser cache (Ctrl+F5) and reload"