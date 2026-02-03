#!/bin/bash

# n8n Installation Script for Ubuntu Server
# Author: Automatically generated
# Date: $(date)

set -e  # Exit on errors

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
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

# Check root privileges
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root"
fi

# Ask for installation method
echo ""
echo -e "${BLUE}═══ Choose n8n Installation Method ═══${NC}"
echo ""
echo "1. Native Installation (Node.js + PostgreSQL)"
echo "2. Docker Compose Installation (Container)"
echo ""

while true; do
    read -p "Choose installation method (1 or 2): " INSTALL_METHOD
    case $INSTALL_METHOD in
        1)
            INSTALL_TYPE="native"
            log "Native installation selected"
            break
            ;;
        2)
            INSTALL_TYPE="docker"
            log "Docker Compose installation selected"
            break
            ;;
        *)
            error "Invalid selection. Please choose 1 or 2."
            ;;
    esac
done

echo ""

# Variables (customizable)
N8N_USER="n8n"
N8N_HOME="/home/$N8N_USER"
N8N_DIR="$N8N_HOME/n8n"
POSTGRES_DB="n8n_db"
POSTGRES_USER="n8n_user"
POSTGRES_PASSWORD=$(openssl rand -base64 32)
DOMAIN_NAME="${1:-localhost}"  # Parameter or localhost
EMAIL="${2:-admin@example.com}"  # Parameter or default

log "Starting n8n installation on Ubuntu Server..."
log "Domain: $DOMAIN_NAME"
log "Email: $EMAIL"
log "Installation type: $INSTALL_TYPE"

if [[ "$INSTALL_TYPE" == "docker" ]]; then
    # Docker Compose Installation
    install_docker_compose
else
    # Native Installation
    install_native
fi

# Common post-installation configuration
post_install_config

# Docker Compose Installation Function
install_docker_compose() {
    log "Starting Docker Compose installation..."

    # System Update
    log "Updating system..."
    apt update && apt upgrade -y

    # Install Docker and Docker Compose
    log "Installing Docker and Docker Compose..."
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

    # Add Docker GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Start Docker service
    systemctl start docker
    systemctl enable docker

    # Manage n8n Encryption Key
    N8N_KEY_DIR="/var/n8n"
    N8N_KEY_FILE="$N8N_KEY_DIR/encryption.key"

    log "Configuring n8n encryption key..."
    mkdir -p "$N8N_KEY_DIR"
    chmod 700 "$N8N_KEY_DIR"

    if [[ -f "$N8N_KEY_FILE" ]]; then
        log "Existing encryption key found - will be reused"
        N8N_ENCRYPTION_KEY=$(cat "$N8N_KEY_FILE")
    else
        log "Generating new encryption key..."
        N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)
        echo "$N8N_ENCRYPTION_KEY" > "$N8N_KEY_FILE"
        chmod 600 "$N8N_KEY_FILE"
        log "Encryption key saved in $N8N_KEY_FILE"
    fi

    # Generate PostgreSQL password
    POSTGRES_PASSWORD=$(openssl rand -base64 32)

    # Create n8n working directory
    N8N_DOCKER_DIR="/opt/n8n"
    mkdir -p "$N8N_DOCKER_DIR"
    chmod 755 "$N8N_DOCKER_DIR"

    # Create Docker Compose configuration
    log "Creating Docker Compose configuration..."
    create_docker_compose

    # nginx configuration for Docker
    configure_nginx_docker

    # Start Docker services
    log "Starting Docker services..."
    cd "$N8N_DOCKER_DIR"
    docker compose up -d

    # Wait until services are ready
    log "Waiting for services..."
    sleep 30

    # Check services
    if docker compose ps | grep -q "Up"; then
        log "Docker services started successfully!"
    else
        error "Error starting Docker services"
    fi
}

# Native Installation Function
install_native() {

    log "Starting native n8n installation..."

    # Manage n8n Encryption Key
    N8N_KEY_DIR="/var/n8n"
    N8N_KEY_FILE="$N8N_KEY_DIR/encryption.key"

    log "Configuring n8n encryption key..."
    mkdir -p "$N8N_KEY_DIR"
    chmod 700 "$N8N_KEY_DIR"

    if [[ -f "$N8N_KEY_FILE" ]]; then
        log "Existing encryption key found - will be reused"
        N8N_ENCRYPTION_KEY=$(cat "$N8N_KEY_FILE")
    else
        log "Generating new encryption key..."
        N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)
        echo "$N8N_ENCRYPTION_KEY" > "$N8N_KEY_FILE"
        chmod 600 "$N8N_KEY_FILE"
        log "Encryption key saved in $N8N_KEY_FILE"
    fi

# System update
log "Updating system..."
apt update && apt upgrade -y

# Install basic packages
log "Installing basic packages..."
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

