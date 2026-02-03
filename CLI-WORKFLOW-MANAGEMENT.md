# 🚀 n8n Standard CLI Workflow Management

**Clean, standard-compliant n8n workflow and credential management using only official CLI commands.**

## 📋 Quick Reference

### Export Workflows & Credentials
```bash
cd development/
../scripts/export-workflows-cli.sh 360Group
../scripts/export-credentials-cli.sh 360Group
```

### Import Workflows & Credentials  
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

## 🎯 Standard CLI Commands Used

- `npx n8n export:workflow --backup --output=/data/workflows/`
- `npx n8n import:workflow --separate --input=/data/workflows/`
- `npx n8n export:credentials --all --pretty --output=credentials.json`
- `npx n8n import:credentials --input=credentials.json`

## ✅ Advantages

- **🔒 Official n8n CLI only** - No database hacks or API workarounds
- **📦 Version compatible** - Works with all n8n versions  
- **🛡️ Production ready** - Same commands as production environments
- **🔄 Future-proof** - Independent of internal database structure

## 📖 Documentation

- **[scripts/README-standard-cli.md](scripts/README-standard-cli.md)** - Complete CLI documentation
- **[scripts/README.md](scripts/README.md)** - Script overview and usage examples