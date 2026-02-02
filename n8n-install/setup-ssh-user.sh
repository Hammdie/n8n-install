#!/bin/bash

# n8n für SSH-User odoo Setup
# Konfiguriert n8n für Zugriff durch SSH-User odoo

set -e

# Farben
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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

# Root-Rechte prüfen
if [[ $EUID -ne 0 ]]; then
   error "Dieses Script muss als root ausgeführt werden"
fi

log "Konfiguriere n8n für SSH-User odoo..."

# Odoo-Benutzer erstellen falls nicht vorhanden
if ! id "odoo" &>/dev/null; then
    log "Erstelle odoo Benutzer..."
    useradd -m -s /bin/bash odoo
    usermod -aG sudo odoo
    
    # SSH-Schlüssel für odoo vorbereiten
    mkdir -p /home/odoo/.ssh
    touch /home/odoo/.ssh/authorized_keys
    chmod 700 /home/odoo/.ssh
    chmod 600 /home/odoo/.ssh/authorized_keys
    chown -R odoo:odoo /home/odoo/.ssh
    
    warning "SSH-Schlüssel für odoo-Benutzer manuell hinzufügen:"
    warning "  - Fügen Sie den öffentlichen SSH-Schlüssel in /home/odoo/.ssh/authorized_keys ein"
    warning "  - Oder setzen Sie ein Passwort: passwd odoo"
fi

# n8n Benutzer zu odoo-Gruppe hinzufügen
log "Füge n8n-Benutzer zur odoo-Gruppe hinzu..."
usermod -aG odoo n8n

# Odoo-Benutzer zu n8n-Gruppe hinzufügen  
usermod -aG n8n odoo

# Berechtigungen für n8n-Verzeichnis anpassen
log "Anpassen der Berechtigungen..."
chmod g+rx /home/n8n
chmod g+rx /home/n8n/n8n

# Sudo-Berechtigung für odoo für n8n-Befehle
log "Konfiguriere sudo-Berechtigung für odoo..."
cat > /etc/sudoers.d/odoo-n8n << 'EOF'
# Erlaubt odoo-Benutzer n8n zu verwalten
odoo ALL=(root) NOPASSWD: /bin/systemctl start n8n
odoo ALL=(root) NOPASSWD: /bin/systemctl stop n8n
odoo ALL=(root) NOPASSWD: /bin/systemctl restart n8n
odoo ALL=(root) NOPASSWD: /bin/systemctl status n8n
odoo ALL=(root) NOPASSWD: /bin/journalctl -u n8n*
odoo ALL=(root) NOPASSWD: /bin/systemctl * nginx
odoo ALL=(root) NOPASSWD: /root/n8n-install/n8n-menu.sh
odoo ALL=(root) NOPASSWD: /root/n8n-install/setup-reverse-proxy.sh
odoo ALL=(root) NOPASSWD: /root/n8n-install/backup-n8n.sh
odoo ALL=(root) NOPASSWD: /root/n8n-install/update-n8n.sh
odoo ALL=(root) NOPASSWD: /usr/bin/nginx -t
odoo ALL=(root) NOPASSWD: /usr/bin/certbot *
odoo ALL=(n8n) NOPASSWD: ALL
EOF

# n8n Status-Skript für odoo erstellen
log "Erstelle n8n-Status-Skript..."
cat > /home/odoo/n8n-status.sh << 'EOF'
#!/bin/bash

# n8n Status-Dashboard für odoo-Benutzer
# Zeigt alle wichtigen Informationen über n8n an

# Farben
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}         n8n Status Dashboard          ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Service Status
echo -e "${YELLOW}Service Status:${NC}"
if sudo systemctl is-active --quiet n8n; then
    echo -e "  n8n: ${GREEN}Läuft${NC}"
else
    echo -e "  n8n: ${RED}Gestoppt${NC}"
fi

if sudo systemctl is-enabled --quiet n8n; then
    echo -e "  Autostart: ${GREEN}Aktiviert${NC}"
else
    echo -e "  Autostart: ${RED}Deaktiviert${NC}"
fi

echo ""

# Prozess-Information
echo -e "${YELLOW}Prozess-Information:${NC}"
N8N_PID=$(pgrep -f "n8n start" || echo "")
if [[ -n "$N8N_PID" ]]; then
    echo -e "  PID: ${GREEN}$N8N_PID${NC}"
    echo -e "  Speicher: ${GREEN}$(ps -p $N8N_PID -o rss= | awk '{printf "%.1f MB\n", $1/1024}')${NC}"
    echo -e "  Laufzeit: ${GREEN}$(ps -p $N8N_PID -o etime= | xargs)${NC}"
else
    echo -e "  ${RED}Kein n8n-Prozess gefunden${NC}"
fi

echo ""

# Port und Netzwerk
echo -e "${YELLOW}Netzwerk:${NC}"
if netstat -tlnp 2>/dev/null | grep -q ":5678"; then
    echo -e "  Port 5678: ${GREEN}Offen${NC}"
