#!/bin/bash

# n8n Development Export Script
# Extracts all workflows and credentials to development directory structure

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; exit 1; }
warning() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }

# Default values
N8N_HOST="${N8N_HOST:-localhost:5678}"
N8N_USER="${N8N_USER:-admin}"
N8N_PASSWORD="${N8N_PASSWORD:-admin123}"
DEV_DIR="${HOME}/n8n-development/$(basename $(pwd))"
N8N_CLI_PATH="$(which n8n 2>/dev/null || echo '')"

# Check if n8n CLI is available
if [[ -z "$N8N_CLI_PATH" ]]; then
    # Try to find n8n in common locations
    if [[ -f "/usr/local/bin/n8n" ]]; then
        N8N_CLI_PATH="/usr/local/bin/n8n"
    elif [[ -f "/usr/bin/n8n" ]]; then
        N8N_CLI_PATH="/usr/bin/n8n"
    else
        error "n8n CLI not found. Please install n8n or add it to PATH"
    fi
fi

info "Using n8n CLI at: $N8N_CLI_PATH"

# Parse arguments
EXPORT_WORKFLOWS=true
EXPORT_CREDENTIALS=true
CREATE_STRUCTURE=true

for arg in "$@"; do
    case $arg in
        --workflows-only)
            EXPORT_CREDENTIALS=false
            ;;
        --credentials-only)
            EXPORT_WORKFLOWS=false
            ;;
        --skip-structure)
            CREATE_STRUCTURE=false
            ;;
        --dev-dir=*)
            DEV_DIR="${arg#*=}"
            ;;
        --help)
            echo "n8n Development Export Script"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --workflows-only     Export workflows only"
            echo "  --credentials-only   Export credentials only"
            echo "  --skip-structure     Don't create development directory structure"
            echo "  --dev-dir=PATH       Custom development directory (default: ~/n8n-development/project-name)"
            echo ""
            echo "Environment Variables:"
            echo "  N8N_HOST             n8n host:port (default: localhost:5678)"
            echo "  N8N_USER             n8n username (default: admin)"
            echo "  N8N_PASSWORD         n8n password (default: admin123)"
            echo ""
            echo "Examples:"
            echo "  $0                          # Export everything"
            echo "  $0 --workflows-only         # Export workflows only"
            echo "  $0 --dev-dir=/path/to/dev   # Custom development directory"
            exit 0
            ;;
    esac
done

echo ""
echo "=============================================="
echo "📦 n8n Development Export"
echo "=============================================="
echo ""
echo "Host: $N8N_HOST"
echo "Development Directory: $DEV_DIR"
echo "Workflows: $([ "$EXPORT_WORKFLOWS" = true ] && echo "✅" || echo "❌")"
echo "Credentials: $([ "$EXPORT_CREDENTIALS" = true ] && echo "✅" || echo "❌")"
echo ""

# Create development directory structure
if [[ "$CREATE_STRUCTURE" = true ]]; then
    log "Creating development directory structure..."
    mkdir -p "$DEV_DIR"/{workflows,credentials,backups,exports}/{development,staging,production}
    mkdir -p "$DEV_DIR/git-repos"
    
    # Create development README
    cat > "$DEV_DIR/README.md" << 'EOF'
# n8n Development Environment

This directory contains extracted workflows and credentials from n8n for development purposes.

## Structure

- `workflows/` - Exported workflows by environment
- `credentials/` - Exported credential templates (sanitized)
- `backups/` - Environment backups
- `exports/` - Raw export files
- `git-repos/` - Linked Git repositories for workflow versioning

## Usage

1. Modify workflows in the appropriate environment directory
2. Use `import-workflows.sh` to deploy changes
3. Commit changes to Git repositories for version control

## Security

⚠️ **Never commit real credentials to Git!**
- Credential exports contain only templates
- Use environment variables or Ansible Vault for real values
EOF
fi

# Change to development directory
cd "$DEV_DIR"

# Check n8n connectivity
log "Checking n8n connectivity..."
if ! curl -s "http://$N8N_HOST" > /dev/null; then
    error "Cannot connect to n8n at $N8N_HOST. Please check if n8n is running."
