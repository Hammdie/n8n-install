#!/bin/bash

# n8n Development Environment Setup
# Erstellt lokale Entwicklungsumgebung mit Git-Integration

set -e

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
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

# Parameter prüfen
if [ "$#" -lt 2 ]; then
    error "Verwendung: $0 <workspace-name> <environment> [git-repo-url]"
fi

WORKSPACE_NAME="$1"
ENVIRONMENT="$2"
GIT_REPO_URL="$3"

# Validiere Environment
case $ENVIRONMENT in
    development|preproduction|production)
        ;;
    *)
        error "Ungültiges Environment. Verwende: development, preproduction, production"
        ;;
esac
DEV_BASE_DIR="$HOME/n8n-development"
WORKSPACE_DIR="$DEV_BASE_DIR/$WORKSPACE_NAME"

echo ""
echo "=============================================="
echo "🚀 n8n Development Environment Setup"
echo "=============================================="
echo ""
echo "Workspace: $WORKSPACE_NAME"
echo "Directory: $WORKSPACE_DIR"
if [ -n "$GIT_REPO_URL" ]; then
    echo "Git Repository: $GIT_REPO_URL"
fi
echo ""

# Entwicklungsverzeichnis erstellen
log "Erstelle Entwicklungsverzeichnis..."
mkdir -p "$WORKSPACE_DIR"
cd "$WORKSPACE_DIR"

# Git Repository initialisieren oder klonen
if [ -n "$GIT_REPO_URL" ]; then
    log "Klone Git Repository..."
    git clone "$GIT_REPO_URL" "n8n-workflows" || error "Git Clone fehlgeschlagen"
    cd "n8n-workflows"
else
    log "Initialisiere lokales Git Repository..."
    mkdir -p "n8n-workflows"
    cd "n8n-workflows"
    git init
    
    # .gitignore erstellen
    cat > .gitignore << 'EOF'
# n8n Development
.env
node_modules/
dist/
logs/
*.log
.DS_Store
Thumbs.db

# Sensitive data
credentials/production/*
!credentials/production/.gitkeep

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Backup files
*.bak
*.backup
backup-*/
EOF

    git add .gitignore
    git commit -m "Initial commit: Add .gitignore"
fi

# Verzeichnisstruktur erstellen
log "Erstelle Projektstruktur für $ENVIRONMENT..."

# Environment-spezifische Verzeichnisse
mkdir -p workflows/{development,preproduction,production}
mkdir -p credentials/{development,preproduction,production}
mkdir -p ansible/{inventories/{development,preproduction,production},playbooks,roles}
mkdir -p scripts/{export,import,deploy}
mkdir -p docs
mkdir -p environments/$ENVIRONMENT

# Development-spezifische Dateien erstellen
cat > workflows/README.md << 'EOF'
# n8n Workflows

Dieses Verzeichnis enthält alle n8n-Workflows organisiert nach Umgebungen.

## Struktur

- `development/` - Lokale Entwicklungs-Workflows
- `staging/` - Test-Workflows für Staging-Umgebung
- `production/` - Produktive Workflows

## Workflow-Naming

Workflows sollten nach folgendem Schema benannt werden:
- `[prefix]-[function]-[version].json`
- Beispiel: `crm-lead-processing-v1.json`

## Export/Import

Verwende die Scripts in `../scripts/` für Export und Import:
```bash
# Export von lokalem n8n
../scripts/export-workflows.sh development

# Import auf Zielserver
../scripts/import-workflows.sh production target-server
```
EOF

cat > credentials/README.md << 'EOF'
# n8n Credentials

Dieses Verzeichnis enthält Credential-Templates und Konfigurationen.

## Sicherheit

⚠️ **WICHTIG**: Niemals echte Credentials in Git committen!

## Struktur

- `development/` - Lokale Dev-Credentials (Templates)
- `staging/` - Staging Credential-Templates
- `production/` - Produktive Credential-Templates

## Templates

Credential-Templates enthalten nur die Struktur ohne echte Werte:

```json
{
  "name": "api-service",
  "type": "httpBasicAuth",
  "data": {
    "user": "{{API_USER}}",
    "password": "{{API_PASSWORD}}"
  }
}
```

Echte Werte werden über Ansible Vault oder Environment Variables injiziert.
EOF

# Placeholder-Dateien erstellen
touch workflows/development/.gitkeep
touch workflows/staging/.gitkeep
touch workflows/production/.gitkeep
touch credentials/development/.gitkeep
touch credentials/staging/.gitkeep
touch credentials/production/.gitkeep

