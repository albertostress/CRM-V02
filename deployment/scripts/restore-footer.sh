#!/bin/bash

# ===================================
# EVERTEC Footer Restore Script
# ===================================
# Restores footer customization from backup

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}Evertec Footer Restore${NC}"
echo -e "${BLUE}====================================${NC}"

# Check if backup file is provided
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Usage: $0 [backup-file]${NC}"
    echo -e "${YELLOW}If no file specified, will use latest backup${NC}"
    echo ""
    
    # Find latest backup
    BACKUP_DIR="/backups/footer-customization"
    if [ -d "${BACKUP_DIR}" ]; then
        LATEST_BACKUP=$(ls -1t ${BACKUP_DIR}/*.tar.gz 2>/dev/null | head -1)
        if [ ! -z "${LATEST_BACKUP}" ]; then
            echo -e "${GREEN}Found latest backup: ${LATEST_BACKUP}${NC}"
            BACKUP_FILE="${LATEST_BACKUP}"
        else
            echo -e "${RED}No backups found in ${BACKUP_DIR}${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Backup directory not found${NC}"
        exit 1
    fi
else
    BACKUP_FILE=$1
fi

# Verify backup file exists
if [ ! -f "${BACKUP_FILE}" ]; then
    echo -e "${RED}Backup file not found: ${BACKUP_FILE}${NC}"
    exit 1
fi

echo -e "${YELLOW}Restoring from: ${BACKUP_FILE}${NC}"

# Create temporary directory
TEMP_DIR="/tmp/footer-restore-$(date +%Y%m%d_%H%M%S)"
mkdir -p ${TEMP_DIR}

# Extract backup
echo -e "${YELLOW}Extracting backup...${NC}"
tar -xzf ${BACKUP_FILE} -C ${TEMP_DIR}

# Find the extracted directory
EXTRACTED_DIR=$(find ${TEMP_DIR} -maxdepth 1 -type d -name "evertec-footer-backup-*" | head -1)

if [ -z "${EXTRACTED_DIR}" ]; then
    echo -e "${RED}Invalid backup file structure${NC}"
    rm -rf ${TEMP_DIR}
    exit 1
fi

# Restore CSS
if [ -f "${EXTRACTED_DIR}/client/custom/res/css/custom.css" ]; then
    mkdir -p /var/www/html/client/custom/res/css
    cp ${EXTRACTED_DIR}/client/custom/res/css/custom.css /var/www/html/client/custom/res/css/
    chown www-data:www-data /var/www/html/client/custom/res/css/custom.css
    echo -e "${GREEN}✓ CSS file restored${NC}"
fi

# Restore JavaScript
if [ -f "${EXTRACTED_DIR}/client/custom/lib/custom-footer.js" ]; then
    mkdir -p /var/www/html/client/custom/lib
    cp ${EXTRACTED_DIR}/client/custom/lib/custom-footer.js /var/www/html/client/custom/lib/
    chown www-data:www-data /var/www/html/client/custom/lib/custom-footer.js
    echo -e "${GREEN}✓ JavaScript file restored${NC}"
fi

# Restore Metadata
if [ -f "${EXTRACTED_DIR}/custom/Espo/Custom/Resources/metadata/app/client.json" ]; then
    mkdir -p /var/www/html/custom/Espo/Custom/Resources/metadata/app
    cp ${EXTRACTED_DIR}/custom/Espo/Custom/Resources/metadata/app/client.json /var/www/html/custom/Espo/Custom/Resources/metadata/app/
    chown -R www-data:www-data /var/www/html/custom/Espo/Custom/Resources/metadata/
    echo -e "${GREEN}✓ Metadata file restored${NC}"
fi

# Restore Templates
if [ -f "${EXTRACTED_DIR}/custom/Espo/Custom/Resources/templates/site/footer.tpl" ]; then
    mkdir -p /var/www/html/custom/Espo/Custom/Resources/templates/site
    cp ${EXTRACTED_DIR}/custom/Espo/Custom/Resources/templates/site/footer.tpl /var/www/html/custom/Espo/Custom/Resources/templates/site/
    chown -R www-data:www-data /var/www/html/custom/Espo/Custom/Resources/templates/
    echo -e "${GREEN}✓ Template file restored${NC}"
fi

# Fix all permissions
echo -e "${YELLOW}Fixing permissions...${NC}"
chown -R www-data:www-data /var/www/html/client/custom/
chown -R www-data:www-data /var/www/html/custom/

# Clean up temporary directory
rm -rf ${TEMP_DIR}

# Clear cache and rebuild
echo -e "${YELLOW}Clearing cache...${NC}"
rm -rf /var/www/html/data/cache/*
rm -f /var/www/html/client/lib/templates.tpl

echo -e "${YELLOW}Rebuilding EspoCRM...${NC}"
php /var/www/html/rebuild.php 2>/dev/null || true
php /var/www/html/clear_cache.php 2>/dev/null || true

echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}Footer customization restored!${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Clear browser cache (Ctrl+F5)"
echo -e "2. Restart container if needed: docker restart espocrm"
echo ""
echo -e "${GREEN}Footer should now show: © 2025 Evertec${NC}"

exit 0