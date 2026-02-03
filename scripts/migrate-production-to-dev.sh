#!/bin/bash
#
# Production to Development Migration Script
# Uses standard n8n CLI to export from production and import to development
#

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if required parameters are provided
if [ $# -lt 3 ]; then
    print_error "Missing required parameters"
    echo "Usage: $0 <project-name> <production-server> <ssh-user>"
    echo "Example: $0 360Group n8n-sandbox.detalex.de root"
    exit 1
fi

PROJECT_NAME="$1"
PRODUCTION_SERVER="$2"
SSH_USER="$3"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
DEV_DIR="$(dirname "$SCRIPT_DIR")/development"
PROJECT_DIR="$DEV_DIR/$PROJECT_NAME"
TEMP_DIR="/tmp/n8n-migration-$$"

print_status "🚀 Production to Development Migration using standard n8n CLI"
print_status "Project: $PROJECT_NAME"
print_status "Production Server: $PRODUCTION_SERVER"
print_status "SSH User: $SSH_USER"

# Check if project exists
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory not found: $PROJECT_DIR"
    print_status "Create project first with: ./scripts/deployment/setup-development.sh $PROJECT_NAME development"
    exit 1
fi

# Check if development n8n is running
cd "$DEV_DIR"
if ! docker compose -f "$PROJECT_NAME/docker-compose.yml" ps | grep -q "running"; then
    print_error "Development n8n container is not running"
    print_status "Start with: ./start-dev.sh $PROJECT_NAME"
    exit 1
fi

# Create temporary directory
mkdir -p "$TEMP_DIR/workflows" "$TEMP_DIR/credentials"

print_status "📤 Step 1: Exporting from production server..."

# Test SSH connection
print_status "Testing SSH connection to $SSH_USER@$PRODUCTION_SERVER..."
if ! ssh -o ConnectTimeout=10 "$SSH_USER@$PRODUCTION_SERVER" "echo 'SSH connection successful'"; then
    print_error "Cannot connect to production server via SSH"
    exit 1
fi

# Export workflows from production
print_status "Exporting workflows from production..."
if ssh "$SSH_USER@$PRODUCTION_SERVER" "npx n8n export:workflow --backup --output=/tmp/n8n-export/"; then
    print_success "Workflows exported on production server"
else
    print_error "Failed to export workflows from production"
    exit 1
fi

# Copy workflows from production to local temp
print_status "Downloading workflows from production..."
if scp -r "$SSH_USER@$PRODUCTION_SERVER:/tmp/n8n-export/*" "$TEMP_DIR/workflows/"; then
    print_success "Workflows downloaded"
else
    print_error "Failed to download workflows"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Export credentials from production
print_status "Exporting credentials from production..."
if ssh "$SSH_USER@$PRODUCTION_SERVER" "npx n8n export:credentials --all --pretty --output=/tmp/n8n-credentials.json"; then
    print_success "Credentials exported on production server"
    
    # Download credentials
    print_status "Downloading credentials from production..."
    if scp "$SSH_USER@$PRODUCTION_SERVER:/tmp/n8n-credentials.json" "$TEMP_DIR/credentials/credentials.json"; then
        print_success "Credentials downloaded"
    else
        print_warning "Failed to download credentials (may not exist)"
    fi
else
    print_warning "Failed to export credentials from production (may not exist)"
fi

# Clean up on production server
print_status "Cleaning up temporary files on production server..."
ssh "$SSH_USER@$PRODUCTION_SERVER" "rm -rf /tmp/n8n-export /tmp/n8n-credentials.json" || true

print_status "📥 Step 2: Importing to development environment..."

# Copy workflows to project directory
print_status "Preparing workflows for import..."
cp -r "$TEMP_DIR/workflows/"* "$PROJECT_DIR/workflows/" 2>/dev/null || print_warning "No workflow files to copy"

# Copy credentials to project directory
if [ -f "$TEMP_DIR/credentials/credentials.json" ]; then
    mkdir -p "$PROJECT_DIR/credentials"
    cp "$TEMP_DIR/credentials/credentials.json" "$PROJECT_DIR/credentials/"
    print_status "Credentials prepared for import"
fi

# Count files
WORKFLOW_COUNT=$(find "$PROJECT_DIR/workflows" -name "*.json" -type f 2>/dev/null | wc -l)
print_status "Found $WORKFLOW_COUNT workflow file(s) to import"

if [ "$WORKFLOW_COUNT" -gt 0 ]; then
    # Import workflows using CLI
    print_status "Importing workflows to development environment..."
    if "$SCRIPT_DIR/import-workflows-cli.sh" "$PROJECT_NAME"; then
        print_success "Workflows imported successfully"
    else
        print_error "Workflow import failed"
    fi
fi

# Import credentials if available
if [ -f "$PROJECT_DIR/credentials/credentials.json" ]; then
    print_status "Importing credentials to development environment..."
    print_warning "Note: Credentials might fail if encryption keys differ between production and development"
    
    if "$SCRIPT_DIR/import-credentials-cli.sh" "$PROJECT_NAME"; then
        print_success "Credentials imported successfully"
    else
        print_warning "Credentials import failed (likely due to different encryption keys)"
        print_status "You may need to manually recreate credentials in development"
    fi
fi

# Clean up temporary directory
rm -rf "$TEMP_DIR"

print_success "🎉 Migration completed!"
print_status "Access your development environment at: http://localhost:5678"
print_status "Workflows location: $PROJECT_DIR/workflows"
if [ -f "$PROJECT_DIR/credentials/credentials.json" ]; then
    print_status "Credentials location: $PROJECT_DIR/credentials"
fi