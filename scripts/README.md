# n8n Standard CLI Management Scripts

This directory contains **standard n8n CLI-based scripts** for managing workflows and credentials across different environments. All scripts use only official n8n CLI commands.

## Directory Structure

```
scripts/
├── deployment/               # Installation & environment setup
├── workflows/               # Data pipeline management  
├── host/                    # System maintenance
├── management/              # Interactive user interfaces
├── docker/                  # Container operations
└── README-standard-cli.md   # Detailed CLI documentation
```

## Standard CLI Scripts

### 📤 Export Scripts
- `export-workflows-cli.sh` - Export workflows using `n8n export:workflow --backup`
- `export-credentials-cli.sh` - Export credentials using `n8n export:credentials --all`

### 📥 Import Scripts  
- `import-workflows-cli.sh` - Import workflows using `n8n import:workflow --separate`
- `import-credentials-cli.sh` - Import credentials using `n8n import:credentials`

### 🔄 Migration Scripts
- `migrate-production-to-dev.sh` - Complete production to development migration

### Development Environment
- `deployment/setup-development.sh` - Create development workspaces
- `deployment/manage-environments.sh` - Multi-environment management

### System Operations
- `host/backup-n8n.sh` - Backup n8n data
- `host/update-n8n.sh` - Update n8n installation

## Usage Examples

### Export from Development Environment
```bash
cd development/
../scripts/export-workflows-cli.sh 360Group
../scripts/export-credentials-cli.sh 360Group
```

### Import to Development Environment
```bash
cd development/
../scripts/import-workflows-cli.sh 360Group
../scripts/import-credentials-cli.sh 360Group
```

### Production to Development Migration
```bash
cd development/
../scripts/migrate-production-to-dev.sh 360Group n8n-sandbox.detalex.de root
```

### Setup Development Environment
```bash
./deployment/setup-development.sh my-project development
```

## 📖 Detailed Documentation

See [README-standard-cli.md](README-standard-cli.md) for complete documentation of all standard CLI commands and usage examples.

## ✅ Standard CLI Advantages

1. **🔒 Official Support** - Uses only documented n8n CLI commands
2. **🛡️ No Database Hacks** - Avoids direct SQLite manipulation  
3. **📦 Version Compatible** - Works with all n8n versions
4. **🔄 Future-Proof** - No dependency on internal database structure
5. **💼 Production Ready** - Same commands used in production environments