else
    echo -e "  Port 5678: ${RED}Geschlossen${NC}"
fi

# Nginx Status
if sudo systemctl is-active --quiet nginx; then
    echo -e "  Nginx: ${GREEN}Läuft${NC}"
else
    echo -e "  Nginx: ${RED}Gestoppt${NC}"
fi

echo ""

# Datenbank-Verbindung
echo -e "${YELLOW}Datenbank:${NC}"
if sudo -u postgres psql -l | grep -q "n8n_db"; then
    echo -e "  PostgreSQL: ${GREEN}Verbindung OK${NC}"
    DB_SIZE=$(sudo -u postgres psql -d n8n_db -t -c "SELECT pg_size_pretty(pg_database_size('n8n_db'));" | xargs)
    echo -e "  DB-Größe: ${GREEN}$DB_SIZE${NC}"
else
    echo -e "  PostgreSQL: ${RED}Verbindung fehlgeschlagen${NC}"
fi

echo ""

# Logs (letzte 5 Zeilen)
echo -e "${YELLOW}Aktuelle Logs (letzte 5 Zeilen):${NC}"
sudo journalctl -u n8n --no-pager -n 5 | tail -5

echo ""

# Verfügbare Befehle
echo -e "${YELLOW}Verfügbare Befehle:${NC}"
echo -e "  ${GREEN}sudo systemctl start n8n${NC}     - n8n starten"
echo -e "  ${GREEN}sudo systemctl stop n8n${NC}      - n8n stoppen"
echo -e "  ${GREEN}sudo systemctl restart n8n${NC}   - n8n neustarten"
echo -e "  ${GREEN}sudo journalctl -u n8n -f${NC}    - Live-Logs anzeigen"
echo -e "  ${GREEN}./n8n-manage.sh${NC}               - Management-Menü"

echo ""
echo -e "${BLUE}========================================${NC}"
EOF

# n8n Management-Skript für odoo erstellen
log "Erstelle n8n-Management-Skript..."
cat > /home/odoo/n8n-manage.sh << 'EOF'
#!/bin/bash

# n8n Management-Skript für odoo-Benutzer
# Interaktives Menü zur n8n-Verwaltung

# Farben
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_menu() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}         n8n Management Menü           ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "1. Status anzeigen"
    echo "2. n8n starten"
    echo "3. n8n stoppen"
    echo "4. n8n neustarten"
    echo "5. Live-Logs anzeigen"
    echo "6. Konfiguration anzeigen"
    echo "7. Backup erstellen"
    echo "8. System-Information"
    echo "9. Beenden"
    echo ""
}

while true; do
    show_menu
    read -p "Wählen Sie eine Option (1-9): " choice
    
    case $choice in
        1)
            echo -e "${YELLOW}Status wird angezeigt...${NC}"
            ./n8n-status.sh
            read -p "Drücken Sie Enter um fortzufahren..."
            ;;
        2)
            echo -e "${YELLOW}Starte n8n...${NC}"
            sudo systemctl start n8n
            sleep 2
            if sudo systemctl is-active --quiet n8n; then
                echo -e "${GREEN}n8n wurde erfolgreich gestartet!${NC}"
            else
                echo -e "${RED}Fehler beim Starten von n8n!${NC}"
            fi
            read -p "Drücken Sie Enter um fortzufahren..."
            ;;
        3)
            echo -e "${YELLOW}Stoppe n8n...${NC}"
            sudo systemctl stop n8n
            sleep 2
            if ! sudo systemctl is-active --quiet n8n; then
                echo -e "${GREEN}n8n wurde erfolgreich gestoppt!${NC}"
            else
                echo -e "${RED}Fehler beim Stoppen von n8n!${NC}"
            fi
            read -p "Drücken Sie Enter um fortzufahren..."
            ;;
        4)
            echo -e "${YELLOW}Starte n8n neu...${NC}"
            sudo systemctl restart n8n
            sleep 3
            if sudo systemctl is-active --quiet n8n; then
                echo -e "${GREEN}n8n wurde erfolgreich neugestartet!${NC}"
            else
                echo -e "${RED}Fehler beim Neustart von n8n!${NC}"
            fi
            read -p "Drücken Sie Enter um fortzufahren..."
            ;;
        5)
            echo -e "${YELLOW}Live-Logs anzeigen (Ctrl+C zum Beenden)...${NC}"
            sudo journalctl -u n8n -f
            ;;
        6)
            echo -e "${YELLOW}n8n Konfiguration:${NC}"
            echo ""
            if [[ -f /home/n8n/n8n/.env ]]; then
                echo "Konfigurationsdatei: /home/n8n/n8n/.env"
                echo ""
                grep -v "PASSWORD\|SECRET\|KEY" /home/n8n/n8n/.env || echo "Keine Konfiguration gefunden"
            else
                echo -e "${RED}Konfigurationsdatei nicht gefunden!${NC}"
            fi
            read -p "Drücken Sie Enter um fortzufahren..."
            ;;
        7)
            echo -e "${YELLOW}Backup wird erstellt...${NC}"
            if sudo /root/backup-n8n.sh; then
                echo -e "${GREEN}Backup erfolgreich erstellt!${NC}"
            else
                echo -e "${RED}Fehler beim Backup!${NC}"
            fi
            read -p "Drücken Sie Enter um fortzufahren..."
            ;;
        8)
            echo -e "${YELLOW}System-Information:${NC}"
            echo ""
            echo "n8n Version: $(npm list -g n8n --depth=0 2>/dev/null | grep n8n@ | cut -d@ -f2 || echo 'Unbekannt')"
            echo "Node.js Version: $(node --version)"
            echo "System: $(uname -a)"
            echo "Verfügbarer Speicher: $(df -h / | awk 'NR==2{print $4}')"
            echo "Systemlast: $(uptime | awk -F'load average:' '{print $2}')"
            read -p "Drücken Sie Enter um fortzufahren..."
            ;;
        9)
            echo -e "${GREEN}Auf Wiedersehen!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Ungültige Auswahl. Bitte wählen Sie 1-9.${NC}"
            read -p "Drücken Sie Enter um fortzufahren..."
            ;;
    esac
