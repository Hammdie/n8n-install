#!/bin/bash
#
# Standard n8n CLI Credentials Import Script
# Imports credentials to running n8n instance using official CLI
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

# Check if project name is provided
if [ $# -lt 1 ]; then
    print_error "Project name and credentials file required"
    echo "Usage: $0 <project-name> [credentials-file]"
    echo "Example: $0 360Group"
    echo "Example: $0 360Group /path/to/credentials.json"
    exit 1
fi

PROJECT_NAME="$1"
CREDENTIALS_FILE="$2"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
DEV_DIR="$(dirname "$SCRIPT_DIR")/development"
PROJECT_DIR="$DEV_DIR/$PROJECT_NAME"

# Default credentials file if not provided
if [ -z "$CREDENTIALS_FILE" ]; then
    CREDENTIALS_FILE="$PROJECT_DIR/credentials/credentials.json"
fi

print_status "Standard n8n CLI Credentials Import for project: $PROJECT_NAME"
print_status "Credentials file: $CREDENTIALS_FILE"

# Check if project exists
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory not found: $PROJECT_DIR"
    exit 1
fi

# Check if credentials file exists
if [ ! -f "$CREDENTIALS_FILE" ]; then
    print_error "Credentials file not found: $CREDENTIALS_FILE"
    exit 1
fi

# Check if Docker Compose file exists
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"
if [ ! -f "$COMPOSE_FILE" ]; then
    print_error "Docker Compose file not found: $COMPOSE_FILE"
    exit 1
fi

# Check if container is running
cd "$DEV_DIR"
if ! docker compose -f "$PROJECT_NAME/docker-compose.yml" ps | grep -q "running"; then
    print_error "n8n container is not running"
    print_status "Start with: ./start-dev.sh $PROJECT_NAME"
    exit 1
fi

# Get relative path for container volume mount
if [[ "$CREDENTIALS_FILE" == "$PROJECT_DIR"* ]]; then
    CONTAINER_PATH="/data${CREDENTIALS_FILE#$PROJECT_DIR}"
else
    print_error "Credentials file must be within project directory for container access"
    print_status "Expected: $PROJECT_DIR/credentials/credentials.json"
    print_status "Got: $CREDENTIALS_FILE"
    exit 1
fi

print_status "Container path: $CONTAINER_PATH"

# Check credentials file content
CRED_COUNT=$(jq '. | length' "$CREDENTIALS_FILE" 2>/dev/null || echo "0")
if [ "$CRED_COUNT" -eq 0 ]; then
    print_warning "No credentials found in file or invalid JSON format"
    exit 1
fi

print_status "Found $CRED_COUNT credential(s) to import"

# Wait for n8n to be fully ready
print_status "Checking if n8n is ready..."
for i in {1..30}; do
    if curl -s -f http://localhost:5678/healthz > /dev/null 2>&1; then
        print_success "n8n is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        print_error "n8n is not responding after 30 seconds"
        exit 1
    fi
    sleep 1
done

# Import credentials using standard CLI
print_status "Importing credentials using n8n CLI..."

print_warning "IMPORTANT: Credentials must be encrypted with the same encryption key"
print_status "Current encryption key: $PROJECT_DIR/data/.n8n/encryption_key"

if docker compose -f "$PROJECT_NAME/docker-compose.yml" exec n8n npx n8n import:credentials \
    --input="$CONTAINER_PATH"; then
    
    print_success "Credentials imported successfully using standard n8n CLI"
    print_success "✨ Import completed successfully!"
    print_status "Access your credentials at: http://localhost:5678/credentials"
    
else
    print_error "Credentials import failed"
    print_warning "This could be due to:"
    print_warning "- Different encryption key (credentials encrypted with different key)"
    print_warning "- Invalid JSON format"
    print_warning "- Duplicate credential names"
    exit 1
fi