# 🚀 n8n Standard CLI Workflow & Credentials Management

## 📖 Overview

This directory contains **standard n8n CLI-based scripts** for managing workflows and credentials without any database hacks or API workarounds. All scripts use official n8n CLI commands.

## 🛠️ Available Scripts

### 📤 Export Scripts

#### `export-workflows-cli.sh`
**Purpose:** Export all workflows from running n8n using standard CLI
```bash
../scripts/export-workflows-cli.sh <project-name>
```
**Features:**
- ✅ Uses official `n8n export:workflow --backup` command  
- ✅ Exports in separate files format for version control
- ✅ Pretty-printed JSON output
- ✅ Container status validation

**Example:**
```bash
../scripts/export-workflows-cli.sh 360Group
```

#### `export-credentials-cli.sh`
**Purpose:** Export all credentials from running n8n using standard CLI
```bash
../scripts/export-credentials-cli.sh <project-name>
```
**Features:**
- ✅ Uses official `n8n export:credentials --all` command
- ✅ Encrypted export (requires same encryption key for import)
- ✅ Security warnings and guidance

### 📥 Import Scripts

#### `import-workflows-cli.sh`
**Purpose:** Import workflows to running n8n using standard CLI
```bash
../scripts/import-workflows-cli.sh <project-name> [source-directory]
```
**Features:**
- ✅ Uses official `n8n import:workflow --separate` command
- ✅ Automatic file discovery and validation
- ✅ Health check before import
- ✅ Import verification

**Example:**
```bash
../scripts/import-workflows-cli.sh 360Group
../scripts/import-workflows-cli.sh 360Group /path/to/workflows
```

#### `import-credentials-cli.sh`
**Purpose:** Import credentials to running n8n using standard CLI
```bash
../scripts/import-credentials-cli.sh <project-name> [credentials-file]
```
**Features:**
- ✅ Uses official `n8n import:credentials` command
- ✅ Encryption key compatibility validation
- ✅ Detailed error guidance

### 🔄 Migration Scripts

#### `migrate-production-to-dev.sh`
**Purpose:** Complete production to development migration using standard CLI
```bash
../scripts/migrate-production-to-dev.sh <project-name> <production-server> <ssh-user>
```
**Features:**
- ✅ SSH-based production export
- ✅ Automatic download and import
- ✅ Both workflows and credentials
- ✅ Cleanup and verification

**Example:**
```bash
../scripts/migrate-production-to-dev.sh 360Group n8n-sandbox.detalex.de root
```

## 🔧 Standard n8n CLI Commands Used

### Workflow Management
```bash
# Export all workflows
npx n8n export:workflow --backup --output=/data/workflows/

# Export specific workflow  
npx n8n export:workflow --id=<workflow-id> --output=workflow.json

# Import workflows from directory
npx n8n import:workflow --separate --input=/data/workflows/

# Import single workflow
npx n8n import:workflow --input=workflow.json
```

### Credentials Management
```bash
# Export all credentials
npx n8n export:credentials --all --pretty --output=credentials.json

# Import credentials
npx n8n import:credentials --input=credentials.json
```

### Listing and Information
```bash
# List all workflows
npx n8n list:workflow

# Get n8n help
npx n8n --help
```

## 📁 Expected Directory Structure

```
360Group/
├── docker-compose.yml          # n8n container configuration
├── data/                       # n8n data volume
│   ├── database.sqlite         # n8n database
│   └── .n8n/
│       └── encryption_key      # Encryption key for credentials
├── workflows/                  # Exported workflows (JSON files)
│   ├── workflow_1_<id>.json
│   ├── workflow_2_<id>.json
│   └── ...
└── credentials/                # Exported credentials
    └── credentials.json        # Encrypted credentials file
```

## 🔑 Important Notes

### Workflow IDs
- **Standard CLI imports generate NEW workflow IDs**
- Original IDs are not preserved (this is n8n CLI standard behavior)
- For ID preservation, database-level operations would be needed

### Credential Encryption
- Credentials are **encrypted with environment-specific keys**
- Same encryption key required for successful import
- Location: `/data/.n8n/encryption_key` in container

### Container Requirements
- n8n container must be **running** before import/export
- Scripts validate container status automatically
- Uses Docker Compose commands for container management

## 🚀 Quick Start Guide

### 1. Export from Running Development Environment
```bash
cd /Users/dietmar.hamm/PycharmProjects/n8n-install/development
../scripts/export-workflows-cli.sh 360Group
../scripts/export-credentials-cli.sh 360Group
```

### 2. Import to Clean Development Environment
```bash
cd /Users/dietmar.hamm/PycharmProjects/n8n-install/development
./start-dev.sh 360Group
../scripts/import-workflows-cli.sh 360Group
../scripts/import-credentials-cli.sh 360Group
```

### 3. Production to Development Migration
```bash
cd /Users/dietmar.hamm/PycharmProjects/n8n-install/development
../scripts/migrate-production-to-dev.sh 360Group production-server.com user
```

## ✅ Advantages of Standard CLI Approach

1. **🔒 Official Support:** Uses only documented n8n CLI commands
2. **🛡️ No Database Hacks:** Avoids direct SQLite manipulation  
3. **📦 Version Compatible:** Works with all n8n versions
4. **🔄 Future-Proof:** No dependency on internal database structure
5. **💼 Production Ready:** Same commands used in production environments
6. **🐛 Debuggable:** Standard error messages and logging

## ⚠️ Limitations

1. **🆔 ID Assignment:** Workflow IDs are regenerated during import
2. **🔐 Encryption Dependencies:** Credentials require matching encryption keys
3. **🌐 Network Requirements:** Production migration requires SSH access
4. **📊 No Partial Updates:** Full import/export only (no individual workflow updates)

## 🎯 Best Practices

1. **🔄 Regular Exports:** Schedule regular workflow/credential backups
2. **🔑 Key Management:** Maintain encryption key backups separately
3. **✅ Test Imports:** Verify imports in development before production use
4. **📝 Documentation:** Document custom credentials for manual recreation
5. **🔍 Version Control:** Use separate JSON files for Git tracking

---

**🎉 This approach provides a clean, maintainable, and standard-compliant way to manage n8n workflows and credentials across environments.**