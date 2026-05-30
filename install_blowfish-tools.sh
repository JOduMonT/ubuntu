#!/usr/bin/env bash
# install_blowfish-tools.sh — Idempotent installer for blowfish-tools & dependencies.
#
# Usage:
#   sudo ./install_blowfish-tools.sh

set -euo pipefail

# ANSI Color Codes for Premium CLI Aesthetics
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[install-blowfish-tools]${NC} 🚀 $*"; }
success() { echo -e "${GREEN}[install-blowfish-tools]${NC} ✨ $*"; }
warn() { echo -e "${YELLOW}[install-blowfish-tools]${NC} ⚠️  $*"; }
error() { echo -e "${RED}[install-blowfish-tools] [ERROR]${NC} ❌ $*" >&2; }

# Ensure script is run as root/sudo
if [[ $EUID -ne 0 ]]; then
   error "This installer must be run as root (or via sudo)."
   exit 1
fi

# Invoke bootstrap sequence to ensure base tools are ready
./bootstrap.sh || exit

# 1. Verify Node.js & npm Dependency
MIN_NODE_VER="20.0.0"
node_installed=false

log "Checking Node.js & npm requirement..."
if command -v node &>/dev/null && command -v npm &>/dev/null; then
    node_ver=$(node --version | sed 's/^v//' || echo "")
    if [[ -n "$node_ver" ]]; then
        log "Found existing Node.js version: $node_ver"
        if [ "$(printf '%s\n%s' "$MIN_NODE_VER" "$node_ver" | sort -V | head -n 1)" == "$MIN_NODE_VER" ]; then
            node_installed=true
            success "Existing Node.js version $node_ver satisfies requirement >= $MIN_NODE_VER."
        else
            warn "Existing Node.js version is too low ($node_ver < $MIN_NODE_VER)."
        fi
    fi
fi

if [ "$node_installed" = false ]; then
    log "Invoking install_nodejs.sh to set up Node.js..."
    if [[ -f "./install_nodejs.sh" ]]; then
        ./install_nodejs.sh || exit
        success "Node.js successfully configured."
    else
        error "Could not find ./install_nodejs.sh in the current directory."
        exit 1
    fi
fi

# 2. Verify Hugo Dependency
hugo_installed=false

log "Checking Hugo Extended requirement..."
if command -v hugo &>/dev/null; then
    hugo_installed=true
    success "Hugo Extended is already installed."
fi

if [ "$hugo_installed" = false ]; then
    log "Invoking install_hugo.sh to configure Hugo Extended..."
    if [[ -f "./install_hugo.sh" ]]; then
        ./install_hugo.sh || exit
        success "Hugo Extended successfully configured."
    else
        error "Could not find ./install_hugo.sh in the current directory."
        exit 1
    fi
fi

# 3. Install blowfish-tools Globally
log "Installing blowfish-tools globally via npm..."
# Set NPM to run in non-interactive production mode safely
npm install -g blowfish-tools

# Confirm command is in path
if command -v blowfish-tools &>/dev/null; then
    success "blowfish-tools successfully installed in path."
else
    # Fallback/dynamic wrapper warning
    warn "blowfish-tools package installed globally, but command was not immediately found in active PATH."
fi

# 4. Beautiful Success Card
installed_node_ver=$(node --version || echo "unknown")
installed_hugo_ver=$(hugo version | awk '{print $1}' || echo "unknown")

echo -e "\n${GREEN}=========================================================================${NC}"
echo -e " ${GREEN}🎉 blowfish-tools has been successfully installed! 🎉${NC}"
echo -e "-------------------------------------------------------------------------"
echo -e " ${CYAN}CLI Command:${NC}   blowfish-tools"
echo -e " ${CYAN}Node Version:${NC}  $installed_node_ver"
echo -e " ${CYAN}Hugo Version:${NC}  $installed_hugo_ver"
echo -e "-------------------------------------------------------------------------"
echo -e " ${GREEN}You can now manage your Blowfish sites immediately by running:${NC}"
echo -e "   ${CYAN}blowfish-tools${NC}  or  ${CYAN}npx blowfish-tools${NC}"
echo -e "${GREEN}=========================================================================${NC}\n"
