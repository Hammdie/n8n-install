#!/bin/bash

# Server-Listen Konfiguration für verschiedene n8n Umgebungen
# Zentrale Konfigurationsdatei für alle Environments

# ==============================================
# DEVELOPMENT ENVIRONMENT
# ==============================================

# Lokale Entwicklungsserver
DEVELOPMENT_SERVERS=(
    "local:localhost:5678:Native Development auf localhost"
    "dev-vm:dev.internal.com:5678:Development VM im internen Netz"
    "dev-docker:dev-docker.internal.com:5678:Docker Development Server"
)

# Development Konfiguration
DEV_CONFIG_SSH_USER="odoo"
DEV_CONFIG_SSH_KEY="~/.ssh/dev_rsa"
DEV_CONFIG_ANSIBLE_USER="odoo"
DEV_CONFIG_SUDO_REQUIRED="yes"

# ==============================================
# PRE-PRODUCTION ENVIRONMENT  
# ==============================================

# Staging und Test-Server
PREPRODUCTION_SERVERS=(
    "staging-01:staging-01.example.com:443:Primary Staging Server"
    "staging-02:staging-02.example.com:443:Secondary Staging Server"
    "test-cluster:test-cluster.example.com:443:Integration Test Cluster"
    "qa-server:qa.example.com:443:Quality Assurance Server"
    "demo-server:demo.example.com:443:Demo Environment Server"
)

# Pre-Production Konfiguration
PREPROD_CONFIG_SSH_USER="odoo"
PREPROD_CONFIG_SSH_KEY="~/.ssh/staging_rsa"
PREPROD_CONFIG_ANSIBLE_USER="odoo"
PREPROD_CONFIG_SUDO_REQUIRED="yes"
PREPROD_CONFIG_SSL_REQUIRED="yes"
PREPROD_CONFIG_BACKUP_ENABLED="yes"

# ==============================================
# PRODUCTION ENVIRONMENT
# ==============================================

# Live Production Server
PRODUCTION_SERVERS=(
    "prod-01:prod-01.example.com:443:Primary Production Server"
    "prod-02:prod-02.example.com:443:Secondary Production Server"
    "prod-03:prod-03.example.com:443:Tertiary Production Server"
    "prod-backup:backup.example.com:443:Production Backup Server"
    "prod-dr:dr.example.com:443:Disaster Recovery Server"
)

# Production Konfiguration
PROD_CONFIG_SSH_USER="odoo"
PROD_CONFIG_SSH_KEY="~/.ssh/production_rsa"
PROD_CONFIG_ANSIBLE_USER="odoo"
PROD_CONFIG_SUDO_REQUIRED="yes"
PROD_CONFIG_SSL_REQUIRED="yes"
PROD_CONFIG_BACKUP_ENABLED="yes"
PROD_CONFIG_MONITORING_ENABLED="yes"
PROD_CONFIG_SECURITY_HARDENING="yes"

# ==============================================
# FUNKTIONEN FÜR SERVER-VERWALTUNG
# ==============================================

# Funktion: Server-Liste für Environment abrufen
get_servers_for_environment() {
    local environment="$1"
    case "$environment" in
        "development")
            printf '%s\n' "${DEVELOPMENT_SERVERS[@]}"
            ;;
        "preproduction")
            printf '%s\n' "${PREPRODUCTION_SERVERS[@]}"
            ;;
        "production")
            printf '%s\n' "${PRODUCTION_SERVERS[@]}"
            ;;
        *)
            echo "Fehler: Unbekanntes Environment '$environment'"
            return 1
            ;;
    esac
}

# Funktion: Server-Details parsen
parse_server_details() {
    local server_string="$1"
    IFS=':' read -r server_name server_host server_port server_description <<< "$server_string"
    
    echo "Name: $server_name"
    echo "Host: $server_host"
    echo "Port: $server_port"
    echo "Beschreibung: $server_description"
}

