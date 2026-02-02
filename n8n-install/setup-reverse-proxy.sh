#!/bin/bash

# n8n Reverse Proxy Setup für zusätzliche Domains
# Ermöglicht mehrere Domains für n8n mit separaten vhosts

set -e

# Farben
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Root-Rechte prüfen
if [[ $EUID -ne 0 ]]; then
   error "Dieses Script muss als root ausgeführt werden"
fi

# Parameter prüfen
if [[ $# -lt 2 ]]; then
    echo "Verwendung: $0 <neue-domain> <email> [port] [ssl]"
    echo ""
    echo "Parameter:"
    echo "  neue-domain  - Domain für den neuen vhost (z.B. n8n-staging.example.com)"
    echo "  email        - E-Mail für SSL-Zertifikat"
    echo "  port         - Optionaler Port (Standard: 5678)"
    echo "  ssl          - SSL aktivieren (true/false, Standard: true)"
    echo ""
    echo "Beispiele:"
    echo "  $0 n8n-staging.example.com admin@example.com"
    echo "  $0 n8n-dev.example.com admin@example.com 5679 false"
    exit 1
fi

NEW_DOMAIN="$1"
EMAIL="$2"
N8N_PORT="${3:-5678}"
ENABLE_SSL="${4:-true}"

log "Konfiguriere Reverse Proxy für Domain: $NEW_DOMAIN"
log "Port: $N8N_PORT"
log "SSL: $ENABLE_SSL"

# Prüfe ob Domain bereits existiert
if [[ -f "/etc/nginx/sites-available/$NEW_DOMAIN" ]]; then
    warning "Konfiguration für $NEW_DOMAIN existiert bereits!"
    read -p "Überschreiben? (ja/nein): " response
    if [[ "$response" != "ja" ]]; then
        echo "Abgebrochen."
        exit 0
    fi
fi

# Erstelle Nginx vhost Konfiguration
log "Erstelle Nginx vhost für $NEW_DOMAIN..."

if [[ "$ENABLE_SSL" == "true" ]]; then
    # Konfiguration mit SSL
    cat > "/etc/nginx/sites-available/$NEW_DOMAIN" << EOF
server {
    listen 80;
    server_name $NEW_DOMAIN;

    # Redirect to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $NEW_DOMAIN;

    # SSL Konfiguration (wird durch certbot ergänzt)
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers on;

    # Sicherheits-Header
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Client max body size für file uploads
    client_max_body_size 50M;

    # Custom headers für n8n multi-domain
    add_header X-n8n-Domain "$NEW_DOMAIN" always;

    location / {
        proxy_pass http://localhost:$N8N_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
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
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }

    # Webhook endpoint optimization
    location /webhook {
        proxy_pass http://localhost:$N8N_PORT;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
        
        # Webhook spezifische Timeouts
        proxy_connect_timeout 10s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }

    # API endpoint optimization
    location /api {
        proxy_pass http://localhost:$N8N_PORT;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:$N8N_PORT;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        access_log off;
    }

    # Static files caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://localhost:$N8N_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Cache static files
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
    }

    # Security: Block access to sensitive files
    location ~ /\\.ht {
        deny all;
    }

    location ~ /\\.(env|git) {
        deny all;
    }
}
EOF
else
    # Konfiguration ohne SSL
    cat > "/etc/nginx/sites-available/$NEW_DOMAIN" << EOF
server {
    listen 80;
    server_name $NEW_DOMAIN;

    # Sicherheits-Header (auch ohne SSL)
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Client max body size für file uploads
    client_max_body_size 50M;

    # Custom headers für n8n multi-domain
    add_header X-n8n-Domain "$NEW_DOMAIN" always;

    location / {
        proxy_pass http://localhost:$N8N_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
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

    # Webhook endpoint
    location /webhook {
        proxy_pass http://localhost:$N8N_PORT;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
    }

    # Security: Block access to sensitive files
    location ~ /\\.ht {
        deny all;
    }

    location ~ /\\.(env|git) {
        deny all;
    }
}
EOF
fi

# Site aktivieren
log "Aktiviere nginx Site..."
ln -sf "/etc/nginx/sites-available/$NEW_DOMAIN" "/etc/nginx/sites-enabled/"

# Nginx Konfiguration testen
log "Teste nginx Konfiguration..."
nginx -t || error "Nginx Konfiguration fehlerhaft"

# Nginx neuladen
log "Lade nginx Konfiguration neu..."
systemctl reload nginx

# SSL-Zertifikat erstellen (falls aktiviert)
if [[ "$ENABLE_SSL" == "true" ]]; then
    log "Erstelle SSL-Zertifikat für $NEW_DOMAIN..."
    if certbot --nginx -d "$NEW_DOMAIN" --non-interactive --agree-tos --email "$EMAIL"; then
        log "SSL-Zertifikat erfolgreich erstellt!"
    else
        warning "SSL-Zertifikat konnte nicht erstellt werden. Prüfen Sie DNS-Einstellungen."
    fi
fi

# Konfigurationsdatei für diese Domain erstellen
cat > "/etc/nginx/conf.d/${NEW_DOMAIN}-info.conf" << EOF
# n8n Reverse Proxy Information für $NEW_DOMAIN
# Erstellt am: $(date)
# Domain: $NEW_DOMAIN
# Port: $N8N_PORT
# SSL: $ENABLE_SSL
# Email: $EMAIL
EOF

# Informationen ausgeben
log "Reverse Proxy Setup abgeschlossen!"
echo ""
echo -e "${GREEN}===============================================${NC}"
echo -e "${GREEN}Reverse Proxy für $NEW_DOMAIN konfiguriert!${NC}"
echo -e "${GREEN}===============================================${NC}"
echo ""
echo -e "${YELLOW}Domain-Details:${NC}"
if [[ "$ENABLE_SSL" == "true" ]]; then
    echo -e "  URL: ${GREEN}https://$NEW_DOMAIN${NC}"
else
    echo -e "  URL: ${GREEN}http://$NEW_DOMAIN${NC}"
fi
echo -e "  Backend-Port: ${GREEN}$N8N_PORT${NC}"
echo -e "  SSL: ${GREEN}$ENABLE_SSL${NC}"
echo ""
echo -e "${YELLOW}Konfigurationsdateien:${NC}"
echo -e "  Nginx vhost: ${GREEN}/etc/nginx/sites-available/$NEW_DOMAIN${NC}"
echo -e "  Info: ${GREEN}/etc/nginx/conf.d/${NEW_DOMAIN}-info.conf${NC}"
echo ""
echo -e "${YELLOW}Verwaltung:${NC}"
echo -e "  Site deaktivieren: ${GREEN}rm /etc/nginx/sites-enabled/$NEW_DOMAIN${NC}"
echo -e "  Konfiguration testen: ${GREEN}nginx -t${NC}"
echo -e "  Nginx neuladen: ${GREEN}systemctl reload nginx${NC}"
echo ""
echo -e "${YELLOW}SSL-Zertifikat erneuern:${NC}"
echo -e "  ${GREEN}certbot renew${NC}"
echo ""
if [[ "$ENABLE_SSL" == "true" ]]; then
    echo -e "${YELLOW}Wichtiger Hinweis:${NC}"
    echo -e "  Stellen Sie sicher, dass der DNS-Eintrag für $NEW_DOMAIN"
    echo -e "  auf die IP-Adresse dieses Servers zeigt!"
fi