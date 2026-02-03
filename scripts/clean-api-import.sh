#!/bin/bash

# API-basierter Workflow Import für n8n mit Data-Cleaning
PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Project name required"
    echo "Usage: $0 <project-name>"
    exit 1
fi

WORKFLOW_DIR="${PROJECT_NAME}/workflows"
N8N_URL="http://localhost:5678"
N8N_API_KEY="n8n_api_f754bdafcea3e92aabd9e200701f0d41941eefe5464168615d305710f16de59c317f2b34040fbd34"

if [ ! -d "$WORKFLOW_DIR" ]; then
    echo "❌ Workflow directory not found: $WORKFLOW_DIR"
    exit 1
fi

echo "📥 Importing workflows via API for: $PROJECT_NAME"
echo "🔑 Using API Key: ${N8N_API_KEY:0:20}..."

# Count workflows
WORKFLOW_COUNT=$(find "$WORKFLOW_DIR" -name "*.json" | wc -l | tr -d ' ')
echo "📋 Found $WORKFLOW_COUNT workflow(s) to import"

if [ $WORKFLOW_COUNT -eq 0 ]; then
    echo "⚠️  No workflows found to import"
    exit 0
fi

# Create temp directory for cleaned workflows
TEMP_DIR="/tmp/n8n_import_$$"
mkdir -p "$TEMP_DIR"

echo "🧹 Cleaning workflow data..."

# Import each workflow via API
SUCCESS_COUNT=0
FAIL_COUNT=0

for workflow_file in "$WORKFLOW_DIR"/*.json; do
    if [ -f "$workflow_file" ]; then
        filename=$(basename "$workflow_file")
        echo -n "📝 Processing: $filename ... "
        
        # Clean the workflow JSON - remove read-only fields
        cleaned_file="$TEMP_DIR/cleaned_$(basename "$workflow_file")"
        
        # Remove read-only fields and clean settings
        jq 'del(.id, .active, .createdAt, .updatedAt, .versionId) | .settings = {}' "$workflow_file" > "$cleaned_file"
        
        if [ $? -ne 0 ]; then
            echo "❌ JSON parsing failed"
            ((FAIL_COUNT++))
            continue
        fi
        
        # Try to import via POST API
        response=$(curl -s -w "%{http_code}" -o /tmp/import_response.txt \
            -X POST "$N8N_URL/api/v1/workflows" \
            -H "Content-Type: application/json" \
            -H "X-N8N-API-KEY: $N8N_API_KEY" \
            -d @"$cleaned_file")
        
        if [[ "$response" == "201" || "$response" == "200" ]]; then
            echo "✅ Success"
            ((SUCCESS_COUNT++))
        else
            echo "❌ Failed (HTTP: $response)"
            if [ -f /tmp/import_response.txt ]; then
                error_msg=$(cat /tmp/import_response.txt | jq -r '.message // .' 2>/dev/null || cat /tmp/import_response.txt)
                echo "      Error: $error_msg" | head -1
            fi
            ((FAIL_COUNT++))
        fi
    fi
done

# Cleanup
rm -rf "$TEMP_DIR"
rm -f /tmp/import_response.txt

echo ""
echo "📊 Import Summary:"
echo "  ✅ Successful: $SUCCESS_COUNT"
echo "  ❌ Failed: $FAIL_COUNT"

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo "🌐 Check your workflows at: $N8N_URL"
    echo "✅ Import completed!"
    
    echo ""
    echo "📚 API Key Documentation:"
    echo "🔑 API Key: n8n_api_f754bdafcea3e92aabd9e200701f0d41941eefe5464168615d305710f16de59c317f2b34040fbd34"
    echo ""
    echo "📖 API Usage Examples:"
    echo "# List all workflows:"
    echo "curl -H 'X-N8N-API-KEY: $N8N_API_KEY' $N8N_URL/api/v1/workflows"
    echo ""
    echo "# Get specific workflow:"
    echo "curl -H 'X-N8N-API-KEY: $N8N_API_KEY' $N8N_URL/api/v1/workflows/WORKFLOW_ID"
    echo ""
    echo "# Create new workflow:"
    echo "curl -X POST -H 'Content-Type: application/json' -H 'X-N8N-API-KEY: $N8N_API_KEY' \\"
    echo "  $N8N_URL/api/v1/workflows -d @workflow.json"
    echo ""
    echo "# Execute workflow:"
    echo "curl -X POST -H 'X-N8N-API-KEY: $N8N_API_KEY' \\"
    echo "  $N8N_URL/api/v1/workflows/WORKFLOW_ID/execute"
else
    echo "❌ No workflows were imported successfully"
    exit 1
fi