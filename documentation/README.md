# 🚀 n8n Installation & Multi-Environment Management Suite

> **Complete n8n installation with local development, Git integration, and Ansible-based multi-environment deployment**

## 🎯 Why This Suite Exists

**The Problem with Direct n8n Development:**
- ❌ **Error-prone**: Creating workflows directly in production n8n instances is risky
- ❌ **No versioning**: Changes can't be tracked, rolled back, or collaborated on
- ❌ **Not scalable**: Manual workflow management across multiple environments fails
- ❌ **No testing**: No safe environment to test before going live
- ❌ **Lost work**: Accidental deletions or overwrites with no recovery

**The Solution - Professional n8n Development:**
- ✅ **Local Development**: Safe environment for workflow creation and testing
- ✅ **Git Integration**: Version control, collaboration, and change tracking
- ✅ **Multi-Environment Pipeline**: Development → Staging → Production workflow
- ✅ **Automated Deployment**: Ansible-based deployment with backup and rollback
- ✅ **Scalable Architecture**: Manage multiple servers and environments efficiently

**This suite transforms n8n from a tool into a professional automation platform**, enabling teams to develop, test, and deploy workflows with enterprise-grade reliability and DevOps best practices.

## 📋 Quick Navigation

### 🎯 **Main Documentation**
| Document | Description | Direct Link |
|----------|-------------|-------------|
| **[📑 INDEX](INDEX.md)** | **Central Navigation to EVERYTHING** | **[🎯 Jump Here](INDEX.md)** |
| **[📖 This README](README.md)** | Main Documentation & Installation | You are here |
| **[🌍 Multi-Environment Guide](MULTI-ENVIRONMENT.md)** | Development → Production Workflow | [Jump Here](MULTI-ENVIRONMENT.md) |
| **[🚀 Feature Overview](FEATURES.md)** | All Available Features in Detail | [Jump Here](FEATURES.md) |

### 🛠️ **Management Tools** 
| Tool | Purpose | Quick Launch |
|------|---------|-------------|
| **[🌐 Multi-Environment Manager](manage-environments.sh)** | Central Environment Management | `./manage-environments.sh` |
| **[🔧 Main Installation](install-n8n.sh)** | Install n8n (Native/Docker) | `./install-n8n.sh <domain> <email>` |
| **[🎛️ n8n Management Menu](n8n-menu.sh)** | All n8n Operations | `./n8n-menu.sh` |
| **[🔐 Vault Manager](manage-vault.sh)** | Secure Credential Management | `./manage-vault.sh` |

### 📦 **Workflow Management**
| Script | Function | Usage |
|--------|----------|-------|
| **[📤 Export](export-workflows.sh)** | n8n → Git Export | `./export-workflows.sh <environment>` |
| **[📥 Import](import-workflows.sh)** | Git → n8n Import | `./import-workflows.sh <env> <server>` |
| **[🏗️ Development Setup](setup-development.sh)** | Create Dev Environment | `./setup-development.sh <name> <env>` |

### ⚙️ **Server & Environment Management**
| Tool | Purpose | Quick Access |
|------|---------|-------------|
| **[📋 Server Configuration](server-config.sh)** | Manage Server Lists | `./server-config.sh list <env>` |
| **[🐳 Docker Management](manage-docker.sh)** | Container Management | `./manage-docker.sh status` |
| **[🌐 Domain Management](manage-domains.sh)** | SSL & Domains | SSH: `n8n-domains` |

### 💾 **Backup & Maintenance**
| Script | Function | SSH Alias |
|--------|----------|----------|
| **[💾 Backup](backup-n8n.sh)** | Create n8n Backup | `n8n-backup` |
| **[🔄 Restore](restore-n8n.sh)** | Restore Backup | `n8n-restore` |
| **[🔄 Update](../scripts/host/update-n8n.sh)** | Update n8n | `n8n-update` |

---

## 📋 Suite Components

