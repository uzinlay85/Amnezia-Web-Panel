#!/usr/bin/env bash
# ==============================================================================
# 3X-UI + Cloudflare CDN (VLESS-WebSocket) 1-Click Automated Setup Script
# Version: 2.0 (Production Verified)
# Purpose: Bypass ISP DPI (ATOM/MPT) & Strict VPS BGP DDoS Null-Routes / Blacklists
# ==============================================================================

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}====================================================================${NC}"
echo -e "${GREEN}${BOLD}   3X-UI + Cloudflare CDN Anti-Censorship 1-Click Installer (v2.0)  ${NC}"
echo -e "${YELLOW}   (Bypass ISP DPI, BGP DDoS Null-routes & Dynamic Blacklists)      ${NC}"
echo -e "${CYAN}====================================================================${NC}"
echo ""

# 1. Check Root Privileges
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR] This script must be run as root! Please use sudo.${NC}"
   exit 1
fi

# Detect Server Public IP
SERVER_IP=$(curl -s4m 8 ip.sb || curl -s4m 8 ifconfig.me || curl -s4m 8 icanhazip.com || echo "YOUR_SERVER_IP")
echo -e "${BLUE}[INFO] Detected Server Public IPv4:${NC} ${GREEN}${BOLD}${SERVER_IP}${NC}"
echo ""

# 2. Configuration Prompts
echo -e "${CYAN}--- [Panel Configuration Setup] ---${NC}"
read -rp "Enter 3X-UI Admin Username [default: admin]: " PANEL_USER
PANEL_USER=${PANEL_USER:-admin}

read -rp "Enter 3X-UI Admin Password [default: AdminPass123!]: " PANEL_PASS
PANEL_PASS=${PANEL_PASS:-AdminPass123!}

read -rp "Enter 3X-UI Panel Port [default: 30659]: " PANEL_PORT
PANEL_PORT=${PANEL_PORT:-30659}

read -rp "Enter your Cloudflare Domain (e.g. qqg.uzinlay.cloudns.ph): " CF_DOMAIN
CF_DOMAIN=${CF_DOMAIN:-qqg.uzinlay.cloudns.ph}

# 3. Kernel & Network Optimization (BBR, FastOpen, Forwarding)
echo ""
echo -e "${BLUE}[1/5] Optimizing Linux Kernel & Network Stack (BBR & IP Forward)...${NC}"
cat << 'SYSCONF' > /etc/sysctl.d/99-vps-optimization.conf
net.ipv4.ip_forward = 1
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
SYSCONF
sysctl -p /etc/sysctl.d/99-vps-optimization.conf >/dev/null 2>&1

# 4. Fix UFW Forward Policy
echo -e "${BLUE}[2/5] Configuring UFW Firewall Forwarding Policy...${NC}"
if [ -f "/etc/default/ufw" ]; then
    sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
fi
if [ -f "/etc/ufw/sysctl.conf" ]; then
    sed -i 's/#net\/ipv4\/ip_forward=1/net\/ipv4\/ip_forward=1/' /etc/ufw/sysctl.conf
fi

# 5. Install Dependencies
echo -e "${BLUE}[3/5] Installing core dependencies (curl, socat, jq, iptables, ufw)...${NC}"
apt-get update -y >/dev/null 2>&1
apt-get install -y curl wget tar socat jq iptables ufw cron sqlite3 >/dev/null 2>&1

# 6. Open Ports in UFW
echo -e "${BLUE}[4/5] Opening Firewall Ports (Cloudflare CDN Ports + Panel Port)...${NC}"
if command -v ufw >/dev/null 2>&1; then
    # SSH Ports
    ufw allow 22/tcp >/dev/null 2>&1
    ufw allow 2213/tcp >/dev/null 2>&1
    # Cloudflare Standard HTTP/HTTPS Ports
    ufw allow 80/tcp >/dev/null 2>&1
    ufw allow 443/tcp >/dev/null 2>&1
    ufw allow 2053/tcp >/dev/null 2>&1
    ufw allow 8443/tcp >/dev/null 2>&1
    ufw allow 2083/tcp >/dev/null 2>&1
    ufw allow 2087/tcp >/dev/null 2>&1
    ufw allow 2096/tcp >/dev/null 2>&1
    # Panel Port
    ufw allow "${PANEL_PORT}/tcp" >/dev/null 2>&1
    ufw reload >/dev/null 2>&1 || true
