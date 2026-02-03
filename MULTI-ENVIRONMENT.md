# 🚀 n8n Multi-Environment Development & Deployment Suite

## 📋 Overview

This suite enables complete **local n8n development** with **Ansible-based deployment** to different environments with separated server lists.

### 🎯 Main Goals
- **Local development** with Git versioning
- **Separated environments** (Development, Pre-Production, Production)
- **Ansible pipeline** for automated deployments
- **Secure credential management** with Vault
- **Flexible installation** (Native or Docker)

## 🏗️ System Architecture

### 📁 Directory Structure
```
n8n-install/
├── 🛠️ INSTALLATION SCRIPTS
│   ├── install-n8n.sh              # Main installation script (Native/Docker)
│   ├── setup-ssh-user.sh           # SSH access for management
│   └── setup-development.sh        # Development environment setup
│
├── 🌐 ENVIRONMENT MANAGEMENT  
│   ├── manage-environments.sh       # Multi-environment manager
│   ├── server-config.sh            # Server list configuration
│   └── manage-vault.sh             # Ansible Vault management
│
├── 📦 WORKFLOW MANAGEMENT
│   ├── export-workflows.sh         # n8n → Git export
│   ├── import-workflows.sh         # Git → n8n import
│   └── manage-docker.sh            # Docker container management
│
├── 🔧 UTILITIES
│   ├── n8n-menu.sh                 # Main management menu
│   ├── manage-domains.sh           # Domain & SSL management
│   ├── backup-n8n.sh              # Backup system
│   └── restore-n8n.sh             # Restore system
│
└── 📚 DOCUMENTATION
    ├── README.md                   # Main documentation
    ├── FEATURES.md                 # Feature overview
    └── MULTI-ENVIRONMENT.md        # This file
```

## 🌍 Environments

### 1. 🛠️ Development Environment
**Purpose**: Local development and initial testing

**Server List**:
- `local` → localhost (Docker/Native)
- `dev-vm` → dev.internal.com (Internal VM)
- `dev-docker` → dev-docker.internal.com (Docker Host)

**Properties**:
- Unencrypted credentials
- Basic authentication (admin/admin123)
- Simple configuration
- Direct Git access

### 2. 🧪 Pre-Production Environment  
**Purpose**: Staging, testing, QA, demo

**Server List**:
- `staging-01` → staging-01.example.com
- `staging-02` → staging-02.example.com  
- `test-cluster` → test-cluster.example.com
- `qa-server` → qa.example.com
- `demo-server` → demo.example.com

**Properties**:
- Encrypted credentials (Ansible Vault)
- SSL certificates required
- Backup system activated
- Production-like configuration

### 3. 🏭 Production Environment
**Purpose**: Live system with highest security

**Server List**:
- `prod-01` → prod-01.example.com (Primary)
- `prod-02` → prod-02.example.com (Secondary) 
- `prod-03` → prod-03.example.com (Tertiary)
- `prod-backup` → backup.example.com (Backup)
- `prod-dr` → dr.example.com (Disaster Recovery)

**Properties**:
- Ultra-secure encrypted credentials
- SSL/TLS encryption required
- Automatic backup system
- Monitoring & alerting
- Security hardening enabled

## 🚀 Workflow: Development → Deployment

### 1. Start Local Development
```bash
# Create development environment
./setup-development.sh my-project development

# Switch to workspace
cd ~/n8n-development/my-project/n8n-workflows

# Start local n8n  
docker-compose -f docker-compose.development.yml up -d

# Open n8n: http://localhost:5678
```

### 2. Develop Workflows
- Use n8n UI for workflow creation
- Test workflows in local n8n
- Create credentials as templates

### 3. Export to Git
```bash
# Export workflows
../export-workflows.sh development

# Check Git status
git status

# Commit changes
git add .
git commit -m "Add new customer onboarding workflow"
git push
```

### 4. Deploy to Staging
```bash
# Single server deployment
../import-workflows.sh preproduction staging-01

# Or multi-environment manager
../manage-environments.sh
# → [2] Pre-Production → [3] Import workflows
```

### 5. Production Deployment
```bash
# With security confirmation
../import-workflows.sh production prod-01 --workflows-only

# Or bulk deployment to all production servers
../manage-environments.sh
# → [6] Bulk Deployment → [3] Production import
```

## 🔐 Security Concept

### Credential Management per Environment

**Development**:
```yaml
# Unencrypted for easy development
vault_n8n_password: "dev-admin123"
vault_postgres_password: "dev-postgres123"
vault_encryption_key: "dev-encryption-key-12345"
```

**Pre-Production**:
```yaml
# Encrypted with Ansible Vault
$ANSIBLE_VAULT;1.1;AES256
66386439653...
```

**Production**: 
```yaml
# Ultra-secure encrypted
$ANSIBLE_VAULT;1.1;AES256
99816523987...
```

### Vault Management
```bash
# Start vault manager
./manage-vault.sh

# Or direct commands
./manage-vault.sh edit production
./manage-vault.sh view preproduction
./manage-vault.sh encrypt development
```

