#!/usr/bin/env bash
# install_hugo.sh — Idempotent installer for the latest Hugo extended build & Go prerequisite.
#
# Usage:
#   sudo ./install_hugo.sh

set -euo pipefail

# ANSI Color Codes for Premium CLI Aesthetics
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[install-hugo]${NC} 🚀 $*"; }
success() { echo -e "${GREEN}[install-hugo]${NC} ✨ $*"; }
warn() { echo -e "${YELLOW}[install-hugo]${NC} ⚠️  $*"; }
error() { echo -e "${RED}[install-hugo] [ERROR]${NC} ❌ $*" >&2; }

# Ensure script is run as root/sudo
if [[ $EUID -ne 0 ]]; then
  error "This installer must be run as root (or via sudo)."
  exit 1
fi

# Invoke bootstrap sequence to ensure base tools are ready
./bootstrap.sh || exit

# 1. Verify Minimum System Requirements (GLIBC)
log "Verifying system prerequisites..."

# GLIBC version check (Minimum: 2.28)
glibc_ver=$(ldd --version | sed -n '1s/.* \([0-9]\+\.[0-9]\+\).*/\1/p')
log "Found GLIBC version: $glibc_ver"
if [ "$(printf '%s\n%s' "2.28" "$glibc_ver" | sort -V | head -n 1)" != "2.28" ]; then
  error "GLIBC version is too low ($glibc_ver < 2.28)."
  error "Hugo extended requires GLIBC >= 2.28 (e.g., Ubuntu 20.04+, Debian 10+)."
  exit 1
fi

success "System GLIBC validation passed."

# 2. Manage Go Requirement
MIN_GO_VER="1.26.3"
go_installed=false

log "Checking Go compiler requirements..."
if command -v go &>/dev/null; then
  go_ver=$(go version | awk '{print $3}' | sed 's/^go//' || echo "")
  if [[ -n "$go_ver" ]]; then
    log "Found existing Go version: $go_ver"
    if [ "$(printf '%s\n%s' "$MIN_GO_VER" "$go_ver" | sort -V | head -n 1)" == "$MIN_GO_VER" ]; then
      go_installed=true
      success "Existing Go version $go_ver satisfies requirement >= $MIN_GO_VER."
    else
      warn "Existing Go version is too low ($go_ver < $MIN_GO_VER)."
    fi
  fi
fi

# Set up temporary directory for downloads
TMP_DIR=$(mktemp -d -t hugo-install-XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

if [ "$go_installed" = false ]; then
  log "Installing/upgrading Go to version $MIN_GO_VER..."
  GO_URL="https://go.dev/dl/go${MIN_GO_VER}.linux-amd64.tar.gz"

  log "Downloading Go package..."
  curl -fsSL -o "$TMP_DIR/go.tar.gz" "$GO_URL"

  log "Extracting Go runtime to /usr/local/go..."
  rm -rf /usr/local/go
  tar -C /usr/local -xzf "$TMP_DIR/go.tar.gz"

  log "Configuring system PATH symlinks..."
  mkdir -p /usr/local/bin
  ln -sf /usr/local/go/bin/go /usr/local/bin/go
  ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt

  success "Go runtime $MIN_GO_VER successfully configured."
fi

# Ensure jq is installed for parsing GitHub API
if ! command -v jq &>/dev/null; then
  log "Installing jq for JSON parsing..."
  DEBIAN_FRONTEND=noninteractive apt-get install -y jq >/dev/null
fi

# 3. Dynamic Hugo Version Detection
log "Querying GitHub API for the latest Hugo version..."
hugo_release_json=$(curl -fsSL "https://api.github.com/repos/gohugoio/hugo/releases/latest")
if [[ -z "$hugo_release_json" ]]; then
  error "Failed to fetch version details from GitHub API."
  exit 1
fi

tag_name=$(echo "$hugo_release_json" | jq -r .tag_name)
if [[ -z "$tag_name" || "$tag_name" == "null" ]]; then
  error "Unable to resolve the latest Hugo tag dynamically."
  exit 1
fi

version="${tag_name#v}"
success "Resolved latest stable Hugo release: $version ($tag_name)"
DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/${tag_name}/hugo_extended_${version}_linux-amd64.deb"

# 4. Download and Install Hugo Extended Package
log "Downloading Hugo extended package..."
curl -fsSL -o "$TMP_DIR/hugo.deb" "$DOWNLOAD_URL"
success "Download completed successfully."

log "Installing Hugo extended via apt..."
# apt-get install allows local deb path and resolves internal dependencies automatically
apt-get install -y "$TMP_DIR/hugo.deb"

# 5. Beautiful success message
installed_hugo_ver=$(hugo version | awk '{print $1}' || echo "unknown")
installed_go_ver=$(go version | awk '{print $3}' || echo "unknown")

echo -e "\n${GREEN}=========================================================================${NC}"
echo -e " ${GREEN}🎉 Hugo Extended has been successfully installed! 🎉${NC}"
echo -e "-------------------------------------------------------------------------"
echo -e " ${CYAN}Hugo Version:${NC}  $installed_hugo_ver"
echo -e " ${CYAN}Go Version:${NC}    $installed_go_ver"
echo -e " ${CYAN}Installation:${NC}  $(command -v hugo)"
echo -e "-------------------------------------------------------------------------"
echo -e " ${GREEN}You can now use Hugo and its module engine immediately!${NC}"
echo -e "${GREEN}=========================================================================${NC}\n"
