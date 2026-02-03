#!/bin/bash

# n8n Restore Script
# Restores n8n from a backup

set -e

# Konfiguration
BACKUP_DIR="/var/backups/n8n"
N8N_USER="n8n"
N8N_DIR="/home/$N8N_USER/n8n"
POSTGRES_DB="n8n_db"
POSTGRES_USER="n8n_user"

# Farben
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Check root privileges
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root"
fi

# Check parameters
if [[ -z "$1" ]]; then
    echo "Available backups:"
    ls -la "$BACKUP_DIR"/*.sql 2>/dev/null || error "No backups found"
    echo ""
    echo "Usage: $0 <backup-date>"
    echo "Example: $0 20240202_143000"
    exit 1
fi

BACKUP_DATE="$1"

# Check backup files
DB_BACKUP="$BACKUP_DIR/n8n_db_$BACKUP_DATE.sql"
CONFIG_BACKUP="$BACKUP_DIR/n8n_config_$BACKUP_DATE.tar.gz"
ENCRYPTION_BACKUP="$BACKUP_DIR/n8n_encryption_$BACKUP_DATE.key"

if [[ ! -f "$DB_BACKUP" ]]; then
    error "Database backup not found: $DB_BACKUP"
fi

if [[ ! -f "$CONFIG_BACKUP" ]]; then
    error "Configuration backup not found: $CONFIG_BACKUP"
fi

log "Starting n8n restore for backup from $BACKUP_DATE..."

# Safety confirmation
warning "WARNING: This operation will overwrite the current n8n installation!"
read -p "Do you want to continue? (yes/no): " response
if [[ "$response" != "yes" ]]; then
    echo "Restore cancelled."
    exit 0
fi

# Stop n8n
log "Stopping n8n service..."
systemctl stop n8n

# Restore database
log "Restoring database..."
sudo -u postgres dropdb --if-exists "$POSTGRES_DB"
sudo -u postgres createdb "$POSTGRES_DB"
sudo -u postgres psql -d "$POSTGRES_DB" < "$DB_BACKUP"

# Konfiguration wiederherstellen
log "Stelle Konfiguration wieder her..."
rm -rf "$N8N_DIR"/*
tar -xzf "$CONFIG_BACKUP" -C "$N8N_DIR"
chown -R "$N8N_USER:$N8N_USER" "$N8N_DIR"

# Encryption Key wiederherstellen
if [[ -f "$ENCRYPTION_BACKUP" ]]; then
    log "Stelle Encryption Key wieder her..."
    mkdir -p /var/n8n
    cp "$ENCRYPTION_BACKUP" /var/n8n/encryption.key
    chmod 600 /var/n8n/encryption.key
    chmod 700 /var/n8n
else
    warning "Kein Encryption Key Backup gefunden - Key wird regeneriert"
fi

# n8n starten
log "Starte n8n Service..."
systemctl start n8n

# Status prüfen
sleep 5
if systemctl is-active --quiet n8n; then
    log "Restore erfolgreich abgeschlossen!"
    log "n8n Status: $(systemctl is-active n8n)"
else
    error "n8n konnte nicht gestartet werden. Prüfen Sie die Logs: journalctl -u n8n -f"
fi