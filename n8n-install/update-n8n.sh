#!/bin/bash

# n8n Update Script
# Aktualisiert n8n auf die neueste Version

set -e

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

# Root-Rechte prüfen
if [[ $EUID -ne 0 ]]; then
   error "Dieses Script muss als root ausgeführt werden"
fi

log "Starte n8n Update..."

# Aktuelle Version prüfen
CURRENT_VERSION=$(npm list -g n8n --depth=0 2>/dev/null | grep n8n@ | cut -d@ -f2 || echo "nicht installiert")
LATEST_VERSION=$(npm view n8n version)

log "Aktuelle Version: $CURRENT_VERSION"
log "Neueste Version:  $LATEST_VERSION"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    log "n8n ist bereits auf der neuesten Version!"
    exit 0
fi

# Backup vor Update erstellen
log "Erstelle Backup vor Update..."
/root/backup-n8n.sh

# n8n stoppen
log "Stoppe n8n Service..."
systemctl stop n8n

# n8n aktualisieren
log "Aktualisiere n8n..."
npm update -g n8n

# n8n starten
log "Starte n8n Service..."
systemctl start n8n

# Status prüfen
sleep 5
if systemctl is-active --quiet n8n; then
    NEW_VERSION=$(npm list -g n8n --depth=0 2>/dev/null | grep n8n@ | cut -d@ -f2)
    log "Update erfolgreich abgeschlossen!"
    log "Neue Version: $NEW_VERSION"
    log "n8n Status: $(systemctl is-active n8n)"
else
    error "n8n konnte nicht gestartet werden. Prüfen Sie die Logs: journalctl -u n8n -f"
fi