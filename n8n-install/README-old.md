# n8n Installation und Verwaltung für Ubuntu Server

Dieses Repository enthält Shell-Skripte zur automatischen Installation und Verwaltung von n8n auf einem Ubuntu Server mit PostgreSQL-Datenbank und SSH-Zugang für den Benutzer "odoo".

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

## 🚀 Schnellstart

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

### 2. SSH-User odoo einrichten

```bash
wget https://raw.githubusercontent.com/username/n8n-install/main/setup-ssh-user.sh
chmod +x setup-ssh-user.sh
sudo ./setup-ssh-user.sh
```

### 3. Zusätzliche Domains einrichten (Optional)

```bash
# Neue Domain mit SSL hinzufügen
sudo ./setup-reverse-proxy.sh staging.example.com admin@example.com

# Domain ohne SSL auf anderem Port
sudo ./setup-reverse-proxy.sh dev.example.com admin@example.com 5679 false
```

### 4. Verwaltungsmenü verwenden

```bash
# Hauptmenü starten (als root)
sudo ./n8n-menu.sh

# Domain-Management
./manage-domains.sh
```

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

### SSH-Zugang
- Benutzer "odoo" mit sudo-Rechten
- Management-Skripte für n8n
- Sichere SSH-Konfiguration
- Interaktive Verwaltungstools

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

### Native Installation
```
/home/n8n/n8n/          # n8n Arbeitsverzeichnis
├── .env                # Umgebungsvariablen
├── logs/               # Log-Dateien
└── ...
```

### Docker Installation
```
/opt/n8n/               # Docker Compose Verzeichnis
├── docker-compose.yml  # Docker Services
└── .env                # Umgebungsvariablen

# Docker Volumes
n8n_data                # n8n Anwendungsdaten
postgres_data           # PostgreSQL Datenbank
```

### Gemeinsam
```
/var/n8n/               # Encryption Key Speicher
└── encryption.key      # Sichere Schlüsseldatei

/home/odoo/             # SSH-Benutzer Verzeichnis
├── n8n-status.sh      # Status-Dashboard
├── n8n-manage.sh      # Management-Menü
└── .ssh/              # SSH-Konfiguration

/var/backups/n8n/      # Backup-Verzeichnis
```

## 🔑 SSH-Zugang für odoo

Nach der Installation mit `setup-ssh-user.sh`:

```bash
# SSH-Verbindung herstellen
ssh odoo@your-server-ip

# Verfügbare Befehle
n8n-status    # Status anzeigen
n8n-manage    # Management-Menü
n8n-menu      # Hauptverwaltungsmenü
n8n-domains   # Domain-Management
n8n-docker    # Docker-Verwaltung (nur bei Docker-Installation)
n8n-logs      # Live-Logs anzeigen
n8n-start     # n8n starten
n8n-stop      # n8n stoppen
n8n-restart   # n8n neustarten
```

### SSH-Schlüssel hinzufügen

```bash
# Auf dem Server
sudo nano /home/odoo/.ssh/authorized_keys
# Fügen Sie Ihren öffentlichen SSH-Schlüssel ein

# Oder Passwort setzen
sudo passwd odoo
```

## 💾 Backup und Restore

### Backup erstellen

```bash
# Manuelles Backup
sudo ./backup-n8n.sh

# Automatisches tägliches Backup (Crontab)
echo "0 2 * * * /root/backup-n8n.sh" | sudo crontab -
```

### Backup wiederherstellen

```bash
# Verfügbare Backups anzeigen
sudo ./restore-n8n.sh

# Backup wiederherstellen
sudo ./restore-n8n.sh 20240202_143000
```

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

## 🛠️ Verwaltung

### 🔧 **Service-Befehle**

#### Native Installation 📍 **[→ Native Setup](install-n8n.sh#L220)**
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

#### Docker Installation 📍 **[→ Docker Management](manage-docker.sh)**
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

#### SSH-Aliases (nach Setup verfügbar) 📍 **[→ SSH-Setup](setup-ssh-user.sh#L120)**
```bash
# Einfache Befehle als odoo-User
n8n-status      # Status-Dashboard
n8n-start       # n8n starten
n8n-stop        # n8n stoppen
n8n-restart     # n8n neustarten
n8n-logs        # Live-Logs
```

### ⚙️ **Konfiguration**

#### Native Installation 📍 **[→ Native Config](install-n8n.sh#L240)**
Die Hauptkonfiguration befindet sich in `/home/n8n/n8n/.env`:

```bash
# Konfiguration bearbeiten
sudo nano /home/n8n/n8n/.env

# Service nach Änderungen neustarten
sudo systemctl restart n8n
```

#### Docker Installation 📍 **[→ Docker Config](docker-compose.yml)**
Die Konfiguration befindet sich in `/opt/n8n/.env`:

```bash
# Konfiguration bearbeiten
sudo nano /opt/n8n/.env

# Services nach Änderungen neustarten
sudo ./manage-docker.sh restart
```

#### Multi-Environment Konfiguration 📍 **[→ Environment Config](MULTI-ENVIRONMENT.md#sicherheitskonzept)**
```bash
# Vault für sichere Konfiguration
./manage-vault.sh edit production
./manage-vault.sh view preproduction

# Server-spezifische Konfiguration
./server-config.sh config production
```

## 🌐 Zugriff

### Web-Interface

- **Hauptdomain**: `https://your-domain.com`
- **Zusätzliche Domains**: `https://staging.example.com`, `https://dev.example.com`
- **Lokal**: `http://localhost:5678`

