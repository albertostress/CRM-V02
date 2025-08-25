# Restore Point: working-vanilla

## Information
- **Created**: Mon Aug 25 23:51:29 CEST 2025
- **Git Branch**: main
- **Git Commit**: 5853ed35f8d568d8a199e850ca72a97c84dccef4

## Files Included
- docker-compose.yml
- .env (if exists)
- deployment/scripts/
- client/custom/ (if exists)
- custom/ (if exists)

## How to Restore

### Option 1: Use the restore script
```bash
bash deployment/restore-points/working-vanilla/restore.sh
```

### Option 2: Use the main restore tool
```bash
bash deployment/scripts/restore-from-point.sh working-vanilla
```

### Option 3: Manual restore
1. Copy docker-compose.yml from this directory
2. Copy .env if needed
3. Restart containers

## Container States at Save Time
NAME      IMAGE     COMMAND   SERVICE   CREATED   STATUS    PORTS