# Funktion: Konfiguration für Environment abrufen
get_config_for_environment() {
    local environment="$1"
    case "$environment" in
        "development")
            echo "SSH_USER: $DEV_CONFIG_SSH_USER"
            echo "SSH_KEY: $DEV_CONFIG_SSH_KEY"
            echo "ANSIBLE_USER: $DEV_CONFIG_ANSIBLE_USER"
            echo "SUDO_REQUIRED: $DEV_CONFIG_SUDO_REQUIRED"
            ;;
        "preproduction")
            echo "SSH_USER: $PREPROD_CONFIG_SSH_USER"
            echo "SSH_KEY: $PREPROD_CONFIG_SSH_KEY"
            echo "ANSIBLE_USER: $PREPROD_CONFIG_ANSIBLE_USER"
            echo "SUDO_REQUIRED: $PREPROD_CONFIG_SUDO_REQUIRED"
            echo "SSL_REQUIRED: $PREPROD_CONFIG_SSL_REQUIRED"
            echo "BACKUP_ENABLED: $PREPROD_CONFIG_BACKUP_ENABLED"
            ;;
        "production")
            echo "SSH_USER: $PROD_CONFIG_SSH_USER"
            echo "SSH_KEY: $PROD_CONFIG_SSH_KEY"
            echo "ANSIBLE_USER: $PROD_CONFIG_ANSIBLE_USER"
            echo "SUDO_REQUIRED: $PROD_CONFIG_SUDO_REQUIRED"
            echo "SSL_REQUIRED: $PROD_CONFIG_SSL_REQUIRED"
            echo "BACKUP_ENABLED: $PROD_CONFIG_BACKUP_ENABLED"
            echo "MONITORING_ENABLED: $PROD_CONFIG_MONITORING_ENABLED"
            echo "SECURITY_HARDENING: $PROD_CONFIG_SECURITY_HARDENING"
            ;;
    esac
}

# Funktion: Server-Status prüfen
check_server_status() {
    local environment="$1"
    local server_name="$2"
    
    # Server-Details abrufen
    local servers
    IFS=$'\n' read -d '' -r -a servers < <(get_servers_for_environment "$environment")
    
    for server in "${servers[@]}"; do
        IFS=':' read -r name host port description <<< "$server"
        if [ "$name" = "$server_name" ]; then
            echo "Prüfe Server: $name ($host:$port)"
            
            # Ping-Test
            if ping -c 1 "$host" >/dev/null 2>&1; then
                echo "✅ Host erreichbar"
            else
                echo "❌ Host nicht erreichbar"
                return 1
            fi
            
            # Port-Test
            if nc -z "$host" "$port" 2>/dev/null; then
                echo "✅ Port $port offen"
            else
                echo "❌ Port $port nicht erreichbar"
                return 1
            fi
            
            # HTTP-Test (wenn Port 80/443)
            if [ "$port" = "80" ] || [ "$port" = "443" ]; then
                local protocol
                [ "$port" = "443" ] && protocol="https" || protocol="http"
                
                if curl -s --max-time 5 "$protocol://$host" >/dev/null; then
                    echo "✅ HTTP/HTTPS Service läuft"
                else
                    echo "⚠️  HTTP/HTTPS Service antwortet nicht"
                fi
            fi
            
            return 0
        fi
    done
    
    echo "❌ Server '$server_name' nicht gefunden in $environment"
    return 1
}

# Funktion: Alle Server in Environment prüfen
check_all_servers() {
    local environment="$1"
    echo "Prüfe alle Server in $environment..."
    echo ""
    
    local servers
    IFS=$'\n' read -d '' -r -a servers < <(get_servers_for_environment "$environment")
    
    for server in "${servers[@]}"; do
        IFS=':' read -r name host port description <<< "$server"
        echo "=== $name ==="
        check_server_status "$environment" "$name"
        echo ""
    done
}

# Funktion: Server-Liste anzeigen
show_servers() {
    local environment="$1"
    echo "Server in $environment Environment:"
    echo ""
    
    local servers
    IFS=$'\n' read -d '' -r -a servers < <(get_servers_for_environment "$environment")
    
    for server in "${servers[@]}"; do
        IFS=':' read -r name host port description <<< "$server"
        printf "%-15s %-25s %-5s %s\n" "$name" "$host" "$port" "$description"
    done
}

# ==============================================
# HAUPTPROGRAMM (falls direkt aufgerufen)
# ==============================================

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    case "${1:-}" in
        "list")
            environment="${2:-development}"
            show_servers "$environment"
            ;;
        "check")
            environment="${2:-development}"
            server_name="${3:-}"
            if [ -n "$server_name" ]; then
                check_server_status "$environment" "$server_name"
            else
                check_all_servers "$environment"
            fi
            ;;
        "config")
            environment="${2:-development}"
            get_config_for_environment "$environment"
            ;;
        *)
            echo "Server-Listen Konfiguration für n8n"
            echo ""
            echo "Verwendung:"
            echo "  $0 list [environment]           - Server-Liste anzeigen"
            echo "  $0 check [environment] [server] - Server-Status prüfen"
            echo "  $0 config [environment]         - Konfiguration anzeigen"
            echo ""
            echo "Environments: development, preproduction, production"
            echo ""
            echo "Beispiele:"
            echo "  $0 list production"
            echo "  $0 check development local"
            echo "  $0 check production"
            echo ""
            ;;
    esac
fi