# Docker Compose für Environment
log "Erstelle Docker Compose für $ENVIRONMENT..."
cat > docker-compose.$ENVIRONMENT.yml << 'EOF'
version: '3.8'

services:
  n8n-dev:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: n8n-dev
    ports:
      - "5678:5678"
    environment:
      - DB_TYPE=postgres
      - DB_POSTGRESDB=n8n_dev
      - DB_POSTGRESUSER=n8n
      - DB_POSTGRESPASSWORD=n8n
      - DB_POSTGRESHOST=postgres-dev
      - DB_POSTGRESPORT=5432
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=admin123
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=http://localhost:5678/
      - GENERIC_TIMEZONE=Europe/Berlin
    volumes:
      - n8n_dev_data:/home/node/.n8n
      - ./workflows:/home/node/.n8n/workflows-backup
      - ./credentials:/home/node/.n8n/credentials-backup
    depends_on:
      - postgres-dev
    restart: unless-stopped

  postgres-dev:
    image: postgres:13
    container_name: postgres-dev
    environment:
      - POSTGRES_DB=n8n_dev
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=n8n
    volumes:
      - postgres_dev_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  n8n_dev_data:
  postgres_dev_data:
EOF

# Environment-Datei für $ENVIRONMENT
cat > .env.$ENVIRONMENT << EOF
# n8n $ENVIRONMENT Environment
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=$(case $ENVIRONMENT in
    development) echo "admin123" ;;
    preproduction) echo "staging-pass" ;;
    production) echo "\${VAULT_N8N_PASSWORD}" ;;
esac)
DB_POSTGRESDB=n8n_dev
DB_POSTGRESUSER=n8n
DB_POSTGRESPASSWORD=n8n

# Development Settings
N8N_LOG_LEVEL=debug
N8N_DISABLE_UI=false
N8N_DIAGNOSTICS_ENABLED=false
EOF

# Ansible Inventories erstellen
log "Erstelle Ansible Inventories..."
mkdir -p ansible/inventories/{development,staging,production}

# Development Inventory
cat > ansible/inventories/development/hosts.yml << 'EOF'
all:
  children:
    n8n_servers:
      hosts:
        local:
          ansible_host: localhost
          ansible_connection: local
          n8n_environment: development
          n8n_domain: localhost
        dev-vm:
          ansible_host: dev.internal.com
          ansible_user: odoo
          n8n_environment: development
          n8n_domain: dev.internal.com
EOF

# Pre-Production Inventory
cat > ansible/inventories/preproduction/hosts.yml << 'EOF'
all:
  children:
    n8n_servers:
      hosts:
        staging-01:
          ansible_host: staging-01.example.com
          ansible_user: odoo
          n8n_environment: preproduction
          n8n_domain: staging-01.example.com
        staging-02:
          ansible_host: staging-02.example.com
          ansible_user: odoo
          n8n_environment: preproduction
          n8n_domain: staging-02.example.com
        test-cluster:
          ansible_host: test-cluster.example.com
          ansible_user: odoo
          n8n_environment: preproduction
          n8n_domain: test-cluster.example.com
EOF

cat > ansible/inventories/production/hosts.yml << 'EOF'
all:
  children:
    n8n_servers:
      hosts:
        n8n-prod-01:
          ansible_host: prod1.example.com
          ansible_user: odoo
          n8n_environment: production
        n8n-prod-02:
          ansible_host: prod2.example.com
          ansible_user: odoo
          n8n_environment: production
EOF

# Ansible Konfiguration
cat > ansible/ansible.cfg << 'EOF'
[defaults]
host_key_checking = False
inventory = inventories/development/hosts.yml
remote_user = odoo
private_key_file = ~/.ssh/id_rsa
timeout = 30
gathering = smart
fact_caching = memory

[inventory]
enable_plugins = host_list, script, auto, yaml, ini, toml

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF

log "$ENVIRONMENT Environment erstellt!"
info "Nächste Schritte:"
echo ""
echo "1. Wechseln in Workspace:"
echo "   cd $WORKSPACE_DIR/n8n-workflows"
echo ""
echo "2. Environment starten:"
echo "   docker-compose -f docker-compose.$ENVIRONMENT.yml up -d"
echo ""
echo "3. n8n öffnen:"
echo "   http://localhost:5678"
echo ""
echo "4. Multi-Environment Manager verwenden:"
echo "   ../manage-environments.sh"
echo ""
echo "5. Server-spezifische Deployments:"
echo "   ./export-workflows.sh $ENVIRONMENT"
echo "   ./import-workflows.sh $ENVIRONMENT <server>"
echo ""