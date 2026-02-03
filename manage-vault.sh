#!/bin/bash

# Ansible Vault Management für verschiedene Umgebungen
# Sichere Verwaltung von Credentials und Secrets

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; exit 1; }
warning() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }

# Vault-Dateien pro Environment
VAULT_DIR="ansible/group_vars"
DEV_VAULT="$VAULT_DIR/development/vault.yml"
PREPROD_VAULT="$VAULT_DIR/preproduction/vault.yml"
PROD_VAULT="$VAULT_DIR/production/vault.yml"

# Funktionen
create_vault_structure() {
    log "Erstelle Vault-Struktur..."
    
    mkdir -p "$VAULT_DIR"/{development,preproduction,production}
    
    # Development Vault (unverschlüsselt für einfache Entwicklung)
    if [ ! -f "$DEV_VAULT" ]; then
        cat > "$DEV_VAULT" << 'EOF'
---
# Development Vault (unverschlüsselt)
vault_n8n_password: "dev-admin123"
vault_postgres_password: "dev-postgres123"
vault_encryption_key: "dev-encryption-key-12345"

# API Keys für Development
vault_smtp_password: "dev-smtp-pass"
vault_webhook_secret: "dev-webhook-secret"
vault_oauth_client_secret: "dev-oauth-secret"

# Database URLs
vault_database_url: "postgresql://n8n_dev:dev-postgres123@localhost:5432/n8n_dev"

# External Service Keys
vault_slack_webhook: "https://hooks.slack.com/services/dev/webhook"
vault_github_token: "dev_github_token"
vault_aws_access_key: "AKIADEV123456"
vault_aws_secret_key: "dev_aws_secret_key"
EOF
        info "Development Vault erstellt (unverschlüsselt)"
    fi
    
    # Pre-Production Vault (verschlüsselt)
    if [ ! -f "$PREPROD_VAULT" ]; then
        log "Erstelle Pre-Production Vault..."
        cat > /tmp/preprod_vault.yml << 'EOF'
---
# Pre-Production Vault (verschlüsselt)
vault_n8n_password: "staging-secure-password-123"
vault_postgres_password: "staging-db-password-456"
vault_encryption_key: "staging-encryption-key-very-secure-789"

# API Keys für Pre-Production
vault_smtp_password: "staging-smtp-secure-pass"
vault_webhook_secret: "staging-webhook-secret-key"
vault_oauth_client_secret: "staging-oauth-client-secret"

# Database URLs
vault_database_url: "postgresql://n8n_staging:staging-db-password-456@staging-db.example.com:5432/n8n_staging"

# External Service Keys (Staging)
vault_slack_webhook: "https://hooks.slack.com/services/staging/webhook"
vault_github_token: "staging_github_token_with_limited_access"
vault_aws_access_key: "AKIASTAGING789012"
vault_aws_secret_key: "staging_aws_secret_key_secure"
EOF
        
        # Vault verschlüsseln
        ansible-vault encrypt /tmp/preprod_vault.yml --output "$PREPROD_VAULT"
        rm /tmp/preprod_vault.yml
        info "Pre-Production Vault erstellt (verschlüsselt)"
    fi
    
    # Production Vault (verschlüsselt)
    if [ ! -f "$PROD_VAULT" ]; then
        log "Erstelle Production Vault..."
        cat > /tmp/prod_vault.yml << 'EOF'
---
# Production Vault (verschlüsselt)
vault_n8n_password: "PRODUCTION_SUPER_SECURE_PASSWORD_2024"
vault_postgres_password: "PRODUCTION_DB_ULTRA_SECURE_PASS"
vault_encryption_key: "production-encryption-key-ultra-secure-2024"

# API Keys für Production
vault_smtp_password: "production-smtp-enterprise-password"
vault_webhook_secret: "production-webhook-enterprise-secret"
vault_oauth_client_secret: "production-oauth-enterprise-secret"

# Database URLs
vault_database_url: "postgresql://n8n_prod:PRODUCTION_DB_ULTRA_SECURE_PASS@prod-db.example.com:5432/n8n_prod"

# External Service Keys (Production)
vault_slack_webhook: "https://hooks.slack.com/services/production/webhook"
vault_github_token: "production_github_token_full_access"
vault_aws_access_key: "AKIAPROD345678"
vault_aws_secret_key: "production_aws_secret_key_ultra_secure"

# Monitoring & Alerting
vault_datadog_api_key: "production_datadog_api_key"
vault_pagerduty_key: "production_pagerduty_integration_key"
vault_newrelic_license: "production_newrelic_license_key"
EOF
        
        # Vault verschlüsseln
        ansible-vault encrypt /tmp/prod_vault.yml --output "$PROD_VAULT"
        rm /tmp/prod_vault.yml
        info "Production Vault erstellt (verschlüsselt)"
    fi
}

