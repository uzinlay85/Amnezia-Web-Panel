#!/usr/bin/env bash
# ==============================================================================
# Amnezia Web Panel - One-Click Free Let's Encrypt SSL Setup for Any Domain
# Works dynamically with DuckDNS, Cloudflare, or any Custom Domain on Port 5000
# Safe for Xray on Port 443 (Uses Port 80 for Standalone ACME verification)
# ==============================================================================

set -e

PANEL_PORT="5000"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "===================================================================="
echo "   🔒 Amnezia Web Panel - Universal Free SSL Setup Tool             "
echo "===================================================================="
echo -e "${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] Please run this script with sudo or as root:${NC}"
    echo "sudo bash $0 [domain_name]"
    exit 1
fi

DOMAIN="$1"

# Locate data.json if available
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)"
DATA_JSON="${APP_DIR}/data.json"
if [ ! -f "$DATA_JSON" ]; then
    DATA_JSON=$(find /home /root -maxdepth 3 -name "data.json" 2>/dev/null | grep "Amnezia-Web-Panel" | head -n 1)
fi

# If domain is not provided as an argument, ask interactively
if [ -z "$DOMAIN" ]; then
    SAVED_DOMAIN=""
    if [ -f "$DATA_JSON" ] && command -v jq &>/dev/null; then
        SAVED_DOMAIN=$(jq -r '.settings.ssl.domain // empty' "$DATA_JSON" 2>/dev/null || true)
        if [ -z "$SAVED_DOMAIN" ]; then
            HOST_VAL=$(jq -r '.servers[0].host // empty' "$DATA_JSON" 2>/dev/null || true)
            # Only use if it's not a raw IPv4 address
            if [[ ! "$HOST_VAL" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                SAVED_DOMAIN="$HOST_VAL"
            fi
        fi
    fi

    if [ -t 0 ]; then
        echo -e "${YELLOW}Please enter your Domain Name (DuckDNS, Cloudflare, or Custom Domain):${NC}"
        if [ -n "$SAVED_DOMAIN" ]; then
            read -p "Domain [$SAVED_DOMAIN]: " INPUT_DOMAIN
            DOMAIN="${INPUT_DOMAIN:-$SAVED_DOMAIN}"
        else
            read -p "Domain (e.g. myvpn.duckdns.org): " DOMAIN
        fi
    else
        DOMAIN="${SAVED_DOMAIN}"
    fi
fi

# Clean up domain name (remove http://, https://, trailing slashes, spaces)
DOMAIN=$(echo "$DOMAIN" | sed -e 's|^https\?://||' -e 's|/.*$||' | tr -d '[:space:]')

if [ -z "$DOMAIN" ]; then
    echo -e "${RED}[ERROR] Domain name is required.${NC}"
    echo "Usage: sudo bash $0 <YOUR_DOMAIN>"
    echo "Example: sudo bash $0 myvpn.duckdns.org"
    exit 1
fi

echo -e "\n${YELLOW}---> Target Domain :${NC} ${BOLD}${DOMAIN}${NC}"
echo -e "${YELLOW}---> Panel Port    :${NC} ${BOLD}${PANEL_PORT}${NC}"

# Verify DNS resolution matches Server Public IP
echo -e "\n${YELLOW}[1/6] Verifying DNS resolution for '${DOMAIN}'...${NC}"
SERVER_IP=$(curl -4s --max-time 5 https://api.ipify.org 2>/dev/null || curl -4s --max-time 5 https://ifconfig.me 2>/dev/null || echo "")
RESOLVED_IP=$(getent ahosts "$DOMAIN" 2>/dev/null | awk '{print $1}' | head -n 1 || true)

if [ -n "$SERVER_IP" ] && [ -n "$RESOLVED_IP" ]; then
    if [ "$SERVER_IP" != "$RESOLVED_IP" ]; then
        echo -e "${RED}⚠️  DNS MISMATCH WARNING:${NC}"
        echo -e "   • Domain '${DOMAIN}' points to : ${BOLD}${RESOLVED_IP}${NC}"
        echo -e "   • This Server's Public IP is   : ${BOLD}${SERVER_IP}${NC}"
        echo -e "   Please update your DuckDNS/DNS provider to point '${DOMAIN}' to '${SERVER_IP}' first."
        if [ -t 0 ]; then
            read -p "Do you want to proceed anyway? (y/N): " PROCEED
            if [[ ! "$PROCEED" =~ ^[Yy]$ ]]; then
                echo "Aborted."
                exit 1
            fi
        fi
    else
        echo -e "${GREEN}  ✓ DNS verified: '${DOMAIN}' points correctly to this server (${SERVER_IP})${NC}"
    fi
else
    echo -e "${YELLOW}  ! Could not verify DNS automatically. Continuing...${NC}"
fi

# 2. Install Certbot
echo -e "\n${YELLOW}[2/6] Checking and Installing Certbot...${NC}"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq certbot jq >/dev/null
echo -e "${GREEN}  ✓ Certbot is ready${NC}"

# 3. Issue Certificate via Standalone HTTP (Port 80)
echo -e "\n${YELLOW}[3/6] Requesting Free SSL Certificate from Let's Encrypt...${NC}"
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

# 4. Set Read Permissions for Panel Service
echo -e "\n${YELLOW}[4/6] Setting certificate permissions for panel service...${NC}"
chmod -R 755 /etc/letsencrypt/archive /etc/letsencrypt/live
echo -e "${GREEN}  ✓ Permissions configured${NC}"

# 5. Update data.json automatically
echo -e "\n${YELLOW}[5/6] Activating SSL in Panel configuration (data.json)...${NC}"
if [ -f "$DATA_JSON" ]; then
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

# If servers list exists, also update server host to this domain so VPN configs use it
servers = d.get('servers', [])
if servers:
    servers[0]['host'] = "${DOMAIN}"

with open(data_path, 'w', encoding='utf-8') as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
print("Updated SSL and server host in " + data_path)
PYEOF
    echo -e "${GREEN}  ✓ SSL configuration activated & Server Host set to '${DOMAIN}'${NC}"
else
    echo -e "${YELLOW}  ! data.json not found automatically. You can set the paths in Panel Settings UI.${NC}"
fi

# 6. Set up auto-renewal hook for Certbot
RENEW_HOOK="/etc/letsencrypt/renewal-hooks/deploy/amnezia-reload.sh"
mkdir -p /etc/letsencrypt/renewal-hooks/deploy
cat << 'EOF' > "$RENEW_HOOK"
#!/bin/bash
chmod -R 755 /etc/letsencrypt/archive /etc/letsencrypt/live
systemctl restart amnezia-panel 2>/dev/null || true
EOF
chmod +x "$RENEW_HOOK"

# 7. Restart Amnezia Panel Service
echo -e "\n${YELLOW}[6/6] Restarting Amnezia Web Panel service...${NC}"
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
echo -e "  VPN Endpoint     : ${GREEN}Configs will now use '${DOMAIN}'${NC}"
echo -e "${CYAN}====================================================================${NC}\n"

echo -e "👉 ${BOLD}You can now securely access your panel with green padlock at:${NC}"
echo -e "   ${GREEN}${BOLD}https://${DOMAIN}:${PANEL_PORT}${NC}\n"