### 🎯 **Core Installation**
- **[install-n8n.sh](install-n8n.sh)** - Complete n8n installation ([Native](install-n8n.sh#L45) or [Docker](install-n8n.sh#L52))
- **[setup-ssh-user.sh](setup-ssh-user.sh)** - Configure SSH access for [odoo user](setup-ssh-user.sh#L30)
- **[setup-reverse-proxy.sh](setup-reverse-proxy.sh)** - [Additional domains](setup-reverse-proxy.sh#L15) with reverse proxy

### 🌍 **Multi-Environment System** 
- **[manage-environments.sh](manage-environments.sh)** - [Central environment management](manage-environments.sh#L25) ([Dev](manage-environments.sh#L40), [Pre-Prod](manage-environments.sh#L45), [Production](manage-environments.sh#L50))
- **[setup-development.sh](setup-development.sh)** - [Local development environment](setup-development.sh#L35) with Git
- **[server-config.sh](server-config.sh)** - [Server list configuration](server-config.sh#L15) per environment
- **[manage-vault.sh](manage-vault.sh)** - [Ansible Vault management](manage-vault.sh#L25) for secure credentials

### 📦 **Workflow Pipeline**
- **[export-workflows.sh](export-workflows.sh)** - [n8n → Git export](export-workflows.sh#L40) with [backup option](export-workflows.sh#L65)
- **[import-workflows.sh](import-workflows.sh)** - [Git → n8n import](import-workflows.sh#L55) via [Ansible](import-workflows.sh#L85)

### 🎛️ **Management Interface**
- **[n8n-menu.sh](n8n-menu.sh)** - [Main management menu](n8n-menu.sh#L20) with all options
- **[manage-domains.sh](manage-domains.sh)** - [Domain management](manage-domains.sh#L30) and [SSL management](manage-domains.sh#L65)
- **[manage-docker.sh](manage-docker.sh)** - [Docker Compose management](manage-docker.sh#L25) ([Status](manage-docker.sh#L45), [Logs](manage-docker.sh#L75), [Updates](manage-docker.sh#L95))

### 💾 **Backup & Maintenance**
- **[backup-n8n.sh](backup-n8n.sh)** - [Backup system](backup-n8n.sh#L40) with [encryption key support](backup-n8n.sh#L85)
- **[restore-n8n.sh](restore-n8n.sh)** - [Restore system](restore-n8n.sh#L50) for [complete recovery](restore-n8n.sh#L95)
- **[update-n8n.sh](../scripts/host/update-n8n.sh)** - [Update management](../scripts/host/update-n8n.sh#L25) for n8n versions

---

## 🚀 Installation

### 🎯 **Quick Start Options**

#### 1️⃣ **Simple Server Installation**
```bash
# Clone repository or download scripts
wget https://raw.githubusercontent.com/Hammdie/n8n-install/main/install-n8n.sh
chmod +x install-n8n.sh

# Start installation (will ask for installation method)
sudo ./install-n8n.sh your-domain.com admin@your-domain.com

# Or for local installation
sudo ./install-n8n.sh localhost
```

#### 2️⃣ **Multi-Environment Development Setup** 📍 **[Detailed Guide →](MULTI-ENVIRONMENT.md)**
```bash
# Clone complete repository
git clone https://github.com/Hammdie/n8n-install.git
cd n8n-install

# Create development environment
./setup-development.sh my-project development

# Start multi-environment manager
./manage-environments.sh
```

#### 3️⃣ **Production-Ready with Ansible** 📍 **[Environment Guide →](MULTI-ENVIRONMENT.md#ansible-pipeline)**
```bash
# Check server configuration
./server-config.sh list production

# Vault for secure credentials
./manage-vault.sh init

# Install on all servers
./manage-environments.sh
# → [3] Production → [1] Install n8n
```

### ⚙️ **Installation Options During Setup:**
1. **[Native Installation](install-n8n.sh#L45)** - Node.js + PostgreSQL directly on system
2. **[Docker Compose Installation](install-n8n.sh#L52)** - Containerized solution with Docker

📍 **[→ Detailed Installation Guide](MULTI-ENVIRONMENT.md#workflow-development--deployment)**

---

## 🔧 What Gets Installed?

### 💻 **System Components**
- **Native**: [Node.js 18.x](install-n8n.sh#L120), [PostgreSQL](install-n8n.sh#L140) 
- **Docker**: [Docker CE](install-n8n.sh#L160), [Docker Compose](install-n8n.sh#L165)
- **[nginx as reverse proxy](setup-reverse-proxy.sh#L45)** for both installation types
- **[SSL certificates via Let's Encrypt](setup-reverse-proxy.sh#L85)** (for domain installations)
- **[UFW firewall configuration](install-n8n.sh#L200)**

### ⚙️ **n8n Configuration**
- **Native**: [Systemd service](install-n8n.sh#L220) for automatic startup
- **Docker**: [Docker Compose services](docker-compose.yml) with [health checks](manage-docker.sh#L125)
- **[PostgreSQL database integration](install-n8n.sh#L140)** 
- **[Secure encryption key management](install-n8n.sh#L180)** in `/var/n8n/`
- **[Logging configuration](install-n8n.sh#L240)**
- **[Webhook support](install-n8n.sh#L260)**

### 🌍 **Multi-Environment Features** 📍 **[→ Complete Guide](MULTI-ENVIRONMENT.md)**
- **[Development Environment](setup-development.sh)** - Local Git-based development
- **[Pre-Production Pipeline](manage-environments.sh#L45)** - Staging & Testing
- **[Production Deployment](manage-environments.sh#L50)** - Secure live environment
- **[Ansible Integration](import-workflows.sh#L85)** for automated deployments
- **[Vault-based credential management](manage-vault.sh)**

---

## 🛠️ SSH Management Setup 📍 **[→ SSH Setup Details](setup-ssh-user.sh)**

```bash
# Configure SSH access (automatically called during installation)
sudo ./setup-ssh-user.sh
```

### 🔐 **SSH User Configuration**
- **[Create odoo user](setup-ssh-user.sh#L40)** with n8n management permissions
- **[SSH key authentication](setup-ssh-user.sh#L65)** 
- **[Sudoers configuration](setup-ssh-user.sh#L85)** for n8n-specific commands
- **[Management aliases](setup-ssh-user.sh#L120)** for easy operation

### 🎛️ **Available SSH Commands** 📍 **[→ All Aliases](setup-ssh-user.sh#L120)**
```bash
# Status & Management
n8n-status      # [Show status](n8n-menu.sh#L45)
n8n-manage      # [Management menu](n8n-menu.sh#L25)
n8n-menu        # [Main management menu](n8n-menu.sh#L15)
n8n-domains     # [Domain management](manage-domains.sh)
n8n-docker      # [Docker management](manage-docker.sh) (Docker installation only)

# Service Control
n8n-logs        # [Show live logs](n8n-menu.sh#L85)
n8n-start       # [Start n8n](n8n-menu.sh#L95)
n8n-stop        # [Stop n8n](n8n-menu.sh#L105)
n8n-restart     # [Restart n8n](n8n-menu.sh#L115)

# Backup & Restore
n8n-backup      # [Create backup](backup-n8n.sh)
n8n-restore     # [Restore backup](restore-n8n.sh)

# Multi-Environment (if setup available)
n8n-export      # [Export workflows](export-workflows.sh)
n8n-import      # [Import workflows](import-workflows.sh)
n8n-vault       # [Vault management](manage-vault.sh)
```

---

## 🔄 Updates & Maintenance

### 🔄 **Standard Updates**

#### Native Installation
```bash
# Update n8n to latest version
sudo ./scripts/host/update-n8n.sh
```
📍 **[→ Update Script Details](../scripts/host/update-n8n.sh)**

#### Docker Installation  
```bash
# Update Docker images
sudo ./manage-docker.sh update
```
📍 **[→ Docker Management Details](manage-docker.sh#L95)**

### 🌍 **Multi-Environment Updates** 📍 **[→ Environment Guide](MULTI-ENVIRONMENT.md#deployment)**

```bash
# Environment manager for updates
./manage-environments.sh
# → [Select Environment] → [4] Perform update

# Or directly via script
./import-workflows.sh development local
./import-workflows.sh preproduction staging-01
./import-workflows.sh production prod-01 --force
```

### 🔐 **Vault & Credential Updates**
```bash
# Vault manager for credential updates
./manage-vault.sh edit production
./manage-vault.sh rekey preproduction
```
📍 **[→ Vault Management Guide](manage-vault.sh)**

---

## 🐳 Docker Management 📍 **[→ Docker Management Details](manage-docker.sh)**

### 🎛️ **Docker Management Interface**

```bash
# Interactive Docker management
sudo ./manage-docker.sh
```
📍 **[→ Docker Menu Interface](manage-docker.sh#L25)**

### ⚙️ **Docker Management Commands**

```bash
# Status & Monitoring
sudo ./manage-docker.sh status     # [Container status](manage-docker.sh#L45)
sudo ./manage-docker.sh logs       # [Show logs](manage-docker.sh#L75)
sudo ./manage-docker.sh logs n8n   # [n8n-specific logs](manage-docker.sh#L85)
sudo ./manage-docker.sh logs postgres  # [PostgreSQL logs](manage-docker.sh#L95)

# Service Control
sudo ./manage-docker.sh start      # [Start services](manage-docker.sh#L55)
sudo ./manage-docker.sh stop       # [Stop services](manage-docker.sh#L65)
sudo ./manage-docker.sh restart    # [Restart services](manage-docker.sh#L75)

# Container Access
sudo ./manage-docker.sh shell n8n      # [n8n container shell](manage-docker.sh#L105)
sudo ./manage-docker.sh shell postgres # [PostgreSQL shell](manage-docker.sh#L115)

# Maintenance
sudo ./manage-docker.sh update     # [Update images](manage-docker.sh#L125)
sudo ./manage-docker.sh backup     # [Docker volume backup](manage-docker.sh#L135)
sudo ./manage-docker.sh cleanup    # [Clean up system](manage-docker.sh#L145)
```

### 🔧 **Docker Compose Direct Commands** 

```bash
# In Docker directory
cd /opt/n8n

# Manage services
docker compose ps              # Show status
docker compose logs -f         # Follow logs
docker compose up -d           # Start services
docker compose down            # Stop services
docker compose restart         # Restart services
docker compose pull            # Update images
```
📍 **[→ Docker Compose Configuration](docker-compose.yml)**

---

## 🔧 **Service Commands**

### Native Installation 📍 **[→ Native Setup](install-n8n.sh#L220)**
```bash
# Check status
sudo systemctl status n8n

# Show logs
sudo journalctl -u n8n -f

# Service management
sudo systemctl start n8n
sudo systemctl stop n8n
sudo systemctl restart n8n
```

### Docker Installation 📍 **[→ Docker Management](manage-docker.sh)**
```bash
# Check status
sudo ./manage-docker.sh status

# Show logs
sudo ./manage-docker.sh logs

# Service management
sudo ./manage-docker.sh start
sudo ./manage-docker.sh stop
sudo ./manage-docker.sh restart
```

### SSH Aliases (available after setup) 📍 **[→ SSH Setup](setup-ssh-user.sh#L120)**
```bash
# Simple commands as odoo user
n8n-status      # Status dashboard
n8n-start       # Start n8n
n8n-stop        # Stop n8n
n8n-restart     # Restart n8n
n8n-logs        # Live logs
```

---

## ⚙️ **Configuration**

### Native Installation 📍 **[→ Native Config](install-n8n.sh#L240)**
Main configuration is located in `/home/n8n/n8n/.env`:

```bash
# Edit configuration
sudo nano /home/n8n/n8n/.env

# Restart service after changes
sudo systemctl restart n8n
```

### Docker Installation 📍 **[→ Docker Config](docker-compose.yml)**
Configuration is located in `/opt/n8n/.env`:

```bash
# Edit configuration
sudo nano /opt/n8n/.env

# Restart services after changes
sudo ./manage-docker.sh restart
```

### Multi-Environment Configuration 📍 **[→ Environment Config](MULTI-ENVIRONMENT.md#security-concept)**
```bash
# Vault for secure configuration
./manage-vault.sh edit production
./manage-vault.sh view preproduction

# Server-specific configuration
./server-config.sh config production
```

---

## 🌍 Workflow Development & Multi-Environment

### 🛠️ **Local n8n Development** 📍 **[→ Development Guide](MULTI-ENVIRONMENT.md)**

```bash
# 1. Create development environment
./setup-development.sh my-project development

# 2. Start local n8n
cd ~/n8n-development/my-project/n8n-workflows
docker-compose -f docker-compose.development.yml up -d

# 3. Open n8n: http://localhost:5678
```
📍 **[→ Complete Development Workflow](MULTI-ENVIRONMENT.md#workflow-development--deployment)**

### 📦 **Workflow Management Pipeline**

#### 📤 **Export: n8n → Git** 📍 **[→ Export Script](export-workflows.sh)**
```bash
# Export workflows from n8n
./export-workflows.sh development
./export-workflows.sh preproduction staging-01
```

#### 📥 **Import: Git → n8n** 📍 **[→ Import Script](import-workflows.sh)**
```bash
# Import workflows to server
./import-workflows.sh preproduction staging-01
./import-workflows.sh production prod-01 --force
```

### 🌐 **Multi-Environment Management** 📍 **[→ Environment Manager](manage-environments.sh)**

```bash
# Central environment manager
./manage-environments.sh

# Environments:
# [1] 🛠️ Development     - Local development  
# [2] 🧪 Pre-Production  - Staging & testing
# [3] 🏭 Production       - Live environment
```

### 📋 **Server Management** 📍 **[→ Server Config](server-config.sh)**

```bash
# Show server lists
./server-config.sh list development
./server-config.sh list preproduction
./server-config.sh list production

# Check server status
./server-config.sh check production prod-01
./server-config.sh check preproduction  # All servers
```

### 🔐 **Secure Credential Management** 📍 **[→ Vault Management](manage-vault.sh)**

```bash
# Start vault manager
./manage-vault.sh

# Or directly:
./manage-vault.sh edit production     # Production credentials
./manage-vault.sh view preproduction   # Pre-prod credentials 
./manage-vault.sh encrypt development  # Encrypt development
```

---

## 🆘 Troubleshooting & Support

### 🔍 **Diagnostic Tools**

#### Status Checks
```bash
# Main status dashboard
n8n-status                    # SSH alias for status
./n8n-menu.sh                # Interactive menu with status

# Environment-specific status
./manage-environments.sh      # Multi-environment status
./server-config.sh check production  # Server connectivity
```

#### Log Analysis 📍 **[→ Log Management Details](n8n-menu.sh#L85)**
```bash
# Live logs
n8n-logs                     # SSH alias for logs
sudo ./manage-docker.sh logs  # Docker logs
sudo journalctl -u n8n -f    # systemd logs (Native)

# Specific logs
sudo ./manage-docker.sh logs n8n      # n8n container  
sudo ./manage-docker.sh logs postgres # Database
tail -f /var/log/nginx/error.log      # nginx errors
```

### 🔧 **Common Problems & Solutions**

#### Service Problems
```bash
# n8n won't start
sudo systemctl status n8n              # Check status
sudo journalctl -u n8n --since "1 hour ago"  # Check logs
./server-config.sh check development local   # Test connectivity

# Docker problems
sudo ./manage-docker.sh status         # Container status
sudo docker-compose -f /opt/n8n/docker-compose.yml logs
```

#### Network & SSL
```bash
# SSL certificate problems
./manage-domains.sh                    # Domain manager
sudo certbot certificates              # Check certificates
curl -I https://your-domain.com        # SSL test

# Port problems
sudo ufw status                        # Check firewall
sudo netstat -tlnp | grep :5678       # Port usage
```

#### Multi-Environment Problems 📍 **[→ Environment Troubleshooting](MULTI-ENVIRONMENT.md#support)**
```bash
# Ansible problems
ansible-inventory -i ansible/inventories/production/hosts.yml --list
ansible-playbook --syntax-check ansible/playbooks/install-n8n-native.yml

# Vault problems
./manage-vault.sh status              # Vault status
ansible-vault view ansible/group_vars/production/vault.yml

# Workflow import/export problems
./export-workflows.sh development --backup  # With backup
./import-workflows.sh production prod-01 --dry-run  # Test mode
```

### 📞 **Support Resources**

#### Documentation
- **[📖 This README](README.md)** - Main documentation
- **[🌍 Multi-Environment Guide](MULTI-ENVIRONMENT.md)** - Development → Production
- **[🚀 Feature Overview](FEATURES.md)** - All features in detail

#### Debug Information Collection
```bash
# System info for support
./n8n-menu.sh                         # [7] System Information
./manage-environments.sh               # [7] Status Dashboard
./manage-vault.sh status               # Vault status
./server-config.sh check production    # Server status
```

#### Quick Recovery
```bash
# Service recovery
sudo systemctl restart n8n            # Native restart
sudo ./manage-docker.sh restart       # Docker restart

# Backup recovery (if available)
n8n-restore                           # SSH alias
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

> For questions or problems: **[→ Troubleshooting Guide](#-troubleshooting--support)** or **[→ Multi-Environment Documentation](MULTI-ENVIRONMENT.md)**

### 🎯 **Additional Navigation**
- **[📚 Central Navigation (INDEX)](INDEX.md)** - All scripts and documentation
- **[🌍 Multi-Environment Guide](MULTI-ENVIRONMENT.md)** - Development → Production workflow  
- **[🚀 Feature Catalog](FEATURES.md)** - Technical details of all features