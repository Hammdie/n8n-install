# 🚀 n8n Multi-Environment Development & Deployment Suite

## 📋 Übersicht

Diese Suite ermöglicht eine vollständige **lokale n8n-Entwicklung** mit **Ansible-basiertem Deployment** auf verschiedene Umgebungen mit getrennten Server-Listen.

### 🎯 Hauptziele
- **Lokale Entwicklung** mit Git-Versionierung
- **Getrennte Umgebungen** (Development, Pre-Production, Production)
- **Ansible-Pipeline** für automatisierte Deployments
- **Sichere Credential-Verwaltung** mit Vault
- **Flexible Installation** (Native oder Docker)

## 🏗️ Systemarchitektur

### 📁 Verzeichnisstruktur
```
n8n-install/
├── 🛠️ INSTALLATION SCRIPTS
│   ├── install-n8n.sh              # Haupt-Installationsskript (Native/Docker)
│   ├── setup-ssh-user.sh           # SSH-Zugang für Management
│   └── setup-development.sh        # Entwicklungsumgebung Setup
│
├── 🌐 ENVIRONMENT MANAGEMENT  
│   ├── manage-environments.sh       # Multi-Environment Manager
│   ├── server-config.sh            # Server-Listen Konfiguration
│   └── manage-vault.sh             # Ansible Vault Management
│
├── 📦 WORKFLOW MANAGEMENT
│   ├── export-workflows.sh         # n8n → Git Export
│   ├── import-workflows.sh         # Git → n8n Import
│   └── manage-docker.sh            # Docker Container Verwaltung
│
├── 🔧 UTILITIES
│   ├── n8n-menu.sh                 # Hauptverwaltungsmenü
│   ├── manage-domains.sh           # Domain & SSL Management
│   ├── backup-n8n.sh              # Backup-System
│   └── restore-n8n.sh             # Restore-System
│
└── 📚 DOCUMENTATION
    ├── README.md                   # Hauptdokumentation
    ├── FEATURES.md                 # Feature-Übersicht
    └── MULTI-ENVIRONMENT.md        # Diese Datei
```

## 🌍 Umgebungen

### 1. 🛠️ Development Environment
**Zweck**: Lokale Entwicklung und erste Tests

**Server-Liste**:
- `local` → localhost (Docker/Native)
- `dev-vm` → dev.internal.com (Interne VM)
- `dev-docker` → dev-docker.internal.com (Docker Host)

**Eigenschaften**:
- Unverschlüsselte Credentials
- Basis-Authentifizierung (admin/admin123)
- Einfache Konfiguration
- Direkter Git-Zugriff

### 2. 🧪 Pre-Production Environment  
**Zweck**: Staging, Testing, QA, Demo

**Server-Liste**:
- `staging-01` → staging-01.example.com
- `staging-02` → staging-02.example.com  
- `test-cluster` → test-cluster.example.com
- `qa-server` → qa.example.com
- `demo-server` → demo.example.com

**Eigenschaften**:
- Verschlüsselte Credentials (Ansible Vault)
- SSL-Zertifikate erforderlich
- Backup-System aktiviert
- Production-ähnliche Konfiguration

### 3. 🏭 Production Environment
**Zweck**: Live-System mit höchster Sicherheit

**Server-Liste**:
- `prod-01` → prod-01.example.com (Primary)
- `prod-02` → prod-02.example.com (Secondary) 
- `prod-03` → prod-03.example.com (Tertiary)
- `prod-backup` → backup.example.com (Backup)
- `prod-dr` → dr.example.com (Disaster Recovery)

**Eigenschaften**:
- Ultra-sichere verschlüsselte Credentials
- SSL/TLS-Verschlüsselung erforderlich
- Automatisches Backup-System
- Monitoring & Alerting
- Security Hardening aktiviert

## 🚀 Workflow: Entwicklung → Deployment

### 1. Lokale Entwicklung starten
```bash
# Development Environment erstellen
./setup-development.sh my-project development

# Wechsel in Workspace
cd ~/n8n-development/my-project/n8n-workflows

# Lokales n8n starten  
docker-compose -f docker-compose.development.yml up -d

# n8n öffnen: http://localhost:5678
```

