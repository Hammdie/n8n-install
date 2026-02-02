#!/bin/bash

# n8n Management Hauptmenü
# Zentrales Verwaltungsmenü für alle n8n-Funktionen

set -e

# Farben
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Konfiguration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
N8N_USER="n8n"
N8N_DIR="/home/$N8N_USER/n8n"

# Hilfsfunktionen
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

# Banner anzeigen
show_banner() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    n8n Management Center                     ║"
    echo "║                     Hauptverwaltungsmenü                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# System-Status anzeigen
show_system_status() {
    echo -e "${CYAN}═══ System Status ═══${NC}"
    
    # n8n Service Status
    if systemctl is-active --quiet n8n 2>/dev/null; then
        echo -e "n8n Service: ${GREEN}●${NC} Running"
    else
        echo -e "n8n Service: ${RED}●${NC} Stopped"
    fi
    
    # nginx Status
    if systemctl is-active --quiet nginx 2>/dev/null; then
        echo -e "nginx:       ${GREEN}●${NC} Running"
    else
        echo -e "nginx:       ${RED}●${NC} Stopped"
    fi
    
    # PostgreSQL Status
    if systemctl is-active --quiet postgresql 2>/dev/null; then
        echo -e "PostgreSQL:  ${GREEN}●${NC} Running"
    else
        echo -e "PostgreSQL:  ${RED}●${NC} Stopped"
    fi
    
    # Speicher und Load
    echo -e "Load Average: ${YELLOW}$(uptime | awk -F'load average:' '{print $2}' | xargs)${NC}"
    echo -e "Freier RAM:   ${YELLOW}$(free -h | awk '/^Mem:/ {print $7}')${NC}"
    echo ""
}

# Hauptmenü anzeigen
show_main_menu() {
    show_banner
    show_system_status
    
    echo -e "${PURPLE}═══ Hauptmenü ═══${NC}"
    echo ""
    echo "  ${GREEN}1${NC}  📊  Service Management"
    echo "  ${GREEN}2${NC}  🔧  Installation & Setup"
    echo "  ${GREEN}3${NC}  🌐  Domain & Reverse Proxy"
    echo "  ${GREEN}4${NC}  💾  Backup & Restore"
    echo "  ${GREEN}5${NC}  🔄  Updates & Maintenance"
    echo "  ${GREEN}6${NC}  👤  User Management"
    echo "  ${GREEN}7${NC}  📋  Logs & Monitoring"
    echo "  ${GREEN}8${NC}  🔒  Security & SSL"
    echo "  ${GREEN}9${NC}  ⚙️   Konfiguration"
    echo "  ${GREEN}10${NC} 🗃️  Datenbank Management"
    echo "  ${GREEN}11${NC} 📈  System Information"
    echo "  ${GREEN}12${NC} 🆘  Troubleshooting"
    echo ""
    echo "  ${RED}0${NC}  🚪  Beenden"
    echo ""
}

# Service Management Menü
service_management_menu() {
    while true; do
        clear
        show_banner
        echo -e "${PURPLE}═══ Service Management ═══${NC}"
        echo ""
        echo "  ${GREEN}1${NC}  ▶️   n8n starten"
        echo "  ${GREEN}2${NC}  ⏹️   n8n stoppen"
        echo "  ${GREEN}3${NC}  🔄  n8n neustarten"
        echo "  ${GREEN}4${NC}  📊  Service Status anzeigen"
        echo "  ${GREEN}5${NC}  🔍  Live-Logs anzeigen"
        echo "  ${GREEN}6${NC}  ⚙️   Service konfigurieren"
        echo "  ${GREEN}7${NC}  🔧  nginx Management"
        echo ""
        echo "  ${RED}0${NC}  ⬅️   Zurück zum Hauptmenü"
        echo ""
        
        read -p "Wählen Sie eine Option: " choice
        
        case $choice in
            1)
                log "Starte n8n..."
                if sudo systemctl start n8n; then
                    success "n8n wurde gestartet!"
                else
                    error "Fehler beim Starten von n8n"
                fi
                read -p "Drücken Sie Enter um fortzufahren..."
                ;;
            2)
                log "Stoppe n8n..."
                if sudo systemctl stop n8n; then
                    success "n8n wurde gestoppt!"
                else
                    error "Fehler beim Stoppen von n8n"
                fi
                read -p "Drücken Sie Enter um fortzufahren..."
                ;;
            3)
                log "Starte n8n neu..."
                if sudo systemctl restart n8n; then
                    success "n8n wurde neugestartet!"
                else
                    error "Fehler beim Neustart von n8n"
                fi
                read -p "Drücken Sie Enter um fortzufahren..."
                ;;
            4)
                clear
                echo -e "${CYAN}═══ Service Status ═══${NC}"
                sudo systemctl status n8n --no-pager
                echo ""
                read -p "Drücken Sie Enter um fortzufahren..."
                ;;
            5)
                echo -e "${CYAN}Live-Logs (Ctrl+C zum Beenden)...${NC}"
                sudo journalctl -u n8n -f
                ;;
            6)
                service_configuration_menu
                ;;
            7)
                nginx_management_menu
                ;;
            0)
                break
                ;;
            *)
                error "Ungültige Auswahl!"
                sleep 2
                ;;
        esac
    done
}

