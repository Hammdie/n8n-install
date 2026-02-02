#!/bin/bash

# n8n Backup Script
# Erstellt Backups der n8n Datenbank und Konfiguration

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

# Root-Rechte prüfen
if [[ $EUID -ne 0 ]]; then
   error "Dieses Script muss als root ausgeführt werden"
fi

# Backup-Verzeichnis erstellen
mkdir -p "$BACKUP_DIR"

log "Starte n8n Backup..."

# PostgreSQL Backup
log "Erstelle Datenbank-Backup..."
sudo -u postgres pg_dump "$POSTGRES_DB" > "$BACKUP_DIR/n8n_db_$DATE.sql"

# n8n Konfiguration und Daten backup
log "Erstelle Konfiguration-Backup..."
tar -czf "$BACKUP_DIR/n8n_config_$DATE.tar.gz" -C "$N8N_DIR" .

# Nginx Konfiguration backup
log "Erstelle Nginx-Konfiguration-Backup..."
cp /etc/nginx/sites-available/n8n "$BACKUP_DIR/nginx_n8n_$DATE.conf"

# Systemd Service backup
cp /etc/systemd/system/n8n.service "$BACKUP_DIR/n8n_service_$DATE.service"

# Alte Backups löschen (älter als 30 Tage)
find "$BACKUP_DIR" -name "*.sql" -mtime +30 -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete
find "$BACKUP_DIR" -name "*.conf" -mtime +30 -delete
find "$BACKUP_DIR" -name "*.service" -mtime +30 -delete

log "Backup abgeschlossen!"
log "Backup-Dateien:"
ls -la "$BACKUP_DIR"/*_$DATE.*