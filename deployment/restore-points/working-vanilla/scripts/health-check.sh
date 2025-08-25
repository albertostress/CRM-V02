#!/bin/bash

# ===================================
# EspoCRM Health Check Script
# ===================================
# This script checks the health of all EspoCRM services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOMAIN=${DOMAIN:-localhost}
HEALTH_STATUS=0

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}EspoCRM Health Check${NC}"
echo -e "${GREEN}==================================${NC}"
echo ""

# ===================================
# Check Docker Services
# ===================================
echo -e "${YELLOW}Checking Docker services...${NC}"

SERVICES=("espocrm" "espocrm-db" "espocrm-daemon" "espocrm-websocket" "espocrm-redis")

for service in "${SERVICES[@]}"; do
    if docker ps --filter "name=${service}" --filter "status=running" --format "{{.Names}}" | grep -q ${service}; then
        echo -e "${GREEN}✓ ${service} is running${NC}"
    else
        echo -e "${RED}✗ ${service} is not running${NC}"
        HEALTH_STATUS=1
    fi
done

echo ""

# ===================================
# Check Database Connection
# ===================================
echo -e "${YELLOW}Checking database connection...${NC}"

DB_CHECK=$(docker exec espocrm-db mariadb -u ${DB_USER:-espocrm} -p${DB_PASSWORD} -e "SELECT 1" 2>/dev/null || echo "FAIL")

if [[ "$DB_CHECK" != "FAIL" ]]; then
    echo -e "${GREEN}✓ Database connection successful${NC}"
    
    # Check database size
    DB_SIZE=$(docker exec espocrm-db mariadb -u ${DB_USER:-espocrm} -p${DB_PASSWORD} -e "SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'DB Size in MB' FROM information_schema.tables WHERE table_schema='${DB_NAME:-espocrm}';" -s 2>/dev/null || echo "Unknown")
    echo -e "${GREEN}  Database size: ${DB_SIZE} MB${NC}"
else
    echo -e "${RED}✗ Database connection failed${NC}"
    HEALTH_STATUS=1
fi

echo ""

# ===================================
# Check Redis Connection
# ===================================
echo -e "${YELLOW}Checking Redis connection...${NC}"

REDIS_CHECK=$(docker exec espocrm-redis redis-cli ping 2>/dev/null || echo "FAIL")

if [[ "$REDIS_CHECK" == "PONG" ]]; then
    echo -e "${GREEN}✓ Redis connection successful${NC}"
    
    # Check Redis memory usage
    REDIS_MEM=$(docker exec espocrm-redis redis-cli info memory | grep used_memory_human | cut -d: -f2 | tr -d '\r' 2>/dev/null || echo "Unknown")
    echo -e "${GREEN}  Redis memory usage: ${REDIS_MEM}${NC}"
else
    echo -e "${RED}✗ Redis connection failed${NC}"
    HEALTH_STATUS=1
fi

echo ""

# ===================================
# Check Web Application
# ===================================
echo -e "${YELLOW}Checking web application...${NC}"

# Check main application
APP_STATUS=$(docker exec espocrm curl -s -o /dev/null -w "%{http_code}" http://localhost/api/v1/App/health 2>/dev/null || echo "000")

if [[ "$APP_STATUS" == "200" ]]; then
    echo -e "${GREEN}✓ Application is responding (HTTP ${APP_STATUS})${NC}"
else
    echo -e "${RED}✗ Application is not responding (HTTP ${APP_STATUS})${NC}"
    HEALTH_STATUS=1
fi

# Check WebSocket
WS_STATUS=$(docker exec espocrm-websocket curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")

if [[ "$WS_STATUS" != "000" ]]; then
    echo -e "${GREEN}✓ WebSocket service is responding${NC}"
else
    echo -e "${YELLOW}! WebSocket service may not be responding${NC}"
fi

echo ""

# ===================================
# Check Disk Usage
# ===================================
echo -e "${YELLOW}Checking disk usage...${NC}"

DISK_USAGE=$(df -h /etc/dokploy | tail -1 | awk '{print $5}' | sed 's/%//')
DISK_AVAILABLE=$(df -h /etc/dokploy | tail -1 | awk '{print $4}')

if [ "$DISK_USAGE" -lt 80 ]; then
    echo -e "${GREEN}✓ Disk usage: ${DISK_USAGE}% (${DISK_AVAILABLE} available)${NC}"
elif [ "$DISK_USAGE" -lt 90 ]; then
    echo -e "${YELLOW}! Disk usage: ${DISK_USAGE}% (${DISK_AVAILABLE} available) - Warning${NC}"
else
    echo -e "${RED}✗ Disk usage: ${DISK_USAGE}% (${DISK_AVAILABLE} available) - Critical${NC}"
    HEALTH_STATUS=1
fi

echo ""

# ===================================
# Check Container Logs for Errors
# ===================================
echo -e "${YELLOW}Checking for recent errors...${NC}"

ERROR_COUNT=0
for service in espocrm espocrm-daemon espocrm-websocket; do
    ERRORS=$(docker logs ${service} --tail 100 2>&1 | grep -i "error\|exception\|fatal" | wc -l)
    if [ "$ERRORS" -gt 0 ]; then
        echo -e "${YELLOW}! ${service}: ${ERRORS} errors in recent logs${NC}"
        ERROR_COUNT=$((ERROR_COUNT + ERRORS))
    fi
done

if [ "$ERROR_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ No recent errors found in logs${NC}"
fi

echo ""

# ===================================
# Check Cron Jobs
# ===================================
echo -e "${YELLOW}Checking cron jobs...${NC}"

LAST_CRON=$(docker exec espocrm-db mariadb -u ${DB_USER:-espocrm} -p${DB_PASSWORD} ${DB_NAME:-espocrm} -e "SELECT MAX(executed_at) FROM job WHERE status='Success' AND executed_at > DATE_SUB(NOW(), INTERVAL 10 MINUTE);" -s 2>/dev/null || echo "")

if [ ! -z "$LAST_CRON" ] && [ "$LAST_CRON" != "NULL" ]; then
    echo -e "${GREEN}✓ Cron jobs are running (last: ${LAST_CRON})${NC}"
else
    echo -e "${YELLOW}! No recent cron job execution detected${NC}"
fi

echo ""

# ===================================
# Performance Metrics
# ===================================
echo -e "${YELLOW}Performance metrics...${NC}"

# Container CPU and Memory usage
for service in espocrm espocrm-db espocrm-daemon; do
    STATS=$(docker stats ${service} --no-stream --format "CPU: {{.CPUPerc}} | MEM: {{.MemUsage}}" 2>/dev/null || echo "N/A")
    echo -e "  ${service}: ${STATS}"
done

echo ""

# ===================================
# Summary
# ===================================
echo -e "${GREEN}==================================${NC}"
if [ "$HEALTH_STATUS" -eq 0 ]; then
    echo -e "${GREEN}Health Check: PASSED${NC}"
    echo -e "${GREEN}All systems operational${NC}"
else
    echo -e "${RED}Health Check: FAILED${NC}"
    echo -e "${RED}Some issues detected, please review above${NC}"
fi
echo -e "${GREEN}==================================${NC}"

exit $HEALTH_STATUS