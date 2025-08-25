#!/bin/bash

# ===================================
# RESTORE FROM SAVED POINT
# ===================================
# This script restores configuration from a saved restore point

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        RESTORE FROM SAVED POINT                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

RESTORE_DIR="deployment/restore-points"

# Check if restore directory exists
if [ ! -d "$RESTORE_DIR" ]; then
    echo -e "${RED}No restore points found!${NC}"
    echo -e "${YELLOW}Create a restore point first with:${NC}"
    echo -e "  bash deployment/scripts/save-restore-point.sh"
    exit 1
fi

# Get restore point name
if [ -z "$1" ]; then
    echo -e "${YELLOW}Available restore points:${NC}"
    echo ""
    
    # List restore points with details
    for dir in "$RESTORE_DIR"/*; do
        if [ -d "$dir" ]; then
            POINT_NAME=$(basename "$dir")
            if [ -f "$dir/git-info.txt" ]; then
                DATE=$(grep "Date:" "$dir/git-info.txt" | cut -d':' -f2-)
                BRANCH=$(grep "Branch:" "$dir/git-info.txt" | cut -d':' -f2 | xargs)
                echo -e "${GREEN}• $POINT_NAME${NC}"
                echo -e "  Date:$DATE"
                echo -e "  Branch: $BRANCH"
                echo ""
            else
                echo -e "${GREEN}• $POINT_NAME${NC}"
                echo ""
            fi
        fi
    done
    
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  bash deployment/scripts/restore-from-point.sh <restore-point-name>"
    echo ""
    echo -e "${BLUE}Example:${NC}"
    echo -e "  bash deployment/scripts/restore-from-point.sh working-vanilla"
    exit 0
fi

RESTORE_NAME="$1"
RESTORE_PATH="$RESTORE_DIR/$RESTORE_NAME"

# Check if restore point exists
if [ ! -d "$RESTORE_PATH" ]; then
    echo -e "${RED}Restore point '$RESTORE_NAME' not found!${NC}"
    echo -e "${YELLOW}Available restore points:${NC}"
    ls -1 "$RESTORE_DIR" 2>/dev/null || echo "None"
    exit 1
fi

echo -e "${YELLOW}Restoring from: $RESTORE_NAME${NC}"

# Show restore point info
if [ -f "$RESTORE_PATH/git-info.txt" ]; then
    echo -e "${BLUE}Restore point information:${NC}"
    cat "$RESTORE_PATH/git-info.txt"
    echo ""
fi

# Confirmation
echo -e "${RED}⚠️  WARNING: This will replace current configuration!${NC}"
echo -e "${YELLOW}Current changes will be lost unless saved.${NC}"
echo ""
read -p "Continue with restore? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    echo -e "${YELLOW}Restore cancelled.${NC}"
    exit 0
fi

# Step 1: Stop containers
echo -e "${YELLOW}Step 1: Stopping containers...${NC}"
docker-compose down
echo -e "${GREEN}✓ Containers stopped${NC}"

# Step 2: Backup current state (just in case)
echo -e "${YELLOW}Step 2: Backing up current state...${NC}"
BACKUP_NAME="auto-backup-$(date +%Y%m%d-%H%M%S)"
bash deployment/scripts/save-restore-point.sh "$BACKUP_NAME" >/dev/null 2>&1 || true
echo -e "${GREEN}✓ Current state backed up as: $BACKUP_NAME${NC}"

# Step 3: Restore configuration files
echo -e "${YELLOW}Step 3: Restoring configuration files...${NC}"

# Restore docker-compose.yml
cp "$RESTORE_PATH/docker-compose.yml" ./
echo -e "${GREEN}✓ docker-compose.yml restored${NC}"

# Restore .env if exists
if [ -f "$RESTORE_PATH/.env" ]; then
    cp "$RESTORE_PATH/.env" ./
    echo -e "${GREEN}✓ .env restored${NC}"
fi

# Restore .env.example
if [ -f "$RESTORE_PATH/.env.example" ]; then
    cp "$RESTORE_PATH/.env.example" ./
    echo -e "${GREEN}✓ .env.example restored${NC}"
fi

# Remove or restore override file
if [ -f "$RESTORE_PATH/docker-compose.override.yml" ]; then
    cp "$RESTORE_PATH/docker-compose.override.yml" ./
    echo -e "${GREEN}✓ docker-compose.override.yml restored${NC}"
else
    rm -f docker-compose.override.yml
    echo -e "${GREEN}✓ docker-compose.override.yml removed${NC}"
fi

# Step 4: Restore custom directories
echo -e "${YELLOW}Step 4: Restoring custom directories...${NC}"

if [ -d "$RESTORE_PATH/client-custom" ]; then
    rm -rf client/custom
    cp -r "$RESTORE_PATH/client-custom" client/custom
    echo -e "${GREEN}✓ client/custom restored${NC}"
fi

if [ -d "$RESTORE_PATH/custom" ]; then
    rm -rf custom
    cp -r "$RESTORE_PATH/custom" custom
    echo -e "${GREEN}✓ custom restored${NC}"
fi

# Step 5: Restore deployment scripts
echo -e "${YELLOW}Step 5: Restoring deployment scripts...${NC}"
if [ -d "$RESTORE_PATH/scripts" ]; then
    cp -r "$RESTORE_PATH/scripts"/* deployment/scripts/
    echo -e "${GREEN}✓ Deployment scripts restored${NC}"
fi

# Step 6: Restart containers
echo -e "${YELLOW}Step 6: Starting containers...${NC}"
docker-compose up -d
echo -e "${GREEN}✓ Containers started${NC}"

# Step 7: Wait for services
echo -e "${YELLOW}Step 7: Waiting for services to be ready...${NC}"
sleep 10

# Step 8: Show status
echo -e "${YELLOW}Step 8: Current status:${NC}"
docker-compose ps

# Summary
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ RESTORE COMPLETE                         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Restored from: ${YELLOW}$RESTORE_NAME${NC}"
echo -e "${BLUE}Auto-backup created: ${YELLOW}$BACKUP_NAME${NC}"
echo ""
echo -e "${GREEN}System has been restored to the saved state.${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Check if application is working"
echo -e "2. Clear browser cache"
echo -e "3. Test access to your domain"
echo ""
echo -e "${BLUE}If you need to undo this restore:${NC}"
echo -e "  bash deployment/scripts/restore-from-point.sh $BACKUP_NAME"
echo ""

exit 0