fi

# Export workflows using n8n CLI
if [[ "$EXPORT_WORKFLOWS" = true ]]; then
    log "Exporting workflows..."
    EXPORT_DIR="exports/workflows-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$EXPORT_DIR"
    
    # Use n8n export command
    export N8N_BASIC_AUTH_USER="$N8N_USER"
    export N8N_BASIC_AUTH_PASSWORD="$N8N_PASSWORD"
    
    if [[ -n "$N8N_CLI_PATH" ]]; then
        log "Using n8n CLI to export workflows..."
        "$N8N_CLI_PATH" export:workflow --all --output="$EXPORT_DIR" || warning "CLI export failed, trying alternative method"
    fi
    
    # Alternative: Direct API approach for workflows
    log "Fetching workflows via API..."
    WORKFLOWS_JSON=$(curl -s -u "$N8N_USER:$N8N_PASSWORD" "http://$N8N_HOST/api/v1/workflows" || echo '[]')
    
    if [[ "$WORKFLOWS_JSON" != "[]" && -n "$WORKFLOWS_JSON" ]]; then
        echo "$WORKFLOWS_JSON" | jq -r '.data[]' > "$EXPORT_DIR/all-workflows.json" 2>/dev/null || {
            echo "$WORKFLOWS_JSON" > "$EXPORT_DIR/all-workflows.json"
        }
        
        # Split workflows into individual files
        if command -v jq >/dev/null 2>&1; then
            echo "$WORKFLOWS_JSON" | jq -r '.data[] | @json' | while read -r workflow; do
                WORKFLOW_NAME=$(echo "$workflow" | jq -r '.name // "unnamed"' | tr ' ' '_' | tr -d '/')
                echo "$workflow" | jq '.' > "$EXPORT_DIR/${WORKFLOW_NAME}.json"
            done
        fi
        
        log "Workflows exported to: $EXPORT_DIR"
        
        # Copy to development structure
        cp -r "$EXPORT_DIR"/* "workflows/development/" 2>/dev/null || true
    else
        warning "No workflows found or export failed"
    fi
fi

# Export credentials (sanitized templates)
if [[ "$EXPORT_CREDENTIALS" = true ]]; then
    log "Exporting credential templates..."
    CRED_DIR="exports/credentials-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$CRED_DIR"
    
    # Fetch credentials via API
    CREDENTIALS_JSON=$(curl -s -u "$N8N_USER:$N8N_PASSWORD" "http://$N8N_HOST/api/v1/credentials" || echo '[]')
    
    if [[ "$CREDENTIALS_JSON" != "[]" && -n "$CREDENTIALS_JSON" ]]; then
        # Create sanitized credential templates
        if command -v jq >/dev/null 2>&1; then
            echo "$CREDENTIALS_JSON" | jq -r '.data[]' | while read -r cred; do
                CRED_NAME=$(echo "$cred" | jq -r '.name // "unnamed"' | tr ' ' '_' | tr -d '/')
                CRED_TYPE=$(echo "$cred" | jq -r '.type // "unknown"')
                
                # Create template with placeholders
                cat > "$CRED_DIR/${CRED_NAME}_template.json" << EOF
{
  "name": "$(echo "$cred" | jq -r '.name')",
  "type": "$CRED_TYPE",
  "data": {
    "_note": "This is a template - replace with actual values",
    "_original_keys": $(echo "$cred" | jq -r '.data | keys')
  }
}
EOF
            done
        else
            echo "$CREDENTIALS_JSON" > "$CRED_DIR/all-credentials.json"
        fi
        
        log "Credential templates exported to: $CRED_DIR"
        
        # Copy to development structure  
        cp -r "$CRED_DIR"/* "credentials/development/" 2>/dev/null || true
    else
        warning "No credentials found or export failed"
    fi
fi

log "Development export completed!"
echo ""
echo "Development directory: $DEV_DIR"
echo ""
echo "Next steps:"
echo "1. Review exported workflows and credentials"
echo "2. Set up Git repository for version control:"
echo "   cd $DEV_DIR && git init"
echo "3. Use ../scripts/workflows/import-workflows.sh to deploy changes"
echo ""