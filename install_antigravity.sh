#!/usr/bin/env bash
# install_antigravity.sh — Idempotent installer for the latest Antigravity build.
#
# Usage:
#   sudo ./install_antigravity.sh

set -euo pipefail

# Ensure script is run as root/sudo
if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] This installer must be run as root (or via sudo)." >&2
   exit 1
fi

# Invoke bootstrap sequence to ensure base tools are ready
./bootstrap.sh || exit

log() { echo "[install-antigravity] $*"; }
error() { echo "[install-antigravity] [ERROR] $*" >&2; }

# 1. Verify Minimum System Requirements
log "Verifying system prerequisites..."

# GLIBC version check (Minimum: 2.28)
glibc_ver=$(ldd --version | sed -n '1s/.* \([0-9]\+\.[0-9]\+\).*/\1/p')
log "Found GLIBC version: $glibc_ver"
if [ "$(printf '%s\n%s' "2.28" "$glibc_ver" | sort -V | head -n 1)" != "2.28" ]; then
    error "GLIBC version is too low ($glibc_ver < 2.28)."
    error "Antigravity requires GLIBC >= 2.28 (e.g., Ubuntu 20.04+, Debian 10+)."
    exit 1
fi

# GLIBCXX version check (Minimum: 3.4.25)
# Find the system's libstdc++.so.6 using ldconfig
LDCONFIG_BIN=$(command -v ldconfig || echo "/sbin/ldconfig")
libstdc_path=$($LDCONFIG_BIN -p 2>/dev/null | awk -F '=> ' '/libstdc\+\+\.so\.6/ {if (!printed) {print $2; printed=1}}' || echo "")


if [[ -z "$libstdc_path" || ! -f "$libstdc_path" ]]; then
    # Fallback to scanning common library directories if ldconfig output didn't yield a match
    for path in /lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/libstdc++.so.6 /lib/aarch64-linux-gnu/libstdc++.so.6; do
        if [[ -f "$path" ]]; then
            libstdc_path="$path"
            break
        fi
    done
fi

if [[ -n "$libstdc_path" && -f "$libstdc_path" ]]; then
    log "Found libstdc++ at: $libstdc_path"
    max_glibcxx=$(grep -a -oE 'GLIBCXX_3\.4\.[0-9]+' "$libstdc_path" | sort -V | tail -n 1 || echo "")
    if [[ -n "$max_glibcxx" ]]; then
        log "Found maximum GLIBCXX version: $max_glibcxx"
        if [ "$(printf '%s\n%s' "GLIBCXX_3.4.25" "$max_glibcxx" | sort -V | head -n 1)" != "GLIBCXX_3.4.25" ]; then
            error "GLIBCXX version is too low ($max_glibcxx < GLIBCXX_3.4.25)."
            error "Antigravity requires GLIBCXX >= 3.4.25."
            exit 1
        fi
    else
        error "Could not parse GLIBCXX symbols from $libstdc_path. Skipping safety check, attempting to proceed..."
    fi
else
    error "Could not find libstdc++.so.6 on the system. Skipping safety check, attempting to proceed..."
fi

log "Prerequisite validation passed."

# 2. Dynamic Version Detection
log "Querying Google Cloud Storage for the latest Antigravity version..."
bucket_xml=$(curl -fsSL "https://storage.googleapis.com/antigravity-public/?prefix=antigravity-hub/")
if [[ -z "$bucket_xml" ]]; then
    error "Failed to fetch version list from GCS bucket."
    exit 1
fi

# Match and parse semantic versions, filtering out any test versions (e.g. major versions starting with 100)
latest_version=$(echo "$bucket_xml" | \
    grep -oE 'antigravity-hub/[0-9]+\.[0-9]+\.[0-9]+-[0-9]+/linux-x64/Antigravity\.tar\.gz' | \
    sed -E 's|antigravity-hub/([^/]+)/.*|\1|' | \
    grep -vE '^100\.' | \
    sort -V | \
    tail -n 1)

if [[ -z "$latest_version" ]]; then
    error "Unable to resolve the latest Antigravity version dynamically."
    exit 1
fi

log "Resolved latest stable version: $latest_version"
DOWNLOAD_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub/${latest_version}/linux-x64/Antigravity.tar.gz"

# 3. Download to temporary directory
TMP_DIR=$(mktemp -d -t antigravity-install-XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

log "Downloading Antigravity package..."
curl -fsSL -o "$TMP_DIR/Antigravity.tar.gz" "$DOWNLOAD_URL"
log "Download completed successfully."

# 4. Installation
INSTALL_DIR="/opt/antigravity"
BIN_LINK="/usr/local/bin/antigravity"

log "Preparing installation directory: $INSTALL_DIR"
if [[ -d "$INSTALL_DIR" ]]; then
    log "Backing up old installation..."
    rm -rf "${INSTALL_DIR}.bak"
    mv "$INSTALL_DIR" "${INSTALL_DIR}.bak"
fi
mkdir -p "$INSTALL_DIR"

log "Extracting package contents..."
tar -xzf "$TMP_DIR/Antigravity.tar.gz" -C "$INSTALL_DIR" --strip-components=1
log "Extraction completed."

# Configure chrome-sandbox permissions (essential for Electron sandbox on Linux)
if [[ -f "$INSTALL_DIR/chrome-sandbox" ]]; then
    log "Configuring chrome-sandbox setuid permissions..."
    chown root:root "$INSTALL_DIR/chrome-sandbox"
    chmod 4755 "$INSTALL_DIR/chrome-sandbox"
fi

# Ensure executable permissions
chmod +x "$INSTALL_DIR/antigravity"

# 5. Create dynamic launcher wrapper script
log "Creating dynamic launcher wrapper at $BIN_LINK..."
cat << 'EOF' > "$BIN_LINK"
#!/usr/bin/env bash
# Antigravity Dynamic Launcher Wrapper
# Detects X11 vs Wayland and applies necessary compatibility flags.

set -eu

# Dynamic Display Server Detection
DISPLAY_SERVER=""
if [[ "${XDG_SESSION_TYPE:-}" == "wayland" || "${WAYLAND_DISPLAY:-}" != "" ]]; then
    DISPLAY_SERVER="wayland"
elif [[ "${XDG_SESSION_TYPE:-}" == "x11" || "${DISPLAY:-}" != "" ]]; then
    DISPLAY_SERVER="x11"
fi

ARGS=()
if [[ "$DISPLAY_SERVER" == "wayland" ]]; then
    # Add compatibility arguments for Wayland sessions
    ARGS+=("--ozone-platform=x11")
fi

exec "/opt/antigravity/antigravity" "${ARGS[@]}" "$@"
EOF

chmod 755 "$BIN_LINK"


log "Installation successful!"
echo "========================================================================="
echo " Antigravity has been successfully installed."
echo " Version: $latest_version"
echo " Location: $INSTALL_DIR"
echo " Link: $BIN_LINK"
echo ""
echo " You can now run the application by typing: antigravity"
echo "========================================================================="
