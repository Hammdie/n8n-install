# n8n Installation Scripts

This directory contains all management and deployment scripts for the n8n installation suite.

## Directory Structure

### 🐳 [docker/](docker/)
Docker-specific management scripts:
- `manage-docker.sh` - Docker Compose management interface

### 🚀 [deployment/](deployment/)
Installation and deployment scripts:
- `install-n8n.sh` - Main n8n installation script (Native & Docker)
- `manage-environments.sh` - Multi-environment management system
- `setup-reverse-proxy.sh` - nginx reverse proxy configuration
- `server-config.sh` - Server configuration and optimization
- `manage-domains.sh` - Domain and SSL certificate management
- `setup-development.sh` - Development environment setup

#### 📋 [deployment/ansible/](deployment/ansible/)
Ansible automation scripts:
- `manage-vault.sh` - Ansible Vault credential management

### 🖥️ [host/](host/)
Host-level maintenance and administration:
- `backup-n8n.sh` - Complete system backup solution
- `restore-n8n.sh` - System restore from backups
- `setup-ssh-user.sh` - SSH user configuration for automation
- `update-n8n.sh` - n8n version updates and maintenance

### ⚙️ [management/](management/)
Central management interfaces:
- `n8n-menu.sh` - Main interactive management menu

### 📋 [workflows/](workflows/)
Workflow and data management:
- `export-workflows.sh` - Export workflows and credentials
- `import-workflows.sh` - Import workflows via Ansible
- `extract-to-development.sh` - Extract all workflows/credentials to development structure

## Quick Start

1. **Fresh Installation:**
   ```bash
   sudo ./deployment/install-n8n.sh
   ```

2. **Management Menu:**
   ```bash
   ./management/n8n-menu.sh
   ```

3. **Multi-Environment Setup:**
   ```bash
   ./deployment/manage-environments.sh
   ```

4. **Development Environment:**
   ```bash
   ./deployment/setup-development.sh my-project development
   ```

## Script Categories

| Category | Purpose | Target User |
|----------|---------|-------------|
| **docker** | Container management | DevOps Teams |
| **deployment** | Installation & Setup | System Administrators |
| **host** | System Maintenance | Operations Teams |
| **management** | Daily Operations | End Users |
| **workflows** | Data Management | Developers |

## Security Notes

- All scripts require appropriate permissions
- Production deployments use Ansible Vault for secrets
- Development environments include Git integration
- Backup scripts preserve encryption keys

## For More Information

See [../documentation/](../documentation/) for detailed guides and architecture documentation.