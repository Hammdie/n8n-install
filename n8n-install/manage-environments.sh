#!/bin/bash

# Multi-Environment n8n Management
# Verwaltet verschiedene n8n-Umgebungen mit getrennten Server-Listen

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; exit 1; }
warning() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }

# Umgebungs-Konfiguration
declare -A ENVIRONMENTS
ENVIRONMENTS[development]="Lokale Entwicklung"
ENVIRONMENTS[preproduction]="Pre-Production Testing" 
ENVIRONMENTS[production]="Live Production"

# Server-Konfiguration pro Umgebung
declare -A DEV_SERVERS
DEV_SERVERS[local]="localhost"
DEV_SERVERS[dev-vm]="dev.internal.com"

declare -A PREPROD_SERVERS  
PREPROD_SERVERS[staging-01]="staging-01.example.com"
PREPROD_SERVERS[staging-02]="staging-02.example.com"
PREPROD_SERVERS[test-cluster]="test-cluster.example.com"

declare -A PROD_SERVERS
PROD_SERVERS[prod-01]="prod-01.example.com"
PROD_SERVERS[prod-02]="prod-02.example.com"
PROD_SERVERS[prod-03]="prod-03.example.com"
PROD_SERVERS[prod-backup]="backup.example.com"

show_main_menu() {
    clear
    echo ""
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE}    🚀 n8n Multi-Environment Manager          ${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo ""
    echo -e "${BLUE}Verfügbare Umgebungen:${NC}"
    echo ""
    echo -e "${GREEN}[1] 🛠️  Development${NC}     - Lokale Entwicklung"
    echo -e "${YELLOW}[2] 🧪 Pre-Production${NC}  - Staging & Testing"  
    echo -e "${RED}[3] 🏭 Production${NC}       - Live Environment"
    echo ""
    echo -e "${BLUE}Management Optionen:${NC}"
    echo ""
    echo -e "[4] 📋 Server-Listen anzeigen"
    echo -e "[5] ⚙️  Environment konfigurieren"
    echo -e "[6] 🔄 Bulk-Deployment"
    echo -e "[7] 📊 Status Dashboard"
    echo -e "[8] 🆘 Hilfe"
    echo -e "[0] ❌ Beenden"
    echo ""
}

show_environment_menu() {
    local env="$1"
    local env_name="${ENVIRONMENTS[$env]}"
    
    clear
    echo ""
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE}    📋 $env_name Management                    ${NC}"  
    echo -e "${PURPLE}================================================${NC}"
    echo ""
    
    # Server-Liste anzeigen
    echo -e "${BLUE}Verfügbare Server:${NC}"
    echo ""
    
    case $env in
        "development")
            for server in "${!DEV_SERVERS[@]}"; do
                echo -e "${GREEN}  • $server${NC} (${DEV_SERVERS[$server]})"
            done
            ;;
        "preproduction") 
            for server in "${!PREPROD_SERVERS[@]}"; do
                echo -e "${YELLOW}  • $server${NC} (${PREPROD_SERVERS[$server]})"
            done
            ;;
        "production")
            for server in "${!PROD_SERVERS[@]}"; do
                echo -e "${RED}  • $server${NC} (${PROD_SERVERS[$server]})"
            done
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}Aktionen:${NC}"
    echo ""
    echo -e "[1] 🚀 n8n installieren"
    echo -e "[2] 📤 Workflows exportieren"  
    echo -e "[3] 📥 Workflows importieren"
    echo -e "[4] 🔄 Update durchführen"
    echo -e "[5] 💾 Backup erstellen"
    echo -e "[6] 📊 Status prüfen"
    echo -e "[7] 🔧 Server-Konfiguration" 
    echo -e "[0] ⬅️  Zurück"
    echo ""
}

