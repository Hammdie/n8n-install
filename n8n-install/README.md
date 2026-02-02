# n8n Installation und Verwaltung für Ubuntu Server

Dieses Repository enthält Shell-Skripte zur automatischen Installation und Verwaltung von n8n auf einem Ubuntu Server mit PostgreSQL-Datenbank und SSH-Zugang für den Benutzer "odoo".

## 📋 Inhalt

- `install-n8n.sh` - Vollständige n8n-Installation
- `setup-ssh-user.sh` - SSH-Zugang für odoo-Benutzer konfigurieren
- `setup-reverse-proxy.sh` - Zusätzliche Domains mit Reverse Proxy
- `n8n-menu.sh` - Hauptverwaltungsmenü mit allen Optionen
- `manage-domains.sh` - Domain-Management und SSL-Verwaltung
- `backup-n8n.sh` - Backup-Skript für n8n
- `restore-n8n.sh` - Restore-Skript für n8n
- `update-n8n.sh` - Update-Skript für n8n

## 🚀 Schnellstart

### 1. Installation

```bash
# Repository klonen oder Skripte herunterladen
wget https://raw.githubusercontent.com/username/n8n-install/main/install-n8n.sh
chmod +x install-n8n.sh

# Installation starten (mit Domain)
sudo ./install-n8n.sh your-domain.com admin@your-domain.com

# Oder für lokale Installation
sudo ./install-n8n.sh localhost
```

### 2. SSH-User odoo einrichten

```bash
wget https://raw.githubusercontent.com/username/n8n-install/main/setup-ssh-user.sh
chmod +x setup-ssh-user.sh
sudo ./setup-ssh-user.sh
```

### 3. Zusätzliche Domains einrichten (Optional)

```bash
# Neue Domain mit SSL hinzufügen
sudo ./setup-reverse-proxy.sh staging.example.com admin@example.com

# Domain ohne SSL auf anderem Port
sudo ./setup-reverse-proxy.sh dev.example.com admin@example.com 5679 false
```

### 4. Verwaltungsmenü verwenden

```bash
# Hauptmenü starten (als root)
sudo ./n8n-menu.sh

# Domain-Management
./manage-domains.sh
```

## 🔧 Was wird installiert?

### System-Komponenten
- Node.js 18.x
- PostgreSQL mit konfigurierter Datenbank
- nginx als Reverse Proxy
- SSL-Zertifikate via Let's Encrypt (bei Domain-Installation)
- UFW Firewall-Konfiguration

### n8n-Konfiguration
- Systemd Service für automatischen Start
- PostgreSQL-Datenbank-Integration
- Sichere Umgebungsvariablen
- Logging-Konfiguration
- Webhook-Support

### SSH-Zugang
- Benutzer "odoo" mit sudo-Rechten
- Management-Skripte für n8n
- Sichere SSH-Konfiguration
- Interaktive Verwaltungstools

## 📁 Verzeichnisstruktur

```
/home/n8n/n8n/          # n8n Arbeitsverzeichnis
├── .env                # Umgebungsvariablen
├── logs/               # Log-Dateien
└── ...

/home/odoo/             # SSH-Benutzer Verzeichnis
├── n8n-status.sh      # Status-Dashboard
├── n8n-manage.sh      # Management-Menü
└── .ssh/              # SSH-Konfiguration

/var/backups/n8n/      # Backup-Verzeichnis
```

## 🔑 SSH-Zugang für odoo

Nach der Installation mit `setup-ssh-user.sh`:

```bash
# SSH-Verbindung herstellen
ssh odoo@your-server-ip

# Verfügbare Befehle
n8n-status    # Status anzeigen
n8n-manage    # Management-Menü
n8n-menu      # Hauptverwaltungsmenü
n8n-domains   # Domain-Management
n8n-logs      # Live-Logs anzeigen
n8n-start     # n8n starten
n8n-stop      # n8n stoppen
n8n-restart   # n8n neustarten
```

### SSH-Schlüssel hinzufügen

```bash
# Auf dem Server
sudo nano /home/odoo/.ssh/authorized_keys
# Fügen Sie Ihren öffentlichen SSH-Schlüssel ein

# Oder Passwort setzen
sudo passwd odoo
```

## 💾 Backup und Restore

### Backup erstellen

```bash
# Manuelles Backup
sudo ./backup-n8n.sh

# Automatisches tägliches Backup (Crontab)
echo "0 2 * * * /root/backup-n8n.sh" | sudo crontab -
```

### Backup wiederherstellen

```bash
# Verfügbare Backups anzeigen
sudo ./restore-n8n.sh

# Backup wiederherstellen
sudo ./restore-n8n.sh 20240202_143000
```

## 🔄 Updates

```bash
# n8n auf neueste Version aktualisieren
sudo ./update-n8n.sh
```

## 🛠️ Verwaltung

### Service-Befehle

```bash
# Status prüfen
sudo systemctl status n8n

# Logs anzeigen
sudo journalctl -u n8n -f

# Service-Verwaltung
sudo systemctl start n8n
sudo systemctl stop n8n
sudo systemctl restart n8n
```

### Konfiguration

Die Hauptkonfiguration befindet sich in `/home/n8n/n8n/.env`:

```bash
# Konfiguration bearbeiten
sudo nano /home/n8n/n8n/.env

# Service nach Änderungen neustarten
sudo systemctl restart n8n
```

## 🌐 Zugriff

### Web-Interface

