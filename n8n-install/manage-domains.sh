#!/bin/bash

# Domain-Verwaltungs-Skript für n8n
# Ermöglicht das Hinzufügen, Entfernen und Verwalten von Domains

set -e

# Farben
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Root-Rechte prüfen
check_root() {
    if [[ $EUID -ne 0 ]]; then
       error "Dieses Script muss als root ausgeführt werden"
    fi
}

# Alle konfigurierten Domains anzeigen
list_domains() {
    echo -e "${BLUE}═══ Konfigurierte n8n Domains ═══${NC}"
    echo ""
    
    if [[ ! -d "/etc/nginx/sites-available" ]]; then
        warning "Nginx sites-available Verzeichnis nicht gefunden"
        return
    fi
    
    local found_domains=false
    
    printf "%-30s %-10s %-8s %-15s\n" "Domain" "Status" "SSL" "Port"
    printf "%-30s %-10s %-8s %-15s\n" "$(printf '%*s' 30 | tr ' ' '-')" "$(printf '%*s' 10 | tr ' ' '-')" "$(printf '%*s' 8 | tr ' ' '-')" "$(printf '%*s' 15 | tr ' ' '-')"
    
    for site_file in /etc/nginx/sites-available/*; do
        if [[ -f "$site_file" && ! "$site_file" =~ default$ ]]; then
            local site_name=$(basename "$site_file")
            found_domains=true
            
            # Status prüfen
            if [[ -L "/etc/nginx/sites-enabled/$site_name" ]]; then
                local status="${GREEN}Aktiv${NC}"
            else
                local status="${RED}Inaktiv${NC}"
            fi
            
            # SSL-Status prüfen
            if grep -q "443 ssl" "$site_file" 2>/dev/null; then
                local ssl_status="${GREEN}SSL${NC}"
            else
                local ssl_status="${YELLOW}HTTP${NC}"
            fi
            
            # Port extrahieren
            local port=$(grep -o "localhost:[0-9]*" "$site_file" | head -1 | cut -d: -f2 || echo "5678")
            
            printf "%-30s %-18s %-16s %-15s\n" "$site_name" "$status" "$ssl_status" "$port"
        fi
    done
    
    if [[ "$found_domains" == "false" ]]; then
        warning "Keine n8n Domains konfiguriert"
    fi
    echo ""
}

# Domain hinzufügen
add_domain() {
    local domain="$1"
    local email="$2"
    local port="$3"
    local ssl="$4"
    
    if [[ -z "$domain" ]]; then
        read -p "Domain-Name eingeben: " domain
    fi
    
    if [[ -z "$email" ]]; then
        read -p "E-Mail für SSL-Zertifikat: " email
    fi
    
    if [[ -z "$port" ]]; then
        read -p "n8n Port (Standard: 5678): " port
        port=${port:-5678}
    fi
    
    if [[ -z "$ssl" ]]; then
        echo "SSL aktivieren?"
        select ssl_choice in "Ja" "Nein"; do
            case $ssl_choice in
                Ja) ssl="true"; break;;
                Nein) ssl="false"; break;;
            esac
        done
    fi
    
    log "Füge Domain hinzu: $domain"
    
    # Prüfe ob setup-reverse-proxy.sh existiert
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local proxy_script="$script_dir/setup-reverse-proxy.sh"
    
    if [[ ! -f "$proxy_script" ]]; then
        error "setup-reverse-proxy.sh nicht gefunden in $script_dir"
    fi
    
    # Führe Setup-Skript aus
    "$proxy_script" "$domain" "$email" "$port" "$ssl"
}

# Domain entfernen
remove_domain() {
    local domain="$1"
    
    if [[ -z "$domain" ]]; then
        list_domains
        read -p "Domain zum Entfernen eingeben: " domain
    fi
    
    if [[ -z "$domain" ]]; then
        error "Keine Domain angegeben"
    fi
    
    local site_file="/etc/nginx/sites-available/$domain"
    local enabled_link="/etc/nginx/sites-enabled/$domain"
    
    if [[ ! -f "$site_file" ]]; then
        error "Domain '$domain' nicht gefunden"
    fi
    
    echo -e "${YELLOW}WARNUNG: Dies wird die Domain '$domain' vollständig entfernen!${NC}"
    echo "- nginx Konfiguration"
    echo "- SSL-Zertifikate (falls vorhanden)"
    echo ""
    read -p "Fortfahren? (ja/nein): " confirm
    
    if [[ "$confirm" != "ja" ]]; then
        info "Abgebrochen"
        return
    fi
    
    log "Entferne Domain: $domain"
    
    # Site deaktivieren
    if [[ -L "$enabled_link" ]]; then
        log "Deaktiviere nginx Site..."
        rm -f "$enabled_link"
    fi
    
    # SSL-Zertifikat entfernen
    if command -v certbot &> /dev/null; then
        log "Entferne SSL-Zertifikat..."
        certbot delete --cert-name "$domain" --non-interactive 2>/dev/null || warning "SSL-Zertifikat konnte nicht entfernt werden"
    fi
    
    # nginx Konfiguration entfernen
    log "Entferne nginx Konfiguration..."
    rm -f "$site_file"
    
    # Info-Datei entfernen
    rm -f "/etc/nginx/conf.d/${domain}-info.conf"
    
    # nginx Konfiguration testen und neuladen
    log "Teste und lade nginx Konfiguration neu..."
    if nginx -t; then
        systemctl reload nginx
        log "Domain '$domain' erfolgreich entfernt!"
    else
        error "nginx Konfiguration fehlerhaft nach Entfernung"
    fi
}

# Domain aktivieren/deaktivieren
toggle_domain() {
    local domain="$1"
    
    if [[ -z "$domain" ]]; then
        list_domains
        read -p "Domain eingeben: " domain
    fi
    
    local site_file="/etc/nginx/sites-available/$domain"
    local enabled_link="/etc/nginx/sites-enabled/$domain"
    
    if [[ ! -f "$site_file" ]]; then
        error "Domain '$domain' nicht gefunden"
    fi
    
    if [[ -L "$enabled_link" ]]; then
        log "Deaktiviere Domain: $domain"
        rm -f "$enabled_link"
        action="deaktiviert"
    else
        log "Aktiviere Domain: $domain"
        ln -sf "$site_file" "$enabled_link"
        action="aktiviert"
    fi
    
    # nginx Konfiguration testen und neuladen
    if nginx -t; then
        systemctl reload nginx
        log "Domain '$domain' erfolgreich $action!"
    else
        error "nginx Konfiguration fehlerhaft"
    fi
}

# SSL-Status für Domain prüfen
check_ssl_status() {
    local domain="$1"
    
    if [[ -z "$domain" ]]; then
        list_domains
        read -p "Domain eingeben: " domain
    fi
    
    echo -e "${BLUE}═══ SSL-Status für $domain ═══${NC}"
    
    # Zertifikat-Info von certbot
    if command -v certbot &> /dev/null; then
        certbot certificates -d "$domain" 2>/dev/null || warning "Kein certbot-Zertifikat gefunden"
    fi
    
    # Online SSL-Check
    if command -v openssl &> /dev/null; then
        echo ""
        info "Online SSL-Verbindungstest..."
        timeout 10 openssl s_client -connect "$domain:443" -servername "$domain" < /dev/null 2>/dev/null | openssl x509 -noout -dates 2>/dev/null || warning "SSL-Verbindung fehlgeschlagen"
    fi
}

# Domain-Status prüfen
check_domain_status() {
    local domain="$1"
    
    if [[ -z "$domain" ]]; then
        list_domains
        read -p "Domain eingeben: " domain
    fi
    
    echo -e "${BLUE}═══ Status für $domain ═══${NC}"
    echo ""
    
    # DNS-Auflösung prüfen
    info "DNS-Auflösung:"
    dig +short "$domain" A || warning "DNS-Auflösung fehlgeschlagen"
    
    # HTTP-Status prüfen
    echo ""
    info "HTTP-Erreichbarkeit:"
    if command -v curl &> /dev/null; then
        local http_status=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "http://$domain" 2>/dev/null || echo "ERROR")
        echo "HTTP: $http_status"
        
        local https_status=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "https://$domain" 2>/dev/null || echo "ERROR")
        echo "HTTPS: $https_status"
    fi
    
    # nginx-Konfiguration prüfen
    echo ""
    info "nginx-Konfiguration:"
    local site_file="/etc/nginx/sites-available/$domain"
    if [[ -f "$site_file" ]]; then
        echo "✓ Konfiguration vorhanden"
        if [[ -L "/etc/nginx/sites-enabled/$domain" ]]; then
            echo "✓ Site aktiviert"
        else
            echo "✗ Site nicht aktiviert"
        fi
    else
        echo "✗ Konfiguration nicht gefunden"
    fi
}

# SSL-Zertifikat erneuern
renew_ssl() {
    local domain="$1"
    
    if [[ -z "$domain" ]]; then
        if command -v certbot &> /dev/null; then
            log "Erneuere alle SSL-Zertifikate..."
            certbot renew
        else
            error "certbot nicht installiert"
        fi
    else
        log "Erneuere SSL-Zertifikat für: $domain"
        certbot renew --cert-name "$domain"
    fi
}

# Hilfe anzeigen
show_help() {
    echo "n8n Domain-Verwaltung"
    echo ""
    echo "Verwendung: $0 [BEFEHL] [OPTIONEN]"
    echo ""
    echo "Befehle:"
    echo "  list                           - Alle Domains anzeigen"
    echo "  add <domain> <email> [port] [ssl] - Domain hinzufügen"
    echo "  remove <domain>                - Domain entfernen"
    echo "  toggle <domain>                - Domain aktivieren/deaktivieren"
    echo "  status <domain>                - Domain-Status prüfen"
    echo "  ssl-status <domain>            - SSL-Status prüfen"
    echo "  ssl-renew [domain]             - SSL-Zertifikat erneuern"
    echo "  help                           - Diese Hilfe anzeigen"
    echo ""
    echo "Beispiele:"
    echo "  $0 list"
    echo "  $0 add staging.example.com admin@example.com"
    echo "  $0 add dev.example.com admin@example.com 5679 false"
    echo "  $0 remove staging.example.com"
    echo "  $0 status example.com"
}

# Hauptfunktion
main() {
    local command="$1"
    shift 2>/dev/null || true
    
    case "$command" in
        "list"|"ls")
            list_domains
            ;;
        "add"|"create")
            check_root
            add_domain "$@"
            ;;
        "remove"|"delete"|"rm")
            check_root
            remove_domain "$1"
            ;;
        "toggle"|"switch")
            check_root
            toggle_domain "$1"
            ;;
        "status")
            check_domain_status "$1"
            ;;
        "ssl-status")
            check_ssl_status "$1"
            ;;
        "ssl-renew"|"renew")
            check_root
            renew_ssl "$1"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        "")
            # Interaktives Menü wenn kein Befehl angegeben
            while true; do
                echo ""
                echo -e "${BLUE}═══ n8n Domain-Verwaltung ═══${NC}"
                echo ""
                echo "1. Domains anzeigen"
                echo "2. Domain hinzufügen"
                echo "3. Domain entfernen"
                echo "4. Domain aktivieren/deaktivieren"
                echo "5. Domain-Status prüfen"
                echo "6. SSL-Status prüfen"
                echo "7. SSL-Zertifikat erneuern"
                echo "0. Beenden"
                echo ""
                
                read -p "Wählen Sie eine Option: " choice
                
                case $choice in
                    1) list_domains ;;
                    2) check_root; add_domain ;;
                    3) check_root; remove_domain ;;
                    4) check_root; toggle_domain ;;
                    5) check_domain_status ;;
                    6) check_ssl_status ;;
                    7) check_root; renew_ssl ;;
                    0) echo "Auf Wiedersehen!"; exit 0 ;;
                    *) error "Ungültige Auswahl!" ;;
                esac
            done
            ;;
        *)
            error "Unbekannter Befehl: $command. Verwenden Sie '$0 help' für Hilfe."
            ;;
    esac
}

# Programm starten
main "$@"