handle_installation() {
    local env="$1"
    
    echo ""
    echo -e "${BLUE}🚀 n8n Installation für $env${NC}"
    echo ""
    
    # Server-Auswahl
    echo "Verfügbare Server:"
    local servers_var="${env^^}_SERVERS[@]"
    local servers=("${!servers_var}")
    
    select server in "${!servers[@]}" "Alle Server" "Abbrechen"; do
        case $server in
            "Abbrechen")
                return
                ;;
            "Alle Server")
                log "Installation auf allen Servern wird gestartet..."
                for srv in "${!servers[@]}"; do
                    install_n8n_on_server "$env" "$srv" "${servers[$srv]}"
                done
                break
                ;;
            *)
                if [ -n "$server" ]; then
                    install_n8n_on_server "$env" "$server" "${servers[$server]}"
                    break
                fi
                ;;
        esac
    done
}

install_n8n_on_server() {
    local env="$1"
    local server_name="$2" 
    local server_host="$3"
    
    log "Installiere n8n auf $server_name ($server_host) für $env..."
    
    # Installations-Typ abfragen
    echo ""
    echo "Wählen Sie den Installationstyp:"
    echo "1) Native Installation (Node.js + systemd)"
    echo "2) Docker Compose Installation"
    echo ""
    
    read -p "Installationstyp [1-2]: " install_type
    
    case $install_type in
        1)
            run_ansible_installation "$env" "$server_name" "native"
            ;;
        2) 
            run_ansible_installation "$env" "$server_name" "docker"
            ;;
        *)
            error "Ungültiger Installationstyp"
            ;;
    esac
}

run_ansible_installation() {
    local env="$1"
    local server="$2"
    local install_type="$3"
    
    local inventory_file="ansible/inventories/$env/hosts.yml"
    local playbook_file="ansible/playbooks/install-n8n-$install_type.yml"
    
    # Prüfe ob Ansible-Dateien existieren
    if [ ! -f "$inventory_file" ]; then
        create_ansible_inventory "$env"
    fi
    
    if [ ! -f "$playbook_file" ]; then
        create_ansible_playbooks "$install_type"
    fi
    
    # Führe Installation aus
    log "Starte Ansible-Installation..."
    
    ansible-playbook \
        -i "$inventory_file" \
        "$playbook_file" \
        --limit "$server" \
        -e "environment=$env" \
        -e "install_type=$install_type" \
        || error "Ansible-Installation fehlgeschlagen"
        
    log "✅ Installation auf $server abgeschlossen"
}

create_ansible_inventory() {
    local env="$1"
    local inventory_dir="ansible/inventories/$env"
    local inventory_file="$inventory_dir/hosts.yml"
    
    mkdir -p "$inventory_dir"
    
    log "Erstelle Ansible Inventory für $env..."
    
    case $env in
        "development")
            cat > "$inventory_file" << 'EOF'
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
            ;;
        "preproduction")
            cat > "$inventory_file" << 'EOF'  
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
            ;;
        "production")
            cat > "$inventory_file" << 'EOF'
all:
  children:
    n8n_servers:
      hosts:
        prod-01:
          ansible_host: prod-01.example.com
          ansible_user: odoo
          n8n_environment: production
          n8n_domain: prod-01.example.com
          n8n_ssl_email: admin@example.com
        prod-02:
          ansible_host: prod-02.example.com
          ansible_user: odoo
          n8n_environment: production  
          n8n_domain: prod-02.example.com
          n8n_ssl_email: admin@example.com
        prod-03:
          ansible_host: prod-03.example.com
          ansible_user: odoo
          n8n_environment: production
          n8n_domain: prod-03.example.com
          n8n_ssl_email: admin@example.com
        prod-backup:
          ansible_host: backup.example.com
          ansible_user: odoo
          n8n_environment: production
          n8n_domain: backup.example.com
          n8n_ssl_email: admin@example.com
EOF
            ;;
    esac
    
    # Environment-spezifische Variablen
    local group_vars_dir="$inventory_dir/group_vars"
    mkdir -p "$group_vars_dir"
    
    cat > "$group_vars_dir/all.yml" << EOF
# Environment: $env
n8n_environment: $env
n8n_version: latest

# Security Settings per Environment
$(case $env in
    "development")
        echo "n8n_basic_auth: true"
        echo "n8n_basic_user: admin"  
        echo "n8n_basic_password: admin123"
        echo "n8n_encryption_key: dev-key-12345"
        ;;
    "preproduction")
        echo "n8n_basic_auth: true"
        echo "n8n_basic_user: admin"
        echo "n8n_basic_password: staging-secure-pass"
        echo "n8n_encryption_key: staging-key-67890"
        ;;
    "production") 
        echo "n8n_basic_auth: true"
        echo "n8n_basic_user: admin"
        echo "n8n_basic_password: '{{ vault_n8n_password }}'"
        echo "n8n_encryption_key: '{{ vault_encryption_key }}'"
        ;;