# Install Node.js 18.x
log "Installing Node.js 18.x..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Install PostgreSQL
log "Installing PostgreSQL..."
apt install -y postgresql postgresql-contrib

# Configure PostgreSQL
log "Configuring PostgreSQL..."
systemctl start postgresql
systemctl enable postgresql

# Create database and user
sudo -u postgres psql << EOF
CREATE DATABASE $POSTGRES_DB;
CREATE USER $POSTGRES_USER WITH ENCRYPTED PASSWORD '$POSTGRES_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
ALTER USER $POSTGRES_USER CREATEDB;
\q
EOF

# Create n8n user
log "Creating n8n user..."
if ! id "$N8N_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$N8N_USER"
    usermod -aG sudo "$N8N_USER"
fi

# Install n8n globally
log "Installing n8n..."
npm install -g n8n

# Create n8n directories
log "Creating n8n directories..."
mkdir -p "$N8N_DIR"
chown -R "$N8N_USER:$N8N_USER" "$N8N_HOME"

# Create n8n configuration file
log "Creating n8n configuration..."
cat > "$N8N_DIR/.env" << EOF
# n8n Configuration
N8N_BASIC_AUTH_ACTIVE=false
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_EDITOR_BASE_URL=https://$DOMAIN_NAME/

# Webhook configuration
WEBHOOK_URL=https://$DOMAIN_NAME/

# Database configuration (PostgreSQL)
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=localhost
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=$POSTGRES_DB
DB_POSTGRESDB_USER=$POSTGRES_USER
DB_POSTGRESDB_PASSWORD=$POSTGRES_PASSWORD

# Security
N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY

# Logging
N8N_LOG_LEVEL=info
N8N_LOG_OUTPUT=file
N8N_LOG_FILE_LOCATION=$N8N_DIR/logs/

# Limits
N8N_PAYLOAD_SIZE_MAX=16777216
N8N_METRICS=true

# User authentication (optional)
# N8N_USER_MANAGEMENT_DISABLED=false
# N8N_USER_MANAGEMENT_JWT_SECRET=$(openssl rand -base64 32)

# Email configuration (for user management)
# N8N_EMAIL_MODE=smtp
# N8N_SMTP_HOST=your-smtp-host
# N8N_SMTP_PORT=587
# N8N_SMTP_USER=your-email@domain.com
# N8N_SMTP_PASS=your-password
# N8N_SMTP_SENDER=your-email@domain.com
EOF

# Create logs directory
mkdir -p "$N8N_DIR/logs"
chown -R "$N8N_USER:$N8N_USER" "$N8N_DIR"

# Create systemd service for n8n
log "Creating systemd service..."
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

# Security settings
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$N8N_DIR
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# Nginx configuration
log "Configuring nginx..."
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

# Activate nginx site
ln -sf /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
nginx -t || error "Nginx configuration invalid"

# Start and enable services
log "Starting services..."
systemctl daemon-reload
systemctl enable n8n
systemctl restart nginx

# SSL certificate with Certbot (only if not localhost)
if [[ "$DOMAIN_NAME" != "localhost" ]]; then
    log "Creating SSL certificate for $DOMAIN_NAME..."
    certbot --nginx -d "$DOMAIN_NAME" --non-interactive --agree-tos --email "$EMAIL" || warning "SSL certificate could not be created"
fi

# Start n8n
log "Starting n8n..."
systemctl start n8n
}

