#!/bin/bash

# n8n Docker Management Script
# Management of n8n Docker Compose installation

set -e

# Farben
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Konfiguration
DOCKER_DIR="/opt/n8n"

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

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check if Docker Compose installation exists
check_docker_installation() {
    if [[ ! -f "/root/n8n-db-credentials.txt" ]]; then
        error "No n8n installation found"
    fi
    
    if ! grep -q "INSTALL_TYPE=docker" /root/n8n-db-credentials.txt; then
        error "This installation is not Docker-based"
    fi
    
    if [[ ! -d "$DOCKER_DIR" ]]; then
        error "Docker directory not found: $DOCKER_DIR"
    fi
}

# Docker Services Status
docker_status() {
    echo -e "${BLUE}═══ Docker Services Status ═══${NC}"
    cd "$DOCKER_DIR"
    
    if docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"; then
        echo ""
        echo -e "${YELLOW}Container Details:${NC}"
        docker compose ps --format "table {{.Name}}\t{{.Image}}\t{{.Status}}"
    else
        warning "Docker Services not reachable"
    fi
}

# Show Docker logs
docker_logs() {
    local service="$1"
    cd "$DOCKER_DIR"
    
    if [[ -n "$service" ]]; then
        log "Showing logs for service: $service"
        docker compose logs -f "$service"
    else
        echo "Available services:"
        docker compose config --services
        echo ""
        read -p "Select service (or Enter for all): " service
        if [[ -n "$service" ]]; then
            docker compose logs -f "$service"
        else
            docker compose logs -f
        fi
    fi
}

# Docker Services stoppen
docker_stop() {
    log "Stoppe Docker Services..."
    cd "$DOCKER_DIR"
    docker compose down
    log "Services gestoppt"
}

# Docker Services starten
docker_start() {
    log "Starte Docker Services..."
    cd "$DOCKER_DIR"
    docker compose up -d
    sleep 10
    log "Services gestartet"
    docker_status
}

# Docker Services neustarten
docker_restart() {
    log "Starte Docker Services neu..."
    cd "$DOCKER_DIR"
    docker compose restart
    sleep 10
    log "Services neugestartet"
    docker_status
}

# Docker Update
docker_update() {
    log "Aktualisiere Docker Images..."
    cd "$DOCKER_DIR"
    
    # Backup vor Update
    if [[ -f "/root/backup-n8n.sh" ]]; then
        log "Erstelle Backup vor Update..."
        /root/backup-n8n.sh
    fi
    
    # Images aktualisieren
    docker compose pull
    docker compose up -d
    
    # Alte Images aufräumen
    docker image prune -f
    
    log "Update abgeschlossen"
    docker_status
}

# Docker Cleanup
docker_cleanup() {
    log "Führe Docker Cleanup durch..."
    cd "$DOCKER_DIR"
    
    # Stoppe Services
    docker compose down
    
    # Entferne ungenutzte Images und Volumes
    docker system prune -f
    docker volume prune -f
    
    log "Cleanup abgeschlossen"
}