esac)

# Database Settings
postgres_db: n8n_$env
postgres_user: n8n_$env
$(case $env in
    "development"|"preproduction")
        echo "postgres_password: simple-db-pass"
        ;;
    "production")
        echo "postgres_password: '{{ vault_postgres_password }}'"
        ;;
esac)
EOF
    
    info "Ansible Inventory erstellt: $inventory_file"
}

create_ansible_playbooks() {
    local install_type="$1"
    local playbook_dir="ansible/playbooks"
    mkdir -p "$playbook_dir"
    
    # Native Installation Playbook
    cat > "$playbook_dir/install-n8n-native.yml" << 'EOF'
---
- name: Install n8n Native (Node.js + systemd)
  hosts: n8n_servers
  become: yes
  
  tasks:
    - name: Download and execute n8n installation script
      shell: |
        wget -O /tmp/install-n8n.sh https://raw.githubusercontent.com/your-repo/n8n-install/main/install-n8n.sh
        chmod +x /tmp/install-n8n.sh
        /tmp/install-n8n.sh {{ n8n_domain }} {{ n8n_ssl_email | default('') }}
      environment:
        INSTALL_METHOD: "1"  # Native installation
        
    - name: Setup SSH user with n8n access
      shell: |
        wget -O /tmp/setup-ssh-user.sh https://raw.githubusercontent.com/your-repo/n8n-install/main/setup-ssh-user.sh
        chmod +x /tmp/setup-ssh-user.sh  
        /tmp/setup-ssh-user.sh
        
    - name: Verify n8n service is running
      systemd:
        name: n8n
        state: started
        enabled: yes
EOF
    
    # Docker Installation Playbook  
    cat > "$playbook_dir/install-n8n-docker.yml" << 'EOF'
---
- name: Install n8n Docker Compose
  hosts: n8n_servers
  become: yes
  
  tasks:
    - name: Download and execute n8n installation script
      shell: |
        wget -O /tmp/install-n8n.sh https://raw.githubusercontent.com/your-repo/n8n-install/main/install-n8n.sh
        chmod +x /tmp/install-n8n.sh
        /tmp/install-n8n.sh {{ n8n_domain }} {{ n8n_ssl_email | default('') }}
      environment:
        INSTALL_METHOD: "2"  # Docker installation
        
    - name: Setup SSH user with docker access
      shell: |
        wget -O /tmp/setup-ssh-user.sh https://raw.githubusercontent.com/your-repo/n8n-install/main/setup-ssh-user.sh
        chmod +x /tmp/setup-ssh-user.sh
        /tmp/setup-ssh-user.sh
        
    - name: Verify n8n containers are running
      shell: docker-compose -f /opt/n8n/docker-compose.yml ps
      register: docker_status
      
    - name: Show container status
      debug:
        msg: "{{ docker_status.stdout }}"
EOF

    info "Ansible Playbooks erstellt für $install_type"
}

show_server_lists() {
    clear
    echo ""
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE}    📋 Server-Listen Übersicht                 ${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo ""
    
    # Development Server
    echo -e "${GREEN}🛠️  Development Server:${NC}"
    for server in "${!DEV_SERVERS[@]}"; do
        echo -e "   • ${GREEN}$server${NC} → ${DEV_SERVERS[$server]}"
    done
    echo ""
    
    # Pre-Production Server
    echo -e "${YELLOW}🧪 Pre-Production Server:${NC}" 
    for server in "${!PREPROD_SERVERS[@]}"; do
        echo -e "   • ${YELLOW}$server${NC} → ${PREPROD_SERVERS[$server]}"
    done
    echo ""
    
    # Production Server
    echo -e "${RED}🏭 Production Server:${NC}"
    for server in "${!PROD_SERVERS[@]}"; do  
        echo -e "   • ${RED}$server${NC} → ${PROD_SERVERS[$server]}"
    done
    echo ""
    
    read -p "Drücken Sie Enter um fortzufahren..."
}