edit_vault() {
    local environment="$1"
    local vault_file
    
    case "$environment" in
        "development")
            vault_file="$DEV_VAULT"
            ;;
        "preproduction")
            vault_file="$PREPROD_VAULT"
            ;;
        "production")
            vault_file="$PROD_VAULT"
            ;;
        *)
            error "Unbekanntes Environment: $environment"
            ;;
    esac
    
    if [ ! -f "$vault_file" ]; then
        error "Vault-Datei nicht gefunden: $vault_file"
    fi
    
    if [ "$environment" = "development" ]; then
        # Development Vault ist unverschlüsselt
        ${EDITOR:-nano} "$vault_file"
    else
        # Andere Vaults sind verschlüsselt
        ansible-vault edit "$vault_file"
    fi
}

view_vault() {
    local environment="$1"
    local vault_file
    
    case "$environment" in
        "development")
            vault_file="$DEV_VAULT"
            ;;
        "preproduction") 
            vault_file="$PREPROD_VAULT"
            ;;
        "production")
            vault_file="$PROD_VAULT"
            ;;
        *)
            error "Unbekanntes Environment: $environment"
            ;;
    esac
    
    if [ ! -f "$vault_file" ]; then
        error "Vault-Datei nicht gefunden: $vault_file"
    fi
    
    if [ "$environment" = "development" ]; then
        cat "$vault_file"
    else
        ansible-vault view "$vault_file"
    fi
}

encrypt_vault() {
    local environment="$1"
    
    if [ "$environment" = "development" ]; then
        warning "Development Vault wird normalerweise unverschlüsselt gelassen"
        read -p "Trotzdem verschlüsseln? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    local vault_file
    case "$environment" in
        "development") vault_file="$DEV_VAULT" ;;
        "preproduction") vault_file="$PREPROD_VAULT" ;;
        "production") vault_file="$PROD_VAULT" ;;
        *) error "Unbekanntes Environment: $environment" ;;
    esac
    
    if [ ! -f "$vault_file" ]; then
        error "Vault-Datei nicht gefunden: $vault_file"
    fi
    
    ansible-vault encrypt "$vault_file"
    log "✅ Vault für $environment verschlüsselt"
}

decrypt_vault() {
    local environment="$1"
    
    if [ "$environment" = "production" ]; then
        warning "⚠️  ACHTUNG: Production Vault wird entschlüsselt!"
        read -p "Sind Sie sicher? (yes/no): " -r
        if [[ ! $REPLY =~ ^yes$ ]]; then
            return
        fi
    fi
    
    local vault_file
    case "$environment" in
        "development") vault_file="$DEV_VAULT" ;;
        "preproduction") vault_file="$PREPROD_VAULT" ;;
        "production") vault_file="$PROD_VAULT" ;;
        *) error "Unbekanntes Environment: $environment" ;;
    esac
    
    if [ ! -f "$vault_file" ]; then
        error "Vault-Datei nicht gefunden: $vault_file"
    fi
    
    ansible-vault decrypt "$vault_file"
    log "✅ Vault für $environment entschlüsselt"
}

rekey_vault() {
    local environment="$1"
    
    local vault_file
    case "$environment" in
        "development") vault_file="$DEV_VAULT" ;;
        "preproduction") vault_file="$PREPROD_VAULT" ;;
        "production") vault_file="$PROD_VAULT" ;;
        *) error "Unbekanntes Environment: $environment" ;;
    esac
    
    if [ ! -f "$vault_file" ]; then
        error "Vault-Datei nicht gefunden: $vault_file"
    fi
    
    ansible-vault rekey "$vault_file"
    log "✅ Vault-Passwort für $environment geändert"
}

create_vault_password_file() {
    local environment="$1"
    local password_file="vault_pass_$environment.txt"
    
    if [ -f "$password_file" ]; then
        warning "Passwort-Datei existiert bereits: $password_file"
        return
    fi
    
    echo "Erstelle Passwort-Datei für $environment..."
    read -s -p "Vault-Passwort eingeben: " password
    echo ""
    read -s -p "Passwort bestätigen: " password_confirm
    echo ""
    
    if [ "$password" != "$password_confirm" ]; then
        error "Passwörter stimmen nicht überein"
    fi
    
    echo "$password" > "$password_file"
    chmod 600 "$password_file"
    
    log "✅ Passwort-Datei erstellt: $password_file"
    warning "WICHTIG: Füge $password_file zu .gitignore hinzu!"
}

