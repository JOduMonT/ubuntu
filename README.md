# Ubuntu Workspace hardening, Configuration, and System Installers

Welcome! This repository is a curated collection of **Ubuntu system configurations, hardening profiles, and idempotent installer scripts**. Its goal is to transform a standard, fresh Ubuntu installation into a secure, high-performance, and modern workspace with automated, reliable dependency resolution.

---

## 🚀 Quick Start

Before running any script, ensure your system package lists are up to date and base requirements are met:

```bash
# Clone the repository
git clone https://github.com/JOduMonT/ubuntu.git
cd ubuntu

# Invoke the baseline bootstrap (installs curl, ca-certificates, etc.)
sudo ./bootstrap.sh
```

### Run an Installer

Installers are located in the root directory and are prefixed with `install_`. They are designed to be completely **idempotent** and safe to run multiple times.

```bash
# Example: Install Hugo Extended (automatically manages Go compiler requirement)
sudo ./install_hugo.sh

# Example: Install Antigravity IDE (automatically configures Display Server sandbox wrappers)
sudo ./install_antigravity-ide.sh
```

### Verify an Installation

Use the post-install assertion helper to quickly test if a tool is correctly configured and accessible in your shell:

```bash
./verify.sh hugo "hugo version"
./verify.sh go "go version"
./verify.sh node "node --version"
```

---

## 📂 Project Architecture

```
ubuntu/
├── install_*.sh          # Idempotent installer scripts
├── bootstrap.sh          # Idempotent baseline script for system preparation
├── verify.sh             # Tiny post-install test/assertion utility
├── rclone-bisync.sh      # Sync tool between local folders and Google Drive
├── etc/                  # System-level config templates
│   ├── ssh/              # Hardened SSH configuration profiles
│   ├── systemd/system/   # systemd wrapper unit files
│   └── searxng/          # Configs for search engines and limiting tools
├── AGENTS.md             # AI coding agent context and style guide
└── README.md             # High-level documentation (this file)
```

---

## 🛠️ Included Tools & Configs

### Hardening & Security
- **`hardening_cis-level1.sh`**: Standard system securing profile.
- **`secure_sshd.sh`**: Installs high-grade, modern cryptographic policies for OpenSSH Server.

### Development Installers
- **`install_antigravity-ide.sh`**: High-performance development workspace.
- **`install_hugo.sh`**: Static site generator extended engine. Resolves Go compiler versions `>= 1.26.3`.
- **`install_blowfish-tools.sh`**: Interactive scaffolder CLI for Blowfish Hugo sites. Manages Hugo and Node.js dependencies natively.
- **`install_nodejs.sh`**: Provisions stable Node.js 24 and NPM globally with group-based write access.
- **`install_docker.sh`**: Core virtualization platform.

### Storage & Utilities
- **`install_rclone.sh`**: Installs rclone and bidirectionally syncs local file directories with Google Drive.
- **`install_kopia.sh`**: Fast, encrypted, and deduplicated backup tool.
- **`install_yt-dlp.sh`**: Media retriever command-line engine.

---

## ✍️ Contribution & Script Standards

All scripts in this repository follow strict production guidelines to guarantee stability, readability, and safe terminal formatting:

1. **Safety First**: All scripts enforce `set -euo pipefail` and require root permissions (`sudo`) for package installation steps.
2. **Beautiful Aesthetics**: Define ANSI color codes and use styled logging methods (`log`, `success`, `warn`, `error`) with standard icons/emojis.
3. **Directory Rotation**: Never overwrite existing target directories in `/opt/` directly; safely move them to `.bak` directories to avoid file locks.
4. **AI-Ready Context**: AI coding assistants working on this repository should reference [AGENTS.md](AGENTS.md) for automated coding standards and system boundaries.

---

## 📄 License
This project is open-source and available under standard repository terms.
