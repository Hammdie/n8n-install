#!/bin/bash

# n8n Installation Script für Ubuntu Server
# Autor: Automatisch generiert
# Datum: $(date)

set -e  # Exit bei Fehlern

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging-Funktion
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Prüfe Root-Rechte
if [[ $EUID -ne 0 ]]; then
   error "Dieses Script muss als root ausgeführt werden"
fi

# Variablen (anpassbar)
N8N_USER="n8n"
N8N_HOME="/home/$N8N_USER"
N8N_DIR="$N8N_HOME/n8n"
POSTGRES_DB="n8n_db"
POSTGRES_USER="n8n_user"
POSTGRES_PASSWORD=$(openssl rand -base64 32)
DOMAIN_NAME="${1:-localhost}"  # Parameter oder localhost
EMAIL="${2:-admin@example.com}"  # Parameter oder default

log "Starte n8n Installation auf Ubuntu Server..."
log "Domain: $DOMAIN_NAME"
log "Email: $EMAIL"

# System Update
log "Aktualisiere System..."
apt update && apt upgrade -y

# Installiere grundlegende Pakete
log "Installiere grundlegende Pakete..."
apt install -y \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    nginx \
    certbot \
    python3-certbot-nginx

# Node.js 18.x installieren
log "Installiere Node.js 18.x..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# PostgreSQL installieren
log "Installiere PostgreSQL..."
apt install -y postgresql postgresql-contrib

# PostgreSQL konfigurieren
log "Konfiguriere PostgreSQL..."
systemctl start postgresql
systemctl enable postgresql

# Datenbank und Benutzer erstellen
sudo -u postgres psql << EOF
CREATE DATABASE $POSTGRES_DB;
CREATE USER $POSTGRES_USER WITH ENCRYPTED PASSWORD '$POSTGRES_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
ALTER USER $POSTGRES_USER CREATEDB;
\q
EOF

# n8n Benutzer erstellen
log "Erstelle n8n Benutzer..."
if ! id "$N8N_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$N8N_USER"
    usermod -aG sudo "$N8N_USER"
fi

# n8n global installieren
log "Installiere n8n..."
npm install -g n8n

# Erstelle n8n Verzeichnisse
log "Erstelle n8n Verzeichnisse..."
mkdir -p "$N8N_DIR"
chown -R "$N8N_USER:$N8N_USER" "$N8N_HOME"

# n8n Konfigurationsdatei erstellen
log "Erstelle n8n Konfiguration..."
cat > "$N8N_DIR/.env" << EOF
# n8n Konfiguration
N8N_BASIC_AUTH_ACTIVE=false
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_EDITOR_BASE_URL=https://$DOMAIN_NAME/

# Webhook-Konfiguration
WEBHOOK_URL=https://$DOMAIN_NAME/

# Datenbank-Konfiguration (PostgreSQL)
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=localhost
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=$POSTGRES_DB
DB_POSTGRESDB_USER=$POSTGRES_USER
DB_POSTGRESDB_PASSWORD=$POSTGRES_PASSWORD

# Sicherheit
N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)

# Logging
N8N_LOG_LEVEL=info
N8N_LOG_OUTPUT=file
N8N_LOG_FILE_LOCATION=$N8N_DIR/logs/

# Limits
N8N_PAYLOAD_SIZE_MAX=16777216
N8N_METRICS=true

# Benutzer-Authentifizierung (optional)
# N8N_USER_MANAGEMENT_DISABLED=false
# N8N_USER_MANAGEMENT_JWT_SECRET=$(openssl rand -base64 32)

# E-Mail Konfiguration (für Benutzer-Management)
# N8N_EMAIL_MODE=smtp
# N8N_SMTP_HOST=your-smtp-host
# N8N_SMTP_PORT=587
# N8N_SMTP_USER=your-email@domain.com
# N8N_SMTP_PASS=your-password
# N8N_SMTP_SENDER=your-email@domain.com
EOF

# Logs-Verzeichnis erstellen
mkdir -p "$N8N_DIR/logs"
chown -R "$N8N_USER:$N8N_USER" "$N8N_DIR"