show_vault_status() {
    echo ""
    echo "Vault-Status Übersicht:"
    echo "======================="
    echo ""
    
    for env in development preproduction production; do
        local vault_file
        case "$env" in
            "development") vault_file="$DEV_VAULT" ;;
            "preproduction") vault_file="$PREPROD_VAULT" ;;
            "production") vault_file="$PROD_VAULT" ;;
        esac
        
        printf "%-15s " "$env:"
        
        if [ -f "$vault_file" ]; then
            if ansible-vault view "$vault_file" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Verschlüsselt${NC}"
            else
                echo -e "${YELLOW}⚠️  Unverschlüsselt${NC}"
            fi
        else
            echo -e "${RED}❌ Nicht gefunden${NC}"
        fi
    done
    echo ""
}

# Hauptmenü
show_menu() {
    clear
    echo ""
    echo "================================================"
    echo "    🔐 Ansible Vault Manager"
    echo "================================================"
    echo ""
    echo "[1] Vault-Struktur erstellen"
    echo "[2] Vault bearbeiten"
    echo "[3] Vault anzeigen"
    echo "[4] Vault verschlüsseln"
    echo "[5] Vault entschlüsseln"
    echo "[6] Vault-Passwort ändern"
    echo "[7] Passwort-Datei erstellen"
    echo "[8] Vault-Status anzeigen"
    echo "[0] Beenden"
    echo ""
}

# Hauptlogik
if [ "$#" -eq 0 ]; then
    # Interaktiver Modus
    while true; do
        show_menu
        read -p "Ihre Wahl [0-8]: " choice
        
        case $choice in
            1)
                create_vault_structure
                read -p "Drücken Sie Enter um fortzufahren..."
                ;;
            2)
                echo ""
                echo "Environment wählen:"
                select env in development preproduction production; do
                    if [ -n "$env" ]; then
                        edit_vault "$env"
                        break
                    fi
                done
                ;;
            3)
                echo ""
                echo "Environment wählen:"
                select env in development preproduction production; do
                    if [ -n "$env" ]; then
                        view_vault "$env"
                        read -p "Drücken Sie Enter um fortzufahren..."
                        break
                    fi
                done
                ;;
            4)
                echo ""
                echo "Environment wählen:"
                select env in development preproduction production; do
                    if [ -n "$env" ]; then
                        encrypt_vault "$env"
                        break
                    fi
                done
                ;;
            5)
                echo ""
                echo "Environment wählen:"
                select env in development preproduction production; do
                    if [ -n "$env" ]; then
                        decrypt_vault "$env"
                        break
                    fi
                done
                ;;
            6)
                echo ""
                echo "Environment wählen:"
                select env in development preproduction production; do
                    if [ -n "$env" ]; then
                        rekey_vault "$env"
                        break
                    fi
                done
                ;;
            7)
                echo ""
                echo "Environment wählen:"
                select env in development preproduction production; do
                    if [ -n "$env" ]; then
                        create_vault_password_file "$env"
                        break
                    fi
                done
                ;;
            8)
                show_vault_status
                read -p "Drücken Sie Enter um fortzufahren..."
                ;;
            0)
                log "Auf Wiedersehen!"
                exit 0
                ;;
            *)
                warning "Ungültige Auswahl"
                sleep 1
                ;;
        esac
    done
else
    # Command-line Modus
    action="$1"
    environment="$2"
    
    case $action in
        "init")
            create_vault_structure
            ;;
        "edit")
            if [ -z "$environment" ]; then
                error "Environment fehlt: development, preproduction, production"
            fi
            edit_vault "$environment"
            ;;
        "view")
            if [ -z "$environment" ]; then
                error "Environment fehlt: development, preproduction, production"
            fi
            view_vault "$environment"
            ;;
        "encrypt")
            if [ -z "$environment" ]; then
                error "Environment fehlt: development, preproduction, production"
            fi
            encrypt_vault "$environment"
            ;;
        "decrypt")
            if [ -z "$environment" ]; then
                error "Environment fehlt: development, preproduction, production"
            fi
            decrypt_vault "$environment"
            ;;
        "status")
            show_vault_status
            ;;
        *)
            echo "Ansible Vault Manager"
            echo ""
            echo "Verwendung: $0 [action] [environment]"
            echo ""
            echo "Actions:"
            echo "  init                    - Vault-Struktur erstellen"
            echo "  edit <env>              - Vault bearbeiten"
            echo "  view <env>              - Vault anzeigen"
            echo "  encrypt <env>           - Vault verschlüsseln"
            echo "  decrypt <env>           - Vault entschlüsseln"
            echo "  status                  - Vault-Status anzeigen"
            echo ""
            echo "Environments: development, preproduction, production"
            echo ""
            ;;
    esac
fi