#!/usr/bin/env python3
"""
n8n Workflow Update Script mit Original-ID Tracking
Ermöglicht Updates von Workflows unter Beibehaltung der Original-IDs
"""

import json
import os
import sys
import requests
import glob
import re

class WorkflowUpdater:
    def __init__(self, project_name):
        self.project_name = project_name
        self.workflow_dir = f"{project_name}/workflows"
        self.n8n_url = "http://localhost:5678"
        self.api_key = "n8n_api_f754bdafcea3e92aabd9e200701f0d41941eefe5464168615d305710f16de59c317f2b34040fbd34"
        self.headers = {
            'X-N8N-API-KEY': self.api_key,
            'Content-Type': 'application/json'
        }
        
    def get_current_workflows(self):
        """Hole aktuelle Workflows aus n8n"""
        try:
            response = requests.get(f"{self.n8n_url}/api/v1/workflows", headers=self.headers)
            response.raise_for_status()
            return response.json().get('data', [])
        except Exception as e:
            print(f"❌ Error fetching workflows: {e}")
            return []
    
    def create_id_mapping(self):
        """Erstelle Mapping zwischen Original-IDs und Current-IDs"""
        current_workflows = self.get_current_workflows()
        original_to_current = {}
        current_to_original = {}
        
        # Erstelle Name->Current-ID Mapping
        name_to_current = {wf['name']: wf['id'] for wf in current_workflows}
        
        print("📊 Creating ID mapping...")
        
        # Durchlaufe lokale Workflow-Dateien
        workflow_files = glob.glob(f"{self.workflow_dir}/workflow_*.json")
        
        for workflow_file in workflow_files:
            # Extrahiere Original-ID aus Dateiname
            filename = os.path.basename(workflow_file)
            match = re.match(r'workflow_\d+_(.+)\.json$', filename)
            
            if not match:
                continue
                
            original_id = match.group(1)
            
            # Hole Workflow-Name aus JSON
            try:
                with open(workflow_file, 'r', encoding='utf-8') as f:
                    workflow_data = json.load(f)
                    workflow_name = workflow_data.get('name', 'UNKNOWN')
                    
                # Finde aktuelle ID über Namen
                current_id = name_to_current.get(workflow_name)
                
                if current_id and original_id:
                    original_to_current[original_id] = current_id
                    current_to_original[current_id] = original_id
                    print(f"  ✓ {workflow_name}: {original_id} → {current_id}")
                    
            except Exception as e:
                print(f"  ❌ Error processing {filename}: {e}")
        
        return original_to_current, current_to_original
    
    def clean_workflow_data(self, workflow_data):
        """Bereinige Workflow-Daten für Update"""
        # Entferne read-only Felder
        fields_to_remove = ['id', 'active', 'createdAt', 'updatedAt', 'versionId']
        cleaned = {k: v for k, v in workflow_data.items() if k not in fields_to_remove}
        
        # Setze leere settings falls nicht vorhanden
        cleaned['settings'] = {}
        
        return cleaned
    
    def update_workflow(self, workflow_file, current_id):
        """Update einen einzelnen Workflow"""
        try:
            with open(workflow_file, 'r', encoding='utf-8') as f:
                workflow_data = json.load(f)
                
            workflow_name = workflow_data.get('name', 'UNKNOWN')
            print(f"🔄 Upgrading: {workflow_name}...", end=' ')
            
            # Bereinige Daten
            cleaned_data = self.clean_workflow_data(workflow_data)
            
            # Update via PUT API
            response = requests.put(
                f"{self.n8n_url}/api/v1/workflows/{current_id}",
                headers=self.headers,
                json=cleaned_data
            )
            
            if response.status_code == 200:
                print("✅ Success")
                return True
            else:
                print(f"❌ Failed (HTTP: {response.status_code})")
                try:
                    error_msg = response.json().get('message', response.text)
                    print(f"      Error: {error_msg}")
                except:
                    print(f"      Error: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Error: {e}")
            return False
    
    def show_id_mappings(self):
        """Zeige ID-Mappings"""
        original_to_current, _ = self.create_id_mapping()
        
        print(f"\n📋 ID Mapping Summary:")
        print(f"  Total mappings: {len(original_to_current)}")
        
        if original_to_current:
            print("\n📚 Original→Current ID Mappings:")
            for orig_id, curr_id in sorted(original_to_current.items()):
                print(f"  {orig_id} → {curr_id}")
        
        return original_to_current
    
    def update_all(self):
        """Update alle Workflows"""
        original_to_current, _ = self.create_id_mapping()
        
        print(f"\n🚀 Updating ALL workflows...")
        success_count = 0
        fail_count = 0
        
        workflow_files = glob.glob(f"{self.workflow_dir}/workflow_*.json")
        
        for workflow_file in workflow_files:
            filename = os.path.basename(workflow_file)
            match = re.match(r'workflow_\d+_(.+)\.json$', filename)
            
            if not match:
                continue
                
            original_id = match.group(1)
            current_id = original_to_current.get(original_id)
            
            if not current_id:
                print(f"❌ No mapping found for {original_id}")
                fail_count += 1
                continue
            
            if self.update_workflow(workflow_file, current_id):
                success_count += 1
            else:
                fail_count += 1
        
        print(f"\n📊 Update Summary:")
        print(f"  ✅ Updated: {success_count}")
        print(f"  ❌ Failed: {fail_count}")
    
    def update_interactive(self):
        """Interactive Update Mode"""
        original_to_current, _ = self.create_id_mapping()
        
        print(f"\n🎛️  Interactive Update Mode")
        print("Select workflows to update:")
        
        workflow_files = glob.glob(f"{self.workflow_dir}/workflow_*.json")
        
        for workflow_file in workflow_files:
            try:
                with open(workflow_file, 'r', encoding='utf-8') as f:
                    workflow_data = json.load(f)
                    workflow_name = workflow_data.get('name', 'UNKNOWN')
                    
                filename = os.path.basename(workflow_file)
                match = re.match(r'workflow_\d+_(.+)\.json$', filename)
                
                if not match:
                    continue
                    
                original_id = match.group(1)
                current_id = original_to_current.get(original_id)
                
                if not current_id:
                    print(f"⏭️  Skipped '{workflow_name}' (no mapping)")
                    continue
                
                choice = input(f"Update '{workflow_name}' ({original_id})? (y/n): ")
                if choice.lower().startswith('y'):
                    self.update_workflow(workflow_file, current_id)
                else:
                    print("  ⏭️  Skipped")
                    
            except Exception as e:
                print(f"❌ Error processing {workflow_file}: {e}")

def main():
    if len(sys.argv) < 2:
        print("❌ Project name required")
        print("Usage: python3 update-workflows.py <project-name> [mode]")
        print("Modes: list, all, interactive")
        sys.exit(1)
    
    project_name = sys.argv[1]
    mode = sys.argv[2] if len(sys.argv) > 2 else 'list'
    
    updater = WorkflowUpdater(project_name)
    
    print(f"🔄 Workflow Update Script for: {project_name}")
    print(f"🔑 Using API Key: {updater.api_key[:20]}...")
    
    if mode == 'list':
        updater.show_id_mappings()
        print(f"\n💡 Usage Options:")
        print(f"  python3 update-workflows.py {project_name} all          # Update all workflows")
        print(f"  python3 update-workflows.py {project_name} interactive  # Interactive selection")
        print(f"  python3 update-workflows.py {project_name} list         # Show ID mappings only")
        
    elif mode == 'all':
        updater.update_all()
        
    elif mode == 'interactive':
        updater.update_interactive()
        
    else:
        print(f"❌ Unknown mode: {mode}")
        print("Available modes: list, all, interactive")
        sys.exit(1)

if __name__ == "__main__":
    main()