# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Change Log

### 2025-08-26 02:45:00
- **Core files edited directly for EVERTEC branding**
  - Modified: `html/main.html` - Changed title to "EVERTEC CRM", added custom CSS/JS links, replaced footer
  - Backup: `html/main.html.bak` - Original file preserved
  - Updated: `client/custom/res/css/custom.css` - Hide About menu, remove EspoCRM references
  - Updated: `client/custom/lib/custom-footer.js` - Remove About links, replace text dynamically
  - Note: **NOT upgrade-safe** - Core files modified directly for immediate branding
  - Result: Complete EVERTEC CRM branding without external scripts

### 2025-08-26 01:15:00
- **Replaced About page with custom branding "Kwame Oil & Gas CRM"**
  - Created: `custom/Espo/Custom/Resources/metadata/clientDefs/About.json` - Metadata to use custom view
  - Created: `client/custom/src/views/about.js` - Custom view definition
  - Created: `client/custom/res/templates/about.tpl` - Custom HTML template with company branding
  - Note: Upgrade-safe customization using EspoCRM's metadata override system
  - Commands to run after deploy:
    ```bash
    docker exec espocrm rm -rf /var/www/html/data/cache/*
    docker exec espocrm php /var/www/html/rebuild.php
    ```

### 2025-08-26 01:02:06
- **Fixed footer replacement to use textContent instead of innerHTML**
  - Modified: `client/custom/lib/custom-footer.js` - Changed from innerHTML to textContent to preserve DOM structure
  - Verified: `custom/Espo/Custom/Resources/metadata/app/client.json` - Configuration correct
  - Note: Container not running during cache clear - will be cleared on next deployment
  - Commands to run after deploy:
    ```bash
    docker exec espocrm rm -rf /var/www/html/data/cache/*
    docker exec espocrm php /var/www/html/rebuild.php
    docker exec espocrm php /var/www/html/clear_cache.php
    docker restart espocrm
    ```

### 2025-08-26 00:10:54
- **Updated watermark to "© 2025 EVERTEC CRM — Todos os direitos reservados"**
  - Modified: `client/custom/res/css/custom.css` - Updated CSS to show new watermark text
  - Modified: `client/custom/lib/custom-footer.js` - Updated JS to replace with new text
  - Verified: `custom/Espo/Custom/Resources/metadata/app/client.json` - Already configured correctly
  - Note: Upgrade-safe customization (no core files modified)

## Project Overview

EspoCRM is a free, open-source CRM platform with a PHP backend (REST API) and JavaScript frontend (single-page application). It uses a modular architecture with metadata-driven configuration.

## Branding Override Evertec

This instance has been customized with Evertec branding:

- **Footer override**: `custom/Espo/Custom/Resources/templates/site/footer.tpl`
- **Translations override**: `custom/Espo/Custom/Resources/i18n/en_US/Global.json` and `pt_BR/Global.json`
- **Config patch**: `deployment/scripts/start.sh` forces `'outboundEmailFromName' => 'Evertec'`
- **JavaScript override**: `client/custom/lib/custom-footer.js` - aggressive footer replacement
- **CSS override**: `client/custom/res/css/custom.css` - visual branding

### Como limpar cache e validar

1. **Dentro do container:**
   ```bash
   rm -rf /var/www/html/data/cache/*
   php /var/www/html/clear_cache.php || true
   ```

2. **Reiniciar o container:**
   ```bash
   docker restart espocrm
   ```

3. **Aplicar branding completo:**
   ```bash
   docker exec espocrm bash /deployment/scripts/apply-evertec-complete.sh
   ```

4. **Verificar status:**
   ```bash
   docker exec espocrm bash /deployment/scripts/verify-watermark.sh
   ```

5. **Testar no browser:**
   - Rodapé deve exibir `© 2025 Evertec`
   - No Admin > Email Settings, o From Name aparece como `Evertec`
   - UI mostra "Evertec CRM" no topo
   - Console do browser: digite `evertecStatus()` para ver status do JS