# Systemd Service für n8n erstellen
log "Erstelle systemd Service..."
cat > /etc/systemd/system/n8n.service << EOF
[Unit]
Description=n8n workflow automation tool
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=$N8N_USER
Group=$N8N_USER
ExecStart=/usr/bin/n8n start
Restart=on-failure
RestartSec=5
Environment=NODE_ENV=production
EnvironmentFile=$N8N_DIR/.env
WorkingDirectory=$N8N_DIR

# Sicherheitseinstellungen
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$N8N_DIR
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# Nginx Konfiguration
log "Konfiguriere nginx..."
cat > /etc/nginx/sites-available/n8n << EOF
server {
    listen 80;
    server_name $DOMAIN_NAME;

    # Redirect to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN_NAME;

    # SSL Konfiguration (wird durch certbot ergänzt)
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers on;

    # Sicherheits-Header
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

    # Client max body size für file uploads
    client_max_body_size 50M;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # WebSocket Support
        proxy_set_header Sec-WebSocket-Extensions \$http_sec_websocket_extensions;
        proxy_set_header Sec-WebSocket-Key \$http_sec_websocket_key;
        proxy_set_header Sec-WebSocket-Protocol \$http_sec_websocket_protocol;
        proxy_set_header Sec-WebSocket-Version \$http_sec_websocket_version;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Webhook endpoint optimization
    location /webhook {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Nginx Site aktivieren
ln -sf /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Nginx Konfiguration testen
nginx -t || error "Nginx Konfiguration fehlerhaft"

# Services starten und aktivieren
log "Starte Services..."
systemctl daemon-reload
systemctl enable n8n
systemctl restart nginx

# SSL-Zertifikat mit Certbot (nur wenn nicht localhost)
if [[ "$DOMAIN_NAME" != "localhost" ]]; then
    log "Erstelle SSL-Zertifikat für $DOMAIN_NAME..."
    certbot --nginx -d "$DOMAIN_NAME" --non-interactive --agree-tos --email "$EMAIL" || warning "SSL-Zertifikat konnte nicht erstellt werden"
fi

# n8n starten
log "Starte n8n..."
systemctl start n8n

# Firewall konfigurieren (UFW)
log "Konfiguriere Firewall..."
if command -v ufw &> /dev/null; then
    ufw --force enable
    ufw allow ssh
    ufw allow 'Nginx Full'
    ufw status
fi

# Informationen ausgeben
log "Installation abgeschlossen!"
echo ""
echo -e "${GREEN}===============================================${NC}"
echo -e "${GREEN}n8n Installation erfolgreich abgeschlossen!${NC}"
echo -e "${GREEN}===============================================${NC}"
echo ""
echo -e "${YELLOW}Zugriff:${NC}"
if [[ "$DOMAIN_NAME" != "localhost" ]]; then
    echo -e "  URL: ${GREEN}https://$DOMAIN_NAME${NC}"
else
    echo -e "  URL: ${GREEN}http://localhost:5678${NC}"
fi
echo ""
echo -e "${YELLOW}Datenbank-Details:${NC}"
echo -e "  Host: localhost"
echo -e "  Database: $POSTGRES_DB"
echo -e "  User: $POSTGRES_USER"
echo -e "  Password: $POSTGRES_PASSWORD"
echo ""
echo -e "${YELLOW}Wichtige Befehle:${NC}"
echo -e "  Status prüfen:    ${GREEN}systemctl status n8n${NC}"
echo -e "  Logs anzeigen:    ${GREEN}journalctl -u n8n -f${NC}"
echo -e "  n8n stoppen:      ${GREEN}systemctl stop n8n${NC}"
echo -e "  n8n starten:      ${GREEN}systemctl start n8n${NC}"
echo -e "  n8n neustarten:   ${GREEN}systemctl restart n8n${NC}"
echo ""
echo -e "${YELLOW}Konfigurationsdatei:${NC} $N8N_DIR/.env"
echo ""
echo -e "${YELLOW}Hinweis:${NC} Beim ersten Zugriff müssen Sie einen Admin-Benutzer erstellen."

# Passwort in separater Datei speichern
echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" > /root/n8n-db-credentials.txt
chmod 600 /root/n8n-db-credentials.txt
echo -e "${YELLOW}Datenbank-Passwort wurde in /root/n8n-db-credentials.txt gespeichert${NC}"