# Post-installation configuration
post_install_config() {
    # Configure firewall (UFW)
    log "Configuring firewall..."
    if command -v ufw &> /dev/null; then
        ufw --force enable
        ufw allow ssh
        ufw allow 'Nginx Full'
        ufw status
    fi

    # SSL certificate with Certbot (only if not localhost and Docker)
    if [[ "$DOMAIN_NAME" != "localhost" && "$INSTALL_TYPE" == "docker" ]]; then
        log "Creating SSL certificate for $DOMAIN_NAME..."
        certbot --nginx -d "$DOMAIN_NAME" --non-interactive --agree-tos --email "$EMAIL" || warning "SSL certificate could not be created"
    fi

    # Output information
    log "Installation completed!"
    echo ""
    echo -e "${GREEN}===============================================${NC}"
    echo -e "${GREEN}n8n Installation completed successfully!${NC}"
    echo -e "${GREEN}===============================================${NC}"
    echo ""
    echo -e "${YELLOW}Installation type:${NC} $INSTALL_TYPE"
    echo -e "${YELLOW}Access:${NC}"
    if [[ "$DOMAIN_NAME" != "localhost" ]]; then
        echo -e "  URL: ${GREEN}https://$DOMAIN_NAME${NC}"
    else
        echo -e "  URL: ${GREEN}http://localhost:5678${NC}"
    fi
    echo ""
    
    if [[ "$INSTALL_TYPE" == "docker" ]]; then
        echo -e "${YELLOW}Docker commands:${NC}"
        echo -e "  Check status:     ${GREEN}cd /opt/n8n && docker compose ps${NC}"
        echo -e "  Show logs:        ${GREEN}cd /opt/n8n && docker compose logs -f${NC}"
        echo -e "  Stop:             ${GREEN}cd /opt/n8n && docker compose down${NC}"
        echo -e "  Start:            ${GREEN}cd /opt/n8n && docker compose up -d${NC}"
        echo -e "  Restart:          ${GREEN}cd /opt/n8n && docker compose restart${NC}"
    else
        echo -e "${YELLOW}Database details:${NC}"
        echo -e "  Host: localhost"
        echo -e "  Database: $POSTGRES_DB"
        echo -e "  User: $POSTGRES_USER"
        echo -e "  Password: $POSTGRES_PASSWORD"
        echo ""
        echo -e "${YELLOW}Important commands:${NC}"
        echo -e "  Check status:     ${GREEN}systemctl status n8n${NC}"
        echo -e "  Show logs:        ${GREEN}journalctl -u n8n -f${NC}"
        echo -e "  Stop n8n:         ${GREEN}systemctl stop n8n${NC}"
        echo -e "  Start n8n:        ${GREEN}systemctl start n8n${NC}"
        echo -e "  Restart n8n:      ${GREEN}systemctl restart n8n${NC}"
        echo ""
        echo -e "${YELLOW}Configuration file:${NC} $N8N_DIR/.env"
    fi
    echo ""
    echo -e "${YELLOW}Note:${NC} On first access you need to create an admin user."

    # Save password in separate file
    if [[ "$INSTALL_TYPE" == "docker" ]]; then
        echo "INSTALL_TYPE=docker" > /root/n8n-db-credentials.txt
        echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> /root/n8n-db-credentials.txt
        echo "N8N_ENCRYPTION_KEY_FILE=$N8N_KEY_FILE" >> /root/n8n-db-credentials.txt
        echo "DOCKER_DIR=/opt/n8n" >> /root/n8n-db-credentials.txt
    else
        echo "INSTALL_TYPE=native" > /root/n8n-db-credentials.txt
        echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> /root/n8n-db-credentials.txt
        echo "N8N_ENCRYPTION_KEY_FILE=$N8N_KEY_FILE" >> /root/n8n-db-credentials.txt
    fi
    chmod 600 /root/n8n-db-credentials.txt
    echo -e "${YELLOW}Installation details saved in /root/n8n-db-credentials.txt${NC}"
    echo -e "${YELLOW}Encryption key permanently saved in $N8N_KEY_FILE${NC}"
}

# Create Docker Compose configuration
create_docker_compose() {
    cat > "$N8N_DOCKER_DIR/docker-compose.yml" << EOF
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=false
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - N8N_EDITOR_BASE_URL=https://$DOMAIN_NAME/
      - WEBHOOK_URL=https://$DOMAIN_NAME/
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n_db
      - DB_POSTGRESDB_USER=n8n_user
      - DB_POSTGRESDB_PASSWORD=$POSTGRES_PASSWORD
      - N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY
      - N8N_LOG_LEVEL=info
      - N8N_LOG_OUTPUT=console
      - N8N_PAYLOAD_SIZE_MAX=16777216
      - N8N_METRICS=true
      - NODE_ENV=production
    volumes:
      - n8n_data:/home/node/.n8n
      - /var/n8n/encryption.key:/home/node/.n8n/encryption.key:ro
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - n8n-network

  postgres:
    image: postgres:15
    container_name: n8n_postgres
    restart: unless-stopped
    environment:
      - POSTGRES_DB=n8n_db
      - POSTGRES_USER=n8n_user
      - POSTGRES_PASSWORD=$POSTGRES_PASSWORD
      - POSTGRES_NON_ROOT_USER=n8n_user
      - POSTGRES_NON_ROOT_PASSWORD=$POSTGRES_PASSWORD
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U n8n_user -d n8n_db"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - n8n-network

volumes:
  n8n_data:
  postgres_data:

networks:
  n8n-network:
    driver: bridge
EOF

    # .env Datei für Docker Compose
    cat > "$N8N_DOCKER_DIR/.env" << EOF
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY
DOMAIN_NAME=$DOMAIN_NAME
EOF
    chmod 600 "$N8N_DOCKER_DIR/.env"
}

# nginx configuration for Docker
configure_nginx_docker() {
    log "Configuring nginx for Docker..."
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

    # Activate nginx site
    ln -sf /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default

    # Test nginx configuration
    nginx -t || error "Nginx configuration invalid"

    # reload nginx
    systemctl restart nginx
}