# nginx Management Menü
nginx_management_menu() {
    while true; do
        clear
        show_banner
        echo -e "${PURPLE}═══ nginx Management ═══${NC}"
        echo ""
        echo "  ${GREEN}1${NC}  ▶️   nginx starten"
        echo "  ${GREEN}2${NC}  ⏹️   nginx stoppen"
        echo "  ${GREEN}3${NC}  🔄  nginx neustarten"
        echo "  ${GREEN}4${NC}  📊  nginx Status"
        echo "  ${GREEN}5${NC}  🔍  nginx Logs"
        echo "  ${GREEN}6${NC}  ✅  Konfiguration testen"
        echo "  ${GREEN}7${NC}  📋  Sites anzeigen"
        echo "  ${GREEN}8${NC}  🔧  Site aktivieren/deaktivieren"
        echo ""
        echo "  ${RED}0${NC}  ⬅️   Zurück"
        echo ""
        
        read -p "Wählen Sie eine Option: " choice
        
        case $choice in
            1)
                sudo systemctl start nginx && success "nginx gestartet!" || error "Fehler beim Starten"
                read -p "Drücken Sie Enter um fortzufahren..."
                ;;
            2)
                sudo systemctl stop nginx && success "nginx gestoppt!" || error "Fehler beim Stoppen"
                read -p "Drücken Sie Enter um fortzufahren..."
                ;;
            3)
                sudo systemctl restart nginx && success "nginx neugestartet!" || error "Fehler beim Neustart"
                read -p "Drücken Sie Enter um fortzufahren..."
                ;;
            4)
                sudo systemctl status nginx --no-pager
                read -p "Drücken Sie Enter um fortzufahren..."
                ;;
            5)
                sudo tail -f /var/log/nginx/access.log
                ;;
            6)
                if sudo nginx -t; then
                    success "nginx Konfiguration ist OK!"
                else
                    error "nginx Konfiguration fehlerhaft!"
                fi
                read -p "Drücken Sie Enter um fortzufahren..."
                ;;
            7)
                echo -e "${CYAN}Verfügbare Sites:${NC}"
                ls -la /etc/nginx/sites-available/
                echo -e "${CYAN}Aktivierte Sites:${NC}"
                ls -la /etc/nginx/sites-enabled/
                read -p "Drücken Sie Enter um fortzufahren..."
                ;;
            8)
                nginx_site_management
                ;;
            0)
                break
                ;;
            *)
                error "Ungültige Auswahl!"
                sleep 2
                ;;
        esac
    done
}

# Domain & Reverse Proxy Menü
domain_proxy_menu() {
    while true; do
        clear
        show_banner
        echo -e "${PURPLE}═══ Domain & Reverse Proxy ═══${NC}"
        echo ""
        echo "  ${GREEN}1${NC}  🆕  Neue Domain hinzufügen"
        echo "  ${GREEN}2${NC}  📋  Domains anzeigen"
        echo "  ${GREEN}3${NC}  🗑️   Domain entfernen"
        echo "  ${GREEN}4${NC}  🔧  Domain konfigurieren"
        echo "  ${GREEN}5${NC}  🔒  SSL-Zertifikat erneuern"
        echo "  ${GREEN}6${NC}  📊  Domain-Status prüfen"
        echo ""
        echo "  ${RED}0${NC}  ⬅️   Zurück zum Hauptmenü"
        echo ""
        
        read -p "Wählen Sie eine Option: " choice
        
        case $choice in
            1)
                setup_new_domain
                ;;
            2)
                show_domains
                ;;
            3)
                remove_domain
                ;;
            4)
                configure_domain
                ;;
            5)
                renew_ssl_certificates
                ;;
            6)
                check_domain_status
                ;;
            0)
                break
                ;;
            *)
                error "Ungültige Auswahl!"
                sleep 2
                ;;
        esac
    done
}