- **Hauptdomain**: `https://your-domain.com`
- **Zusätzliche Domains**: `https://staging.example.com`, `https://dev.example.com`
- **Lokal**: `http://localhost:5678`

### Multi-Domain Setup

```bash
# Verschiedene Umgebungen auf einer Installation
sudo ./setup-reverse-proxy.sh staging.example.com admin@example.com 5678 true
sudo ./setup-reverse-proxy.sh dev.example.com admin@example.com 5679 false
sudo ./setup-reverse-proxy.sh api.example.com admin@example.com 5680 true
```

### Domain-Verwaltung

```bash
# Domains anzeigen
./manage-domains.sh list

# Domain hinzufügen
./manage-domains.sh add new.example.com admin@example.com

# Domain entfernen
./manage-domains.sh remove old.example.com

# Domain-Status prüfen
./manage-domains.sh status example.com
```

### Ersteinrichtung

1. Öffnen Sie die Web-URL im Browser
2. Erstellen Sie einen Admin-Benutzer
3. Beginnen Sie mit der Konfiguration Ihrer Workflows

## 🔒 Sicherheit

### Implementierte Sicherheitsmaßnahmen

- SSL/TLS-Verschlüsselung
- Firewall-Konfiguration (UFW)
- Sichere PostgreSQL-Konfiguration
- SSH-Schlüssel-Authentifizierung
- Systemd-Härtung
- Nginx-Sicherheits-Header

### Empfohlene zusätzliche Maßnahmen

```bash
# Fail2ban installieren
sudo apt install fail2ban

# SSH-Port ändern (optional)
sudo nano /etc/ssh/sshd_config
# Port 22 zu Port 2222 ändern

# Automatische Sicherheitsupdates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades
```

## 🗃️ Datenbank

### Verbindungsdetails

```bash
# Datenbank-Credentials anzeigen
sudo cat /root/n8n-db-credentials.txt

# PostgreSQL-Shell öffnen
sudo -u postgres psql n8n_db
```

### Datenbankgröße prüfen

```sql
-- In PostgreSQL-Shell
SELECT pg_size_pretty(pg_database_size('n8n_db'));
```

## 📊 Monitoring

### System-Monitoring

```bash
# Prozess-Status
ps aux | grep n8n

# Speicherverbrauch
free -h

# Festplattenbelegung
df -h

# Port-Status
netstat -tlnp | grep 5678
```

### Log-Analyse

```bash
# Fehler-Logs
sudo journalctl -u n8n --since today | grep ERROR

# Letzte Starts
sudo journalctl -u n8n --since "1 hour ago"

# Log-Größe begrenzen
sudo journalctl --vacuum-size=100M
```

## 🚨 Troubleshooting

### Häufige Probleme

#### n8n startet nicht

```bash
# Logs prüfen
sudo journalctl -u n8n -n 50

# Konfiguration prüfen
sudo -u n8n n8n start --check

# Berechtigungen prüfen
ls -la /home/n8n/n8n/
```

#### Datenbank-Verbindungsprobleme

```bash
# PostgreSQL-Status
sudo systemctl status postgresql

# Datenbank-Verbindung testen
sudo -u postgres psql -c "\l"

# n8n-Benutzer-Berechtigung prüfen
sudo -u postgres psql -c "\du"
```

#### SSL-Probleme

```bash
# Zertifikat erneuern
sudo certbot renew

# Nginx-Konfiguration testen
sudo nginx -t

# SSL-Status prüfen
openssl s_client -connect your-domain.com:443
```

## 🔧 Anpassungen

### Erweiterte Konfiguration

```bash
# .env-Datei anpassen
sudo nano /home/n8n/n8n/.env

# Wichtige Einstellungen:
# N8N_PORT=5678
# N8N_PROTOCOL=https
# WEBHOOK_URL=https://your-domain.com/
# N8N_ENCRYPTION_KEY=your-key
```

### Nginx-Konfiguration

```bash
# Nginx-Konfiguration bearbeiten
sudo nano /etc/nginx/sites-available/n8n

# Konfiguration testen
sudo nginx -t

# Nginx neuladen
sudo systemctl reload nginx
```

## 📈 Performance-Optimierung

### Node.js-Speicher erhöhen

```bash
# Systemd-Service bearbeiten
sudo systemctl edit n8n

# Hinzufügen:
[Service]
Environment="NODE_OPTIONS=--max-old-space-size=4096"
```

### PostgreSQL-Optimierung

```bash
# PostgreSQL-Konfiguration
sudo nano /etc/postgresql/*/main/postgresql.conf

# Empfohlene Einstellungen für kleine bis mittlere Installationen:
# shared_buffers = 256MB
# effective_cache_size = 1GB
# work_mem = 4MB
```

## 📞 Support

### Debugging aktivieren

```bash
# Debug-Modus in .env
echo "N8N_LOG_LEVEL=debug" | sudo tee -a /home/n8n/n8n/.env
sudo systemctl restart n8n
```

### Community-Ressourcen

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
- [n8n GitHub Repository](https://github.com/n8n-io/n8n)

## ⚖️ Lizenz

Diese Skripte sind unter der MIT-Lizenz lizenziert. Siehe LICENSE-Datei für Details.

## 🤝 Beitrag leisten

Beiträge sind willkommen! Bitte öffnen Sie ein Issue oder erstellen Sie einen Pull Request.

---

**Hinweis**: Diese Skripte sind für Produktionsumgebungen geeignet, aber stellen Sie sicher, dass Sie sie zuerst in einer Testumgebung testen.