# 🚀 n8n Installation Suite - Feature Übersicht

## 📋 Installationsoptionen

### 🖥️ Native Installation
- **Node.js 18.x** direkt auf dem System
- **PostgreSQL** als lokale Datenbank
- **systemd Service** für automatischen Start
- Direkte System-Integration
- Optimale Performance

### 🐳 Docker Compose Installation
- **Containerisierte** n8n-Instance
- **PostgreSQL Container** mit persistenten Volumes
- **Health Checks** für alle Services
- Einfaches Deployment und Skalierung
- Isolierte Umgebung

## 🔐 Sicherheitsfeatures

### Encryption Key Management
- **Zentrale Speicherung** in `/var/n8n/`
- **600/700 Berechtigungen** für maximale Sicherheit
- **Persistente Schlüssel** zwischen Installationen
- **Backup/Restore** unterstützt Verschlüsselung

### SSH-Sicherheit
- **Dedicated SSH-User** "odoo" 
- **Key-basierte Authentifizierung**
- **Sudoers-Konfiguration** für n8n-Management
- **Sichere Aliase** für alle Management-Befehle

## 🌐 Web & Proxy Features

### Reverse Proxy
- **nginx** als SSL-Termination
- **Let's Encrypt** automatische SSL-Zertifikate
- **Multi-Domain Support** für mehrere Instanzen
- **WebSocket Support** für n8n-Features
- **Security Headers** für erhöhte Sicherheit

### Firewall-Konfiguration
- **UFW** automatische Konfiguration
- **Port 80/443** für Web-Traffic
- **Port 22** für SSH
- **Minimal Attack Surface**

## 🛠️ Management Tools

### Hauptverwaltung (`n8n-menu.sh`)
```
===============================
    🚀 n8n Management System    
===============================
[1] 📊 Status Dashboard
[2] 🔧 Service Management  
[3] 🌐 Domain Management
[4] 🐳 Docker Management (bei Docker-Installation)
[5] 💾 Backup & Restore
[6] 🔄 Updates & Maintenance
[7] 📋 System Information
[8] ❌ Exit
```

### Domain-Management (`manage-domains.sh`)
- **SSL-Zertifikat Management**
- **Reverse Proxy Konfiguration**
- **Domain hinzufügen/entfernen**
- **Automatische nginx-Konfiguration**

### Docker-Management (`manage-docker.sh`)
```
================================
    🐳 Docker Management
================================
[1] 📊 Container Status
[2] ⚡ Start Services
[3] 🛑 Stop Services
[4] 🔄 Restart Services
[5] 📋 Show Logs
[6] 🔧 Container Shell
[7] 🔄 Update Images
[8] 💾 Backup Data
[9] 🧹 System Cleanup
```

## 💾 Backup & Restore

### Backup-Features
- **Automatisierte Backups** mit Zeitstempel
- **PostgreSQL Database Dumps**
- **Konfigurationsdateien Backup**
- **Encryption Key Backup**
- **Docker Volume Backup** (bei Docker-Installation)
- **Komprimierte Backup-Archive**

### Restore-Features
- **Vollständige Systemwiederherstellung**
- **Selektives Restore** von Komponenten
- **Encryption Key Wiederherstellung**
- **Service-Neustart** nach Restore
- **Backup-Validierung**

## 🔄 Update & Maintenance

### Native Updates
- **n8n Version Updates**
- **Node.js Updates**
- **System Package Updates**
- **Service-Restart Management**

### Docker Updates  
- **Image Updates** für alle Container
- **Version Pinning** für Stabilität
- **Rolling Updates** ohne Downtime
- **Rollback-Fähigkeit**

## 📊 Monitoring & Logging

### Status Dashboard
- **Service Status** (Running/Stopped)
- **Port Availability**
- **SSL Certificate Status**
- **Disk Space Usage**
- **Memory Usage**
- **Database Connection**

### Logging
- **Strukturierte Logs** für alle Operationen
- **systemd Journals** (Native)
- **Docker Container Logs**
- **nginx Access/Error Logs**
- **Centralized Log Viewing**

## 🎯 SSH-Aliases & Shortcuts

### Verfügbare Befehle (als odoo-Benutzer)
```bash
n8n-status      # Status Dashboard
n8n-manage      # Management-Menü
n8n-menu        # Hauptverwaltungsmenü
n8n-domains     # Domain-Management
n8n-docker      # Docker-Verwaltung (nur bei Docker)
n8n-logs        # Live-Logs anzeigen
n8n-start       # n8n starten
n8n-stop        # n8n stoppen
n8n-restart     # n8n neustarten
n8n-backup      # Backup erstellen
n8n-restore     # Backup wiederherstellen
```

## 🏗️ Installation Flow

### 1. Voraussetzungen prüfen
- Ubuntu Server 20.04+ Erkennung
- Root-Berechtigung Validierung
- Internet-Verbindung Test
- Domain/SSL Validierung

### 2. Installation Method Auswahl
```
Wählen Sie die Installationsmethode:
[1] Native Installation (Node.js + systemd)
[2] Docker Compose Installation

Ihre Wahl [1-2]:
```

### 3. System Setup
- **Pakete installieren** (Node.js oder Docker)
- **Benutzer erstellen** (n8n)
- **Verzeichnisse erstellen**
- **Berechtigungen setzen**

### 4. Database Setup
- **PostgreSQL Installation/Container**
- **Datenbank erstellen**
- **Benutzer konfigurieren**
- **Verbindung testen**

### 5. n8n Configuration
- **Environment Variables**
- **Service Configuration**
- **Encryption Key Setup**
- **Webhook Configuration**

### 6. Web Server Setup
- **nginx Installation**
- **Reverse Proxy Configuration**
- **SSL Certificate (Let's Encrypt)**
- **Security Headers**

### 7. SSH User Setup
- **odoo User erstellen**
- **SSH Keys konfigurieren**
- **Aliases einrichten**
- **Sudoers Berechtigungen**

## 🔧 Wartung & Best Practices

### Regelmäßige Wartung
- **Tägliche Backups** via Cron
- **Wöchentliche Updates** 
- **Monatliche Cleanup** (Docker)
- **SSL Certificate Monitoring**

### Troubleshooting
- **Service Status Checks**
- **Log Analysis Tools**
- **Database Connection Tests**
- **SSL Certificate Validation**
- **Docker Health Checks**

### Performance Optimierung
- **PostgreSQL Tuning**
- **nginx Optimization**
- **Docker Resource Limits**
- **Log Rotation**

## 📈 Skalierbarkeit

### Horizontal Scaling
- **Multi-Domain Support**
- **Load Balancer Integration**
- **Database Clustering** (PostgreSQL)

### Vertical Scaling
- **Resource Monitoring**
- **Container Limits** (Docker)
- **Service Tuning**

## 🛡️ Security Hardening

### System Security
- **UFW Firewall** aktiviert
- **fail2ban** Integration möglich
- **SSH Key-only** Authentication
- **Minimal User Privileges**

### Application Security
- **Secure Headers** (nginx)
- **SSL/TLS** Encryption
- **Database Isolation**
- **Secure Environment Variables**

## 📖 Dokumentation

### Verfügbare Dokumentation
- `README.md` - Hauptdokumentation
- `FEATURES.md` - Diese Feature-Übersicht
- Inline-Kommentare in allen Skripten
- Help-Funktionen in Management-Tools

### Support & Troubleshooting
- Detaillierte Error Messages
- Logging für alle Operationen
- Debug-Modi verfügbar
- Recovery-Procedures dokumentiert