# Neue Domain einrichten
setup_new_domain() {
    clear
    echo -e "${CYAN}═══ Neue Domain hinzufügen ═══${NC}"
    echo ""
    
    read -p "Domain-Name: " domain
    read -p "E-Mail für SSL: " email
    read -p "n8n Port (Standard: 5678): " port
    port=${port:-5678}
    
    echo ""
    echo "SSL aktivieren?"
    select ssl in "Ja" "Nein"; do
        case $ssl in
            Ja)
                ssl_enabled="true"
                break
                ;;
            Nein)
                ssl_enabled="false"
                break
                ;;
        esac
    done
    
    echo ""
    echo -e "${YELLOW}Konfiguration:${NC}"
    echo "  Domain: $domain"
    echo "  E-Mail: $email"
    echo "  Port: $port"
    echo "  SSL: $ssl_enabled"
    echo ""
    
    read -p "Fortfahren? (ja/nein): " confirm
    if [[ "$confirm" == "ja" ]]; then
        if [[ -f "$SCRIPT_DIR/setup-reverse-proxy.sh" ]]; then
            sudo "$SCRIPT_DIR/setup-reverse-proxy.sh" "$domain" "$email" "$port" "$ssl_enabled"
        else
            error "setup-reverse-proxy.sh nicht gefunden!"
        fi
    fi
    
    read -p "Drücken Sie Enter um fortzufahren..."
}