### 2. Workflows entwickeln
- n8n UI für Workflow-Erstellung verwenden
- Workflows in lokalem n8n testen
- Credentials als Templates anlegen

### 3. Export in Git
```bash
# Workflows exportieren
../export-workflows.sh development

# Git Status prüfen
git status

# Änderungen committen
git add .
git commit -m "Add new customer onboarding workflow"
git push
```

### 4. Deployment auf Staging
```bash
# Einzelserver Deployment
../import-workflows.sh preproduction staging-01

# Oder Multi-Environment Manager
../manage-environments.sh
# → [2] Pre-Production → [3] Workflows importieren
```

### 5. Production Deployment
```bash
# Mit Sicherheitsabfrage
../import-workflows.sh production prod-01 --workflows-only

# Oder Bulk-Deployment auf alle Production-Server
../manage-environments.sh
# → [6] Bulk-Deployment → [3] Production Import
```

## 🔐 Sicherheitskonzept

### Credential-Management pro Environment

**Development**:
```yaml
# Unverschlüsselt für einfache Entwicklung
vault_n8n_password: "dev-admin123"
vault_postgres_password: "dev-postgres123"
vault_encryption_key: "dev-encryption-key-12345"
```

**Pre-Production**:
```yaml
# Verschlüsselt mit Ansible Vault
$ANSIBLE_VAULT;1.1;AES256
66386439653...
```

**Production**: 
```yaml
# Ultra-sicher verschlüsselt
$ANSIBLE_VAULT;1.1;AES256
99816523987...
```

### Vault-Verwaltung
```bash
# Vault-Manager starten
./manage-vault.sh

# Oder direkt Commands
./manage-vault.sh edit production
./manage-vault.sh view preproduction
./manage-vault.sh encrypt development
```

## 🔄 Ansible-Pipeline

### Inventories pro Environment
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

### Playbook-Execution
```bash
# Native Installation
ansible-playbook -i ansible/inventories/production/hosts.yml \
                 ansible/playbooks/install-n8n-native.yml \
                 --limit prod-01

# Docker Installation  
ansible-playbook -i ansible/inventories/preproduction/hosts.yml \
                 ansible/playbooks/install-n8n-docker.yml \
                 --limit staging-01

# Workflow Import
ansible-playbook -i ansible/inventories/development/hosts.yml \
                 ansible/playbooks/import-n8n-workflows.yml \
                 --limit local
```

## 🛠️ Management-Tools

### 1. Multi-Environment Manager
```bash
./manage-environments.sh
```
**Features**:
- Umgebungs-spezifische Server-Listen
- Installationstyp-Auswahl (Native/Docker)
- Bulk-Operations für alle Server
- Status-Dashboard

### 2. Server-Konfiguration
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
4. SSH-Key basierte Authentifizierung

### 3. Deployment
1. Dry-Run vor jedem Production-Deployment
2. Backup vor jedem Import
3. Staged Rollout auf multiple Server
4. Rollback-Plan verfügbar halten

### 4. Monitoring
1. Regelmäßige Status-Checks
2. Automatisierte Backup-Validierung  
3. SSL-Zertifikat Monitoring
4. Performance-Überwachung

## 🚀 Quick Start

### Komplettes Setup in 5 Minuten
```bash
# 1. Klone Repository
git clone https://github.com/username/n8n-install.git
cd n8n-install

# 2. Development Environment erstellen
./setup-development.sh my-project development

# 3. Lokales n8n starten
cd ~/n8n-development/my-project/n8n-workflows
docker-compose -f docker-compose.development.yml up -d

# 4. Multi-Environment Manager starten
cd ~/n8n-install
./manage-environments.sh

# 5. Workflows entwickeln und deployen!
```

## 📞 Support

Bei Problemen:

1. **Logs prüfen**: `./manage-docker.sh logs` oder `journalctl -u n8n -f`
2. **Status-Dashboard**: `./manage-environments.sh` → [7]
3. **Server-Connectivity**: `./server-config.sh check <environment>`
4. **Vault-Probleme**: `./manage-vault.sh status`

Die Suite ist vollständig dokumentiert und bereit für produktiven Einsatz! 🎉