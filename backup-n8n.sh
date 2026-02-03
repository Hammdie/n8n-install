#!/bin/bash

# n8n Backup Script
# Creates backups of n8n database and configuration

set -e

# Konfiguration
BACKUP_DIR="/var/backups/n8n"
DATE=$(date +%Y%m%d_%H%M%S)
N8N_USER="n8n"
N8N_DIR="/home/$N8N_USER/n8n"
POSTGRES_DB="n8n_db"
POSTGRES_USER="n8n_user"

# Farben
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# Check root privileges
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root"
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

log "Starting n8n backup..."

# PostgreSQL Backup
log "Creating database backup..."
sudo -u postgres pg_dump "$POSTGRES_DB" > "$BACKUP_DIR/n8n_db_$DATE.sql"

# n8n configuration and data backup
log "Creating configuration backup..."
tar -czf "$BACKUP_DIR/n8n_config_$DATE.tar.gz" -C "$N8N_DIR" .

# Nginx configuration backup
log "Creating nginx configuration backup..."
cp /etc/nginx/sites-available/n8n "$BACKUP_DIR/nginx_n8n_$DATE.conf"

# Systemd service backup
cp /etc/systemd/system/n8n.service "$BACKUP_DIR/n8n_service_$DATE.service"

# Encryption key backup
if [[ -f "/var/n8n/encryption.key" ]]; then
    log "Backing up encryption key..."
    cp /var/n8n/encryption.key "$BACKUP_DIR/n8n_encryption_$DATE.key"
    chmod 600 "$BACKUP_DIR/n8n_encryption_$DATE.key"
fi

# Delete old backups (older than 30 days)
find "$BACKUP_DIR" -name "*.sql" -mtime +30 -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete
find "$BACKUP_DIR" -name "*.conf" -mtime +30 -delete
find "$BACKUP_DIR" -name "*.service" -mtime +30 -delete
find "$BACKUP_DIR" -name "*.key" -mtime +30 -delete

log "Backup completed!"
log "Backup files:"
ls -la "$BACKUP_DIR"/*_$DATE.*