done
EOF

# Skripte ausführbar machen und Besitzer setzen
chmod +x /home/odoo/n8n-status.sh
chmod +x /home/odoo/n8n-manage.sh
chown odoo:odoo /home/odoo/n8n-status.sh
chown odoo:odoo /home/odoo/n8n-manage.sh

# SSH-Konfiguration sicherer machen
log "Konfiguriere SSH-Sicherheit..."
if ! grep -q "AllowUsers odoo" /etc/ssh/sshd_config; then
    echo "" >> /etc/ssh/sshd_config
    echo "# n8n SSH-Zugang für odoo" >> /etc/ssh/sshd_config
    echo "AllowUsers odoo" >> /etc/ssh/sshd_config
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
    
    # SSH-Service neuladen
    systemctl reload ssh
fi

# .bashrc für odoo anpassen
log "Konfiguriere .bashrc für odoo..."
cat >> /home/odoo/.bashrc << 'EOF'

# n8n Management Aliase
alias n8n-status='~/n8n-status.sh'
alias n8n-manage='~/n8n-manage.sh'
alias n8n-menu='sudo /root/n8n-install/n8n-menu.sh'
alias n8n-domains='/root/n8n-install/manage-domains.sh'
alias n8n-logs='sudo journalctl -u n8n -f'
alias n8n-start='sudo systemctl start n8n'
alias n8n-stop='sudo systemctl stop n8n'
alias n8n-restart='sudo systemctl restart n8n'

# Automatisch n8n-Status beim Login anzeigen
if [[ -n "$SSH_CONNECTION" ]]; then
    echo "Willkommen zur n8n-Verwaltung!"
    echo "Verwenden Sie 'n8n-status' oder 'n8n-manage' für die Verwaltung."
    echo ""
fi
EOF

chown odoo:odoo /home/odoo/.bashrc

log "Konfiguration für SSH-User odoo abgeschlossen!"
echo ""
echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}SSH-Zugang für odoo konfiguriert!${NC}"
echo -e "${GREEN}=======================================${NC}"
echo ""
echo -e "${YELLOW}SSH-Verbindung:${NC}"
echo -e "  ${GREEN}ssh odoo@your-server-ip${NC}"
echo ""
echo -e "${YELLOW}Verfügbare Befehle nach SSH-Login:${NC}"
echo -e "  ${GREEN}n8n-status${NC}   - Status anzeigen"
echo -e "  ${GREEN}n8n-manage${NC}   - Management-Menü"
echo -e "  ${GREEN}n8n-menu${NC}     - Hauptverwaltungsmenü"
echo -e "  ${GREEN}n8n-domains${NC}  - Domain-Management"
echo -e "  ${GREEN}n8n-logs${NC}     - Live-Logs anzeigen"
echo -e "  ${GREEN}n8n-start${NC}    - n8n starten"
echo -e "  ${GREEN}n8n-stop${NC}     - n8n stoppen"
echo -e "  ${GREEN}n8n-restart${NC}  - n8n neustarten"
echo ""
echo -e "${YELLOW}Wichtige Schritte:${NC}"
echo "1. SSH-Schlüssel für odoo hinzufügen:"
echo "   Bearbeiten Sie /home/odoo/.ssh/authorized_keys"
echo "2. Oder Passwort setzen: passwd odoo"
echo "3. SSH-Service neustarten: systemctl restart ssh"
echo ""
warning "Denken Sie daran, Ihre SSH-Schlüssel zu konfigurieren!"