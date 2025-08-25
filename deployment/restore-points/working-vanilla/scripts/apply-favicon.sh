#!/bin/bash

# ===================================
# APPLY EVERTEC FAVICON
# ===================================
# This script applies custom favicon to the Docker container

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         APPLYING EVERTEC FAVICON                ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running in Docker
if [ ! -f /.dockerenv ] && [ "$1" != "--local" ]; then
    echo -e "${YELLOW}Executing in Docker container...${NC}"
    
    # Check if container is running
    if ! docker ps | grep -q espocrm; then
        echo -e "${RED}Error: EspoCRM container is not running${NC}"
        echo -e "${YELLOW}Start the container first with: docker-compose up -d${NC}"
        exit 1
    fi
    
    # Copy favicon files to container
    echo -e "${YELLOW}Copying favicon files to container...${NC}"
    
    # Copy to public directory
    docker cp favicon_io/favicon.ico espocrm:/var/www/html/favicon.ico
    docker cp favicon_io/favicon-16x16.png espocrm:/var/www/html/favicon-16x16.png
    docker cp favicon_io/favicon-32x32.png espocrm:/var/www/html/favicon-32x32.png
    docker cp favicon_io/apple-touch-icon.png espocrm:/var/www/html/apple-touch-icon.png
    docker cp favicon_io/android-chrome-192x192.png espocrm:/var/www/html/android-chrome-192x192.png
    docker cp favicon_io/android-chrome-512x512.png espocrm:/var/www/html/android-chrome-512x512.png
    docker cp favicon_io/site.webmanifest espocrm:/var/www/html/site.webmanifest
    
    # Copy to public directory
    docker exec espocrm mkdir -p /var/www/html/public
    docker cp favicon_io/favicon.ico espocrm:/var/www/html/public/favicon.ico
    docker cp favicon_io/favicon-16x16.png espocrm:/var/www/html/public/favicon-16x16.png
    docker cp favicon_io/favicon-32x32.png espocrm:/var/www/html/public/favicon-32x32.png
    docker cp favicon_io/apple-touch-icon.png espocrm:/var/www/html/public/apple-touch-icon.png
    docker cp favicon_io/android-chrome-192x192.png espocrm:/var/www/html/public/android-chrome-192x192.png
    docker cp favicon_io/android-chrome-512x512.png espocrm:/var/www/html/public/android-chrome-512x512.png
    docker cp favicon_io/site.webmanifest espocrm:/var/www/html/public/site.webmanifest
    
    # Copy HTML template
    docker cp html/main.html espocrm:/var/www/html/html/main.html
    
    # Set permissions
    docker exec espocrm bash -c "
        chown -R www-data:www-data /var/www/html/*.png
        chown -R www-data:www-data /var/www/html/*.ico
        chown -R www-data:www-data /var/www/html/site.webmanifest
        chown -R www-data:www-data /var/www/html/public/
        chown www-data:www-data /var/www/html/html/main.html
        chmod 644 /var/www/html/*.png
        chmod 644 /var/www/html/*.ico
        chmod 644 /var/www/html/site.webmanifest
    "
    
    echo -e "${GREEN}✓ Favicon files copied to container${NC}"
    
    # Clear cache
    echo -e "${YELLOW}Clearing cache...${NC}"
    docker exec espocrm bash -c "
        rm -rf /var/www/html/data/cache/*
        php /var/www/html/clear_cache.php 2>/dev/null || true
    "
    
    echo -e "${GREEN}✓ Cache cleared${NC}"
    
    exit 0
fi

# If running inside Docker
echo -e "${YELLOW}Setting up favicon files...${NC}"

# Copy favicon files to appropriate locations
cp -f /favicon_io/* /var/www/html/ 2>/dev/null || true
cp -f /favicon_io/* /var/www/html/public/ 2>/dev/null || true

# Set permissions
chown -R www-data:www-data /var/www/html/*.png
chown -R www-data:www-data /var/www/html/*.ico
chown -R www-data:www-data /var/www/html/site.webmanifest
chmod 644 /var/www/html/*.png
chmod 644 /var/www/html/*.ico
chmod 644 /var/www/html/site.webmanifest

# Clear cache
rm -rf /var/www/html/data/cache/*
php /var/www/html/clear_cache.php 2>/dev/null || true

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ FAVICON APPLIED SUCCESSFULLY             ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Clear browser cache (Ctrl+Shift+F5)"
echo -e "2. The favicon should now be visible"
echo ""

exit 0