### Multi-Domain Setup

```bash
# Verschiedene Umgebungen auf einer Installation
sudo ./setup-reverse-proxy.sh staging.example.com admin@example.com 5678 true
sudo ./setup-reverse-proxy.sh dev.example.com admin@example.com 5679 false
sudo ./setup-reverse-proxy.sh api.example.com admin@example.com 5680 true
```

### Domain-Verwaltung

```bash
# Domains anzeigen
./manage-domains.sh list

# Domain hinzufügen
./manage-domains.sh add new.example.com admin@example.com

# Domain entfernen
./manage-domains.sh remove old.example.com

# Domain-Status prüfen
./manage-domains.sh status example.com
```

### Ersteinrichtung

1. Öffnen Sie die Web-URL im Browser
2. Erstellen Sie einen Admin-Benutzer
3. Beginnen Sie mit der Konfiguration Ihrer Workflows

## 🔒 Sicherheit

### Implementierte Sicherheitsmaßnahmen

- SSL/TLS-Verschlüsselung
- Firewall-Konfiguration (UFW)
- Sichere PostgreSQL-Konfiguration
- SSH-Schlüssel-Authentifizierung
- Systemd-Härtung
- Nginx-Sicherheits-Header

### Empfohlene zusätzliche Maßnahmen

```bash
# Fail2ban installieren
sudo apt install fail2ban

# SSH-Port ändern (optional)
sudo nano /etc/ssh/sshd_config
# Port 22 zu Port 2222 ändern

# Automatische Sicherheitsupdates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades
```

## 🗃️ Datenbank

### Verbindungsdetails

```bash
# Datenbank-Credentials anzeigen
sudo cat /root/n8n-db-credentials.txt

# PostgreSQL-Shell öffnen
sudo -u postgres psql n8n_db
```

### Datenbankgröße prüfen

```sql
-- In PostgreSQL-Shell
SELECT pg_size_pretty(pg_database_size('n8n_db'));
```

## 📊 Monitoring

### System-Monitoring

```bash
# Prozess-Status
ps aux | grep n8n

# Speicherverbrauch
free -h

# Festplattenbelegung
df -h

# Port-Status
netstat -tlnp | grep 5678
```

### Log-Analyse

```bash
# Fehler-Logs
sudo journalctl -u n8n --since today | grep ERROR

# Letzte Starts
sudo journalctl -u n8n --since "1 hour ago"

# Log-Größe begrenzen
sudo journalctl --vacuum-size=100M
```

## 🚨 Troubleshooting

### Häufige Probleme

#### n8n startet nicht

```bash
# Logs prüfen
sudo journalctl -u n8n -n 50

# Konfiguration prüfen
sudo -u n8n n8n start --check

# Berechtigungen prüfen
ls -la /home/n8n/n8n/
```

#### Datenbank-Verbindungsprobleme

```bash
# PostgreSQL-Status
sudo systemctl status postgresql

# Datenbank-Verbindung testen
sudo -u postgres psql -c "\l"

# n8n-Benutzer-Berechtigung prüfen
sudo -u postgres psql -c "\du"
```

#### SSL-Probleme

```bash
# Zertifikat erneuern
sudo certbot renew

# Nginx-Konfiguration testen
sudo nginx -t

# SSL-Status prüfen
openssl s_client -connect your-domain.com:443
```

## 🔧 Anpassungen

### Erweiterte Konfiguration

```bash
# .env-Datei anpassen
sudo nano /home/n8n/n8n/.env

# Wichtige Einstellungen:
# N8N_PORT=5678
# N8N_PROTOCOL=https
# WEBHOOK_URL=https://your-domain.com/
# N8N_ENCRYPTION_KEY=your-key
```

### Nginx-Konfiguration

```bash
# Nginx-Konfiguration bearbeiten
sudo nano /etc/nginx/sites-available/n8n

# Konfiguration testen
sudo nginx -t

# Nginx neuladen
sudo systemctl reload nginx
```

## 📈 Performance-Optimierung

### Node.js-Speicher erhöhen

```bash
# Systemd-Service bearbeiten
sudo systemctl edit n8n

# Hinzufügen:
[Service]
Environment="NODE_OPTIONS=--max-old-space-size=4096"
```

### PostgreSQL-Optimierung

```bash
# PostgreSQL-Konfiguration
sudo nano /etc/postgresql/*/main/postgresql.conf

# Empfohlene Einstellungen für kleine bis mittlere Installationen:
# shared_buffers = 256MB
# effective_cache_size = 1GB
# work_mem = 4MB
```

## 📞 Support

### Debugging aktivieren

```bash
# Debug-Modus in .env
echo "N8N_LOG_LEVEL=debug" | sudo tee -a /home/n8n/n8n/.env
sudo systemctl restart n8n
```

### Community-Ressourcen

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
- [n8n GitHub Repository](https://github.com/n8n-io/n8n)

## ⚖️ Lizenz

Diese Skripte sind unter der MIT-Lizenz lizenziert. Siehe LICENSE-Datei für Details.

## 🤝 Beitrag leisten

Beiträge sind willkommen! Bitte öffnen Sie ein Issue oder erstellen Sie einen Pull Request.

---

**Hinweis**: Diese Skripte sind für Produktionsumgebungen geeignet, aber stellen Sie sicher, dass Sie sie zuerst in einer Testumgebung testen.