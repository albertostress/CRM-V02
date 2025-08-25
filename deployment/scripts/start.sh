#!/bin/bash

# ===================================
# ESPOCRM STARTUP SCRIPT
# ===================================
# This script initializes the EspoCRM container
# and applies Evertec branding customizations

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting EspoCRM with Evertec Branding...${NC}"

# Wait for database to be ready
echo -e "${YELLOW}Waiting for database...${NC}"
until mysql -h"${DB_HOST:-espocrm-db}" -u"${DB_USER:-espocrm}" -p"${DB_PASSWORD:-espocrm_password}" -e "SELECT 1" >/dev/null 2>&1; do
    echo -n "."
    sleep 2
done
echo -e "${GREEN}Database is ready!${NC}"

# Run initial setup if needed
if [ ! -f /var/www/html/data/config.php ]; then
    echo -e "${YELLOW}Running initial setup...${NC}"
    php /var/www/html/install/cli.php --action=install \
        --db-host="${DB_HOST:-espocrm-db}" \
        --db-name="${DB_NAME:-espocrm}" \
        --db-user="${DB_USER:-espocrm}" \
        --db-password="${DB_PASSWORD:-espocrm_password}" \
        --admin-username="${ADMIN_USERNAME:-admin}" \
        --admin-password="${ADMIN_PASSWORD:-admin123}" \
        --site-url="${SITE_URL:-http://localhost}"
fi

# ===================================
# EVERTEC BRANDING CUSTOMIZATION
# ===================================

echo -e "${BLUE}🔧 Forcing outboundEmailFromName = Evertec...${NC}"
if [ -f /var/www/html/data/config.php ]; then
    if grep -q "'outboundEmailFromName'" /var/www/html/data/config.php; then
        sed -i "s/'outboundEmailFromName' => .*/'outboundEmailFromName' => 'Evertec',/" /var/www/html/data/config.php
    else
        # adiciona no array config se não existir
        sed -i "/return array (/a \ \ 'outboundEmailFromName' => 'Evertec'," /var/www/html/data/config.php
    fi
    echo -e "${GREEN}✓ Email From Name set to Evertec${NC}"
fi

# Apply footer customization if script exists
if [ -f /deployment/scripts/apply-evertec-branding.sh ]; then
    echo -e "${YELLOW}Applying Evertec branding...${NC}"
    bash /deployment/scripts/apply-evertec-branding.sh --local
fi

# Clear cache to ensure changes take effect
echo -e "${YELLOW}Clearing cache...${NC}"
rm -rf /var/www/html/data/cache/*
php /var/www/html/clear_cache.php 2>/dev/null || true

# Fix permissions
echo -e "${YELLOW}Setting permissions...${NC}"
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo -e "${GREEN}✓ EspoCRM ready with Evertec branding!${NC}"

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf