# EspoCRM Deployment on Dokploy

This directory contains all necessary files and scripts for deploying EspoCRM on Dokploy.

## Quick Start

1. **Install Dokploy** on your server:
   ```bash
   curl -sSL https://dokploy.com/install.sh | sh
   ```

2. **Configure Environment Variables**:
   - Copy `.env.example` to `.env`
   - Update all values, especially:
     - `DOMAIN` - Your domain name
     - Database passwords
     - Admin credentials

3. **Deploy on Dokploy**:
   - Create a new project in Dokploy
   - Add Docker Compose service
   - Paste the `docker-compose.yml` content
   - Configure environment variables
   - Deploy!

## Directory Structure

```
deployment/
├── README.md           # This file
├── scripts/           
│   ├── backup.sh      # Automated backup script
│   ├── restore.sh     # Restore from backup
│   └── health-check.sh # System health monitoring
└── ...
```

## Scripts

### Backup Script (`backup.sh`)
Automated backup of database and files:
```bash
./deployment/scripts/backup.sh
```

Features:
- Database backup (MariaDB)
- Files backup (data, custom, uploads)
- Automatic cleanup of old backups
- Optional S3 upload support
- Backup retention management

### Restore Script (`restore.sh`)
Restore from a backup file:
```bash
./deployment/scripts/restore.sh /backups/espocrm_full_20240101_120000.tar.gz
```

### Health Check Script (`health-check.sh`)
Monitor system health:
```bash
./deployment/scripts/health-check.sh
```

Checks:
- All Docker services status
- Database connectivity
- Redis connectivity
- Web application availability
- Disk usage
- Recent errors in logs
- Cron job execution

## Scheduled Jobs in Dokploy

Configure these as scheduled jobs in Dokploy:

### Daily Backup (2 AM)
```
0 2 * * * /deployment/scripts/backup.sh
```

### Health Check (Every 5 minutes)
```
*/5 * * * * /deployment/scripts/health-check.sh
```

## Environment Variables

Key environment variables (see `.env.example` for full list):

| Variable | Description | Example |
|----------|-------------|---------|
| `DOMAIN` | Your domain name | `crm.example.com` |
| `DB_PASSWORD` | Database password | Strong password |
| `ADMIN_PASSWORD` | Admin user password | Strong password |
| `BACKUP_RETENTION_DAYS` | Days to keep backups | `30` |
| `S3_BUCKET` | S3 bucket for backups (optional) | `my-backups` |

## Security Considerations

1. **Always use strong passwords** in production
2. **Enable SSL/TLS** via Let's Encrypt
3. **Regular backups** with offsite storage
4. **Monitor logs** for suspicious activity
5. **Keep Docker images updated**
6. **Implement firewall rules** for database ports
7. **Use environment variables** for sensitive data
8. **Never commit `.env` file** to version control

## Monitoring

### View Logs
```bash
# Application logs
docker logs espocrm

# Database logs
docker logs espocrm-db

# Background jobs
docker logs espocrm-daemon

# WebSocket service
docker logs espocrm-websocket
```

### Check Service Status
```bash
docker ps | grep espocrm
```

### Database Connection Test
```bash
docker exec espocrm-db mariadb -u espocrm -p${DB_PASSWORD} -e "SELECT 1"
```

## Troubleshooting

### Bad Gateway (502)
1. Check if containers are running: `docker ps`
2. View application logs: `docker logs espocrm`
3. Verify Traefik labels in docker-compose.yml

### Database Connection Failed
1. Check database container: `docker logs espocrm-db`
2. Verify environment variables
3. Test connection manually

### WebSocket Issues
1. Check websocket container: `docker logs espocrm-websocket`
2. Verify domain configuration includes `/ws` path
3. Check SSL certificate validity

### High Disk Usage
1. Clean old backups: `find /backups -name "*.tar.gz" -mtime +30 -delete`
2. Clear Docker cache: `docker system prune -a`
3. Check log sizes: `du -h /var/lib/docker/containers/*/`

## Performance Optimization

### Resource Limits
Configure in Dokploy Advanced settings:
- Memory: 2GB minimum, 4GB recommended
- CPU: 2 cores minimum

### Database Optimization
```sql
-- Add indexes for better performance
-- Run in database container
docker exec espocrm-db mariadb -u root -p${DB_ROOT_PASSWORD} espocrm
```

### Redis Caching
Redis is included for improved performance:
- Session storage
- Application cache
- Job queue optimization

## Scaling

For high-availability:

1. **Database Replication**: Configure MariaDB master-slave
2. **Multiple Replicas**: Use Dokploy cluster features
3. **CDN**: Serve static assets via CDN
4. **Load Balancing**: Traefik handles this automatically

## Support

- EspoCRM Documentation: https://docs.espocrm.com/
- Dokploy Documentation: https://docs.dokploy.com/
- GitHub Issues: Report bugs and feature requests

## License

EspoCRM is open source software. See LICENSE file for details.