# Backup für Docker Installation
docker_backup() {
    log "Erstelle Docker Backup..."
    
    BACKUP_DIR="/var/backups/n8n"
    DATE=$(date +%Y%m%d_%H%M%S)
    mkdir -p "$BACKUP_DIR"
    
    cd "$DOCKER_DIR"
    
    # Docker Compose Dateien sichern
    tar -czf "$BACKUP_DIR/docker_config_$DATE.tar.gz" docker-compose.yml .env
    
    # n8n Daten aus Container exportieren
    if docker compose ps n8n | grep -q "Up"; then
        log "Exportiere n8n Daten..."
        docker compose exec -T n8n tar -czf - -C /home/node/.n8n . > "$BACKUP_DIR/n8n_data_$DATE.tar.gz"
    fi
    
    # PostgreSQL Dump
    if docker compose ps postgres | grep -q "Up"; then
        log "Erstelle PostgreSQL Dump..."
        docker compose exec -T postgres pg_dump -U n8n_user n8n_db > "$BACKUP_DIR/n8n_db_$DATE.sql"
    fi
    
    # Encryption Key
    if [[ -f "/var/n8n/encryption.key" ]]; then
        cp /var/n8n/encryption.key "$BACKUP_DIR/n8n_encryption_$DATE.key"
        chmod 600 "$BACKUP_DIR/n8n_encryption_$DATE.key"
    fi
    
    log "Backup abgeschlossen: $BACKUP_DIR"
    ls -la "$BACKUP_DIR"/*_$DATE.*
}

# Container Shell Access
docker_shell() {
    local service="${1:-n8n}"
    cd "$DOCKER_DIR"
    
    if docker compose ps "$service" | grep -q "Up"; then
        log "Öffne Shell für $service..."
        docker compose exec "$service" /bin/sh
    else
        error "Service $service ist nicht gestartet"
    fi
}

# Hilfe anzeigen
show_help() {
    echo "n8n Docker Management"
    echo ""
    echo "Verwendung: $0 [BEFEHL]"
    echo ""
    echo "Befehle:"
    echo "  status                     - Services Status anzeigen"
    echo "  start                      - Services starten"
    echo "  stop                       - Services stoppen"
    echo "  restart                    - Services neustarten"
    echo "  logs [service]             - Logs anzeigen"
    echo "  update                     - Images aktualisieren"
    echo "  backup                     - Backup erstellen"
    echo "  cleanup                    - Docker Cleanup"
    echo "  shell [service]            - Container Shell"
    echo "  help                       - Diese Hilfe anzeigen"
    echo ""
    echo "Beispiele:"
    echo "  $0 status"
    echo "  $0 logs n8n"
    echo "  $0 shell postgres"
}

# Interaktives Menü
interactive_menu() {
    while true; do
        echo ""
        echo -e "${BLUE}═══ n8n Docker Management ═══${NC}"
        echo ""
        echo "1. Status anzeigen"
        echo "2. Services starten"
        echo "3. Services stoppen"
        echo "4. Services neustarten"
        echo "5. Logs anzeigen"
        echo "6. Update durchführen"
        echo "7. Backup erstellen"
        echo "8. Container Shell öffnen"
        echo "9. Cleanup durchführen"
        echo "0. Beenden"
        echo ""
        
        read -p "Wählen Sie eine Option: " choice
        
        case $choice in
            1) docker_status ;;
            2) docker_start ;;
            3) docker_stop ;;
            4) docker_restart ;;
            5) docker_logs ;;
            6) docker_update ;;
            7) docker_backup ;;
            8) docker_shell ;;
            9) docker_cleanup ;;
            0) echo "Auf Wiedersehen!"; exit 0 ;;
            *) error "Ungültige Auswahl!" ;;
        esac
        
        read -p "Drücken Sie Enter um fortzufahren..."
    done
}

# Hauptfunktion
main() {
    # Prüfe Installation
    check_docker_installation
    
    local command="$1"
    
    case "$command" in
        "status")
            docker_status
            ;;
        "start")
            docker_start
            ;;
        "stop")
            docker_stop
            ;;
        "restart")
            docker_restart
            ;;
        "logs")
            docker_logs "$2"
            ;;
        "update")
            docker_update
            ;;
        "backup")
            docker_backup
            ;;
        "cleanup")
            docker_cleanup
            ;;
        "shell")
            docker_shell "$2"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        "")
            # Interaktives Menü wenn kein Befehl angegeben
            interactive_menu
            ;;
        *)
            error "Unbekannter Befehl: $command. Verwenden Sie '$0 help' für Hilfe."
            ;;
    esac
}

# Root-Rechte prüfen
if [[ $EUID -ne 0 ]]; then
   error "Dieses Script muss als root ausgeführt werden"
fi

# Programm starten
main "$@"