### Observação
Os overrides em `custom/...` são carregados automaticamente pelo EspoCRM e sobrevivem a upgrades. A customização é aplicada em múltiplas camadas para garantir permanência.

## Common Development Commands

### Build Commands
- `npm run build` or `grunt` - Full production build
- `npm run build-dev` or `grunt dev` - Development build (includes dev dependencies)
- `npm run build-frontend` or `grunt internal` - Build only frontend assets (libs and CSS)
- `grunt offline` - Build without running composer install

### Testing Commands
- `npm run unit-tests` or `php vendor/bin/phpunit tests/unit` - Run PHP unit tests
- `npm run integration-tests` or `php vendor/bin/phpunit tests/integration` - Run PHP integration tests
- `grunt run-tests` - Build and run all PHP tests
- Frontend tests: `cd frontend/test && jasmine-browser-runner serve`

### Static Analysis
- `npm run sa` or `php vendor/bin/phpstan` - Run PHPStan static analysis (level 8)

### Development Setup
- `composer install` - Install PHP dependencies (dev)
- `npm ci` - Install Node.js dependencies
- `grunt dev` - Quick development build

## Architecture Overview

### Backend (PHP)
- **Framework**: Custom PHP framework with dependency injection
- **Entry Point**: `bootstrap.php` → `application/Espo/Core/Application.php`
- **Pattern**: MVC with Service Layer
- **Key Components**:
  - Controllers: `application/Espo/Controllers/`
  - Services: `application/Espo/Services/`
  - Entities: `application/Espo/Entities/`
  - Repositories: `application/Espo/Repositories/`
  - Core: `application/Espo/Core/` (application framework)

### Frontend (JavaScript)
- **Framework**: Backbone.js with custom extensions (Bullbone)
- **Entry Point**: `client/src/app.js`
- **Pattern**: MVC with modular views
- **Key Components**:
  - Views: `client/src/views/`
  - Controllers: `client/src/controllers/`
  - Models: `client/src/models/`
  - Collections: `client/src/collections/`

### Dependency Injection
The application uses a sophisticated DI container (`application/Espo/Core/Container.php`). Services are auto-wired based on constructor dependencies and binding configurations in `application/Espo/Binding.php`.

### Metadata System
EspoCRM is heavily metadata-driven. Configuration is stored in JSON files:
- `schema/metadata/` - Schema definitions
- `application/Espo/Resources/metadata/` - Default metadata
- `custom/Espo/Custom/Resources/metadata/` - Custom extensions

### Module System
- Core modules: `application/Espo/Modules/`
- Custom modules: `custom/Espo/Modules/`
- CRM module: `client/modules/crm/`

## Database
Supports MySQL 8.0+, MariaDB 10.3+, and PostgreSQL 15+. Uses Doctrine DBAL for database abstraction.

## File Structure Notes
- `application/` - PHP backend code
- `client/` - Frontend JavaScript/CSS code
- `custom/` - Customizations and extensions
- `data/` - Runtime data directory
- `install/` - Installation system
- `public/` - Web-accessible files
- `tests/` - PHP test suites
- `frontend/test/` - JavaScript test suites

## Development Workflow
1. Make changes to source files
2. Run `grunt dev` to build frontend assets
3. Run tests to verify changes
4. Use PHPStan for static analysis
5. Follow PSR standards for PHP code

## Key Technologies
- **PHP**: 8.2-8.4 required
- **Node.js**: 17+ required for build process
- **Frontend**: Backbone.js, jQuery, Bootstrap, Handlebars templates
- **Build**: Grunt.js with custom build pipeline
- **Testing**: PHPUnit (PHP), Jasmine (JavaScript)

## Deployment on Dokploy

### Overview
Dokploy is an open-source, self-hostable deployment platform that simplifies application management using Docker and Traefik. This guide covers deploying EspoCRM on Dokploy with proper configuration for production use.

