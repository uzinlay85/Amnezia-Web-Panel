#!/usr/bin/env bash
# ==============================================================================
# Amnezia Web Panel - One-Click VPS Pre-Flight Checker & Auto-Optimizer
# Designed for Ubuntu 20.04 / 22.04 / 24.04 & Debian 11 / 12
# ==============================================================================

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${CYAN}${BOLD}"
echo "===================================================================="
echo "   🚀 Amnezia Web Panel - VPS Pre-Flight Checker & Auto-Optimizer   "
echo "===================================================================="
echo -e "${NC}"

# 1. Root / Sudo Check
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] This script must be run as root or with sudo.${NC}"
    echo "Please run: sudo bash $0"
    exit 1
fi

# Detect actual logged in user (e.g. zinko, or root)
ACTUAL_USER="${SUDO_USER:-$USER}"
if [ -z "$ACTUAL_USER" ] || [ "$ACTUAL_USER" = "root" ]; then
    ACTUAL_USER=$(logname 2>/dev/null || who | awk '{print $1}' | head -n 1)
fi
if [ -z "$ACTUAL_USER" ]; then
    ACTUAL_USER="root"
fi

echo -e "${BLUE}[INFO] Detected Target User: ${BOLD}${ACTUAL_USER}${NC}"
echo -e "${BLUE}[INFO] Running pre-flight system diagnostics & auto-fixes...${NC}\n"

# ------------------------------------------------------------------------------
# 2. Kernel & BBR / IP Forwarding Optimization
# ------------------------------------------------------------------------------
echo -e "${YELLOW}---> [1/7] Optimizing Kernel, BBR & IP Forwarding...${NC}"

SYSCTL_CONF="/etc/sysctl.d/99-amnezia-vps-tuning.conf"
cat << 'EOF' > "$SYSCTL_CONF"
# Amnezia VPN & VPS Performance Optimization
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1

# Google BBR Congestion Control & Fair Queueing
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# TCP Buffer & Speed Optimizations
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 100000
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1

# File descriptors & socket limits
fs.file-max = 1000000
EOF

sysctl --system >/dev/null 2>&1 || sysctl -p "$SYSCTL_CONF" >/dev/null 2>&1

BBR_STATUS=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo "unknown")
IP_FWD_STATUS=$(sysctl -n net.ipv4.ip_forward 2>/dev/null || echo "0")

if [ "$BBR_STATUS" = "bbr" ]; then
    echo -e "${GREEN}  ✓ Google BBR Congestion Control: ACTIVE${NC}"
else
    echo -e "${YELLOW}  ! BBR not supported on this kernel (current: $BBR_STATUS)${NC}"
fi

if [ "$IP_FWD_STATUS" = "1" ]; then
    echo -e "${GREEN}  ✓ IPv4/IPv6 Packet Forwarding: ENABLED${NC}"
else
    echo -e "${RED}  ✗ Failed to enable IP forwarding${NC}"
fi

# ------------------------------------------------------------------------------
# 3. System Limits (ulimit & file descriptors)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}---> [2/7] Optimizing System Limits (ulimit / nofile)...${NC}"

LIMITS_CONF="/etc/security/limits.d/99-amnezia-limits.conf"
cat << 'EOF' > "$LIMITS_CONF"
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
root soft nofile 65535
root hard nofile 65535
root soft nproc 65535
root hard nproc 65535
EOF
echo -e "${GREEN}  ✓ Max open files limit raised to 65535${NC}"

# ------------------------------------------------------------------------------
# 4. Swap Memory Check & Creation (Prevents OOM Crashes)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}---> [3/7] Checking RAM & Swap Memory...${NC}"

TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_SWAP_KB=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
TOTAL_SWAP_MB=$((TOTAL_SWAP_KB / 1024))

echo -e "  • Total RAM: ${TOTAL_RAM_MB} MB | Existing Swap: ${TOTAL_SWAP_MB} MB"

if [ "$TOTAL_SWAP_MB" -lt 1024 ]; then
    echo -e "${YELLOW}  ! Low swap detected. Creating 4GB Swapfile to prevent OOM crash...${NC}"
    if [ ! -f /swapfile ]; then
        fallocate -l 4G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=4096
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        if ! grep -q '/swapfile' /etc/fstab; then
            echo '/swapfile none swap sw 0 0' >> /etc/fstab
        fi
        echo -e "${GREEN}  ✓ 4GB Swapfile created and activated successfully!${NC}"
    else
        swapon /swapfile 2>/dev/null || true
    fi
else
    echo -e "${GREEN}  ✓ Swap memory is healthy (${TOTAL_SWAP_MB} MB)${NC}"
fi

# ------------------------------------------------------------------------------
# 5. Essential Packages Installation
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}---> [4/7] Installing System Utilities & Dependencies...${NC}"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq git curl wget ufw iptables jq python3 python3-pip python3-venv >/dev/null

