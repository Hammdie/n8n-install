#!/bin/bash

# Workflow Update Script - nutzt Original-IDs für Updates
PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Project name required"
    echo "Usage: $0 <project-name>"
    exit 1
fi

WORKFLOW_DIR="${PROJECT_NAME}/workflows"
N8N_URL="http://localhost:5678"
N8N_API_KEY="n8n_api_f754bdafcea3e92aabd9e200701f0d41941eefe5464168615d305710f16de59c317f2b34040fbd34"

echo "🔄 Workflow Update Script for: $PROJECT_NAME"
echo "🔑 Using API Key: ${N8N_API_KEY:0:20}..."

# Create mapping of original IDs to current IDs
echo "📊 Creating ID mapping..."

# Get current workflows with their names
curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_URL/api/v1/workflows" | \
    jq -r '.data[] | "\(.name)|\(.id)"' > /tmp/current_workflows.txt

# Get original IDs from filenames
declare -A original_to_current_map
declare -A current_to_original_map

for workflow_file in "$WORKFLOW_DIR"/*.json; do
    if [ -f "$workflow_file" ]; then
        filename=$(basename "$workflow_file")
        
        # Extract original ID from filename (workflow_X_ORIGINALID.json)
        original_id=$(echo "$filename" | sed 's/^workflow_[0-9]*_\(.*\)\.json$/\1/')
        
        # Get workflow name from JSON
        workflow_name=$(jq -r '.name // "UNKNOWN"' "$workflow_file" 2>/dev/null)
        
        # Find current ID by matching name
        current_id=$(grep "^$workflow_name|" /tmp/current_workflows.txt | cut -d'|' -f2)
        
        if [ -n "$current_id" ] && [ -n "$original_id" ]; then
            original_to_current_map["$original_id"]="$current_id"
            current_to_original_map["$current_id"]="$original_id"
            echo "  ✓ $workflow_name: $original_id → $current_id"
        fi
    fi
done

echo ""
echo "📋 ID Mapping Summary:"
echo "  Total mappings: ${#original_to_current_map[@]}"

# Create upgrade function
upgrade_workflow() {
    local workflow_file=$1
    local filename=$(basename "$workflow_file")
    local original_id=$(echo "$filename" | sed 's/^workflow_[0-9]*_\(.*\)\.json$/\1/')
    local current_id="${original_to_current_map[$original_id]}"
    
    if [ -z "$current_id" ]; then
        echo "❌ No mapping found for original ID: $original_id"
        return 1
    fi
    
    local workflow_name=$(jq -r '.name // "UNKNOWN"' "$workflow_file")
    echo -n "🔄 Upgrading: $workflow_name ($original_id → $current_id) ... "
    
    # Clean workflow data for update
    cleaned_file="/tmp/update_$(basename "$workflow_file")"
    jq 'del(.id, .active, .createdAt, .updatedAt, .versionId) | .settings = {}' "$workflow_file" > "$cleaned_file"
    
    # Update via PUT API
    response=$(curl -s -w "%{http_code}" -o /tmp/update_response.txt \
        -X PUT "$N8N_URL/api/v1/workflows/$current_id" \
        -H "Content-Type: application/json" \
        -H "X-N8N-API-KEY: $N8N_API_KEY" \
        -d @"$cleaned_file")
    
    if [[ "$response" == "200" ]]; then
        echo "✅ Success"
        rm -f "$cleaned_file"
        return 0
    else
        echo "❌ Failed (HTTP: $response)"
        if [ -f /tmp/update_response.txt ]; then
            error_msg=$(cat /tmp/update_response.txt | jq -r '.message // .' 2>/dev/null || cat /tmp/update_response.txt)
            echo "      Error: $error_msg"
        fi
        rm -f "$cleaned_file"
        return 1
    fi
}

# Interactive mode
if [ "$2" = "interactive" ]; then
    echo ""
    echo "🎛️  Interactive Update Mode"
    echo "Select workflows to update:"
    
    for workflow_file in "$WORKFLOW_DIR"/*.json; do
        if [ -f "$workflow_file" ]; then
            workflow_name=$(jq -r '.name // "UNKNOWN"' "$workflow_file")
            read -p "Update '$workflow_name'? (y/n): " choice
            case $choice in
                [Yy]* ) upgrade_workflow "$workflow_file";;
                * ) echo "  ⏭️  Skipped";;
            esac
        fi
    done
elif [ "$2" = "all" ]; then
    echo ""
    echo "🚀 Updating ALL workflows..."
    success_count=0
    fail_count=0
    
    for workflow_file in "$WORKFLOW_DIR"/*.json; do
        if [ -f "$workflow_file" ]; then
            if upgrade_workflow "$workflow_file"; then
                ((success_count++))
            else
                ((fail_count++))
            fi
        fi
    done
    
    echo ""
    echo "📊 Update Summary:"
    echo "  ✅ Updated: $success_count"
    echo "  ❌ Failed: $fail_count"
else
    echo ""
    echo "💡 Usage Options:"
    echo "  $0 $PROJECT_NAME all          # Update all workflows"
    echo "  $0 $PROJECT_NAME interactive  # Interactive selection"
    echo "  $0 $PROJECT_NAME list         # Show ID mappings only"
fi

# Cleanup
rm -f /tmp/current_workflows.txt /tmp/update_response.txt

echo ""
echo "📚 Original→Current ID Mappings saved for reference:"
for orig_id in "${!original_to_current_map[@]}"; do
    echo "  $orig_id → ${original_to_current_map[$orig_id]}"
done | sort