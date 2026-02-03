# Claude AI Assistant Notes

## Projekt Kontext

Dieses Repository enthält ein umfassendes n8n-Installationssystem, das über mehrere Sitzungen entwickelt wurde:

### Hauptziele:
- Professionelle n8n-Installation für Ubuntu Server (Native + Docker)
- Multi-Environment-System (Development, Preproduction, Production)
- Sichere Ansible-basierte Deployment-Pipeline
- Git-integrierte Workflow-Entwicklung und -Export
- Umfassende Dokumentation mit Cross-Navigation

### Technischer Stack:
- **Target OS**: Ubuntu Server (systemd, UFW, SSH)
- **n8n**: Neueste Version mit PostgreSQL Backend
- **Webserver**: nginx mit Let's Encrypt SSL/TLS
- **Container**: Docker & Docker Compose Support
- **Automation**: Ansible mit Vault für Credentials
- **Versionierung**: Git für Workflow-Management

### Repository Struktur:
```
n8n-install/
├── install-n8n.sh              # Hauptinstallation (Native/Docker)
├── manage-environments.sh      # Multi-Environment-Management
├── setup-development.sh        # Dev-Workspace mit Git
├── export-workflows.sh         # Git-basierter Workflow-Export
├── import-workflows.sh         # Workflow-Import mit Ansible
├── manage-vault.sh             # Sichere Credential-Verwaltung
├── server-config.sh            # Server-Listen für alle Environments
├── manage-docker.sh            # Docker Container-Management
├── README.md                   # Haupt-Navigation
├── INDEX.md                    # Vollständige Navigation
├── FEATURES.md                 # Feature-Katalog
├── MULTI-ENVIRONMENT.md        # Multi-Environment-Guide
└── CLAUDE.md                   # Diese Datei (AI-Notizen)
```

## User Präferenzen:

### Git-Operations:
- **NIEMALS automatisch git commit oder git push ausführen**
- User möchte manuelle Kontrolle über Git-Operationen
- Nur bei expliziter Anweisung Git-Commands verwenden

### Code-Organisation:
- Alle Skripte müssen ausführbar sein (chmod +x)
- Relative Pfade für interne Dokumentation verwenden
- GitHub-Repository: `Hammdie/n8n-install`

### Dokumentation:
- Vollständige Cross-Navigation zwischen allen Markdown-Dateien
- Deutsche und englische Versionen pflegen
- Technische Genauigkeit bei Übersetzungen

## Entwicklungshistorie:

### Phase 1: Basis-Installation
- Einfache n8n-Installation für Ubuntu
- systemd Service-Integration
- nginx Reverse Proxy Setup

### Phase 2: Sicherheit & Flexibilität
- Encryption Key Management
- Docker Compose Alternative
- UFW Firewall-Integration

### Phase 3: Multi-Environment
- Development/Preproduction/Production Trennung
- Ansible Deployment Pipeline
- Sichere Vault Credential-Verwaltung

### Phase 4: Workflow-Management
- Git-basierte Workflow-Versionierung
- Export/Import-Pipeline mit Ansible
- Development-to-Production Workflow

### Phase 5: Dokumentation
- Umfassende cross-verlinkte Dokumentation
- Navigation-System (INDEX.md)
- Feature-Katalog (FEATURES.md)

### Phase 6: Repository-Reorganisation
- Verschiebung aller Dateien ins Root-Verzeichnis
- GitHub-Links von Platzhaltern zu echten URLs aktualisiert
- Alle relativen Pfade beibehalten

## Aktuelle Aufgaben:

### Sofortige Priorität:
1. **Dokumentation ins Englische übersetzen**
   - README.md
   - INDEX.md
   - FEATURES.md
   - MULTI-ENVIRONMENT.md
   - Alle Formatierung und Links beibehalten

### Code-Wartung:
- Alle Skripte sind funktional und getestet
- Multi-Environment-System ist vollständig implementiert
- Docker und Native Installation beide unterstützt

## Wichtige Notizen:

### Server-Management:
- Drei getrennte Environment-Listen in server-config.sh
- SSH-Key-basierte Authentifizierung
- Ansible für Remote-Deployment

### Sicherheit:
- Ansible Vault für sensible Daten
- SSL/TLS mit Let's Encrypt
- UFW Firewall-Konfiguration
- Encryption Keys für Backups

### Docker vs. Native:
- Docker: Einfache Wartung, Container-Isolierung
- Native: Direkter systemd-Service, bessere Performance
- Beide Optionen vollständig dokumentiert

## Debugging-Info:

### Häufige Issues:
- Port-Konflikte (8080/80/443)
- PostgreSQL-Verbindungsprobleme
- nginx SSL-Zertifikat-Renewal
- Docker Volume-Berechtigungen

### Testing-Workflow:
1. Development auf localhost/dev-vm
2. Preproduction auf Staging-Server
3. Production Deployment mit Ansible
4. Backup/Restore-Tests regelmäßig

## Code-Standards:

### Shell-Skripte:
- Bash mit set -euo pipefail
- Farbige Ausgaben für bessere UX
- Ausführliche Logging und Error-Handling
- Interactive Menüs wo angebracht

### Dokumentation:
- Markdown mit relativen Links
- Technische Genauigkeit
- Cross-Reference Navigation
- Mehrsprachige Unterstützung