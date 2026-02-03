# 📚 n8n Suite - Dokumentations-Index

> **Zentrale Navigationshilfe zu allen Features, Scripts und Dokumentationen**

## 🎯 **Start hier für...**

### 📥 **Ich möchte n8n installieren**
- **Einfache Installation**: **[README.md → Installation](README.md#-installation)**
- **Multi-Environment Setup**: **[MULTI-ENVIRONMENT.md → Quick Start](MULTI-ENVIRONMENT.md#quick-start)**
- **Docker Installation**: **[README.md → Docker-Management](README.md#-docker-verwaltung)**

### 🛠️ **Ich möchte Workflows entwickeln**
- **Development Environment**: **[setup-development.sh](setup-development.sh)**
- **Export/Import Workflows**: **[README.md → Workflow-Management](README.md#-workflow-development--multi-environment)**
- **Git-basierter Workflow**: **[MULTI-ENVIRONMENT.md → Development Workflow](MULTI-ENVIRONMENT.md#workflow-entwicklung--deployment)**

### 🌍 **Ich möchte Multiple Environments verwalten**
- **Environment Manager**: **[manage-environments.sh](manage-environments.sh)**
- **Server-Konfiguration**: **[server-config.sh](server-config.sh)**
- **Multi-Environment Guide**: **[MULTI-ENVIRONMENT.md](MULTI-ENVIRONMENT.md)**

### 🔐 **Ich möchte Credentials sicher verwalten**
- **Vault-Manager**: **[manage-vault.sh](manage-vault.sh)**
- **Sicherheitskonzept**: **[MULTI-ENVIRONMENT.md → Sicherheitskonzept](MULTI-ENVIRONMENT.md#sicherheitskonzept)**

### 🆘 **Ich habe Probleme**
- **Troubleshooting**: **[README.md → Troubleshooting](README.md#-troubleshooting--support)**
- **Service-Probleme**: **[README.md → Service-Befehle](README.md#-service-befehle)**
- **Docker-Probleme**: **[manage-docker.sh](manage-docker.sh)**

---

## 📋 **Vollständige Script-Referenz**

### 🎯 **Installation & Setup**
| Script | Zweck | Quick Access | Dokumentation |
|--------|-------|-------------|---------------|
| **[install-n8n.sh](install-n8n.sh)** | Haupt-Installation | `sudo ./install-n8n.sh <domain>` | **[→ Guide](README.md#-installation)** |
| **[setup-ssh-user.sh](setup-ssh-user.sh)** | SSH-Benutzer Setup | Automatisch bei Installation | **[→ SSH-Setup](README.md#%EF%B8%8F-ssh-management-setup)** |
| **[setup-reverse-proxy.sh](setup-reverse-proxy.sh)** | Zusätzliche Domains | `sudo ./setup-reverse-proxy.sh <domain>` | **[→ Domain-Management](manage-domains.sh)** |
| **[setup-development.sh](setup-development.sh)** | Dev-Environment | `./setup-development.sh <name> <env>` | **[→ Development Guide](MULTI-ENVIRONMENT.md#lokale-n8n-entwicklung)** |

### 🌍 **Environment Management**
| Script | Zweck | Quick Access | Dokumentation |
|--------|-------|-------------|---------------|
| **[manage-environments.sh](manage-environments.sh)** | Multi-Environment Manager | `./manage-environments.sh` | **[→ Environment Guide](MULTI-ENVIRONMENT.md)** |
| **[server-config.sh](server-config.sh)** | Server-Listen verwalten | `./server-config.sh list <env>` | **[→ Server-Management](MULTI-ENVIRONMENT.md#server-management)** |
| **[manage-vault.sh](manage-vault.sh)** | Credential-Verwaltung | `./manage-vault.sh` | **[→ Vault Guide](MULTI-ENVIRONMENT.md#sichere-credential-verwaltung)** |

### 📦 **Workflow-Pipeline**
| Script | Zweck | Quick Access | Dokumentation |
|--------|-------|-------------|---------------|
| **[export-workflows.sh](export-workflows.sh)** | n8n → Git Export | `./export-workflows.sh <env>` | **[→ Export Guide](MULTI-ENVIRONMENT.md#export-n8n--git)** |
| **[import-workflows.sh](import-workflows.sh)** | Git → n8n Import | `./import-workflows.sh <env> <server>` | **[→ Import Guide](MULTI-ENVIRONMENT.md#import-git--n8n)** |

### 🎛️ **Management Interface**
| Script | Zweck | SSH-Alias | Dokumentation |
|--------|-------|-----------|---------------|
| **[n8n-menu.sh](n8n-menu.sh)** | Hauptverwaltungsmenü | `n8n-menu` | **[→ SSH-Befehle](README.md#%EF%B8%8F-verfügbare-ssh-befehle)** |
| **[manage-domains.sh](manage-domains.sh)** | Domain & SSL Management | `n8n-domains` | **[→ Domain-Management](README.md#%EF%B8%8F-server--environment-management)** |
| **[manage-docker.sh](manage-docker.sh)** | Docker Container-Verwaltung | `n8n-docker` | **[→ Docker Guide](README.md#-docker-verwaltung)** |

### 💾 **Backup & Maintenance**
| Script | Zweck | SSH-Alias | Dokumentation |
|--------|-------|-----------|---------------|
| **[backup-n8n.sh](backup-n8n.sh)** | Backup-System | `n8n-backup` | **[→ Backup Guide](README.md#-backup--maintenance)** |
| **[restore-n8n.sh](restore-n8n.sh)** | Restore-System | `n8n-restore` | **[→ Restore Guide](README.md#-backup--maintenance)** |
| **[update-n8n.sh](update-n8n.sh)** | Update-Management | `n8n-update` | **[→ Update Guide](README.md#-updates--maintenance)** |

---

## 📖 **Dokumentations-Roadmap**

### 1. **[README.md](README.md)** - Haupteinstieg
- **Zweck**: Erste Anlaufstelle für alle Nutzer
- **Inhalt**: Installation, Grundsetup, SSH-Management, Docker
- **Für wen**: Alle Nutzer, besonders Erstinstallation

### 2. **[MULTI-ENVIRONMENT.md](MULTI-ENVIRONMENT.md)** - Development → Production
- **Zweck**: Vollständiger Workflow-Guide für Entwickler
- **Inhalt**: Development Setup, Git-Integration, Ansible-Pipeline
- **Für wen**: Entwickler, DevOps-Teams, Multi-Environment-Nutzer

### 3. **[FEATURES.md](FEATURES.md)** - Feature-Katalog
- **Zweck**: Detaillierte Feature-Übersicht und technische Details
- **Inhalt**: Alle Funktionen, technische Spezifikationen, Performance
- **Für wen**: Technische Nutzer, Feature-Evaluation

### 4. **[INDEX.md](INDEX.md)** - Diese Datei
- **Zweck**: Navigation und Schnelleinstieg zu allen Bereichen
- **Inhalt**: Links, Quick-Reference, Wo-finde-ich-was
- **Für wen**: Alle Nutzer als Navigationshilfe

---

## 🎯 **Schnelleinstiege nach Anwendungsfall**

### 🏢 **Enterprise/Team-Setup**
1. **[Multi-Environment Manager starten](manage-environments.sh)**
2. **[Server-Konfiguration prüfen](server-config.sh)**
3. **[Vault für Credentials einrichten](manage-vault.sh)**
4. **[Production-Installation](MULTI-ENVIRONMENT.md#production-deployment)**

### 👨‍💻 **Developer-Workflow**
1. **[Development Environment erstellen](setup-development.sh)**
2. **[Lokales n8n starten](MULTI-ENVIRONMENT.md#lokale-entwicklung-starten)**
3. **[Workflows entwickeln und exportieren](export-workflows.sh)**
4. **[Auf Staging deployen](import-workflows.sh)**

### 🖥️ **Single-Server Setup**
1. **[Einfache Installation](install-n8n.sh)**
2. **[SSH-Zugang einrichten](setup-ssh-user.sh)**
3. **[Status über SSH prüfen](README.md#%EF%B8%8F-verfügbare-ssh-befehle)**

### 🐳 **Docker-only Setup**
1. **[Docker-Installation wählen](install-n8n.sh)** (Option 2)
2. **[Docker-Management lernen](manage-docker.sh)**
3. **[Container-Verwaltung](README.md#-docker-verwaltung)**

### 🔧 **Maintenance & Troubleshooting**
1. **[Status-Dashboard nutzen](n8n-menu.sh)**
2. **[Logs analysieren](README.md#log-analyse)**
3. **[Backup-Strategie](backup-n8n.sh)**
4. **[Troubleshooting-Guide](README.md#-troubleshooting--support)**

---

## 🔍 **Suche nach Themen**

### 🔐 **Security**
- **[Vault-Management](manage-vault.sh)** - Sichere Credentials
- **[SSH-Setup](setup-ssh-user.sh)** - Sichere Server-Zugriffe
- **[SSL-Zertifikate](setup-reverse-proxy.sh)** - HTTPS-Verschlüsselung
- **[Firewall](install-n8n.sh#L200)** - UFW-Konfiguration

### 🚀 **Performance**
- **[Docker vs Native](README.md#%EF%B8%8F-installationsoptionen-während-der-installation)** - Performance-Vergleich
- **[System-Monitoring](n8n-menu.sh)** - Resource-Überwachung
- **[Update-Management](update-n8n.sh)** - Performance-Updates

### 🔧 **Administration**
- **[Service-Management](README.md#-service-befehle)** - Start/Stop/Restart
- **[Log-Management](README.md#log-analyse)** - Logging & Debugging
- **[Backup-Strategien](README.md#-backup--maintenance)** - Datensicherung

### 🌐 **Network**
- **[Domain-Management](manage-domains.sh)** - DNS & SSL
- **[Reverse Proxy](setup-reverse-proxy.sh)** - nginx-Konfiguration
- **[Firewall-Setup](install-n8n.sh)** - Port-Konfiguration

---

## 📱 **Mobile-Friendly Navigation**

### 📋 **Quick Commands**
```bash
# Status prüfen
n8n-status

# Logs anzeigen
n8n-logs

# Restart
n8n-restart

# Backup
n8n-backup

# Multi-Environment
./manage-environments.sh

# Docker-Management
./manage-docker.sh
```

### 🔗 **Important Links**
- **[Installation starten](README.md#-installation)**
- **[Development Setup](MULTI-ENVIRONMENT.md#development-environment-erstellen)**
- **[Troubleshooting](README.md#-troubleshooting--support)**
- **[SSH-Commands](README.md#%EF%B8%8F-verfügbare-ssh-befehle)**

---

**🎯 Diese Index-Datei hilft dir, schnell zu finden was du suchst! Bei Fragen folge den Links zur detaillierten Dokumentation.**