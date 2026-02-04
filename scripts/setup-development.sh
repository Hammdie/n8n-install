#!/bin/bash
#
# Setup n8n Development Environment
# Creates configuration for single project without subdirectories
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
if [ $# -lt 2 ]; then
    print_error "Missing required parameters"
    echo ""
    echo "Usage: $0 <project-name> <production-server> [ssh-user]"
    echo ""
    echo "Examples:"
    echo "  $0 360Group n8n-sandbox.detalex.de"
    echo "  $0 MyProject production.company.com admin"
    echo ""
    exit 1
fi

PROJECT_NAME="$1"
PRODUCTION_SERVER="$2"
SSH_USER="${3:-root}"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
DEV_DIR="$BASE_DIR/development"

print_status "🚀 Setting up n8n Development Environment"
print_status "Project: $PROJECT_NAME"
print_status "Production Server: $PRODUCTION_SERVER"
print_status "SSH User: $SSH_USER"

# Create development directory if it doesn't exist
mkdir -p "$DEV_DIR"

print_status "📝 Creating .env configuration file..."

# Create .env file
cat > "$DEV_DIR/.env" << EOF
# n8n Development Environment Configuration
# Generated: $(date)

# Project Settings
PROJECT_NAME=$PROJECT_NAME
PROJECT_DESCRIPTION="$PROJECT_NAME n8n Development Environment"

# n8n Container Settings  
N8N_VERSION=1.19.4
N8N_PORT=5678
N8N_CONTAINER_NAME=n8n-dev-$PROJECT_NAME

# Production Server Settings (for sync)
PRODUCTION_SERVER=$PRODUCTION_SERVER
PRODUCTION_SSH_USER=$SSH_USER
PRODUCTION_SSH_PORT=22

# Development Settings
DEVELOPMENT_MODE=true
ENABLE_TUNNEL=false

# Auto-sync Settings (for future upload functionality)
AUTO_SYNC_ENABLED=false
SYNC_INTERVAL_MINUTES=30
BACKUP_BEFORE_UPLOAD=true

# Paths
WORKFLOWS_DIR=./workflows
CREDENTIALS_DIR=./credentials
BACKUPS_DIR=./backups
DATA_DIR=./data
EOF

print_success ".env file created"

print_status "📝 Creating docker-compose.yml..."

# Create docker-compose.yml
cat > "$DEV_DIR/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:${N8N_VERSION}
    container_name: ${N8N_CONTAINER_NAME}
    restart: unless-stopped
    ports:
      - "${N8N_PORT}:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=false
      - N8N_METRICS=false
      - WEBHOOK_URL=http://localhost:${N8N_PORT}/
      - GENERIC_TIMEZONE=Europe/Berlin
      - N8N_LOG_LEVEL=info
      - N8N_ENABLE_FILESYSTEM_FOR_BINARY_DATA=true
    volumes:
      - ./data:/data
      - ./workflows:/data/workflows
      - ./credentials:/data/credentials
      - ./backups:/data/backups

networks:
  default:
    name: ${PROJECT_NAME}-n8n-dev
EOF

print_success "docker-compose.yml created"

print_status "📁 Creating directory structure..."

# Create necessary directories
mkdir -p "$DEV_DIR/data"
mkdir -p "$DEV_DIR/workflows"
mkdir -p "$DEV_DIR/credentials"
mkdir -p "$DEV_DIR/backups"

print_success "Directory structure created"

print_status "📝 Creating start script..."

# Create start script
cat > "$DEV_DIR/start.sh" << 'EOF'
#!/bin/bash
#
# Start n8n Development Environment
#

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

echo "🚀 Starting n8n Development Environment: $PROJECT_NAME"

# Start container
docker compose up -d

# Wait for n8n to be ready
echo "⏳ Waiting for n8n to be ready..."
for i in {1..60}; do
    if curl -s -f http://localhost:$N8N_PORT/healthz > /dev/null 2>&1; then
        echo "✅ n8n is ready!"
        break
    fi
    if [ $i -eq 60 ]; then
        echo "❌ n8n is not responding after 60 seconds"
        exit 1
    fi
    sleep 1
done

echo ""
echo "🌐 n8n Development Environment is running!"
echo "🔗 Access: http://localhost:$N8N_PORT"
echo "📋 Project: $PROJECT_NAME"
echo ""
echo "Available commands:"
echo "  ./stop.sh                                    # Stop environment"
echo "  ../scripts/export-workflows-cli.sh          # Export workflows"
echo "  ../scripts/import-workflows-cli.sh          # Import workflows" 
echo "  ../scripts/export-credentials-cli.sh        # Export credentials"
echo "  ../scripts/import-credentials-cli.sh        # Import credentials"
echo "  ../scripts/download-from-production.sh      # Download from production"
echo "  ../scripts/upload-to-production.sh          # Upload to production (future)"
EOF

chmod +x "$DEV_DIR/start.sh"
print_success "start.sh created"

print_status "📝 Creating stop script..."

# Create stop script  
cat > "$DEV_DIR/stop.sh" << 'EOF'
#!/bin/bash
#
# Stop n8n Development Environment
#

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

echo "🛑 Stopping n8n Development Environment: $PROJECT_NAME"

# Stop and remove container
docker compose down

echo "✅ Environment stopped"
EOF

chmod +x "$DEV_DIR/stop.sh"
print_success "stop.sh created"

print_status "📝 Creating production download script..."

# Create download script
cat > "$DEV_DIR/download-from-production.sh" << 'EOF'
#!/bin/bash
#
# Download workflows and credentials from production
#

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

echo "📤 Downloading from production server: $PRODUCTION_SERVER"

# Use the migration script
../scripts/migrate-production-to-dev.sh "$PROJECT_NAME" "$PRODUCTION_SERVER" "$PRODUCTION_SSH_USER"
EOF

chmod +x "$DEV_DIR/download-from-production.sh"
print_success "download-from-production.sh created"

print_status "📝 Creating .gitignore..."

# Create .gitignore for development directory
cat > "$DEV_DIR/.gitignore" << 'EOF'
# n8n Development Environment

# Data directory (contains database)
data/
!data/.gitkeep

# Credentials (may contain sensitive data)
credentials/*.json
!credentials/.gitkeep

# Backups
backups/*.json
backups/*.sql
!backups/.gitkeep

# Docker volumes
.docker/

# Environment secrets (if any)
.env.local
.env.secrets
EOF

print_success ".gitignore created"

# Create .gitkeep files
touch "$DEV_DIR/data/.gitkeep"
touch "$DEV_DIR/workflows/.gitkeep"
touch "$DEV_DIR/credentials/.gitkeep"
touch "$DEV_DIR/backups/.gitkeep"

print_success "Development environment configured!"

echo ""
print_status "📋 Next steps:"
echo "  1. cd development"
echo "  2. ./start.sh                          # Start n8n"
echo "  3. ./download-from-production.sh       # Download workflows from $PRODUCTION_SERVER"
echo "  4. Open http://localhost:5678          # Access n8n interface"
echo ""
print_status "Configuration saved in:"
echo "  - development/.env                     # Environment variables"
echo "  - development/docker-compose.yml      # Container configuration"
echo ""
print_success "🎉 Setup completed successfully!"