### Prerequisites
- Dokploy installed on your server (run: `curl -sSL https://dokploy.com/install.sh | sh`)
- Domain name pointed to your server's IP address
- SSL certificate (Let's Encrypt recommended)

### Docker Compose Configuration

Create a `docker-compose.yml` file for EspoCRM deployment on Dokploy:

```yaml
version: "3.8"

services:
  espocrm-db:
    image: mariadb:latest
    container_name: espocrm-db
    environment:
      MARIADB_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MARIADB_DATABASE: espocrm
      MARIADB_USER: espocrm
      MARIADB_PASSWORD: ${DB_PASSWORD}
    volumes:
      - ../files/espocrm-db:/var/lib/mysql
    networks:
      - dokploy-network
    restart: always
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 20s
      start_period: 10s
      timeout: 10s
      retries: 3

  espocrm:
    image: espocrm/espocrm:latest
    container_name: espocrm
    environment:
      ESPOCRM_DATABASE_PLATFORM: Mysql
      ESPOCRM_DATABASE_HOST: espocrm-db
      ESPOCRM_DATABASE_USER: espocrm
      ESPOCRM_DATABASE_PASSWORD: ${DB_PASSWORD}
      ESPOCRM_ADMIN_USERNAME: ${ADMIN_USERNAME}
      ESPOCRM_ADMIN_PASSWORD: ${ADMIN_PASSWORD}
      ESPOCRM_SITE_URL: "https://${DOMAIN}"
    volumes:
      - ../files/espocrm-data:/var/www/html
    networks:
      - dokploy-network
    restart: always
    depends_on:
      espocrm-db:
        condition: service_healthy
    expose:
      - 80
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.espocrm.rule=Host(`${DOMAIN}`)"
      - "traefik.http.routers.espocrm.entrypoints=websecure"
      - "traefik.http.routers.espocrm.tls.certResolver=letsencrypt"
      - "traefik.http.services.espocrm.loadbalancer.server.port=80"

  espocrm-daemon:
    image: espocrm/espocrm:latest
    container_name: espocrm-daemon
    volumes:
      - ../files/espocrm-data:/var/www/html
    networks:
      - dokploy-network
    restart: always
    depends_on:
      - espocrm
    entrypoint: docker-daemon.sh

  espocrm-websocket:
    image: espocrm/espocrm:latest
    container_name: espocrm-websocket
    environment:
      ESPOCRM_CONFIG_USE_WEB_SOCKET: "true"
      ESPOCRM_CONFIG_WEB_SOCKET_URL: "wss://${DOMAIN}/ws"
      ESPOCRM_CONFIG_WEB_SOCKET_ZERO_M_Q_SUBSCRIBER_DSN: "tcp://*:7777"
      ESPOCRM_CONFIG_WEB_SOCKET_ZERO_M_Q_SUBMISSION_DSN: "tcp://espocrm-websocket:7777"
    volumes:
      - ../files/espocrm-data:/var/www/html
    networks:
      - dokploy-network
    restart: always
    depends_on:
      - espocrm
    entrypoint: docker-websocket.sh
    expose:
      - 8080
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.espocrm-ws.rule=Host(`${DOMAIN}`) && PathPrefix(`/ws`)"
      - "traefik.http.routers.espocrm-ws.entrypoints=websecure"
      - "traefik.http.routers.espocrm-ws.tls.certResolver=letsencrypt"
      - "traefik.http.services.espocrm-ws.loadbalancer.server.port=8080"

networks:
  dokploy-network:
    external: true
```

### Environment Variables

Configure these environment variables in Dokploy's project settings:

```bash
# Database Configuration
DB_ROOT_PASSWORD=your_secure_root_password
DB_PASSWORD=your_secure_db_password

# Admin Configuration
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_secure_admin_password

# Domain Configuration
DOMAIN=crm.yourdomain.com
```

### Deployment Steps

1. **Create a new project in Dokploy**
   - Navigate to Dokploy dashboard
   - Click "Create Project"
   - Name it "EspoCRM"

2. **Add Docker Compose service**
   - Within the project, select "Docker Compose"
   - Paste the docker-compose.yml configuration
   - Set up environment variables

3. **Configure domain**
   - Go to the Domains section
   - Add your domain (e.g., crm.yourdomain.com)
   - Enable HTTPS and select Let's Encrypt certificate

4. **Deploy**
   - Click "Deploy" to start the deployment
   - Monitor logs for any issues
   - First deployment will initialize the database

### Important Dokploy-Specific Considerations

#### Volume Mounting
- Always use `../files/` prefix for persistent volumes in Dokploy
- Example: `../files/espocrm-data:/var/www/html`
- This ensures data persists across deployments

#### Network Configuration
- Always use `dokploy-network` as the external network
- Don't define custom networks unless necessary

#### Port Exposure
- Use `expose` instead of `ports` for internal services
- Traefik handles external routing via labels
- Only expose ports that Traefik needs to route to

#### Health Checks
Configure health checks for zero-downtime deployments:

```json
{
  "Test": ["CMD", "curl", "-f", "http://localhost:80/api/v1/App/health"],
  "Interval": 30000000000,
  "Timeout": 10000000000,
  "StartPeriod": 30000000000,
  "Retries": 3
}
```

### Backup Strategy

#### Automated Backups
Configure scheduled jobs in Dokploy for regular backups:

1. **Database Backup Script**:
```bash
#!/bin/bash
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="espocrm_${BACKUP_DATE}.sql.gz"

docker exec espocrm-db mariadb-dump \
  --user='espocrm' \
  --password='${DB_PASSWORD}' \
  --databases espocrm | gzip > /backups/${BACKUP_FILE}
```

2. **File Backup**:
```bash
tar -czf /backups/espocrm-files-$(date +%Y%m%d_%H%M%S).tar.gz \
  /etc/dokploy/projects/espocrm/files/espocrm-data
```

### Monitoring and Maintenance

#### Log Monitoring
Access logs through Dokploy UI or CLI:
```bash
docker logs espocrm
docker logs espocrm-daemon
docker logs espocrm-websocket
```

#### Performance Optimization
1. Configure resource limits in Dokploy's Advanced settings:
   - Memory: 2GB minimum, 4GB recommended
   - CPU: 2 cores minimum

2. Enable caching in EspoCRM configuration

3. Configure proper indexes in database

### Troubleshooting

#### Common Issues

1. **Bad Gateway (502)**
   - Check if EspoCRM container is running
   - Verify Traefik labels are correct
   - Check container logs for PHP errors

2. **Database Connection Failed**
   - Verify database container is healthy
   - Check environment variables
   - Ensure network connectivity between containers

3. **WebSocket Connection Issues**
   - Verify websocket container is running
   - Check Traefik routing for /ws path
   - Ensure SSL certificate is valid

#### Debug Commands
```bash
# Check container status
docker ps | grep espocrm

# Test database connection
docker exec espocrm-db mariadb -u espocrm -p${DB_PASSWORD} -e "SELECT 1"

# Verify network connectivity
docker exec espocrm ping espocrm-db

# Check Traefik routing
docker logs dokploy-traefik | grep espocrm
```

### Security Best Practices

1. **Use strong passwords** for database and admin accounts
2. **Enable SSL/TLS** via Let's Encrypt
3. **Regular updates** of Docker images
4. **Implement firewall rules** to restrict database access
5. **Regular backups** with offsite storage
6. **Monitor logs** for suspicious activity

### Scaling Considerations

For high-availability deployments:

1. **Database Replication**: Set up MariaDB master-slave replication
2. **Load Balancing**: Use Dokploy's cluster features with multiple replicas
3. **CDN Integration**: Serve static assets via CDN
4. **Redis Cache**: Add Redis container for session and cache storage

### Additional Resources

- EspoCRM Documentation: https://docs.espocrm.com/
- Dokploy Documentation: https://docs.dokploy.com/
- Docker Compose Reference: https://docs.docker.com/compose/
- Traefik Documentation: https://doc.traefik.io/traefik/