## 🔄 Ansible Pipeline

### Inventories per Environment
```yaml
# ansible/inventories/development/hosts.yml
all:
  children:
    n8n_servers:
      hosts:
        local:
          ansible_host: localhost
          n8n_environment: development

# ansible/inventories/preproduction/hosts.yml  
all:
  children:
    n8n_servers:
      hosts:
        staging-01:
          ansible_host: staging-01.example.com
          n8n_environment: preproduction

# ansible/inventories/production/hosts.yml
all:
  children:
    n8n_servers:
      hosts:
        prod-01:
          ansible_host: prod-01.example.com
          n8n_environment: production
```

### Playbook Execution
```bash
# Native installation
ansible-playbook -i ansible/inventories/production/hosts.yml \
                 ansible/playbooks/install-n8n-native.yml \
                 --limit prod-01

# Docker installation  
ansible-playbook -i ansible/inventories/preproduction/hosts.yml \
                 ansible/playbooks/install-n8n-docker.yml \
                 --limit staging-01

# Workflow import
ansible-playbook -i ansible/inventories/development/hosts.yml \
                 ansible/playbooks/import-n8n-workflows.yml \
                 --limit local
```

## 🛠️ Management Tools

### 1. Multi-Environment Manager
```bash
./manage-environments.sh
```
**Features**:
- Environment-specific server lists
- Installation type selection (Native/Docker)
- Bulk operations for all servers
- Status dashboard

### 2. Server Configuration
```bash
# Server-Listen anzeigen
./server-config.sh list production

# Einzelnen Server prüfen
./server-config.sh check development local

# Alle Server prüfen  
./server-config.sh check production
```

### 3. Workflow Export/Import
```bash
# Export von lokalem n8n
./export-workflows.sh development localhost:5678

# Import auf Staging
./import-workflows.sh preproduction staging-01

# Import auf Production (mit Bestätigung)
./import-workflows.sh production prod-01 --force
```

### 4. Vault-Management
```bash
# Interaktiver Vault-Manager
./manage-vault.sh

# Command-line
./manage-vault.sh edit production
./manage-vault.sh view preproduction  
./manage-vault.sh encrypt development
```

## 📊 Status & Monitoring

### Server-Status prüfen
```bash
# Alle Environments
./server-config.sh check development
./server-config.sh check preproduction  
./server-config.sh check production

# Multi-Environment Manager
./manage-environments.sh
# → [7] Status Dashboard
```

### n8n-Service Status
```bash
# Native Installation
sudo systemctl status n8n

# Docker Installation
./manage-docker.sh status

# Ansible-basierte Prüfung
ansible -i ansible/inventories/production/hosts.yml \
        prod-01 -m shell \
        -a "systemctl is-active n8n"
```

## 🔄 Backup & Recovery

### Automatische Backups
- **Development**: Lokale Git-Commits
- **Pre-Production**: Täglich automatisch
- **Production**: Stündlich mit Retention

### Backup-Strategien
```bash
# Einzelbackup
./backup-n8n.sh

# Bulk-Backup aller Production-Server
./manage-environments.sh
# → [6] Bulk-Deployment → [5] Production Backup
```

### Recovery
```bash
# Einzelserver
./restore-n8n.sh /var/backups/n8n/backup-20240203.tar.gz

# Mit Environment-Manager
./manage-environments.sh
# → [Environment] → [5] Backup erstellen/wiederherstellen
```

## 🎯 Best Practices

### 1. Development Workflow
1. Lokale Entwicklung in `development` Environment
2. Export nach Git nach jedem Feature
3. Test auf `preproduction` vor Production
4. Staged Deployment: `staging-01` → `staging-02` → `production`

### 2. Security
1. Niemals echte Credentials in Git committen
2. Ansible Vault für alle Non-Dev Environments
3. Regelmäßige Vault-Passwort Rotation
4. SSH key-based authentication

### 3. Deployment
1. Dry-run before every production deployment
2. Backup before every import
3. Staged rollout to multiple servers
4. Keep rollback plan available

### 4. Monitoring
1. Regular status checks
2. Automated backup validation  
3. SSL certificate monitoring
4. Performance monitoring

## 🚀 Quick Start

### Complete Setup in 5 Minutes
```bash
# 1. Clone repository
git clone https://github.com/Hammdie/n8n-install.git
cd n8n-install

# 2. Create development environment
./setup-development.sh my-project development

# 3. Start local n8n
cd ~/n8n-development/my-project/n8n-workflows
docker-compose -f docker-compose.development.yml up -d

# 4. Start multi-environment manager
cd ~/n8n-install
./manage-environments.sh

# 5. Develop and deploy workflows!
```

## 📞 Support

For problems:

1. **Check logs**: `./manage-docker.sh logs` or `journalctl -u n8n -f`
2. **Status dashboard**: `./manage-environments.sh` → [7]
3. **Server connectivity**: `./server-config.sh check <environment>`
4. **Vault issues**: `./manage-vault.sh status`

The suite is fully documented and ready for production use! 🎉