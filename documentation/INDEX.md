# 📚 n8n Suite - Documentation Index

> **Central navigation guide to all features, scripts, and documentation**

## 🎯 **Start here for...**

### 📥 **I want to install n8n**
- **Simple Installation**: **[README.md → Installation](README.md#-installation)**
- **Multi-Environment Setup**: **[MULTI-ENVIRONMENT.md → Quick Start](MULTI-ENVIRONMENT.md#quick-start)**
- **Docker Installation**: **[README.md → Docker Management](README.md#-docker-management)**

### 🛠️ **I want to develop workflows**
- **Development Environment**: **[setup-development.sh](setup-development.sh)**
- **Export/Import Workflows**: **[README.md → Workflow Management](README.md#-workflow-development--multi-environment)**
- **Git-based Workflow**: **[MULTI-ENVIRONMENT.md → Development Workflow](MULTI-ENVIRONMENT.md#workflow-development--deployment)**

### 🌍 **I want to manage multiple environments**
- **Environment Manager**: **[manage-environments.sh](manage-environments.sh)**
- **Server Configuration**: **[server-config.sh](server-config.sh)**
- **Multi-Environment Guide**: **[MULTI-ENVIRONMENT.md](MULTI-ENVIRONMENT.md)**

### 🔐 **I want to manage credentials securely**
- **Vault Manager**: **[manage-vault.sh](manage-vault.sh)**
- **Security Concept**: **[MULTI-ENVIRONMENT.md → Security Concept](MULTI-ENVIRONMENT.md#security-concept)**

### 🆘 **I have problems**
- **Troubleshooting**: **[README.md → Troubleshooting](README.md#-troubleshooting--support)**
- **Service Problems**: **[README.md → Service Commands](README.md#-service-commands)**
- **Docker Problems**: **[manage-docker.sh](manage-docker.sh)**

---

## 📋 **Complete Script Reference**

### 🎯 **Installation & Setup**
| Script | Purpose | Quick Access | Documentation |
|--------|---------|-------------|---------------|
| **[install-n8n.sh](install-n8n.sh)** | Main installation | `sudo ./install-n8n.sh <domain>` | **[→ Guide](README.md#-installation)** |
| **[setup-ssh-user.sh](setup-ssh-user.sh)** | SSH user setup | Automatic during installation | **[→ SSH Setup](README.md#%EF%B8%8F-ssh-management-setup)** |
| **[setup-reverse-proxy.sh](setup-reverse-proxy.sh)** | Additional domains | `sudo ./setup-reverse-proxy.sh <domain>` | **[→ Domain Management](manage-domains.sh)** |
| **[setup-development.sh](setup-development.sh)** | Dev environment | `./setup-development.sh <name> <env>` | **[→ Development Guide](MULTI-ENVIRONMENT.md#local-n8n-development)** |

### 🌍 **Environment Management**
| Script | Purpose | Quick Access | Documentation |
|--------|---------|-------------|---------------|
| **[manage-environments.sh](manage-environments.sh)** | Multi-environment manager | `./manage-environments.sh` | **[→ Environment Guide](MULTI-ENVIRONMENT.md)** |
| **[server-config.sh](server-config.sh)** | Manage server lists | `./server-config.sh list <env>` | **[→ Server Management](MULTI-ENVIRONMENT.md#server-management)** |
| **[manage-vault.sh](manage-vault.sh)** | Credential management | `./manage-vault.sh` | **[→ Vault Guide](MULTI-ENVIRONMENT.md#secure-credential-management)** |

### 📦 **Workflow Pipeline**
| Script | Purpose | Quick Access | Documentation |
|--------|---------|-------------|---------------|
| **[export-workflows.sh](export-workflows.sh)** | n8n → Git export | `./export-workflows.sh <env>` | **[→ Export Guide](MULTI-ENVIRONMENT.md#export-n8n--git)** |
| **[import-workflows.sh](import-workflows.sh)** | Git → n8n import | `./import-workflows.sh <env> <server>` | **[→ Import Guide](MULTI-ENVIRONMENT.md#import-git--n8n)** |

### 🎛️ **Management Interface**
| Script | Purpose | SSH Alias | Documentation |
|--------|---------|-----------|---------------|
| **[n8n-menu.sh](n8n-menu.sh)** | Main management menu | `n8n-menu` | **[→ SSH Commands](README.md#%EF%B8%8F-available-ssh-commands)** |
| **[manage-domains.sh](manage-domains.sh)** | Domain & SSL management | `n8n-domains` | **[→ Domain Management](README.md#%EF%B8%8F-server--environment-management)** |
| **[manage-docker.sh](manage-docker.sh)** | Docker container management | `n8n-docker` | **[→ Docker Guide](README.md#-docker-management)** |

### 💾 **Backup & Maintenance**
| Script | Purpose | SSH Alias | Documentation |
|--------|---------|-----------|---------------|
| **[backup-n8n.sh](backup-n8n.sh)** | Backup system | `n8n-backup` | **[→ Backup Guide](README.md#-backup--maintenance)** |
| **[restore-n8n.sh](restore-n8n.sh)** | Restore system | `n8n-restore` | **[→ Restore Guide](README.md#-backup--maintenance)** |
| **[update-n8n.sh](../scripts/host/update-n8n.sh)** | Update management | `n8n-update` | **[→ Update Guide](README.md#-updates--maintenance)** |

---

## 📖 **Documentation Roadmap**

### 1. **[README.md](README.md)** - Main Entry Point
- **Purpose**: First point of contact for all users
- **Content**: Installation, basic setup, SSH management, Docker
- **For whom**: All users, especially first-time installation

### 2. **[MULTI-ENVIRONMENT.md](MULTI-ENVIRONMENT.md)** - Development → Production
- **Purpose**: Complete workflow guide for developers
- **Content**: Development setup, Git integration, Ansible pipeline
- **For whom**: Developers, DevOps teams, multi-environment users

### 3. **[FEATURES.md](FEATURES.md)** - Feature Catalog
- **Purpose**: Detailed feature overview and technical details
- **Content**: All functions, technical specifications, performance
- **For whom**: Technical users, feature evaluation

### 4. **[INDEX.md](INDEX.md)** - This File
- **Purpose**: Navigation and quick access to all areas
- **Content**: Links, quick reference, where-to-find-what
- **For whom**: All users as navigation aid

---

## 🎯 **Quick Starts by Use Case**

### 🏢 **Enterprise/Team Setup**
1. **[Start multi-environment manager](manage-environments.sh)**
2. **[Check server configuration](server-config.sh)**
3. **[Set up vault for credentials](manage-vault.sh)**
4. **[Production installation](MULTI-ENVIRONMENT.md#production-deployment)**

### 👨‍💻 **Developer Workflow**
1. **[Create development environment](setup-development.sh)**
2. **[Start local n8n](MULTI-ENVIRONMENT.md#start-local-development)**
3. **[Develop and export workflows](export-workflows.sh)**
4. **[Deploy to staging](import-workflows.sh)**

### 🖥️ **Single Server Setup**
1. **[Simple installation](install-n8n.sh)**
2. **[Set up SSH access](setup-ssh-user.sh)**
3. **[Check status via SSH](README.md#%EF%B8%8F-available-ssh-commands)**

### 🐳 **Docker-only Setup**
1. **[Choose Docker installation](install-n8n.sh)** (Option 2)
2. **[Learn Docker management](manage-docker.sh)**
3. **[Container management](README.md#-docker-management)**

### 🔧 **Maintenance & Troubleshooting**
1. **[Use status dashboard](n8n-menu.sh)**
2. **[Analyze logs](README.md#log-analysis)**
3. **[Backup strategy](backup-n8n.sh)**
4. **[Troubleshooting guide](README.md#-troubleshooting--support)**

---

## 🔍 **Search by Topics**

### 🔐 **Security**
- **[Vault Management](manage-vault.sh)** - Secure credentials
- **[SSH Setup](setup-ssh-user.sh)** - Secure server access
- **[SSL Certificates](setup-reverse-proxy.sh)** - HTTPS encryption
- **[Firewall](install-n8n.sh#L200)** - UFW configuration

### 🚀 **Performance**
- **[Docker vs Native](README.md#%EF%B8%8F-installation-options-during-setup)** - Performance comparison
- **[System Monitoring](n8n-menu.sh)** - Resource monitoring
- **[Update Management](../scripts/host/update-n8n.sh)** - Performance updates

### 🔧 **Administration**
- **[Service Management](README.md#-service-commands)** - Start/Stop/Restart
- **[Log Management](README.md#log-analysis)** - Logging & debugging
- **[Backup Strategies](README.md#-backup--maintenance)** - Data backup

### 🌐 **Network**
- **[Domain Management](manage-domains.sh)** - DNS & SSL
- **[Reverse Proxy](setup-reverse-proxy.sh)** - nginx configuration
- **[Firewall Setup](install-n8n.sh)** - Port configuration

---

## 📱 **Mobile-Friendly Navigation**

### 📋 **Quick Commands**
```bash
# Check status
n8n-status

# Show logs
n8n-logs

# Restart
n8n-restart

# Backup
n8n-backup

# Multi-environment
./manage-environments.sh

# Docker management
./manage-docker.sh
```

### 🔗 **Important Links**
- **[Start installation](README.md#-installation)**
- **[Development setup](MULTI-ENVIRONMENT.md#create-development-environment)**
- **[Troubleshooting](README.md#-troubleshooting--support)**
- **[SSH commands](README.md#%EF%B8%8F-available-ssh-commands)**

---

**🎯 This index file helps you quickly find what you're looking for! For questions, follow the links to detailed documentation.**