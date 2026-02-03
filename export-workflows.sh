#!/bin/bash

# n8n Workflow Export Script
# Exportiert Workflows und Credentials aus n8n für Git-Versionierung

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

# Parameter prüfen
if [ "$#" -lt 1 ]; then
    error "Verwendung: $0 <environment> [n8n-host] [options]"
fi

ENVIRONMENT="$1"
N8N_HOST="${2:-localhost:5678}"
N8N_USER="${N8N_USER:-admin}"
N8N_PASSWORD="${N8N_PASSWORD:-admin123}"

# Optionen
EXPORT_WORKFLOWS=true
EXPORT_CREDENTIALS=true
CREATE_BACKUP=false

# Optionen parsen
for arg in "${@:3}"; do
    case $arg in
        --workflows-only)
            EXPORT_CREDENTIALS=false
            ;;
        --credentials-only)
            EXPORT_WORKFLOWS=false
            ;;
        --backup)
            CREATE_BACKUP=true
            ;;
        --help)
            echo "n8n Export Script"
            echo ""
            echo "Verwendung: $0 <environment> [host] [optionen]"
            echo ""
            echo "Umgebungen: development, staging, production"
            echo "Host:       Standard ist localhost:5678"
            echo ""
            echo "Optionen:"
            echo "  --workflows-only    Nur Workflows exportieren"
            echo "  --credentials-only  Nur Credentials exportieren"
            echo "  --backup           Backup vor Export erstellen"
            echo ""
            echo "Environment Variables:"
            echo "  N8N_USER           n8n Benutzername (Standard: admin)"
            echo "  N8N_PASSWORD       n8n Passwort (Standard: admin123)"
            echo ""
            exit 0
            ;;
    esac
done

echo ""
echo "=============================================="
echo "📦 n8n Export für $ENVIRONMENT"
echo "=============================================="
echo ""
echo "Host: $N8N_HOST"
echo "Workflows: $([ "$EXPORT_WORKFLOWS" = true ] && echo "✅" || echo "❌")"
echo "Credentials: $([ "$EXPORT_CREDENTIALS" = true ] && echo "✅" || echo "❌")"
echo ""

# Verzeichnisse prüfen
WORKFLOWS_DIR="workflows/$ENVIRONMENT"
CREDENTIALS_DIR="credentials/$ENVIRONMENT"

if [ ! -d "$WORKFLOWS_DIR" ]; then
    error "Workflows-Verzeichnis nicht gefunden: $WORKFLOWS_DIR"
fi

if [ ! -d "$CREDENTIALS_DIR" ]; then
    error "Credentials-Verzeichnis nicht gefunden: $CREDENTIALS_DIR"
fi

# n8n CLI prüfen
if ! command -v n8n &> /dev/null; then
    warning "n8n CLI nicht gefunden. Installiere..."
    npm install -g n8n
fi

# Backup erstellen falls gewünscht
if [ "$CREATE_BACKUP" = true ]; then
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_DIR="backup-$ENVIRONMENT-$TIMESTAMP"
    
    log "Erstelle Backup in $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "$WORKFLOWS_DIR" ]; then
        cp -r "$WORKFLOWS_DIR" "$BACKUP_DIR/"
    fi
    
    if [ -d "$CREDENTIALS_DIR" ]; then
        cp -r "$CREDENTIALS_DIR" "$BACKUP_DIR/"
    fi
fi

# n8n Verbindung testen
log "Teste n8n Verbindung..."
if ! curl -s -f "http://$N8N_HOST" >/dev/null; then
    error "Keine Verbindung zu n8n: http://$N8N_HOST"
fi