fi

# 7. Install Official 3X-UI Panel
echo -e "${BLUE}[5/5] Installing official 3X-UI Panel (Mhsanaei)...${NC}"
export DEBIAN_FRONTEND=noninteractive
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) <<EOF
y
${PANEL_USER}
${PANEL_PASS}
${PANEL_PORT}
EOF

# Ensure credentials and port are configured
if command -v x-ui >/dev/null 2>&1; then
    x-ui setting -username "${PANEL_USER}" -password "${PANEL_PASS}" -port "${PANEL_PORT}" >/dev/null 2>&1 || true
    x-ui restart >/dev/null 2>&1 || true
fi

# Read Secret Web Base Path from Database
SECRET_PATH=""
if [ -f "/etc/x-ui/x-ui.db" ] && command -v sqlite3 >/dev/null 2>&1; then
    SECRET_PATH=$(sqlite3 /etc/x-ui/x-ui.db "SELECT value FROM settings WHERE key='webBasePath';" 2>/dev/null || true)
fi

FULL_URL="http://${SERVER_IP}:${PANEL_PORT}${SECRET_PATH}"

# Completion Output
echo ""
echo -e "${GREEN}====================================================================${NC}"
echo -e "${GREEN}${BOLD}   🎉 3X-UI & Cloudflare CDN Setup Completed Successfully!          ${NC}"
echo -e "${GREEN}====================================================================${NC}"
echo ""
echo -e "${YELLOW}Panel Login URL:${NC}    ${CYAN}${BOLD}${FULL_URL}${NC}"
echo -e "${YELLOW}Admin Username:${NC}     ${GREEN}${PANEL_USER}${NC}"
echo -e "${YELLOW}Admin Password:${NC}     ${GREEN}${PANEL_PASS}${NC}"
echo -e "${YELLOW}Panel Port:${NC}         ${PURPLE}${PANEL_PORT}${NC}"
if [ -n "$SECRET_PATH" ]; then
echo -e "${YELLOW}Secret Web Path:${NC}    ${PURPLE}${SECRET_PATH}${NC}"
fi
echo -e "${YELLOW}Cloudflare Domain:${NC}  ${GREEN}${CF_DOMAIN}${NC}"
echo ""
echo -e "${CYAN}--------------------------------------------------------------------${NC}"
echo -e "${YELLOW}${BOLD}📌 Cloudflare CDN VLESS-WS Inbound ထည့်သွင်းရန် အဆင့်များ:${NC}"
echo -e "1. Browser တွင် ${CYAN}${FULL_URL}${NC} သို့ Login ဝင်ပါ။"
echo -e "2. ဘယ်ဘက် Menu ရှိ ${BLUE}Inbounds${NC} -> ${GREEN}+ Add Inbound${NC} ကို နှိပ်ပါ။"
echo -e "   - ${PURPLE}Basics Tab:${NC}"
echo -e "       * Remark:   ${GREEN}CF-VLESS-WS${NC}"
echo -e "       * Protocol: ${GREEN}vless${NC}"
echo -e "       * Port:     ${GREEN}2053${NC} (Cloudflare HTTPS Port)"
echo -e "   - ${PURPLE}Stream Tab:${NC}"
echo -e "       * Transmission: ${GREEN}WebSocket${NC}"
echo -e "       * Host:         ${GREEN}${CF_DOMAIN}${NC}"
echo -e "       * Path:         ${GREEN}/ws${NC}"
echo -e "   - ${PURPLE}Security Tab:${NC}"
echo -e "       * Security:     ${GREEN}None${NC} (Cloudflare SSL mode: Flexible ထားပါ)"
echo -e "   - ${PURPLE}Sniffing Tab:${NC}"
echo -e "       * Sniffing:     ${GREEN}ON${NC}"
echo -e "3. ${GREEN}Create${NC} နှိပ်ပြီး Inbound ဖန်တီးပါ။"
echo -e "4. Inbound ဘေးရှိ ${YELLOW}QR Code / Copy Link${NC} ဖြင့် v2rayNG / Sing-box ထဲသို့ ထည့်သွင်းအသုံးပြုပါ!"
echo -e "${CYAN}====================================================================${NC}"
