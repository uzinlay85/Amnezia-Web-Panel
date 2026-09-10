#!/usr/bin/env bash
# ==============================================================================
# Amnezia Web Panel - GitHub 12-Hour Auto-Update Script & Cron Setup
# Automatically fetches updates from origin/main, updates dependencies if
# requirements.txt changed, and restarts amnezia-panel service safely.
# ==============================================================================

set -e

# Colors for CLI output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

LOG_FILE="/var/log/amnezia-autoupdate.log"
CRON_FILE="/etc/cron.d/amnezia-autoupdate"

# Locate Repo Directory
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)"
if [ ! -f "${APP_DIR}/app.py" ]; then
    APP_DIR=$(find /home /root -maxdepth 3 -name "app.py" 2>/dev/null | grep "Amnezia-Web-Panel" | head -n 1)
    if [ -n "$APP_DIR" ]; then
        APP_DIR="$(dirname "$APP_DIR")"
    fi
fi

if [ -z "$APP_DIR" ] || [ ! -d "$APP_DIR/.git" ]; then
    echo -e "${RED}[ERROR] Could not find Amnezia-Web-Panel git repository.${NC}" >&2
    exit 1
fi

# Detect repository owner/user
REPO_USER=$(stat -c '%U' "$APP_DIR" 2>/dev/null || echo "root")

# Function: Install Cron Job
install_cron() {
    echo -e "${CYAN}${BOLD}====================================================================${NC}"
    echo -e "${CYAN}${BOLD}   ⏰ Installing Amnezia Web Panel 12-Hour Auto-Update Cron Job     ${NC}"
    echo -e "${CYAN}${BOLD}====================================================================${NC}\n"
    
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[ERROR] Please run with sudo or as root to install the cron job.${NC}"
        echo "Example: sudo bash $0 --install"
        exit 1
    fi

    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"
    chmod 644 "$LOG_FILE"

    # Write /etc/cron.d/amnezia-autoupdate
    # Runs at 00:00 and 12:00 every day (0 */12 * * *)
    cat << EOF > "$CRON_FILE"
# Amnezia Web Panel 12-Hour Auto-Update Cron Job
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

0 */12 * * * root /bin/bash ${APP_DIR}/scripts/auto_update.sh >> ${LOG_FILE} 2>&1
EOF

    chmod 644 "$CRON_FILE"
    echo -e "${GREEN}✓ Cron job successfully installed at ${BOLD}${CRON_FILE}${NC}"
    echo -e "  Schedule : ${BOLD}Every 12 hours (00:00 & 12:00 Daily)${NC}"
    echo -e "  Target   : ${BOLD}${APP_DIR}${NC}"
    echo -e "  Log File : ${BOLD}${LOG_FILE}${NC}\n"
    
    # Run an update check immediately
    echo -e "${YELLOW}Running initial update check now...${NC}"
    run_update
}

# Function: Uninstall Cron Job
uninstall_cron() {
    echo -e "${YELLOW}===> Removing 12-Hour Auto-Update Cron Job...${NC}"
    if [ -f "$CRON_FILE" ]; then
        rm -f "$CRON_FILE"
        echo -e "${GREEN}✓ Removed ${CRON_FILE}${NC}"
    else
        echo "Cron job file not found. Nothing to remove."
    fi
}

# Function: Run Update
run_update() {
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] --- Checking for GitHub Updates (Repo: $APP_DIR) ---"

    cd "$APP_DIR"

    # Mark repo safe for git in case cron runs as root while repo is owned by user
    git config --global --add safe.directory "$APP_DIR" 2>/dev/null || true

    # Fetch updates from origin
    git fetch origin main --quiet || {
        echo "[$TIMESTAMP] [ERROR] Failed to git fetch origin main."
        return 1
    }

    LOCAL_HASH=$(git rev-parse HEAD)
    REMOTE_HASH=$(git rev-parse origin/main)

    if [ "$LOCAL_HASH" = "$REMOTE_HASH" ]; then
        echo "[$TIMESTAMP] ✓ Already up to date (Commit: ${LOCAL_HASH:0:7}). No changes."
        return 0
    fi

    echo "[$TIMESTAMP] 🚀 New updates found: ${LOCAL_HASH:0:7} -> ${REMOTE_HASH:0:7}"
    echo "[$TIMESTAMP] Pulling changes from origin/main..."

    # Check if requirements.txt changes in this update
    REQ_CHANGED=$(git diff --name-only "$LOCAL_HASH" "$REMOTE_HASH" | grep "requirements.txt" || true)

    # Pull changes
    git pull origin main --quiet

    # Ensure repository file ownership remains intact for non-root users
    if [ "$EUID" -eq 0 ] && [ -n "$REPO_USER" ] && [ "$REPO_USER" != "root" ]; then
        chown -R "${REPO_USER}:${REPO_USER}" "$APP_DIR"
    fi

    # Update dependencies if requirements.txt changed
    if [ -n "$REQ_CHANGED" ]; then
        echo "[$TIMESTAMP] requirements.txt changed. Updating python dependencies..."
        if [ -d "$APP_DIR/venv" ]; then
            "$APP_DIR/venv/bin/pip" install -q -r "$APP_DIR/requirements.txt" || true
            if [ "$EUID" -eq 0 ] && [ -n "$REPO_USER" ] && [ "$REPO_USER" != "root" ]; then
                chown -R "${REPO_USER}:${REPO_USER}" "$APP_DIR/venv"
            fi
        fi
    fi

    # Restart amnezia-panel service
    echo "[$TIMESTAMP] Restarting amnezia-panel service..."
    if command -v systemctl &>/dev/null; then
        systemctl restart amnezia-panel
        echo "[$TIMESTAMP] ✓ amnezia-panel service restarted successfully."
    fi

    echo "[$TIMESTAMP] 🎉 Update completed successfully to commit ${REMOTE_HASH:0:7}."

    # Keep log file size reasonable (max 1000 lines)
    if [ -f "$LOG_FILE" ] && [ "$(wc -l < "$LOG_FILE")" -gt 1500 ]; then
        tail -n 1000 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
    fi
}

# CLI Argument handling
case "$1" in
    --install|-i)
        install_cron
        ;;
    --uninstall|-u)
        uninstall_cron
        ;;
    --check|-c)
        run_update
        ;;
    *)
        # Default: if run with no args, execute the update check
        run_update
        ;;
esac