# Domains anzeigen
show_domains() {
    clear
    echo -e "${CYAN}═══ Konfigurierte Domains ═══${NC}"
    echo ""
    
    if [[ -d "/etc/nginx/sites-available" ]]; then
        for site in /etc/nginx/sites-available/*; do
            if [[ -f "$site" && ! "$site" =~ default$ ]]; then
                site_name=$(basename "$site")
                if [[ -L "/etc/nginx/sites-enabled/$site_name" ]]; then
                    status="${GREEN}Aktiv${NC}"
                else
                    status="${RED}Inaktiv${NC}"
                fi
                
                # SSL-Status prüfen
                if grep -q "443 ssl" "$site" 2>/dev/null; then
                    ssl_status="${GREEN}SSL${NC}"
                else
                    ssl_status="${YELLOW}HTTP${NC}"
                fi
                
                echo -e "  ${BLUE}$site_name${NC} - $status - $ssl_status"
            fi
        done
    fi
    
    echo ""
    read -p "Drücken Sie Enter um fortzufahren..."
}

# Backup & Restore Menü
backup_restore_menu() {
    while true; do
        clear
        show_banner
        echo -e "${PURPLE}═══ Backup & Restore ═══${NC}"
        echo ""
        echo "  ${GREEN}1${NC}  💾  Backup erstellen"
        echo "  ${GREEN}2${NC}  📋  Backups anzeigen"
        echo "  ${GREEN}3${NC}  🔄  Backup wiederherstellen"
        echo "  ${GREEN}4${NC}  🗑️   Alte Backups löschen"
        echo "  ${GREEN}5${NC}  ⚙️   Automatisches Backup konfigurieren"
        echo "  ${GREEN}6${NC}  📤  Backup exportieren"
        echo ""
        echo "  ${RED}0${NC}  ⬅️   Zurück zum Hauptmenü"
        echo ""
        
        read -p "Wählen Sie eine Option: " choice
        
        case $choice in
            1)
                log "Erstelle Backup..."
                if [[ -f "$SCRIPT_DIR/backup-n8n.sh" ]]; then
                    sudo "$SCRIPT_DIR/backup-n8n.sh"
                    success "Backup erstellt!"
                else
                    error "backup-n8n.sh nicht gefunden!"
                fi
                read -p "Drücken Sie Enter um fortzufahren..."
                ;;
            2)
                echo -e "${CYAN}Verfügbare Backups:${NC}"
                if [[ -d "/var/backups/n8n" ]]; then
                    ls -la /var/backups/n8n/
                else
                    warning "Kein Backup-Verzeichnis gefunden"
                fi
                read -p "Drücken Sie Enter um fortzufahren..."
                ;;
            3)
                restore_backup
                ;;
            4)
                cleanup_old_backups
                ;;
            5)
                setup_automatic_backup
                ;;
            6)
                export_backup
                ;;
            0)
                break
                ;;
            *)
                error "Ungültige Auswahl!"
                sleep 2
                ;;
        esac
    done
}

# System Information anzeigen
show_system_info() {
    clear
    echo -e "${CYAN}═══ System Information ═══${NC}"
    echo ""
    
    echo -e "${YELLOW}n8n Version:${NC} $(npm list -g n8n --depth=0 2>/dev/null | grep n8n@ | cut -d@ -f2 || echo 'Unbekannt')"
    echo -e "${YELLOW}Node.js Version:${NC} $(node --version)"
    echo -e "${YELLOW}npm Version:${NC} $(npm --version)"
    echo -e "${YELLOW}System:${NC} $(uname -a)"
    echo -e "${YELLOW}Uptime:${NC} $(uptime -p)"
    echo -e "${YELLOW}Load Average:${NC} $(uptime | awk -F'load average:' '{print $2}')"
    
    echo ""
    echo -e "${CYAN}Speicher:${NC}"
    free -h
    
    echo ""
    echo -e "${CYAN}Festplatte:${NC}"
    df -h / /var /home 2>/dev/null | grep -v "tmpfs"
    
    echo ""
    echo -e "${CYAN}Netzwerk:${NC}"
    echo -e "${YELLOW}Offene Ports:${NC}"
    ss -tlnp | grep -E ':(80|443|5678|5432)'
    
    echo ""
    echo -e "${CYAN}Services:${NC}"
    for service in n8n nginx postgresql; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            echo -e "  $service: ${GREEN}Running${NC}"
        else
            echo -e "  $service: ${RED}Stopped${NC}"
        fi
    done
    
    echo ""
    read -p "Drücken Sie Enter um fortzufahren..."
}

# Hauptschleife
main() {
    while true; do
        show_main_menu
        read -p "Wählen Sie eine Option (0-12): " choice
        
        case $choice in
            1)
                service_management_menu
                ;;
            2)
                installation_setup_menu
                ;;
            3)
                domain_proxy_menu
                ;;
            4)
                backup_restore_menu
                ;;
            5)
                updates_maintenance_menu
                ;;
            6)
                user_management_menu
                ;;
            7)
                logs_monitoring_menu
                ;;
            8)
                security_ssl_menu
                ;;
            9)
                configuration_menu
                ;;
            10)
                database_management_menu
                ;;
            11)
                show_system_info
                ;;
            12)
                troubleshooting_menu
                ;;
            0)
                echo -e "${GREEN}Auf Wiedersehen!${NC}"
                exit 0
                ;;
            *)
                error "Ungültige Auswahl! Bitte wählen Sie 0-12."
                sleep 2
                ;;
        esac
    done
}

# Dummy-Funktionen für nicht implementierte Menüs
installation_setup_menu() {
    info "Installation & Setup Menü - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

updates_maintenance_menu() {
    info "Updates & Maintenance Menü - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

user_management_menu() {
    info "User Management Menü - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

logs_monitoring_menu() {
    info "Logs & Monitoring Menü - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

security_ssl_menu() {
    info "Security & SSL Menü - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

configuration_menu() {
    info "Configuration Menü - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

database_management_menu() {
    info "Database Management Menü - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

troubleshooting_menu() {
    info "Troubleshooting Menü - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

service_configuration_menu() {
    info "Service Configuration - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

nginx_site_management() {
    info "nginx Site Management - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

remove_domain() {
    info "Domain entfernen - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

configure_domain() {
    info "Domain konfigurieren - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

renew_ssl_certificates() {
    info "SSL-Zertifikate erneuern - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

check_domain_status() {
    info "Domain-Status prüfen - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

restore_backup() {
    info "Backup wiederherstellen - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

cleanup_old_backups() {
    info "Alte Backups löschen - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

setup_automatic_backup() {
    info "Automatisches Backup konfigurieren - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

export_backup() {
    info "Backup exportieren - In Entwicklung"
    read -p "Drücken Sie Enter um fortzufahren..."
}

# Programm starten
main