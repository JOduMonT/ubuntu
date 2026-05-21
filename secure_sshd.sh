#!/usr/bin/env bash
set -euo pipefail

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="${SSHD_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
URL="https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/etc/ssh/sshd_config"

# Backup current config
cp "${SSHD_CONFIG}" "${BACKUP}"
echo "✓ Backup saved to ${BACKUP}"

# Download — fail loudly if it doesn't work
curl -fsSL "${URL}" -o "${SSHD_CONFIG}"
echo "✓ Config downloaded"

# Validate before touching the daemon
sshd -t || {
    echo "✗ Config invalid — restoring backup"
    cp "${BACKUP}" "${SSHD_CONFIG}"
    exit 1
}
echo "✓ Config valid"

# Reload (not restart) — keeps your current session alive
systemctl reload ssh.service
echo "✓ sshd reloaded"

echo ""
echo "  Test login in a NEW terminal before closing this session."

# Post-install assertion (best-effort — non-fatal if verify.sh is absent)
if [[ -x ./verify.sh ]]; then
    ./verify.sh sshd "sshd -t" || true
fi
