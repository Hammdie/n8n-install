#!/bin/bash
#
# Download workflows and credentials from production server
# Uses standard n8n CLI for export/import
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

# Load environment variables
if [ ! -f .env ]; then
    print_error ".env file not found"
    print_status "Run ../scripts/setup-development.sh first"
    exit 1
fi

# Load .env file
export $(grep -v '^#' .env | xargs)

print_status "📤 Downloading from production: $PRODUCTION_SERVER"
print_status "Project: $PROJECT_NAME"
print_status "SSH User: $PRODUCTION_SSH_USER"

# Check if development n8n is running
if ! docker ps | grep -q "$N8N_CONTAINER_NAME"; then
    print_error "n8n container is not running"
    print_status "Start with: ./start.sh"
    exit 1
fi

# Test SSH connection
print_status "Testing SSH connection to $PRODUCTION_SSH_USER@$PRODUCTION_SERVER..."
if ! ssh -o ConnectTimeout=10 "$PRODUCTION_SSH_USER@$PRODUCTION_SERVER" "echo 'SSH connection successful'"; then
    print_error "Cannot connect to production server via SSH"
    exit 1
fi

print_status "📤 Step 1: Exporting from production server..."

# Create temporary directory for export
TEMP_DIR="/tmp/n8n-download-$$"
mkdir -p "$TEMP_DIR/workflows" "$TEMP_DIR/credentials"

# Export workflows from production
print_status "Exporting workflows from production..."
if ssh "$PRODUCTION_SSH_USER@$PRODUCTION_SERVER" "
    source /opt/n8n/.n8n/.env
    export N8N_USER_FOLDER=/home/n8n/.n8n
    export HOME=/home/n8n
    cd /opt/n8n
    n8n export:workflow --backup --output=/tmp/n8n-export-workflows/
"; then
    print_success "Workflows exported on production server"
else
    print_error "Failed to export workflows from production"
    print_warning "Check if n8n service is running on production server"
    exit 1
fi

# Download workflows from production
print_status "Downloading workflows from production..."
if scp -r "$PRODUCTION_SSH_USER@$PRODUCTION_SERVER:/tmp/n8n-export-workflows/*" "$TEMP_DIR/workflows/"; then
    print_success "Workflows downloaded"
else
    print_error "Failed to download workflows"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Export credentials from production
print_status "Exporting credentials from production..."
if ssh "$PRODUCTION_SSH_USER@$PRODUCTION_SERVER" "
    source /opt/n8n/.n8n/.env
    export N8N_USER_FOLDER=/home/n8n/.n8n
    export HOME=/home/n8n
    cd /opt/n8n
    n8n export:credentials --all --pretty --output=/tmp/n8n-export-credentials.json
"; then
    print_success "Credentials exported on production server"
    
    # Download credentials
    print_status "Downloading credentials from production..."
    if scp "$PRODUCTION_SSH_USER@$PRODUCTION_SERVER:/tmp/n8n-export-credentials.json" "$TEMP_DIR/credentials/credentials.json"; then
        print_success "Credentials downloaded"
    else
        print_warning "Failed to download credentials (may not exist)"
    fi
else
    print_warning "Failed to export credentials from production (may not exist)"
fi

# Clean up on production server
print_status "Cleaning up temporary files on production server..."
ssh "$PRODUCTION_SSH_USER@$PRODUCTION_SERVER" "rm -rf /tmp/n8n-export-workflows /tmp/n8n-export-credentials.json" || true

print_status "📥 Step 2: Importing to development environment..."

# Copy workflows to local directory
print_status "Preparing workflows for import..."
if ls "$TEMP_DIR/workflows/"*.json 1> /dev/null 2>&1; then
    cp "$TEMP_DIR/workflows/"*.json ./workflows/ 2>/dev/null || true
    WORKFLOW_COUNT=$(ls ./workflows/*.json 2>/dev/null | wc -l)
    print_status "Prepared $WORKFLOW_COUNT workflow file(s) for import"
else
    print_warning "No workflow files found"
    WORKFLOW_COUNT=0
fi

# Copy credentials to local directory
if [ -f "$TEMP_DIR/credentials/credentials.json" ]; then
    cp "$TEMP_DIR/credentials/credentials.json" ./credentials/
    print_status "Credentials prepared for import"
    HAS_CREDENTIALS=true
else
    print_warning "No credentials file found"
    HAS_CREDENTIALS=false
fi

# Import workflows using CLI if any exist
if [ "$WORKFLOW_COUNT" -gt 0 ]; then
    print_status "Importing workflows to development environment..."
    
    # Wait for n8n to be fully ready
    print_status "Checking if n8n is ready..."
    for i in {1..30}; do
        if curl -s -f http://localhost:$N8N_PORT/healthz > /dev/null 2>&1; then
            print_success "n8n is ready"
            break
        fi
        if [ $i -eq 30 ]; then
            print_error "n8n is not responding after 30 seconds"
            exit 1
        fi
        sleep 1
    done
    
    # Import workflows using standard CLI
    if docker exec "$N8N_CONTAINER_NAME" npx n8n import:workflow --separate --input=/data/workflows/; then
        print_success "Workflows imported successfully"
    else
        print_error "Workflow import failed"
    fi
else
    print_warning "No workflows to import"
fi

# Import credentials if available
if [ "$HAS_CREDENTIALS" = true ]; then
    print_status "Importing credentials to development environment..."
    print_warning "Note: Credentials might fail if encryption keys differ between production and development"
    
    if docker exec "$N8N_CONTAINER_NAME" npx n8n import:credentials --input=/data/credentials/credentials.json; then
        print_success "Credentials imported successfully"
    else
        print_warning "Credentials import failed (likely due to different encryption keys)"
        print_status "You may need to manually recreate credentials in development"
    fi
fi

# Clean up temporary directory
rm -rf "$TEMP_DIR"

print_success "🎉 Download and import completed!"
print_status "Access your development environment at: http://localhost:$N8N_PORT"
if [ "$WORKFLOW_COUNT" -gt 0 ]; then
    print_status "Workflows location: ./workflows ($WORKFLOW_COUNT files)"
fi
if [ "$HAS_CREDENTIALS" = true ]; then
    print_status "Credentials location: ./credentials"
fi