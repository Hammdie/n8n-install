#!/bin/bash

# n8n Update Script
# Updates n8n to the latest version

set -e

# Colors
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

log "Starting n8n update..."

# Check current version
CURRENT_VERSION=$(npm list -g n8n --depth=0 2>/dev/null | grep n8n@ | cut -d@ -f2 || echo "not installed")
LATEST_VERSION=$(npm view n8n version)

log "Current version: $CURRENT_VERSION"
log "Latest version:  $LATEST_VERSION"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    log "n8n is already on the latest version!"
    exit 0
fi

# Create backup before update
log "Creating backup before update..."
$(dirname "$0")/backup-n8n.sh

# Stop n8n
log "Stopping n8n service..."
systemctl stop n8n

# Update n8n
log "Updating n8n..."
npm update -g n8n

# Start n8n
log "Starting n8n service..."
systemctl start n8n

# Check status
sleep 5
if systemctl is-active --quiet n8n; then
    NEW_VERSION=$(npm list -g n8n --depth=0 2>/dev/null | grep n8n@ | cut -d@ -f2)
    log "Update completed successfully!"
    log "New version: $NEW_VERSION"
    log "n8n status: $(systemctl is-active n8n)"
else
    error "n8n could not be started. Check logs: journalctl -u n8n -f"
fi

# Setup weekly cronjob if requested
if [[ "$1" == "--setup-cronjob" ]]; then
    log "Setting up weekly auto-update cronjob..."
    SCRIPT_PATH="$(readlink -f "$0")"
    CRON_ENTRY="0 2 * * 0 $SCRIPT_PATH --auto >> /var/log/n8n-auto-update.log 2>&1"
    
    if ! crontab -l 2>/dev/null | grep -q "$SCRIPT_PATH"; then
        (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
        log "Weekly auto-update cronjob added (Sundays at 2:00 AM)"
        log "Logs will be written to: /var/log/n8n-auto-update.log"
    else
        log "Cronjob already exists"
    fi
fi