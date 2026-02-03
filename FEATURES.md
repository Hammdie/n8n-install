# 🚀 n8n Installation Suite - Feature Overview

## 📋 Installation Options

### 🖥️ Native Installation
- **Node.js 18.x** directly on system
- **PostgreSQL** as local database
- **systemd service** for automatic startup
- Direct system integration
- Optimal performance

### 🐳 Docker Compose Installation
- **Containerized** n8n instance
- **PostgreSQL container** with persistent volumes
- **Health checks** for all services
- Simple deployment and scaling
- Isolated environment

## 🔐 Security Features

### Encryption Key Management
- **Central storage** in `/var/n8n/`
- **600/700 permissions** for maximum security
- **Persistent keys** between installations
- **Backup/restore** supports encryption

### SSH Security
- **Dedicated SSH user** "odoo" 
- **Key-based authentication**
- **Sudoers configuration** for n8n management
- **Secure aliases** for all management commands

## 🌐 Web & Proxy Features

### Reverse Proxy
- **nginx** as SSL termination
- **Let's Encrypt** automatic SSL certificates
- **Multi-domain support** for multiple instances
- **WebSocket support** for n8n features
- **Security headers** for enhanced security

### Firewall Configuration
- **UFW** automatic configuration
- **Port 80/443** for web traffic
- **Port 22** for SSH
- **Minimal attack surface**

## 🛠️ Management Tools

### Main Management (`n8n-menu.sh`)
```
===============================
    🚀 n8n Management System    
===============================
[1] 📊 Status Dashboard
[2] 🔧 Service Management  
[3] 🌐 Domain Management
[4] 🐳 Docker Management (bei Docker-Installation)
[5] 💾 Backup & Restore
[6] 🔄 Updates & Maintenance
[7] 📋 System Information
[8] ❌ Exit
```

### Domain-Management (`manage-domains.sh`)
- **SSL-Zertifikat Management**
- **Reverse Proxy Konfiguration**
- **Domain hinzufügen/entfernen**
- **Automatische nginx-Konfiguration**

### Docker-Management (`manage-docker.sh`)
```
================================
    🐳 Docker Management
================================
[1] 📊 Container Status
[2] ⚡ Start Services
[3] 🛑 Stop Services
[4] 🔄 Restart Services
[5] 📋 Show Logs
[6] 🔧 Container Shell
[7] 🔄 Update Images
[8] 💾 Backup Data
[9] 🧹 System Cleanup
```

## 💾 Backup & Restore

### Backup Features
- **Automated backups** with timestamps
- **PostgreSQL database dumps**
- **Configuration file backup**
- **Encryption key backup**
- **Docker volume backup** (Docker installation)
- **Compressed backup archives**

### Restore Features
- **Complete system recovery**
- **Selective restore** of components
- **Encryption key recovery**
- **Service restart** after restore
- **Backup validation**

## 🔄 Update & Maintenance

### Native Updates
- **n8n version updates**
- **Node.js updates**
- **System package updates**
- **Service restart management**

### Docker Updates  
- **Image updates** for all containers
- **Version pinning** for stability
- **Rolling updates** without downtime
- **Rollback capability**

## 📊 Monitoring & Logging

### Status Dashboard
- **Service status** (Running/Stopped)
- **Port availability**
- **SSL certificate status**
- **Disk space usage**
- **Memory usage**
- **Database connection**

### Logging
- **Structured logs** for all operations
- **systemd journals** (Native)
- **Docker container logs**
- **nginx access/error logs**
- **Centralized log viewing**

## 🎯 SSH Aliases & Shortcuts

### Available Commands (as odoo user)
```bash
n8n-status      # Status dashboard
n8n-manage      # Management menu
n8n-menu        # Main management menu
n8n-domains     # Domain management
n8n-docker      # Docker management (Docker only)
n8n-logs        # Show live logs
n8n-start       # Start n8n
n8n-stop        # Stop n8n
n8n-restart     # Restart n8n
n8n-backup      # Create backup
n8n-restore     # Restore backup
```

## 🏗️ Installation Flow

### 1. Check Prerequisites
- Ubuntu Server 20.04+ detection
- Root permission validation
- Internet connection test
- Domain/SSL validation

### 2. Installation Method Selection
```
Choose installation method:
[1] Native Installation (Node.js + systemd)
[2] Docker Compose Installation

Your choice [1-2]:
```

### 3. System Setup
- **Install packages** (Node.js or Docker)
- **Create users** (n8n)
- **Create directories**
- **Set permissions**

### 4. Database Setup
- **PostgreSQL installation/container**
- **Create database**
- **Configure user**
- **Test connection**

### 5. n8n Configuration
- **Environment variables**
- **Service configuration**
- **Encryption key setup**
- **Webhook configuration**

### 6. Web Server Setup
- **nginx installation**
- **Reverse proxy configuration**
- **SSL certificate (Let's Encrypt)**
- **Security headers**

### 7. SSH User Setup
- **Create odoo user**
- **Configure SSH keys**
- **Set up aliases**
- **Sudoers permissions**

## 🔧 Maintenance & Best Practices

### Regular Maintenance
- **Daily backups** via cron
- **Weekly updates** 
- **Monthly cleanup** (Docker)
- **SSL certificate monitoring**

### Troubleshooting
- **Service status checks**
- **Log analysis tools**
- **Database connection tests**
- **SSL certificate validation**
- **Docker health checks**

### Performance Optimization
- **PostgreSQL tuning**
- **nginx optimization**
- **Docker resource limits**
- **Log rotation**

## 📈 Scalability

### Horizontal Scaling
- **Multi-domain support**
- **Load balancer integration**
- **Database clustering** (PostgreSQL)

### Vertical Scaling
- **Resource monitoring**
- **Container limits** (Docker)
- **Service tuning**

## 🛡️ Security Hardening

### System Security
- **UFW firewall** enabled
- **fail2ban** integration possible
- **SSH key-only** authentication
- **Minimal user privileges**

### Application Security
- **Secure headers** (nginx)
- **SSL/TLS** encryption
- **Database isolation**
- **Secure environment variables**

## 📖 Documentation

### Available Documentation
- `README.md` - Main documentation
- `FEATURES.md` - This feature overview
- Inline comments in all scripts
- Help functions in management tools

### Support & Troubleshooting
- Detailed error messages
- Logging for all operations
- Debug modes available
- Recovery procedures documented