#!/usr/bin/env bash
# ==============================================================================
# Amnezia Web Panel - One-Click Free Let's Encrypt SSL Setup for DuckDNS / Custom Domain
# Works on Port 5000 without conflicting with Xray on Port 443
# ==============================================================================

set -e

DOMAIN="${1:-awgpannel.duckdns.org}"
PANEL_PORT="5000"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "===================================================================="
echo "   🔒 Amnezia Web Panel - Free Let's Encrypt SSL Setup Tool         "
echo "===================================================================="
echo -e "${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] Please run this script with sudo or as root:${NC}"
    echo "sudo bash $0 $DOMAIN"
    exit 1
fi

echo -e "${YELLOW}---> Target Domain:${NC} ${BOLD}${DOMAIN}${NC}"
echo -e "${YELLOW}---> Target Port  :${NC} ${BOLD}${PANEL_PORT}${NC}\n"

# 1. Install Certbot
echo -e "${YELLOW}[1/5] Installing Certbot...${NC}"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq certbot jq >/dev/null

# 2. Issue Certificate via Standalone HTTP (Port 80)
echo -e "${YELLOW}[2/5] Requesting Free SSL Certificate from Let's Encrypt...${NC}"
# Stop any temporary webserver on 80 if running, but keep Xray on 443 safe
certbot certonly --standalone \
    -d "$DOMAIN" \
    --agree-tos \
    --register-unsafely-without-email \
    --non-interactive \
    --preferred-challenges http

CERT_FILE="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
KEY_FILE="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"

if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
    echo -e "${RED}[ERROR] SSL certificate generation failed.${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Certificate issued successfully!${NC}"

# 3. Set Read Permissions for Panel Service
echo -e "${YELLOW}[3/5] Setting certificate permissions for panel service...${NC}"
chmod -R 755 /etc/letsencrypt/archive /etc/letsencrypt/live
echo -e "${GREEN}  ✓ Permissions configured${NC}"

# 4. Update data.json automatically
echo -e "${YELLOW}[4/5] Enabling SSL in Panel configuration (data.json)...${NC}"
# Find data.json in current directory or user home
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_JSON="${APP_DIR}/data.json"

if [ ! -f "$DATA_JSON" ]; then
    DATA_JSON=$(find /home /root -maxdepth 3 -name "data.json" | grep "Amnezia-Web-Panel" | head -n 1)
fi

if [ -f "$DATA_JSON" ]; then
    # Update data.json using python helper to preserve all existing data safely
    python3 - << PYEOF
import json

data_path = "${DATA_JSON}"
with open(data_path, 'r', encoding='utf-8') as f:
    d = json.load(f)

settings = d.setdefault('settings', {})
ssl_conf = settings.setdefault('ssl', {})

ssl_conf['enabled'] = True
ssl_conf['panel_port'] = int("${PANEL_PORT}")
ssl_conf['domain'] = "${DOMAIN}"
ssl_conf['cert_path'] = "${CERT_FILE}"
ssl_conf['key_path'] = "${KEY_FILE}"
ssl_conf['cert_text'] = ""
ssl_conf['key_text'] = ""

with open(data_path, 'w', encoding='utf-8') as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
print("Updated SSL settings in " + data_path)
PYEOF
    echo -e "${GREEN}  ✓ SSL configuration activated in data.json${NC}"
else
    echo -e "${YELLOW}  ! data.json not found automatically. You can set the paths in Panel Settings UI.${NC}"
fi

# 5. Set up auto-renewal hook for Certbot
RENEW_HOOK="/etc/letsencrypt/renewal-hooks/deploy/amnezia-reload.sh"
mkdir -p /etc/letsencrypt/renewal-hooks/deploy
cat << 'EOF' > "$RENEW_HOOK"
#!/bin/bash
chmod -R 755 /etc/letsencrypt/archive /etc/letsencrypt/live
systemctl restart amnezia-panel 2>/dev/null || true
EOF
chmod +x "$RENEW_HOOK"

# 6. Restart Amnezia Panel Service
echo -e "${YELLOW}[5/5] Restarting Amnezia Web Panel service...${NC}"
systemctl restart amnezia-panel
echo -e "${GREEN}  ✓ Panel service restarted with SSL active${NC}"

# Success message
echo -e "\n${CYAN}${BOLD}====================================================================${NC}"
echo -e "${GREEN}${BOLD}     🎉 HTTPS SSL CERTIFICATE INSTALLED SUCCESSFULLY! 🎉           ${NC}"
echo -e "${CYAN}${BOLD}====================================================================${NC}"
echo -e "  Domain           : ${GREEN}${DOMAIN}${NC}"
echo -e "  SSL Certificate  : ${GREEN}${CERT_FILE}${NC}"
echo -e "  Private Key      : ${GREEN}${KEY_FILE}${NC}"
echo -e "  Auto-Renewal     : ${GREEN}Enabled via Certbot (90 days auto-renew)${NC}"
echo -e "${CYAN}====================================================================${NC}\n"

echo -e "👉 ${BOLD}You can now securely access your panel with green padlock at:${NC}"
echo -e "   ${GREEN}${BOLD}https://${DOMAIN}:${PANEL_PORT}${NC}\n"