bulk_deployment() {
    clear
    echo ""
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE}    🔄 Bulk-Deployment Manager                 ${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo ""
    
    echo "Wählen Sie die Aktion:"
    echo ""
    echo "[1] Workflows auf alle Development-Server exportieren"
    echo "[2] Workflows auf alle Pre-Production-Server importieren"  
    echo "[3] Workflows auf alle Production-Server importieren"
    echo "[4] Status aller Server prüfen"
    echo "[5] Backup aller Production-Server"
    echo "[0] Zurück"
    echo ""
    
    read -p "Ihre Wahl [0-5]: " choice
    
    case $choice in
        1)
            bulk_export "development"
            ;;
        2)
            bulk_import "preproduction"
            ;;
        3)
            bulk_import "production" 
            ;;
        4)
            bulk_status_check
            ;;
        5)
            bulk_backup "production"
            ;;
        0)
            return
            ;;
        *)
            warning "Ungültige Auswahl"
            ;;
    esac
}

bulk_export() {
    local env="$1"
    log "Starte Bulk-Export für $env..."
    
    local servers_var="${env^^}_SERVERS[@]"
    local -n servers=$servers_var
    
    for server in "${!servers[@]}"; do
        log "Exportiere von $server (${servers[$server]})..."
        ./export-workflows.sh "$env" "${servers[$server]}" || warning "Export von $server fehlgeschlagen"
    done
    
    log "✅ Bulk-Export abgeschlossen"
    read -p "Drücken Sie Enter um fortzufahren..."
}

bulk_import() {
    local env="$1"
    
    if [ "$env" = "production" ]; then
        echo ""
        warning "⚠️  ACHTUNG: Bulk-Import in Production!"
        read -p "Sind Sie sicher? (yes/no): " -r
        if [[ ! $REPLY =~ ^yes$ ]]; then
            return
        fi
    fi
    
    log "Starte Bulk-Import für $env..."
    
    local servers_var="${env^^}_SERVERS[@]"
    local -n servers=$servers_var
    
    for server in "${!servers[@]}"; do
        log "Importiere auf $server (${servers[$server]})..."
        ./import-workflows.sh "$env" "$server" || warning "Import auf $server fehlgeschlagen"
    done
    
    log "✅ Bulk-Import abgeschlossen"
    read -p "Drücken Sie Enter um fortzufahren..."
}

# Hauptlogik
if [ "$#" -eq 0 ]; then
    # Interaktiver Modus
    while true; do
        show_main_menu
        read -p "Ihre Wahl [0-8]: " choice
        
        case $choice in
            1)
                show_environment_menu "development"
                read -p "Ihre Wahl [0-7]: " env_choice
                case $env_choice in
                    1) handle_installation "development" ;;
                    2) ./export-workflows.sh development ;;
                    3) ./import-workflows.sh development ;;
                    0) continue ;;
                esac
                ;;
            2)
                show_environment_menu "preproduction"  
                read -p "Ihre Wahl [0-7]: " env_choice
                case $env_choice in
                    1) handle_installation "preproduction" ;;
                    2) ./export-workflows.sh preproduction ;;
                    3) ./import-workflows.sh preproduction ;;
                    0) continue ;;
                esac
                ;;
            3)
                show_environment_menu "production"
                read -p "Ihre Wahl [0-7]: " env_choice  
                case $env_choice in
                    1) handle_installation "production" ;;
                    2) ./export-workflows.sh production ;;
                    3) ./import-workflows.sh production ;;
                    0) continue ;;
                esac
                ;;
            4)
                show_server_lists
                ;;
            6)
                bulk_deployment
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
    environment="$1"
    action="$2"
    server="$3"
    
    case $action in
        "install")
            handle_installation "$environment"
            ;;
        "export")
            ./export-workflows.sh "$environment" "$server"
            ;;
        "import")
            ./import-workflows.sh "$environment" "$server"
            ;;
        *)
            echo "Verwendung: $0 [environment] [action] [server]"
            echo "Environments: development, preproduction, production"
            echo "Actions: install, export, import"
            ;;
    esac
fi