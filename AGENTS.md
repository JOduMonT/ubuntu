# AGENTS.md — AI Coding Agent Instructions

This document provides system context, architectural constraints, and coding standards to help AI coding agents work efficiently and consistently on this repository.

---

## 1. Project Context & Purpose

This repository is a curated collection of **Ubuntu system configuration, hardening, and installer scripts**. Its purpose is to turn a standard Ubuntu installation into a high-performance, secure, and modern workspace with automatic dependency management.

---

## 2. Directory Structure

- **`/` (Root)**: Contains main installer bash scripts (`install_*.sh`), utility scripts (`bootstrap.sh`, `verify.sh`), and runtime configurations (`rclone-bisync.sh`, `claude-code.sh`).
- **`/etc`**: Holds system-level templates and settings (e.g., custom SSH configurations, systemd services, or application limiter files).
- **`/etc/ssh`**: hardended SSH configuration profiles.
- **`/etc/systemd/system`**: systemd service wrappers (e.g. rclone-bisync timers).

---

## 3. Shell Scripting Standards

All installer and configuration bash scripts **MUST** strictly adhere to the following principles:

### A. Strict Execution Safeguards
- Always begin with:
  ```bash
  #!/usr/bin/env bash
  set -euo pipefail
  ```
- Always enforce root checking at the top of installers:
  ```bash
  if [[ $EUID -ne 0 ]]; then
     error "This installer must be run as root (or via sudo)."
     exit 1
  fi
  ```

### B. Standard Bootstrapping
- Invoke `./bootstrap.sh || exit` early to guarantee base system utilities (`curl`, `ca-certificates`) are installed.

### C. CLI Aesthetics & Logging
- Use premium color logging. Define and use the following helper functions in all scripts to preserve terminal formatting consistency:
  ```bash
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  YELLOW='\033[1;33m'
  CYAN='\033[0;36m'
  NC='\033[0m' # No Color

  log() { echo -e "${BLUE}[label]${NC} 🚀 $*"; }
  success() { echo -e "${GREEN}[label]${NC} ✨ $*"; }
  warn() { echo -e "${YELLOW}[label]${NC} ⚠️  $*"; }
  error() { echo -e "${RED}[label] [ERROR]${NC} ❌ $*" >&2; }
  ```

### D. Idempotency & Clean Directory Rotation
- Installers **must** be re-run safe (idempotent).
- Prior to creating target installation folders under `/opt`, safely rotate existing installations into backups (e.g. `.bak`) to prevent file locks or runtime memory fragmentation:
  ```bash
  INSTALL_DIR="/opt/app-name"
  if [[ -d "$INSTALL_DIR" ]]; then
      rm -rf "${INSTALL_DIR}.bak"
      mv "$INSTALL_DIR" "${INSTALL_DIR}.bak"
  fi
  ```

### E. Library Validation Safety
- When working with precompiled Electron or native binaries, dynamically check system library constraints (`GLIBC` and `GLIBCXX`) before unpacking:
  ```bash
  # GLIBC Version assertion (Minimum: 2.28)
  glibc_ver=$(ldd --version | sed -n '1s/.* \([0-9]\+\.[0-9]\+\).*/\1/p')
  ```

### F. Desktop & UI Wrappers
- Electron/GUI tool wrappers should detect the active session server and apply ozone/X11 compatibility switches natively:
  ```bash
  # Wayland ozone platform auto-injection
  ARGS=()
  if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]]; then
      ARGS+=("--ozone-platform=x11")
  fi
  ```

---

## 4. Recursive Dependency Management

When writing installers that rely on other tools in the repository:
1. **Node.js**: Check for Node.js (`node`) and `npm`. If missing or `< 20.0.0`, invoke `./install_nodejs.sh` dynamically.
2. **Hugo Extended**: Check if `hugo` is present. If missing, invoke `./install_hugo.sh` dynamically.
3. **Local DEB packages**: Use `apt-get install -y ./package.deb` to guarantee that local package files are automatically unpacked with all remote dependencies resolved.

---

## 5. Verification Commands

Before concluding any change:
- **Syntax Check**: Ensure syntax passes successfully:
  ```bash
  bash -n install_name.sh
  ```
- **Post-Install Verification**: Run the verification tool helper to assert functional stability:
  ```bash
  ./verify.sh <label> "<command-to-test>"
  ```
- **Repository Integrity**: Verify `git status` is clean of temp files before pushing.
