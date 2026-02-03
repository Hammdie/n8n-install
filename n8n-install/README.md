# 🚀 n8n Installation & Multi-Environment Management Suite

> **Vollständige n8n-Installation mit lokaler Entwicklung, Git-Integration und Ansible-basiertem Multi-Environment-Deployment**

## 📋 Quick Navigation

### 🎯 **Hauptdokumentation**
| Dokument | Beschreibung | Direkt zu |
|----------|--------------|----------|
| **[� INDEX](INDEX.md)** | **Zentrale Navigation zu ALLEM** | **[🎯 Hier springen](INDEX.md)** |
| **[�📖 Diese README](README.md)** | Hauptdokumentation & Installation | Sie sind hier |
| **[🌍 Multi-Environment Guide](MULTI-ENVIRONMENT.md)** | Development → Production Workflow | [Hier springen](MULTI-ENVIRONMENT.md) |
| **[🚀 Feature-Übersicht](FEATURES.md)** | Alle verfügbaren Features im Detail | [Hier springen](FEATURES.md) |

### 🛠️ **Management-Tools** 
| Tool | Zweck | Quick Launch |
|------|-------|-------------|
| **[🌐 Multi-Environment Manager](manage-environments.sh)** | Zentrale Umgebungsverwaltung | `./manage-environments.sh` |
| **[🔧 Haupt-Installation](install-n8n.sh)** | n8n installieren (Native/Docker) | `./install-n8n.sh <domain> <email>` |
| **[🎛️ n8n Management Menü](n8n-menu.sh)** | Alle n8n-Operationen | `./n8n-menu.sh` |
| **[🔐 Vault Manager](manage-vault.sh)** | Sichere Credential-Verwaltung | `./manage-vault.sh` |

### 📦 **Workflow-Management**
| Script | Funktion | Verwendung |
|--------|----------|------------|
| **[📤 Export](export-workflows.sh)** | n8n → Git Export | `./export-workflows.sh <environment>` |
| **[📥 Import](import-workflows.sh)** | Git → n8n Import | `./import-workflows.sh <env> <server>` |
| **[🏗️ Development Setup](setup-development.sh)** | Dev-Environment erstellen | `./setup-development.sh <name> <env>` |

### ⚙️ **Server & Environment Management**
| Tool | Zweck | Quick Access |
|------|-------|-------------|
| **[📋 Server-Konfiguration](server-config.sh)** | Server-Listen verwalten | `./server-config.sh list <env>` |
| **[🐳 Docker Management](manage-docker.sh)** | Container-Verwaltung | `./manage-docker.sh status` |
| **[🌐 Domain Management](manage-domains.sh)** | SSL & Domains | SSH: `n8n-domains` |

### 💾 **Backup & Maintenance**
| Script | Funktion | SSH Alias |
|--------|----------|-----------|
| **[💾 Backup](backup-n8n.sh)** | n8n-Backup erstellen | `n8n-backup` |
| **[🔄 Restore](restore-n8n.sh)** | Backup wiederherstellen | `n8n-restore` |
| **[🔄 Update](update-n8n.sh)** | n8n aktualisieren | `n8n-update` |

---

## 📋 Suite-Komponenten

