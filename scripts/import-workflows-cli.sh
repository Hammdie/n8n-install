#!/bin/bash
#
# Standard n8n CLI Workflow Import Script
# Imports workflows to running n8n instance using official CLI
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
    print_error "Project name required"
    echo "Usage: $0 <project-name> [source-directory]"
    echo "Example: $0 360Group"
    echo "Example: $0 360Group /path/to/workflows"
    exit 1
fi

PROJECT_NAME="$1"
SOURCE_DIR="$2"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
DEV_DIR="$(dirname "$SCRIPT_DIR")/development"
PROJECT_DIR="$DEV_DIR/$PROJECT_NAME"

# Default source directory if not provided
if [ -z "$SOURCE_DIR" ]; then
    SOURCE_DIR="$PROJECT_DIR/workflows"
fi

print_status "Standard n8n CLI Import for project: $PROJECT_NAME"
print_status "Source directory: $SOURCE_DIR"

# Check if project exists
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory not found: $PROJECT_DIR"
    exit 1
fi

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    print_error "Source directory not found: $SOURCE_DIR"
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

# Check for workflow files
WORKFLOW_COUNT=$(find "$SOURCE_DIR" -name "*.json" -type f | wc -l)
if [ "$WORKFLOW_COUNT" -eq 0 ]; then
    print_error "No JSON workflow files found in: $SOURCE_DIR"
    exit 1
fi

print_status "Found $WORKFLOW_COUNT workflow file(s) to import"

# List files to import
print_status "Files to import:"
find "$SOURCE_DIR" -name "*.json" -type f -exec basename {} \; | sort

# Get relative path for container volume mount
# Convert absolute path to relative path from project directory
if [[ "$SOURCE_DIR" == "$PROJECT_DIR"* ]]; then
    CONTAINER_PATH="/data${SOURCE_DIR#$PROJECT_DIR}"
else
    print_error "Source directory must be within project directory for container access"
    print_status "Expected: $PROJECT_DIR/workflows"
    print_status "Got: $SOURCE_DIR"
    exit 1
fi

print_status "Container path: $CONTAINER_PATH"

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

# Import workflows using standard CLI
print_status "Importing workflows using n8n CLI..."

if docker compose -f "$PROJECT_NAME/docker-compose.yml" exec n8n npx n8n import:workflow \
    --separate \
    --input="$CONTAINER_PATH"; then
    
    print_success "Workflows imported successfully using standard n8n CLI"
    
    # Verify import by listing workflows
    print_status "Verifying imported workflows..."
    IMPORTED_COUNT=$(docker compose -f "$PROJECT_NAME/docker-compose.yml" exec n8n npx n8n list:workflow | grep -c "^[[:space:]]*-" || echo "0")
    
    print_success "✨ Import completed successfully!"
    print_status "Total workflows in n8n: $IMPORTED_COUNT"
    print_status "Access your workflows at: http://localhost:5678"
    
else
    print_error "Import failed"
    exit 1
fi