#!/bin/bash

# ===================================
# EspoCRM Backup Script for Dokploy
# ===================================
# This script creates backups of the EspoCRM database and files
# Can be scheduled in Dokploy's scheduled jobs feature

set -e

# Configuration
BACKUP_DIR="/backups"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-30}
PROJECT_NAME="espocrm"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create backup directory if it doesn't exist
mkdir -p ${BACKUP_DIR}

echo -e "${GREEN}Starting EspoCRM backup at $(date)${NC}"

# ===================================
# Database Backup
# ===================================
echo -e "${YELLOW}Backing up database...${NC}"

DB_BACKUP_FILE="${BACKUP_DIR}/${PROJECT_NAME}_db_${BACKUP_DATE}.sql.gz"

# Find the database container
DB_CONTAINER=$(docker ps --filter "name=espocrm-db" --format "{{.Names}}" | head -n 1)

if [ -z "$DB_CONTAINER" ]; then
    echo -e "${RED}Error: Database container not found${NC}"
    exit 1
fi

# Perform database backup
docker exec ${DB_CONTAINER} mariadb-dump \
    --user='${DB_USER:-espocrm}' \
    --password='${DB_PASSWORD}' \
    --single-transaction \
    --no-tablespaces \
    --quick \
    --lock-tables=false \
    --databases ${DB_NAME:-espocrm} | gzip > ${DB_BACKUP_FILE}

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Database backup completed: ${DB_BACKUP_FILE}${NC}"
    echo "Database backup size: $(du -h ${DB_BACKUP_FILE} | cut -f1)"
else
    echo -e "${RED}Database backup failed${NC}"
    exit 1
fi

# ===================================
# Files Backup
# ===================================
echo -e "${YELLOW}Backing up files...${NC}"

FILES_BACKUP_FILE="${BACKUP_DIR}/${PROJECT_NAME}_files_${BACKUP_DATE}.tar.gz"

# Backup important directories
tar -czf ${FILES_BACKUP_FILE} \
    -C /etc/dokploy/projects/${PROJECT_NAME}/files \
    espocrm-data/data \
    espocrm-data/custom \
    espocrm-uploads \
    2>/dev/null || true

if [ $? -eq 0 ] || [ -f ${FILES_BACKUP_FILE} ]; then
    echo -e "${GREEN}Files backup completed: ${FILES_BACKUP_FILE}${NC}"
    echo "Files backup size: $(du -h ${FILES_BACKUP_FILE} | cut -f1)"
else
    echo -e "${RED}Files backup failed${NC}"
    exit 1
fi

# ===================================
# Create combined backup archive
# ===================================
echo -e "${YELLOW}Creating combined backup archive...${NC}"

COMBINED_BACKUP="${BACKUP_DIR}/${PROJECT_NAME}_full_${BACKUP_DATE}.tar.gz"
cd ${BACKUP_DIR}
tar -czf ${COMBINED_BACKUP} \
    $(basename ${DB_BACKUP_FILE}) \
    $(basename ${FILES_BACKUP_FILE})

# Remove individual files after combining
rm -f ${DB_BACKUP_FILE} ${FILES_BACKUP_FILE}

echo -e "${GREEN}Combined backup created: ${COMBINED_BACKUP}${NC}"
echo "Total backup size: $(du -h ${COMBINED_BACKUP} | cut -f1)"

# ===================================
# Upload to S3 (Optional)
# ===================================
if [ ! -z "${S3_BUCKET}" ]; then
    echo -e "${YELLOW}Uploading to S3...${NC}"
    
    # Check if AWS CLI is available
    if command -v aws &> /dev/null; then
        aws s3 cp ${COMBINED_BACKUP} s3://${S3_BUCKET}/espocrm-backups/ \
            --region ${S3_REGION:-us-east-1}
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Backup uploaded to S3 successfully${NC}"
        else
            echo -e "${RED}Failed to upload to S3${NC}"
        fi
    else
        echo -e "${YELLOW}AWS CLI not found, skipping S3 upload${NC}"
    fi
fi

# ===================================
# Clean old backups
# ===================================
echo -e "${YELLOW}Cleaning old backups (older than ${RETENTION_DAYS} days)...${NC}"

find ${BACKUP_DIR} -name "${PROJECT_NAME}_full_*.tar.gz" -type f -mtime +${RETENTION_DAYS} -delete

REMAINING_BACKUPS=$(ls -1 ${BACKUP_DIR}/${PROJECT_NAME}_full_*.tar.gz 2>/dev/null | wc -l)
echo -e "${GREEN}Backup cleanup completed. ${REMAINING_BACKUPS} backups remaining${NC}"

# ===================================
# Generate backup report
# ===================================
REPORT_FILE="${BACKUP_DIR}/backup_report.txt"
{
    echo "==================================="
    echo "EspoCRM Backup Report"
    echo "==================================="
    echo "Date: $(date)"
    echo "Backup File: ${COMBINED_BACKUP}"
    echo "Size: $(du -h ${COMBINED_BACKUP} | cut -f1)"
    echo "Retention: ${RETENTION_DAYS} days"
    echo "Total Backups: ${REMAINING_BACKUPS}"
    echo "==================================="
    echo ""
} >> ${REPORT_FILE}

echo -e "${GREEN}Backup completed successfully at $(date)${NC}"
echo -e "${GREEN}Backup location: ${COMBINED_BACKUP}${NC}"

# ===================================
# Send notification (Optional)
# ===================================
# You can add notification logic here (webhook, email, etc.)
# Example: curl -X POST https://your-webhook-url -d "Backup completed: ${COMBINED_BACKUP}"

exit 0