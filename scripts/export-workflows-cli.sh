#!/bin/bash
#
# Standard n8n CLI Workflow Export Script
# Exports workflows from running n8n instance using official CLI
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
    echo "Usage: $0 <project-name>"
    echo "Example: $0 360Group"
    exit 1
fi

PROJECT_NAME="$1"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
DEV_DIR="$(dirname "$SCRIPT_DIR")/development"
PROJECT_DIR="$DEV_DIR/$PROJECT_NAME"
EXPORT_DIR="$PROJECT_DIR/workflows"

print_status "Standard n8n CLI Export for project: $PROJECT_NAME"

# Check if project exists
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory not found: $PROJECT_DIR"
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

# Create export directory
mkdir -p "$EXPORT_DIR"

print_status "Exporting workflows using n8n CLI..."

# Export all workflows using standard CLI with backup format
# --backup sets --all --pretty --separate automatically
if docker compose -f "$PROJECT_NAME/docker-compose.yml" exec n8n npx n8n export:workflow \
    --backup \
    --output="/data/workflows/"; then
    
    print_success "Workflows exported successfully"
    
    # Count exported files
    WORKFLOW_COUNT=$(find "$EXPORT_DIR" -name "*.json" -type f | wc -l)
    print_status "Exported $WORKFLOW_COUNT workflow file(s) to: $EXPORT_DIR"
    
    # List exported files
    if [ "$WORKFLOW_COUNT" -gt 0 ]; then
        print_status "Exported workflows:"
        find "$EXPORT_DIR" -name "*.json" -type f -exec basename {} \; | sort
    fi
    
    print_success "✨ Export completed successfully!"
    print_status "Files location: $EXPORT_DIR"
    
else
    print_error "Export failed"
    exit 1
fi