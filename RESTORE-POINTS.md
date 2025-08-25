# 🔄 RESTORE POINTS SYSTEM

## Overview
This system allows you to save and restore working configurations of your EspoCRM deployment.

## Current Restore Points

### 📌 working-vanilla
- **Created**: Today
- **Git Tag**: `v1.0-working-vanilla`
- **Description**: Basic working EspoCRM without customizations
- **Status**: ✅ CURRENT STATE

## How to Use Restore Points

### 1️⃣ Save Current State
```bash
# Save with automatic name (includes timestamp)
bash deployment/scripts/save-restore-point.sh

# Save with custom name
bash deployment/scripts/save-restore-point.sh "my-custom-point"
```

### 2️⃣ List Available Restore Points
```bash
# Shows all available restore points
bash deployment/scripts/restore-from-point.sh
```

### 3️⃣ Restore from a Point
```bash
# Restore specific point
bash deployment/scripts/restore-from-point.sh working-vanilla

# Restore from Git tag
git checkout v1.0-working-vanilla
```

## What Gets Saved

Each restore point includes:
- ✅ `docker-compose.yml`
- ✅ `.env` and `.env.example`
- ✅ All deployment scripts
- ✅ Custom directories (`client/custom`, `custom/`)
- ✅ Git commit information
- ✅ Container states

## Emergency Recovery

If everything breaks, you can always return to the working state:

```bash
# Option 1: Use restore point
bash deployment/scripts/restore-from-point.sh working-vanilla

# Option 2: Use Git
git checkout v1.0-working-vanilla
docker-compose down
docker-compose up -d

# Option 3: Manual rollback
bash deployment/scripts/rollback-to-working.sh
```

## Best Practices

1. **Before Major Changes**: Always create a restore point
   ```bash
   bash deployment/scripts/save-restore-point.sh "before-feature-X"
   ```

2. **After Successful Changes**: Save the new working state
   ```bash
   bash deployment/scripts/save-restore-point.sh "feature-X-working"
   ```

3. **Regular Backups**: Create restore points periodically

## Restore Point Locations

- **Local Storage**: `deployment/restore-points/`
- **Git Tags**: Use `git tag -l` to see all tags
- **Auto-backups**: Created automatically when restoring

## Quick Commands Reference

| Action | Command |
|--------|---------|
| Save current state | `bash deployment/scripts/save-restore-point.sh` |
| List restore points | `bash deployment/scripts/restore-from-point.sh` |
| Restore specific point | `bash deployment/scripts/restore-from-point.sh NAME` |
| Emergency rollback | `bash deployment/scripts/rollback-to-working.sh` |
| View Git tags | `git tag -l` |

## Notes

- Restore points are **local** (not pushed to Git)
- Git tags are **permanent** (pushed to repository)
- Auto-backups are created before each restore
- Each restore point includes a `restore.sh` script for direct execution

---

*System created to ensure you can always recover from any issues during deployment or customization.*