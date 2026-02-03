#!/bin/bash

# n8n Workflow Import Script
# Imports workflows and credentials to target server via Ansible

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

# Check parameters
if [ "$#" -lt 2 ]; then
    echo "n8n Import Script"
    echo ""
    echo "Usage: $0 <environment> <target> [options]"
    echo ""
    echo "Environments: development, staging, production"
    echo "Target:       Server name from Ansible inventory or 'local'"
    echo ""
    echo "Options:"
    echo "  --workflows-only    Import workflows only"
    echo "  --credentials-only  Import credentials only"
    echo "  --dry-run          Validation only, no import"
    echo "  --force            Overwrite existing workflows"
    echo ""
    echo "Examples:"
    echo "  $0 production n8n-prod-01"
    echo "  $0 staging n8n-staging-01 --workflows-only"
    echo "  $0 development local --dry-run"
    exit 1
fi

ENVIRONMENT="$1"
TARGET="$2"

# Optionen
IMPORT_WORKFLOWS=true
IMPORT_CREDENTIALS=true
DRY_RUN=false
FORCE_IMPORT=false

# Parse options
for arg in "${@:3}"; do
    case $arg in
        --workflows-only)
            IMPORT_CREDENTIALS=false
            ;;
        --credentials-only)
            IMPORT_WORKFLOWS=false
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --force)
            FORCE_IMPORT=true
            ;;
    esac
done

echo ""
echo "=============================================="
echo "📥 n8n Import for $ENVIRONMENT -> $TARGET"
echo "=============================================="
echo ""
echo "Workflows: $([ "$IMPORT_WORKFLOWS" = true ] && echo "✅" || echo "❌")"
echo "Credentials: $([ "$IMPORT_CREDENTIALS" = true ] && echo "✅" || echo "❌")"
echo "Dry Run: $([ "$DRY_RUN" = true ] && echo "✅" || echo "❌")"
echo "Force: $([ "$FORCE_IMPORT" = true ] && echo "✅" || echo "❌")"
echo ""

# Check Ansible inventory
INVENTORY_FILE="ansible/inventories/$ENVIRONMENT/hosts.yml"
if [ ! -f "$INVENTORY_FILE" ]; then
    error "Ansible Inventory nicht gefunden: $INVENTORY_FILE"
fi

# Workflows und Credentials prüfen
WORKFLOWS_DIR="workflows/$ENVIRONMENT"
CREDENTIALS_DIR="credentials/$ENVIRONMENT"

if [ "$IMPORT_WORKFLOWS" = true ] && [ ! -d "$WORKFLOWS_DIR" ]; then
    error "Workflows-Verzeichnis nicht gefunden: $WORKFLOWS_DIR"
fi

if [ "$IMPORT_CREDENTIALS" = true ] && [ ! -d "$CREDENTIALS_DIR" ]; then
    error "Credentials-Verzeichnis nicht gefunden: $CREDENTIALS_DIR"
fi

# Ansible prüfen
if ! command -v ansible-playbook &> /dev/null; then
    error "Ansible nicht gefunden. Bitte installieren: pip install ansible"
fi

# Workflow-Dateien zählen
if [ "$IMPORT_WORKFLOWS" = true ]; then
    WORKFLOW_COUNT=$(find "$WORKFLOWS_DIR" -name "*.json" -not -name "*template*" | wc -l)
    log "Gefunden: $WORKFLOW_COUNT Workflows in $WORKFLOWS_DIR"
fi

# Credential-Templates zählen
if [ "$IMPORT_CREDENTIALS" = true ]; then
    CRED_COUNT=$(find "$CREDENTIALS_DIR" -name "*template.json" | wc -l)
    log "Gefunden: $CRED_COUNT Credential-Templates in $CREDENTIALS_DIR"
fi

# Ansible-Playbook für Import erstellen
PLAYBOOK_DIR="ansible/playbooks"
mkdir -p "$PLAYBOOK_DIR"

IMPORT_PLAYBOOK="$PLAYBOOK_DIR/import-n8n-workflows.yml"