# Workflows exportieren
if [ "$EXPORT_WORKFLOWS" = true ]; then
    log "Exportiere Workflows..."
    
    # Temporäres Verzeichnis für Export
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Workflows exportieren
    n8n export:workflow \
        --all \
        --output=workflows-export \
        --baseUrl="http://$N8N_HOST" \
        --user="$N8N_USER" \
        --password="$N8N_PASSWORD" || error "Workflow Export fehlgeschlagen"
    
    # Workflows nach Git kopieren
    if [ -d "workflows-export" ]; then
        cd "$OLDPWD"
        rm -rf "$WORKFLOWS_DIR"/*.json 2>/dev/null || true
        
        for workflow in "$TEMP_DIR/workflows-export"/*.json; do
            if [ -f "$workflow" ]; then
                # Workflow-Name aus Datei extrahieren
                WORKFLOW_NAME=$(jq -r '.name // "unnamed"' "$workflow" | sed 's/[^a-zA-Z0-9-]/_/g')
                WORKFLOW_ID=$(jq -r '.id // "no-id"' "$workflow")
                
                # Dateiname generieren
                FILENAME="${WORKFLOW_NAME}-${WORKFLOW_ID}.json"
                
                # Workflow-Daten bereinigen (sensitive Daten entfernen)
                jq 'del(.id) | del(.createdAt) | del(.updatedAt)' "$workflow" > "$WORKFLOWS_DIR/$FILENAME"
                
                info "Workflow exportiert: $FILENAME"
            fi
        done
    fi
    
    rm -rf "$TEMP_DIR"
fi

# Credentials exportieren (nur Templates)
if [ "$EXPORT_CREDENTIALS" = true ]; then
    log "Exportiere Credential-Templates..."
    
    # Temporäres Verzeichnis für Credential-Export
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Credentials exportieren (ohne sensitive Daten)
    n8n export:credentials \
        --all \
        --output=credentials-export \
        --baseUrl="http://$N8N_HOST" \
        --user="$N8N_USER" \
        --password="$N8N_PASSWORD" || error "Credentials Export fehlgeschlagen"
    
    if [ -d "credentials-export" ]; then
        cd "$OLDPWD"
        rm -rf "$CREDENTIALS_DIR"/*.json 2>/dev/null || true
        
        for credential in "$TEMP_DIR/credentials-export"/*.json; do
            if [ -f "$credential" ]; then
                # Credential-Name extrahieren
                CRED_NAME=$(jq -r '.name // "unnamed"' "$credential" | sed 's/[^a-zA-Z0-9-]/_/g')
                CRED_TYPE=$(jq -r '.type // "unknown"' "$credential")
                
                # Template erstellen (ohne echte Daten)
                TEMPLATE_FILE="$CREDENTIALS_DIR/${CRED_NAME}-${CRED_TYPE}-template.json"
                
                # Credential-Template erstellen
                cat > "$TEMPLATE_FILE" << EOF
{
  "name": "$(jq -r '.name' "$credential")",
  "type": "$(jq -r '.type' "$credential")",
  "data": {
    "_comment": "Diese Datei enthält nur die Struktur. Echte Werte über Ansible Vault setzen.",
    "_template": true
  }
}
EOF
                
                info "Credential-Template exportiert: ${CRED_NAME}-${CRED_TYPE}-template.json"
            fi
        done
    fi
    
    rm -rf "$TEMP_DIR"
fi

# Git-Commit erstellen
log "Erstelle Git-Commit..."
git add .

if git diff --staged --quiet; then
    warning "Keine Änderungen zu committen"
else
    COMMIT_MSG="Export $ENVIRONMENT workflows/credentials $(date +'%Y-%m-%d %H:%M:%S')"
    git commit -m "$COMMIT_MSG"
    info "Git-Commit erstellt: $COMMIT_MSG"
fi

log "✅ Export abgeschlossen!"

# Zusammenfassung
echo ""
echo "========== Export Zusammenfassung =========="
if [ "$EXPORT_WORKFLOWS" = true ]; then
    WORKFLOW_COUNT=$(find "$WORKFLOWS_DIR" -name "*.json" | wc -l)
    echo "Workflows exportiert: $WORKFLOW_COUNT"
fi

if [ "$EXPORT_CREDENTIALS" = true ]; then
    CRED_COUNT=$(find "$CREDENTIALS_DIR" -name "*template.json" | wc -l)
    echo "Credential-Templates: $CRED_COUNT"
fi

echo "Git Status: $(git status --porcelain | wc -l) Dateien geändert"
echo ""

# Nächste Schritte
info "Nächste Schritte:"
echo "1. Änderungen prüfen: git status"
echo "2. Push zu Remote: git push"
echo "3. Deployment mit Ansible: ansible-playbook ansible/playbooks/deploy-workflows.yml"