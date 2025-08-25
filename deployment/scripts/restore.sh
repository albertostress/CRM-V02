#!/bin/bash

# ===================================
# EspoCRM Restore Script for Dokploy
# ===================================
# This script restores EspoCRM from a backup file

set -e

# Check if backup file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <backup-file.tar.gz>"
    echo "Example: $0 /backups/espocrm_full_20240101_120000.tar.gz"
    exit 1
fi

BACKUP_FILE=$1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
TEMP_DIR="/tmp/espocrm_restore_$(date +%Y%m%d_%H%M%S)"
PROJECT_NAME="espocrm"

echo -e "${GREEN}Starting EspoCRM restore from: ${BACKUP_FILE}${NC}"

# Check if backup file exists
if [ ! -f "${BACKUP_FILE}" ]; then
    echo -e "${RED}Error: Backup file not found: ${BACKUP_FILE}${NC}"
    exit 1
fi

# Create temporary directory
mkdir -p ${TEMP_DIR}

# ===================================
# Extract backup
# ===================================
echo -e "${YELLOW}Extracting backup file...${NC}"
tar -xzf ${BACKUP_FILE} -C ${TEMP_DIR}

# Find the database and files backups
DB_BACKUP=$(find ${TEMP_DIR} -name "*_db_*.sql.gz" | head -n 1)
FILES_BACKUP=$(find ${TEMP_DIR} -name "*_files_*.tar.gz" | head -n 1)

if [ -z "$DB_BACKUP" ]; then
    echo -e "${RED}Error: Database backup not found in archive${NC}"
    exit 1
fi

# ===================================
# Stop EspoCRM services
# ===================================
echo -e "${YELLOW}Stopping EspoCRM services...${NC}"
docker stop espocrm espocrm-daemon espocrm-websocket 2>/dev/null || true

# ===================================
# Restore Database
# ===================================
echo -e "${YELLOW}Restoring database...${NC}"

# Find the database container
DB_CONTAINER=$(docker ps --filter "name=espocrm-db" --format "{{.Names}}" | head -n 1)

if [ -z "$DB_CONTAINER" ]; then
    echo -e "${RED}Error: Database container not found${NC}"
    exit 1
fi

# Drop existing database and recreate
echo -e "${YELLOW}Dropping existing database...${NC}"
docker exec ${DB_CONTAINER} mariadb \
    -u root -p${DB_ROOT_PASSWORD} \
    -e "DROP DATABASE IF EXISTS ${DB_NAME:-espocrm}; CREATE DATABASE ${DB_NAME:-espocrm};"

# Restore database from backup
echo -e "${YELLOW}Importing database backup...${NC}"
gunzip < ${DB_BACKUP} | docker exec -i ${DB_CONTAINER} mariadb \
    -u root -p${DB_ROOT_PASSWORD} ${DB_NAME:-espocrm}

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Database restored successfully${NC}"
else
    echo -e "${RED}Database restore failed${NC}"
    exit 1
fi

# ===================================
# Restore Files
# ===================================
if [ -f "$FILES_BACKUP" ]; then
    echo -e "${YELLOW}Restoring files...${NC}"
    
    # Backup current files (just in case)
    BACKUP_CURRENT_DATE=$(date +%Y%m%d_%H%M%S)
    echo -e "${YELLOW}Backing up current files...${NC}"
    
    FILES_PATH="/etc/dokploy/projects/${PROJECT_NAME}/files"
    
    if [ -d "${FILES_PATH}/espocrm-data" ]; then
        mv ${FILES_PATH}/espocrm-data/data ${FILES_PATH}/espocrm-data/data.backup.${BACKUP_CURRENT_DATE} 2>/dev/null || true
        mv ${FILES_PATH}/espocrm-data/custom ${FILES_PATH}/espocrm-data/custom.backup.${BACKUP_CURRENT_DATE} 2>/dev/null || true
        mv ${FILES_PATH}/espocrm-uploads ${FILES_PATH}/espocrm-uploads.backup.${BACKUP_CURRENT_DATE} 2>/dev/null || true
    fi
    
    # Extract files backup
    tar -xzf ${FILES_BACKUP} -C ${FILES_PATH}
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Files restored successfully${NC}"
    else
        echo -e "${YELLOW}Warning: Some files may not have been restored${NC}"
    fi
else
    echo -e "${YELLOW}No files backup found, skipping files restore${NC}"
fi

# ===================================
# Fix permissions
# ===================================
echo -e "${YELLOW}Fixing file permissions...${NC}"
docker exec espocrm chown -R www-data:www-data /var/www/html/data /var/www/html/custom 2>/dev/null || true

# ===================================
# Clear cache
# ===================================
echo -e "${YELLOW}Clearing EspoCRM cache...${NC}"
docker exec espocrm php /var/www/html/clear_cache.php 2>/dev/null || true

# ===================================
# Start EspoCRM services
# ===================================
echo -e "${YELLOW}Starting EspoCRM services...${NC}"
docker start espocrm
sleep 5
docker start espocrm-daemon espocrm-websocket

# ===================================
# Rebuild EspoCRM
# ===================================
echo -e "${YELLOW}Rebuilding EspoCRM...${NC}"
docker exec espocrm php /var/www/html/rebuild.php 2>/dev/null || true

# ===================================
# Clean up
# ===================================
echo -e "${YELLOW}Cleaning up temporary files...${NC}"
rm -rf ${TEMP_DIR}

# ===================================
# Verify services
# ===================================
echo -e "${YELLOW}Verifying services...${NC}"
sleep 5

SERVICES_RUNNING=true
for service in espocrm espocrm-db espocrm-daemon espocrm-websocket; do
    if [ -z "$(docker ps --filter "name=${service}" --filter "status=running" --format "{{.Names}}")" ]; then
        echo -e "${RED}Warning: ${service} is not running${NC}"
        SERVICES_RUNNING=false
    else
        echo -e "${GREEN}✓ ${service} is running${NC}"
    fi
done

if [ "$SERVICES_RUNNING" = true ]; then
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}Restore completed successfully!${NC}"
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}Please verify your EspoCRM installation at: https://${DOMAIN}${NC}"
else
    echo -e "${YELLOW}==================================${NC}"
    echo -e "${YELLOW}Restore completed with warnings${NC}"
    echo -e "${YELLOW}Please check the service logs for more details${NC}"
    echo -e "${YELLOW}==================================${NC}"
fi

exit 0