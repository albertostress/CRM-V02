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