### 🎯 **Kern-Installation**
- **[install-n8n.sh](install-n8n.sh)** - Vollständige n8n-Installation ([Native](install-n8n.sh#L45) oder [Docker](install-n8n.sh#L52))
- **[setup-ssh-user.sh](setup-ssh-user.sh)** - SSH-Zugang für [odoo-Benutzer konfigurieren](setup-ssh-user.sh#L30)
- **[setup-reverse-proxy.sh](setup-reverse-proxy.sh)** - [Zusätzliche Domains](setup-reverse-proxy.sh#L15) mit Reverse Proxy

### 🌍 **Multi-Environment System** 
- **[manage-environments.sh](manage-environments.sh)** - [Zentrale Umgebungsverwaltung](manage-environments.sh#L25) ([Dev](manage-environments.sh#L40), [Pre-Prod](manage-environments.sh#L45), [Production](manage-environments.sh#L50))
- **[setup-development.sh](setup-development.sh)** - [Lokale Entwicklungsumgebung](setup-development.sh#L35) mit Git
- **[server-config.sh](server-config.sh)** - [Server-Listen Konfiguration](server-config.sh#L15) pro Environment
- **[manage-vault.sh](manage-vault.sh)** - [Ansible Vault Management](manage-vault.sh#L25) für sichere Credentials

### 📦 **Workflow-Pipeline**
- **[export-workflows.sh](export-workflows.sh)** - [n8n → Git Export](export-workflows.sh#L40) mit [Backup-Option](export-workflows.sh#L65)
- **[import-workflows.sh](import-workflows.sh)** - [Git → n8n Import](import-workflows.sh#L55) via [Ansible](import-workflows.sh#L85)

### 🎛️ **Management-Interface**
- **[n8n-menu.sh](n8n-menu.sh)** - [Hauptverwaltungsmenü](n8n-menu.sh#L20) mit allen Optionen
- **[manage-domains.sh](manage-domains.sh)** - [Domain-Management](manage-domains.sh#L30) und [SSL-Verwaltung](manage-domains.sh#L65)
- **[manage-docker.sh](manage-docker.sh)** - [Docker Compose Verwaltung](manage-docker.sh#L25) ([Status](manage-docker.sh#L45), [Logs](manage-docker.sh#L75), [Updates](manage-docker.sh#L95))

### 💾 **Backup & Maintenance**
- **[backup-n8n.sh](backup-n8n.sh)** - [Backup-System](backup-n8n.sh#L40) mit [Encryption Key Support](backup-n8n.sh#L85)
- **[restore-n8n.sh](restore-n8n.sh)** - [Restore-System](restore-n8n.sh#L50) für [vollständige Wiederherstellung](restore-n8n.sh#L95)
- **[update-n8n.sh](update-n8n.sh)** - [Update-Management](update-n8n.sh#L25) für n8n-Versionen

---

## 🚀 Installation

### 🎯 **Quick Start Optionen**

#### 1️⃣ **Einfache Server-Installation**
```bash
# Repository klonen oder Skripte herunterladen
wget https://raw.githubusercontent.com/username/n8n-install/main/install-n8n.sh
chmod +x install-n8n.sh

# Installation starten (wird nach Installationsmethode gefragt)
sudo ./install-n8n.sh your-domain.com admin@your-domain.com

# Oder für lokale Installation
sudo ./install-n8n.sh localhost
```

#### 2️⃣ **Multi-Environment Development Setup** 📍 **[Detailliertes Guide →](MULTI-ENVIRONMENT.md)**
```bash
# Vollständiges Repository klonen
git clone https://github.com/username/n8n-install.git
cd n8n-install

# Development Environment erstellen
./setup-development.sh my-project development

# Multi-Environment Manager starten
./manage-environments.sh
```

#### 3️⃣ **Production-Ready mit Ansible** 📍 **[Environment Guide →](MULTI-ENVIRONMENT.md#ansible-pipeline)**
```bash
# Server-Konfiguration prüfen
./server-config.sh list production

# Vault für sichere Credentials
./manage-vault.sh init

# Installation auf allen Servern
./manage-environments.sh
# → [3] Production → [1] n8n installieren
```

### ⚙️ **Installationsoptionen während der Installation:**
1. **[Native Installation](install-n8n.sh#L45)** - Node.js + PostgreSQL direkt auf dem System
2. **[Docker Compose Installation](install-n8n.sh#L52)** - Containerisierte Lösung mit Docker

📍 **[→ Detaillierte Installationsanleitung](MULTI-ENVIRONMENT.md#workflow-entwicklung--deployment)**

---

## 🔧 Was wird installiert?

### 💻 **System-Komponenten**
- **Native**: [Node.js 18.x](install-n8n.sh#L120), [PostgreSQL](install-n8n.sh#L140) 
- **Docker**: [Docker CE](install-n8n.sh#L160), [Docker Compose](install-n8n.sh#L165)
- **[nginx als Reverse Proxy](setup-reverse-proxy.sh#L45)** für beide Installationstypen
- **[SSL-Zertifikate via Let's Encrypt](setup-reverse-proxy.sh#L85)** (bei Domain-Installation)
- **[UFW Firewall-Konfiguration](install-n8n.sh#L200)**

### ⚙️ **n8n-Konfiguration**
- **Native**: [Systemd Service](install-n8n.sh#L220) für automatischen Start
- **Docker**: [Docker Compose Services](docker-compose.yml) mit [Health Checks](manage-docker.sh#L125)
- **[PostgreSQL-Datenbank-Integration](install-n8n.sh#L140)** 
- **[Sichere Encryption Key Verwaltung](install-n8n.sh#L180)** in `/var/n8n/`
- **[Logging-Konfiguration](install-n8n.sh#L240)**
- **[Webhook-Support](install-n8n.sh#L260)**

### 🌍 **Multi-Environment Features** 📍 **[→ Vollständiger Guide](MULTI-ENVIRONMENT.md)**
- **[Development Environment](setup-development.sh)** - Lokale Git-basierte Entwicklung
- **[Pre-Production Pipeline](manage-environments.sh#L45)** - Staging & Testing
- **[Production Deployment](manage-environments.sh#L50)** - Sichere Live-Umgebung
- **[Ansible-Integration](import-workflows.sh#L85)** für automatisierte Deployments
- **[Vault-basierte Credential-Verwaltung](manage-vault.sh)**

---

## 🛠️ SSH-Management Setup 📍 **[→ SSH-Setup Details](setup-ssh-user.sh)**

```bash
# SSH-Zugang konfigurieren (wird automatisch bei Installation aufgerufen)
sudo ./setup-ssh-user.sh
```

### 🔐 **SSH-Benutzer Konfiguration**
- **[Odoo-Benutzer erstellen](setup-ssh-user.sh#L40)** mit n8n-Management-Rechten
- **[SSH-Key Authentifizierung](setup-ssh-user.sh#L65)** 
- **[Sudoers-Konfiguration](setup-ssh-user.sh#L85)** für n8n-spezifische Befehle
- **[Management-Aliases](setup-ssh-user.sh#L120)** für einfache Bedienung

### 🎛️ **Verfügbare SSH-Befehle** 📍 **[→ Alle Aliases](setup-ssh-user.sh#L120)**
```bash
# Status & Management
n8n-status      # [Status anzeigen](n8n-menu.sh#L45)
n8n-manage      # [Management-Menü](n8n-menu.sh#L25)
n8n-menu        # [Hauptverwaltungsmenü](n8n-menu.sh#L15)
n8n-domains     # [Domain-Management](manage-domains.sh)
n8n-docker      # [Docker-Verwaltung](manage-docker.sh) (nur bei Docker-Installation)

# Service-Steuerung
n8n-logs        # [Live-Logs anzeigen](n8n-menu.sh#L85)
n8n-start       # [n8n starten](n8n-menu.sh#L95)
n8n-stop        # [n8n stoppen](n8n-menu.sh#L105)
n8n-restart     # [n8n neustarten](n8n-menu.sh#L115)

# Backup & Restore
n8n-backup      # [Backup erstellen](backup-n8n.sh)
n8n-restore     # [Backup wiederherstellen](restore-n8n.sh)

# Multi-Environment (falls Setup vorhanden)
n8n-export      # [Workflows exportieren](export-workflows.sh)
n8n-import      # [Workflows importieren](import-workflows.sh)
n8n-vault       # [Vault-Management](manage-vault.sh)
```

---

## 🔄 Updates & Maintenance

### 🔄 **Standard Updates**

#### Native Installation
```bash
# n8n auf neueste Version aktualisieren
sudo ./update-n8n.sh
```
📍 **[→ Update-Script Details](update-n8n.sh)**

#### Docker Installation  
```bash
# Docker Images aktualisieren
sudo ./manage-docker.sh update
```
📍 **[→ Docker-Management Details](manage-docker.sh#L95)**

### 🌍 **Multi-Environment Updates** 📍 **[→ Environment Guide](MULTI-ENVIRONMENT.md#deployment)**

```bash
# Environment Manager für Updates
./manage-environments.sh
# → [Environment wählen] → [4] Update durchführen

# Oder direkt per Script
./import-workflows.sh development local
./import-workflows.sh preproduction staging-01
./import-workflows.sh production prod-01 --force
```

### 🔐 **Vault & Credential Updates**
```bash
# Vault-Manager für Credential-Updates
./manage-vault.sh edit production
./manage-vault.sh rekey preproduction
```
📍 **[→ Vault-Management Guide](manage-vault.sh)**

---

## 🐳 Docker-Verwaltung 📍 **[→ Docker Management Details](manage-docker.sh)**

### 🎛️ **Docker-Management-Interface**

```bash
# Interaktives Docker-Management
sudo ./manage-docker.sh
```
📍 **[→ Docker-Menü Interface](manage-docker.sh#L25)**

### ⚙️ **Docker-Management-Befehle**

```bash
# Status & Monitoring
sudo ./manage-docker.sh status     # [Container-Status](manage-docker.sh#L45)
sudo ./manage-docker.sh logs       # [Logs anzeigen](manage-docker.sh#L75)
sudo ./manage-docker.sh logs n8n   # [n8n-spezifische Logs](manage-docker.sh#L85)
sudo ./manage-docker.sh logs postgres  # [PostgreSQL Logs](manage-docker.sh#L95)

# Service-Steuerung
sudo ./manage-docker.sh start      # [Services starten](manage-docker.sh#L55)
sudo ./manage-docker.sh stop       # [Services stoppen](manage-docker.sh#L65)
sudo ./manage-docker.sh restart    # [Services neustarten](manage-docker.sh#L75)

# Container-Zugriff
sudo ./manage-docker.sh shell n8n      # [n8n Container Shell](manage-docker.sh#L105)
sudo ./manage-docker.sh shell postgres # [PostgreSQL Shell](manage-docker.sh#L115)

# Wartung
sudo ./manage-docker.sh update     # [Images aktualisieren](manage-docker.sh#L125)
sudo ./manage-docker.sh backup     # [Docker Volume Backup](manage-docker.sh#L135)
sudo ./manage-docker.sh cleanup    # [System aufräumen](manage-docker.sh#L145)
```

### 🔧 **Docker Compose Direktbefehle** 

```bash
# Im Docker-Verzeichnis
cd /opt/n8n

# Services verwalten
docker compose ps              # Status anzeigen
docker compose logs -f         # Logs verfolgen
docker compose up -d           # Services starten
docker compose down            # Services stoppen
docker compose restart         # Services neustarten
docker compose pull            # Images aktualisieren
```
📍 **[→ Docker Compose Konfiguration](docker-compose.yml)**

---

## 🔧 **Service-Befehle**

### Native Installation 📍 **[→ Native Setup](install-n8n.sh#L220)**
```bash
# Status prüfen
sudo systemctl status n8n

# Logs anzeigen
sudo journalctl -u n8n -f

# Service-Verwaltung
sudo systemctl start n8n
sudo systemctl stop n8n
sudo systemctl restart n8n
```

### Docker Installation 📍 **[→ Docker Management](manage-docker.sh)**
```bash
# Status prüfen
sudo ./manage-docker.sh status

# Logs anzeigen
sudo ./manage-docker.sh logs

# Service-Verwaltung
sudo ./manage-docker.sh start
sudo ./manage-docker.sh stop
sudo ./manage-docker.sh restart
```

### SSH-Aliases (nach Setup verfügbar) 📍 **[→ SSH-Setup](setup-ssh-user.sh#L120)**
```bash
# Einfache Befehle als odoo-User
n8n-status      # Status-Dashboard
n8n-start       # n8n starten
n8n-stop        # n8n stoppen
n8n-restart     # n8n neustarten
n8n-logs        # Live-Logs
```

---

## ⚙️ **Konfiguration**

### Native Installation 📍 **[→ Native Config](install-n8n.sh#L240)**
Die Hauptkonfiguration befindet sich in `/home/n8n/n8n/.env`:

```bash
# Konfiguration bearbeiten
sudo nano /home/n8n/n8n/.env

# Service nach Änderungen neustarten
sudo systemctl restart n8n
```

### Docker Installation 📍 **[→ Docker Config](docker-compose.yml)**
Die Konfiguration befindet sich in `/opt/n8n/.env`:

```bash
# Konfiguration bearbeiten
sudo nano /opt/n8n/.env

# Services nach Änderungen neustarten
sudo ./manage-docker.sh restart
```

### Multi-Environment Konfiguration 📍 **[→ Environment Config](MULTI-ENVIRONMENT.md#sicherheitskonzept)**
```bash
# Vault für sichere Konfiguration
./manage-vault.sh edit production
./manage-vault.sh view preproduction

# Server-spezifische Konfiguration
./server-config.sh config production
```

---

## 🌍 Workflow-Development & Multi-Environment

### 🛠️ **Lokale n8n-Entwicklung** 📍 **[→ Development Guide](MULTI-ENVIRONMENT.md)**

```bash
# 1. Development Environment erstellen
./setup-development.sh my-project development

# 2. Lokales n8n starten
cd ~/n8n-development/my-project/n8n-workflows
docker-compose -f docker-compose.development.yml up -d

# 3. n8n öffnen: http://localhost:5678
```
📍 **[→ Vollständiger Development Workflow](MULTI-ENVIRONMENT.md#workflow-entwicklung--deployment)**

### 📦 **Workflow-Management Pipeline**

#### 📤 **Export: n8n → Git** 📍 **[→ Export Script](export-workflows.sh)**
```bash
# Workflows aus n8n exportieren
./export-workflows.sh development
./export-workflows.sh preproduction staging-01
```

#### 📥 **Import: Git → n8n** 📍 **[→ Import Script](import-workflows.sh)**
```bash
# Workflows auf Server importieren
./import-workflows.sh preproduction staging-01
./import-workflows.sh production prod-01 --force
```

### 🌐 **Multi-Environment Management** 📍 **[→ Environment Manager](manage-environments.sh)**

```bash
# Zentraler Environment Manager
./manage-environments.sh

# Environments:
# [1] 🛠️ Development     - Lokale Entwicklung  
# [2] 🧪 Pre-Production  - Staging & Testing
# [3] 🏭 Production       - Live Environment
```

### 📋 **Server-Management** 📍 **[→ Server Config](server-config.sh)**

```bash
# Server-Listen anzeigen
./server-config.sh list development
./server-config.sh list preproduction
./server-config.sh list production

# Server-Status prüfen
./server-config.sh check production prod-01
./server-config.sh check preproduction  # Alle Server
```

### 🔐 **Sichere Credential-Verwaltung** 📍 **[→ Vault Management](manage-vault.sh)**

```bash
# Vault-Manager starten
./manage-vault.sh

# Oder direkt:
./manage-vault.sh edit production     # Production Credentials
./manage-vault.sh view preproduction   # Pre-Prod Credentials 
./manage-vault.sh encrypt development  # Development verschlüsseln
```

---

## 🆘 Troubleshooting & Support

### 🔍 **Diagnose-Tools**

#### Status-Checks
```bash
# Haupt-Status Dashboard
n8n-status                    # SSH-Alias für Status
./n8n-menu.sh                # Interaktives Menü mit Status

# Environment-spezifischer Status
./manage-environments.sh      # Multi-Environment Status
./server-config.sh check production  # Server-Connectivity
```

#### Log-Analyse 📍 **[→ Log-Management Details](n8n-menu.sh#L85)**
```bash
# Live-Logs
n8n-logs                     # SSH-Alias für Logs
sudo ./manage-docker.sh logs  # Docker-Logs
sudo journalctl -u n8n -f    # systemd-Logs (Native)

# Spezifische Logs
sudo ./manage-docker.sh logs n8n      # n8n Container  
sudo ./manage-docker.sh logs postgres # Database
tail -f /var/log/nginx/error.log      # nginx Errors
```

### 🔧 **Häufige Probleme & Lösungen**

#### Service-Probleme
```bash
# n8n startet nicht
sudo systemctl status n8n              # Status prüfen
sudo journalctl -u n8n --since "1 hour ago"  # Logs checken
./server-config.sh check development local   # Connectivity testen

# Docker-Probleme
sudo ./manage-docker.sh status         # Container Status
sudo docker-compose -f /opt/n8n/docker-compose.yml logs
```

#### Netzwerk & SSL
```bash
# SSL-Zertifikat Probleme
./manage-domains.sh                    # Domain-Manager
sudo certbot certificates              # Zertifikate prüfen
curl -I https://your-domain.com        # SSL-Test

# Port-Probleme
sudo ufw status                        # Firewall prüfen
sudo netstat -tlnp | grep :5678       # Port-Belegung
```

#### Multi-Environment Probleme 📍 **[→ Environment Troubleshooting](MULTI-ENVIRONMENT.md#support)**
```bash
# Ansible-Probleme
ansible-inventory -i ansible/inventories/production/hosts.yml --list
ansible-playbook --syntax-check ansible/playbooks/install-n8n-native.yml

# Vault-Probleme
./manage-vault.sh status              # Vault-Status
ansible-vault view ansible/group_vars/production/vault.yml

# Workflow-Import/Export Probleme
./export-workflows.sh development --backup  # Mit Backup
./import-workflows.sh production prod-01 --dry-run  # Test-Modus
```

### 📞 **Support-Ressourcen**

#### Dokumentation
- **[📖 Diese README](README.md)** - Hauptdokumentation
- **[🌍 Multi-Environment Guide](MULTI-ENVIRONMENT.md)** - Development → Production
- **[🚀 Feature-Übersicht](FEATURES.md)** - Alle Features im Detail

#### Debug-Informationen sammeln
```bash
# System-Info für Support
./n8n-menu.sh                         # [7] System Information
./manage-environments.sh               # [7] Status Dashboard
./manage-vault.sh status               # Vault-Status
./server-config.sh check production    # Server-Status
```

#### Quick-Recovery
```bash
# Service-Recovery
sudo systemctl restart n8n            # Native restart
sudo ./manage-docker.sh restart       # Docker restart

# Backup-Recovery (falls verfügbar)
n8n-restore                           # SSH-Alias
./restore-n8n.sh /var/backups/n8n/latest.tar.gz
```

---

## 🎯 Quick Reference

### 📋 **Wichtigste Befehle**
| Zweck | Befehl | Link |
|-------|--------|------|
| **Installation** | `sudo ./install-n8n.sh <domain>` | **[→](install-n8n.sh)** |
| **Multi-Environment** | `./manage-environments.sh` | **[→](manage-environments.sh)** |
| **Status-Check** | `n8n-status` | **[→](n8n-menu.sh#L45)** |
| **Logs** | `n8n-logs` | **[→](n8n-menu.sh#L85)** |
| **Docker-Verwaltung** | `./manage-docker.sh` | **[→](manage-docker.sh)** |
| **Workflow-Export** | `./export-workflows.sh <env>` | **[→](export-workflows.sh)** |
| **Workflow-Import** | `./import-workflows.sh <env> <server>` | **[→](import-workflows.sh)** |
| **Vault-Management** | `./manage-vault.sh` | **[→](manage-vault.sh)** |
| **Backup** | `n8n-backup` | **[→](backup-n8n.sh)** |
| **Restore** | `n8n-restore` | **[→](restore-n8n.sh)** |

### 🌍 **Environment-URLs**
- **Development**: http://localhost:5678
- **Pre-Production**: https://staging-01.example.com
- **Production**: https://prod-01.example.com

### 📁 **Wichtige Pfade**
- **Native Config**: `/home/n8n/n8n/.env`
- **Docker Config**: `/opt/n8n/.env` 
- **Encryption Keys**: `/var/n8n/encryption.key`
- **Backups**: `/var/backups/n8n/`
- **SSH Scripts**: `/home/odoo/`
- **Ansible Inventories**: `ansible/inventories/<env>/hosts.yml`
- **Vault Files**: `ansible/group_vars/<env>/vault.yml`

---

**🚀 Happy n8n Workflow Automation! 🎉**

> Bei Fragen oder Problemen: **[→ Troubleshooting Guide](#-troubleshooting--support)** oder **[→ Multi-Environment Documentation](MULTI-ENVIRONMENT.md)**

### 🎯 **Weitere Navigation**
- **[📚 Zentrale Navigation (INDEX)](INDEX.md)** - Alle Scripts und Dokumentationen
- **[🌍 Multi-Environment Guide](MULTI-ENVIRONMENT.md)** - Development → Production Workflow  
- **[🚀 Feature-Katalog](FEATURES.md)** - Technische Details aller Features