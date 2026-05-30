#!/usr/bin/env bash
# install_rclone.sh — Idempotent installer for rclone and systemd bidirectional sync service.
#
# Usage:
#   sudo ./install_rclone.sh

set -euo pipefail

# Ensure script is run as root/sudo
if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] This installer must be run as root (or via sudo)." >&2
  exit 1
fi

./bootstrap.sh || exit

log() { echo "[install-rclone] $*"; }
error() { echo "[install-rclone] [ERROR] $*" >&2; }

# Determine the actual non-root user for configuration targeting
REAL_USER="${SUDO_USER:-$USER}"
if [[ "$REAL_USER" == "root" ]]; then
  REAL_USER=$(logname 2>/dev/null || echo "")
  if [[ -z "$REAL_USER" || "$REAL_USER" == "root" ]]; then
    # Fallback: get the first regular user from /home directory
    REAL_USER=$(find /home -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | grep -v 'lost+found' | head -n 1 || echo "root")
  fi
fi

REAL_HOME=$(eval echo "~$REAL_USER")
log "Targeting user: $REAL_USER (Home: $REAL_HOME)"

# 1. Install or update Rclone
if command -v rclone &>/dev/null; then
  log "rclone is already installed. Attempting update..."
  # Run official installer but do not crash the script if it fails (e.g. temporary network/DNS issue)
  if ! curl -fsSL https://rclone.org/install.sh | bash; then
    log "WARNING: Could not reach update server. Continuing with existing Rclone version: $(rclone --version | head -n 1)"
  fi
else
  log "rclone not found. Installing the latest official release..."
  curl -fsSL https://rclone.org/install.sh | bash
fi

# Verify installation success
if ! command -v rclone &>/dev/null; then
  error "Rclone installation failed."
  exit 1
fi
log "Rclone successfully installed: $(rclone --version | head -n 1)"

# 2. Install rclone-bisync.sh wrapper script
SCRIPT_SRC="./rclone-bisync.sh"
SCRIPT_DEST="/usr/local/bin/rclone-bisync.sh"

if [[ ! -f "$SCRIPT_SRC" ]]; then
  error "Source script '$SCRIPT_SRC' not found in the current directory."
  exit 1
fi

log "Installing sync wrapper script to $SCRIPT_DEST..."
cp "$SCRIPT_SRC" "$SCRIPT_DEST"
chmod +x "$SCRIPT_DEST"

# 3. Create default configuration file
DEFAULT_CONF="/etc/default/rclone-bisync"
if [[ -f "$DEFAULT_CONF" ]]; then
  log "Backing up existing configuration to ${DEFAULT_CONF}.bak..."
  cp "$DEFAULT_CONF" "${DEFAULT_CONF}.bak"
fi

log "Writing latest configurations to $DEFAULT_CONF..."
cat <<EOF >"$DEFAULT_CONF"
# Rclone Bidirectional Sync Configurations
# Customize these values to match your preferred setup.

# Local directory to synchronize (defaults to actual user home directory)
RCLONE_LOCAL_DIR="$REAL_HOME"

# Google Drive remote name and target path (defined in 'rclone config')
RCLONE_REMOTE_DIR="gdrive:"

# Path to the rclone config file
RCLONE_CONFIG_PATH="$REAL_HOME/.config/rclone/rclone.conf"

# Strategy for handling conflicts (newer | larger | none)
RCLONE_CONFLICT_RESOLVE="newer"

# Maximum deletion percentage (0-100) before aborting as a safety limit
RCLONE_MAX_DELETE="50"

# Enable check-access safety file check (requires RCLONE_TEST file on both sides)
RCLONE_CHECK_ACCESS="true"

# Filters file to restrict sync to specific directories (e.g. Desktop, Documents, etc.)
RCLONE_FILTER_FILE="$REAL_HOME/.config/rclone/rclone-filters.txt"

# Additional rclone bisync flags (optional)
RCLONE_EXTRA_FLAGS=""
EOF
chmod 644 "$DEFAULT_CONF"

# 4. Install the filter rules file
FILTER_SRC="./etc/rclone-filters.txt"
FILTER_DEST_DIR="$REAL_HOME/.config/rclone"
FILTER_DEST="$FILTER_DEST_DIR/rclone-filters.txt"

if [[ ! -f "$FILTER_SRC" ]]; then
  error "Filter rules source '$FILTER_SRC' not found."
  exit 1
fi

log "Installing filter rules file to $FILTER_DEST..."
mkdir -p "$FILTER_DEST_DIR"
cp "$FILTER_SRC" "$FILTER_DEST"
# Ensure the user owns their rclone configuration folder and files so they can run bisync
chown -R "$REAL_USER:$(id -gn "$REAL_USER")" "$FILTER_DEST_DIR"
chmod 644 "$FILTER_DEST"

# 5. Install and template systemd unit files
SERVICE_SRC="./etc/systemd/system/rclone-bisync.service"
TIMER_SRC="./etc/systemd/system/rclone-bisync.timer"

SERVICE_DEST="/etc/systemd/system/rclone-bisync.service"
TIMER_DEST="/etc/systemd/system/rclone-bisync.timer"

if [[ ! -f "$SERVICE_SRC" || ! -f "$TIMER_SRC" ]]; then
  error "Systemd templates not found in etc/systemd/system/."
  exit 1
fi

log "Installing systemd configurations..."
# Template the service file with the actual username and home directory
sed "s/__USER__/$REAL_USER/g" "$SERVICE_SRC" >"$SERVICE_DEST"
chmod 644 "$SERVICE_DEST"

# Copy the timer file directly
cp "$TIMER_SRC" "$TIMER_DEST"
chmod 644 "$TIMER_DEST"

# Reload systemd
log "Reloading systemd daemon..."
systemctl daemon-reload

log "Ready! Setup successfully installed."
echo "========================================================================="
echo " WHAT NEXT?"
echo "========================================================================="
echo " 1. Configure your Google Drive remote:"
echo "    Run: rclone config"
echo "    - Create a new remote named: gdrive (or match RCLONE_REMOTE_DIR in $DEFAULT_CONF)"
echo "    - Select option: drive (Google Drive)"
echo "    - Follow the prompts to authorize access (requires a web browser)."
echo ""
echo " 2. Perform the initial baseline synchronization (MANDATORY):"
echo "    Run: $SCRIPT_DEST --resync"
echo "    - This creates the required '$REAL_HOME/RCLONE_TEST' safety files"
echo "      and establishes the baseline metadata cache."
echo ""
echo " 3. Enable and start the automated timer service:"
echo "    Run: sudo systemctl enable --now rclone-bisync.timer"
echo ""
echo " 4. Monitor and verify:"
echo "    - Check timer status:  systemctl status rclone-bisync.timer"
echo "    - Trigger manual sync: sudo systemctl start rclone-bisync.service"
echo "    - View sync logs:      journalctl -u rclone-bisync.service -f"
echo "========================================================================="
