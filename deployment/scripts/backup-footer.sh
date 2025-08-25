#!/bin/bash

# ===================================
# EVERTEC Footer Backup Script
# ===================================
# Creates backup of all footer customization files

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BACKUP_DIR="/backups/footer-customization"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="evertec-footer-backup-${TIMESTAMP}"

echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}Evertec Footer Backup${NC}"
echo -e "${BLUE}====================================${NC}"

# Create backup directory
mkdir -p ${BACKUP_DIR}

# Create temporary directory for backup
TEMP_DIR="/tmp/${BACKUP_NAME}"
mkdir -p ${TEMP_DIR}

echo -e "${YELLOW}Backing up customization files...${NC}"

# Backup CSS
if [ -f "/var/www/html/client/custom/res/css/custom.css" ]; then
    mkdir -p ${TEMP_DIR}/client/custom/res/css
    cp /var/www/html/client/custom/res/css/custom.css ${TEMP_DIR}/client/custom/res/css/
    echo -e "${GREEN}✓ CSS file backed up${NC}"
fi

# Backup JavaScript
if [ -f "/var/www/html/client/custom/lib/custom-footer.js" ]; then
    mkdir -p ${TEMP_DIR}/client/custom/lib
    cp /var/www/html/client/custom/lib/custom-footer.js ${TEMP_DIR}/client/custom/lib/
    echo -e "${GREEN}✓ JavaScript file backed up${NC}"
fi

# Backup Metadata
if [ -f "/var/www/html/custom/Espo/Custom/Resources/metadata/app/client.json" ]; then
    mkdir -p ${TEMP_DIR}/custom/Espo/Custom/Resources/metadata/app
    cp /var/www/html/custom/Espo/Custom/Resources/metadata/app/client.json ${TEMP_DIR}/custom/Espo/Custom/Resources/metadata/app/
    echo -e "${GREEN}✓ Metadata file backed up${NC}"
fi

# Backup Templates
if [ -f "/var/www/html/custom/Espo/Custom/Resources/templates/site/footer.tpl" ]; then
    mkdir -p ${TEMP_DIR}/custom/Espo/Custom/Resources/templates/site
    cp /var/www/html/custom/Espo/Custom/Resources/templates/site/footer.tpl ${TEMP_DIR}/custom/Espo/Custom/Resources/templates/site/
    echo -e "${GREEN}✓ Template file backed up${NC}"
fi

# Create backup info file
cat > ${TEMP_DIR}/backup-info.txt << EOF
EVERTEC Footer Customization Backup
====================================
Date: $(date)
Timestamp: ${TIMESTAMP}
Files included:
- client/custom/res/css/custom.css
- client/custom/lib/custom-footer.js
- custom/Espo/Custom/Resources/metadata/app/client.json
- custom/Espo/Custom/Resources/templates/site/footer.tpl

To restore, run:
bash /deployment/scripts/restore-footer.sh ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz
EOF

# Create compressed backup
echo -e "${YELLOW}Creating compressed backup...${NC}"
cd /tmp
tar -czf ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz ${BACKUP_NAME}

# Clean up temporary directory
rm -rf ${TEMP_DIR}

# List recent backups
echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}Backup completed successfully!${NC}"
echo -e "${GREEN}====================================${NC}"
echo -e "Backup saved to: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
echo ""
echo -e "${BLUE}Recent backups:${NC}"
ls -lh ${BACKUP_DIR}/*.tar.gz | tail -5

# Keep only last 10 backups
BACKUP_COUNT=$(ls -1 ${BACKUP_DIR}/*.tar.gz 2>/dev/null | wc -l)
if [ ${BACKUP_COUNT} -gt 10 ]; then
    echo -e "${YELLOW}Cleaning old backups (keeping last 10)...${NC}"
    ls -1t ${BACKUP_DIR}/*.tar.gz | tail -n +11 | xargs rm -f
fi

exit 0