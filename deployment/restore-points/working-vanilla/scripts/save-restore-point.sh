#!/bin/bash

# ===================================
# SAVE RESTORE POINT
# ===================================
# This script saves current working configuration as a restore point

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         SAVING RESTORE POINT                    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Get restore point name
if [ -z "$1" ]; then
    RESTORE_NAME="restore-$(date +%Y%m%d-%H%M%S)"
    echo -e "${YELLOW}Using automatic name: $RESTORE_NAME${NC}"
else
    RESTORE_NAME="$1"
    echo -e "${YELLOW}Creating restore point: $RESTORE_NAME${NC}"
fi

# Create restore directory
RESTORE_DIR="deployment/restore-points"
mkdir -p "$RESTORE_DIR"

# Step 1: Save current configuration files
echo -e "${YELLOW}Step 1: Saving configuration files...${NC}"

RESTORE_PATH="$RESTORE_DIR/$RESTORE_NAME"
mkdir -p "$RESTORE_PATH"

# Copy important files
cp docker-compose.yml "$RESTORE_PATH/"
cp .env.example "$RESTORE_PATH/"
[ -f .env ] && cp .env "$RESTORE_PATH/" || echo "No .env file found"
[ -f docker-compose.override.yml ] && cp docker-compose.override.yml "$RESTORE_PATH/" || true

# Copy deployment scripts
cp -r deployment/scripts "$RESTORE_PATH/"

# Copy custom directories if they exist
[ -d client/custom ] && cp -r client/custom "$RESTORE_PATH/client-custom" || true
[ -d custom ] && cp -r custom "$RESTORE_PATH/custom" || true

echo -e "${GREEN}✓ Configuration saved${NC}"

# Step 2: Save current Git commit
echo -e "${YELLOW}Step 2: Saving Git information...${NC}"

CURRENT_COMMIT=$(git rev-parse HEAD)
CURRENT_BRANCH=$(git branch --show-current)

cat > "$RESTORE_PATH/git-info.txt" << EOF
Restore Point: $RESTORE_NAME
Date: $(date)
Branch: $CURRENT_BRANCH
Commit: $CURRENT_COMMIT
Commit Message: $(git log -1 --pretty=%B)
EOF

echo -e "${GREEN}✓ Git info saved${NC}"

# Step 3: Save container states
echo -e "${YELLOW}Step 3: Saving container states...${NC}"

docker-compose ps > "$RESTORE_PATH/container-states.txt" 2>/dev/null || true
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" > "$RESTORE_PATH/docker-status.txt" 2>/dev/null || true

echo -e "${GREEN}✓ Container states saved${NC}"

# Step 4: Create restore script
echo -e "${YELLOW}Step 4: Creating restore script...${NC}"

cat > "$RESTORE_PATH/restore.sh" << 'RESTORE_SCRIPT'
#!/bin/bash

# Auto-generated restore script
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║         RESTORING FROM THIS POINT                ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../../.." && pwd )"

cd "$PROJECT_ROOT"

echo -e "${YELLOW}Restoring configuration files...${NC}"

# Restore files
cp "$SCRIPT_DIR/docker-compose.yml" ./
[ -f "$SCRIPT_DIR/.env" ] && cp "$SCRIPT_DIR/.env" ./
[ -f "$SCRIPT_DIR/docker-compose.override.yml" ] && cp "$SCRIPT_DIR/docker-compose.override.yml" ./ || rm -f docker-compose.override.yml

# Restore custom directories
[ -d "$SCRIPT_DIR/client-custom" ] && cp -r "$SCRIPT_DIR/client-custom" ./client/custom || true
[ -d "$SCRIPT_DIR/custom" ] && cp -r "$SCRIPT_DIR/custom" ./ || true

echo -e "${GREEN}✓ Files restored${NC}"

echo -e "${YELLOW}Restarting containers...${NC}"
docker-compose down
docker-compose up -d

echo -e "${GREEN}✓ Restore complete!${NC}"
RESTORE_SCRIPT

chmod +x "$RESTORE_PATH/restore.sh"
echo -e "${GREEN}✓ Restore script created${NC}"

# Step 5: Create README
echo -e "${YELLOW}Step 5: Creating documentation...${NC}"

cat > "$RESTORE_PATH/README.md" << EOF
# Restore Point: $RESTORE_NAME

## Information
- **Created**: $(date)
- **Git Branch**: $CURRENT_BRANCH
- **Git Commit**: $CURRENT_COMMIT

## Files Included
- docker-compose.yml
- .env (if exists)
- deployment/scripts/
- client/custom/ (if exists)
- custom/ (if exists)

## How to Restore

### Option 1: Use the restore script
\`\`\`bash
bash $RESTORE_PATH/restore.sh
\`\`\`

### Option 2: Use the main restore tool
\`\`\`bash
bash deployment/scripts/restore-from-point.sh $RESTORE_NAME
\`\`\`

### Option 3: Manual restore
1. Copy docker-compose.yml from this directory
2. Copy .env if needed
3. Restart containers

## Container States at Save Time
$(docker-compose ps 2>/dev/null || echo "Containers were not running")
EOF

echo -e "${GREEN}✓ Documentation created${NC}"

# Step 6: List all restore points
echo -e "${YELLOW}Step 6: Current restore points:${NC}"
ls -la "$RESTORE_DIR" | grep "^d" | awk '{print $NF}' | grep -v "^\.$" | grep -v "^\.\.$" || echo "No other restore points"

# Summary
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ RESTORE POINT SAVED SUCCESSFULLY         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Restore point saved as: ${YELLOW}$RESTORE_NAME${NC}"
echo -e "${BLUE}Location: ${YELLOW}$RESTORE_PATH${NC}"
echo ""
echo -e "${GREEN}To restore from this point later:${NC}"
echo -e "  bash deployment/scripts/restore-from-point.sh $RESTORE_NAME"
echo ""

exit 0