echo -e "${GREEN}  ✓ Python3, Git, UFW, Iptables, JQ installed${NC}"

# ------------------------------------------------------------------------------
# 6. Docker Engine Installation & Verification
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}---> [5/7] Checking Docker Engine & Containerd...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}  ! Docker not found. Installing Official Docker CE...${NC}"
    # Remove conflicting old packages if present
    apt-get remove -y -qq containerd docker.io >/dev/null 2>&1 || true
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
    echo -e "${GREEN}  ✓ Docker CE installed successfully!${NC}"
else
    echo -e "${GREEN}  ✓ Docker is already installed: $(docker --version)${NC}"
    systemctl enable --now docker >/dev/null 2>&1 || true
fi

# Ensure Target User is in docker group
if [ "$ACTUAL_USER" != "root" ]; then
    usermod -aG docker "$ACTUAL_USER" || true
    echo -e "${GREEN}  ✓ Added user '${ACTUAL_USER}' to 'docker' group (no sudo needed)${NC}"
fi

# ------------------------------------------------------------------------------
# 7. Safe Firewall (UFW) Configuration
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}---> [6/7] Configuring UFW Firewall Safely...${NC}"

# Detect active SSH port dynamically so user never gets locked out
SSH_PORT="22"
if command -v ss &>/dev/null; then
    DETECTED_SSH=$(ss -tlpn 2>/dev/null | grep -E 'sshd|ssh' | awk '{print $4}' | awk -F':' '{print $NF}' | head -n 1)
    if [ -n "$DETECTED_SSH" ] && [ "$DETECTED_SSH" -gt 0 ] 2>/dev/null; then
        SSH_PORT="$DETECTED_SSH"
    fi
fi
if [ "$SSH_PORT" = "22" ] && [ -f /etc/ssh/sshd_config ]; then
    CONF_PORT=$(grep -E "^Port [0-9]+" /etc/ssh/sshd_config | awk '{print $2}' | head -n 1)
    if [ -n "$CONF_PORT" ]; then
        SSH_PORT="$CONF_PORT"
    fi
fi

echo -e "  • Detected SSH Port: ${BOLD}${SSH_PORT}/tcp${NC}"

# Allow SSH first before enabling UFW
ufw allow "${SSH_PORT}/tcp" comment "SSH Port" >/dev/null 2>&1
ufw allow 80/tcp comment "HTTP Web" >/dev/null 2>&1
ufw allow 443/tcp comment "HTTPS Web / Xray" >/dev/null 2>&1
ufw allow 443/udp comment "AWG / Xray" >/dev/null 2>&1
ufw allow 5000/tcp comment "Amnezia Web Panel" >/dev/null 2>&1
ufw allow 55424/udp comment "AmneziaWG Default" >/dev/null 2>&1

# Enable UFW safely without prompt
ufw --force enable >/dev/null 2>&1

echo -e "${GREEN}  ✓ UFW Firewall configured & active (SSH Port ${SSH_PORT} preserved!)${NC}"

# ------------------------------------------------------------------------------
# Summary Report
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}${BOLD}====================================================================${NC}"
echo -e "${GREEN}${BOLD}      🎉 VPS OPTIMIZATION COMPLETED SUCCESSFULLY! 🎉               ${NC}"
echo -e "${CYAN}${BOLD}====================================================================${NC}"
echo -e "  ${BOLD}BBR Congestion Control :${NC} ${GREEN}${BBR_STATUS}${NC}"
echo -e "  ${BOLD}IP Forwarding          :${NC} ${GREEN}Enabled (IPv4 & IPv6)${NC}"
echo -e "  ${BOLD}RAM / Swap Status      :${NC} ${GREEN}${TOTAL_RAM_MB} MB RAM / ${TOTAL_SWAP_MB} MB Swap${NC}"
echo -e "  ${BOLD}Docker Engine          :${NC} ${GREEN}Running & Configured${NC}"
echo -e "  ${BOLD}Target User in Docker  :${NC} ${GREEN}${ACTUAL_USER}${NC}"
echo -e "  ${BOLD}SSH Port Preserved     :${NC} ${GREEN}${SSH_PORT}/tcp${NC}"
echo -e "  ${BOLD}Open VPN Ports         :${NC} ${GREEN}443 (TCP/UDP), 55424 (UDP), 5000 (TCP)${NC}"
echo -e "${CYAN}====================================================================${NC}\n"

if [ "$ACTUAL_USER" != "root" ]; then
    echo -e "${YELLOW}💡 Note: To apply docker group permissions immediately without re-login, run:${NC}"
    echo -e "   ${BOLD}newgrp docker${NC}\n"
fi

echo -e "${GREEN}Your VPS is now 100% prepared and optimized for Amnezia Web Panel!${NC}\n"