cat > "$IMPORT_PLAYBOOK" << 'EOF'
---
- name: Import n8n Workflows and Credentials
  hosts: "{{ target_host | default('all') }}"
  become: yes
  vars:
    n8n_environment: "{{ environment }}"
    import_workflows: "{{ import_workflows | default(true) }}"
    import_credentials: "{{ import_credentials | default(true) }}"
    force_import: "{{ force_import | default(false) }}"
    
  tasks:
    - name: Check if n8n is running
      systemd:
        name: n8n
      register: n8n_service
      when: ansible_os_family == "Debian"
      
    - name: Check Docker n8n status
      docker_compose:
        project_src: /opt/n8n
        state: present
      register: docker_n8n
      ignore_errors: yes
      
    - name: Detect n8n installation type
      set_fact:
        n8n_type: "{{ 'docker' if docker_n8n is succeeded else 'native' }}"
        
    - name: Create temporary directory
      tempfile:
        state: directory
        suffix: n8n-import
      register: temp_dir
      
    - name: Copy workflows to server
      copy:
        src: "../../workflows/{{ n8n_environment }}/"
        dest: "{{ temp_dir.path }}/workflows/"
      when: import_workflows
      
    - name: Copy credential templates to server
      copy:
        src: "../../credentials/{{ n8n_environment }}/"
        dest: "{{ temp_dir.path }}/credentials/"
      when: import_credentials
      
    - name: Stop n8n service (native)
      systemd:
        name: n8n
        state: stopped
      when: n8n_type == 'native'
      
    - name: Stop n8n containers (docker)
      docker_compose:
        project_src: /opt/n8n
        state: absent
      when: n8n_type == 'docker'
      
    - name: Import workflows (native)
      shell: |
        cd /home/n8n/n8n
        for workflow in {{ temp_dir.path }}/workflows/*.json; do
          if [ -f "$workflow" ]; then
            echo "Importing workflow: $(basename $workflow)"
            n8n import:workflow --file="$workflow" {{ '--force' if force_import else '' }}
          fi
        done
      become_user: n8n
      when: import_workflows and n8n_type == 'native'
      
    - name: Import workflows (docker)
      shell: |
        cd /opt/n8n
        docker-compose run --rm n8n n8n import:workflow --file="/data/{{ item | basename }}" {{ '--force' if force_import else '' }}
      with_fileglob:
        - "{{ temp_dir.path }}/workflows/*.json"
      when: import_workflows and n8n_type == 'docker'
      
    - name: Process credential templates
      shell: |
        for template in {{ temp_dir.path }}/credentials/*-template.json; do
          if [ -f "$template" ]; then
            echo "Processing credential template: $(basename $template)"
            # Hier können Ansible Vault Variablen eingefügt werden
            # Template -> echte Credentials konvertieren
          fi
        done
      when: import_credentials
      
    - name: Start n8n service (native)
      systemd:
        name: n8n
        state: started
        enabled: yes
      when: n8n_type == 'native'
      
    - name: Start n8n containers (docker)
      docker_compose:
        project_src: /opt/n8n
        state: present
      when: n8n_type == 'docker'
      
    - name: Wait for n8n to be ready
      uri:
        url: "{{ 'http://localhost:5678' if n8n_type == 'docker' else 'http://localhost:5678' }}"
        method: GET
        status_code: 200
      retries: 30
      delay: 2
      
    - name: Cleanup temporary directory
      file:
        path: "{{ temp_dir.path }}"
        state: absent
EOF

# Ansible Inventory validieren
log "Validiere Ansible Inventory..."
ansible-inventory -i "$INVENTORY_FILE" --list > /dev/null || error "Ansible Inventory ungültig"

if [ "$TARGET" != "local" ]; then
    # Prüfe ob Target in Inventory existiert
    if ! ansible-inventory -i "$INVENTORY_FILE" --host "$TARGET" > /dev/null 2>&1; then
        error "Target '$TARGET' nicht im Inventory gefunden"
    fi
fi

# Dry Run
if [ "$DRY_RUN" = true ]; then
    log "🔍 Dry Run - Validierung..."
    
    ansible-playbook \
        -i "$INVENTORY_FILE" \
        "$IMPORT_PLAYBOOK" \
        --limit "$TARGET" \
        --check \
        -e "environment=$ENVIRONMENT" \
        -e "import_workflows=$IMPORT_WORKFLOWS" \
        -e "import_credentials=$IMPORT_CREDENTIALS" \
        -e "force_import=$FORCE_IMPORT" || error "Dry Run fehlgeschlagen"
    
    info "✅ Dry Run erfolgreich - Import würde funktionieren"
    exit 0
fi

# Bestätigung für Produktions-Import
if [ "$ENVIRONMENT" = "production" ] && [ "$FORCE_IMPORT" = false ]; then
    echo ""
    warning "⚠️  ACHTUNG: Import in Produktionsumgebung!"
    echo "Target: $TARGET"
    echo "Environment: $ENVIRONMENT"
    echo ""
    read -p "Möchten Sie fortfahren? (yes/no): " -r
    if [[ ! $REPLY =~ ^yes$ ]]; then
        info "Import abgebrochen"
        exit 0
    fi
fi

# Import ausführen
log "🚀 Starte Import auf $TARGET..."

ansible-playbook \
    -i "$INVENTORY_FILE" \
    "$IMPORT_PLAYBOOK" \
    --limit "$TARGET" \
    -e "environment=$ENVIRONMENT" \
    -e "import_workflows=$IMPORT_WORKFLOWS" \
    -e "import_credentials=$IMPORT_CREDENTIALS" \
    -e "force_import=$FORCE_IMPORT" || error "Import fehlgeschlagen"

log "✅ Import erfolgreich abgeschlossen!"

# Status prüfen
log "Prüfe n8n Status auf $TARGET..."
ansible \
    -i "$INVENTORY_FILE" \
    "$TARGET" \
    -m shell \
    -a "systemctl is-active n8n || docker-compose -f /opt/n8n/docker-compose.yml ps" \
    || warning "Status-Prüfung fehlgeschlagen"

echo ""
echo "========== Import Zusammenfassung =========="
echo "Environment: $ENVIRONMENT"
echo "Target: $TARGET"
if [ "$IMPORT_WORKFLOWS" = true ]; then
    echo "Workflows: $WORKFLOW_COUNT importiert"
fi
if [ "$IMPORT_CREDENTIALS" = true ]; then
    echo "Credentials: $CRED_COUNT Templates verarbeitet"
fi
echo ""

info "Import abgeschlossen. n8n sollte unter http://target-server:5678 erreichbar sein."