#!/bin/bash

# Direkter SQLite Workflow Import für n8n
PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Project name required"
    echo "Usage: $0 <project-name>"
    exit 1
fi

WORKFLOW_DIR="${PROJECT_NAME}/workflows"
DB_PATH="${PROJECT_NAME}/data/database.sqlite"

if [ ! -d "$WORKFLOW_DIR" ]; then
    echo "❌ Workflow directory not found: $WORKFLOW_DIR"
    exit 1
fi

echo "📥 Importing workflows directly to SQLite for: $PROJECT_NAME"

# Stoppe Container für sauberen Import
echo "⏸️  Stopping n8n temporarily..."
./stop-dev.sh "$PROJECT_NAME" > /dev/null 2>&1

# Count workflows
WORKFLOW_COUNT=$(find "$WORKFLOW_DIR" -name "*.json" | wc -l | tr -d ' ')
echo "📋 Found $WORKFLOW_COUNT workflow(s) to import"

if [ $WORKFLOW_COUNT -eq 0 ]; then
    echo "⚠️  No workflows found to import"
    ./start-dev.sh "$PROJECT_NAME" > /dev/null 2>&1
    exit 0
fi

# Erstelle Import SQL
echo "📝 Preparing database import..."

IMPORT_SQL="/tmp/import_workflows.sql"
echo "BEGIN TRANSACTION;" > "$IMPORT_SQL"

counter=1
for workflow_file in "$WORKFLOW_DIR"/*.json; do
    if [ -f "$workflow_file" ]; then
        # Extrahiere Workflow Daten
        workflow_data=$(cat "$workflow_file" | jq -c '.')
        workflow_name=$(echo "$workflow_data" | jq -r '.name // "Imported Workflow"' | sed "s/'/''/g")
        workflow_id=$(echo "$workflow_data" | jq -r '.id // ""')
        
        if [ -z "$workflow_id" ]; then
            # Generiere neue ID falls keine vorhanden
            workflow_id="wf_$(openssl rand -hex 8)"
        fi
        
        # Escape JSON for SQL
        escaped_data=$(echo "$workflow_data" | sed "s/'/''/g")
        
        # SQL INSERT
        cat >> "$IMPORT_SQL" << EOF
INSERT OR REPLACE INTO workflow_entity (
    id, name, active, nodes, connections, createdAt, updatedAt, settings, 
    staticData, pinData, versionId
) VALUES (
    '$workflow_id',
    '$workflow_name',
    0,
    '$escaped_data',
    '[]',
    datetime('now'),
    datetime('now'),
    '{}',
    '{}',
    '{}',
    1
);
EOF
        
        echo "  ✓ Prepared: $workflow_name"
        ((counter++))
    fi
done

echo "COMMIT;" >> "$IMPORT_SQL"

# Führe Import aus
echo "💾 Importing to database..."
if sqlite3 "$DB_PATH" < "$IMPORT_SQL"; then
    echo "✅ Database import successful!"
else
    echo "❌ Database import failed!"
    rm -f "$IMPORT_SQL"
    ./start-dev.sh "$PROJECT_NAME" > /dev/null 2>&1
    exit 1
fi

# Aufräumen
rm -f "$IMPORT_SQL"

# n8n wieder starten
echo "🚀 Restarting n8n..."
./start-dev.sh "$PROJECT_NAME" > /dev/null 2>&1

echo "✅ Import completed!"
echo "🌐 Check your workflows at: http://localhost:5678"