#!/usr/bin/env bash
set -euo pipefail

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="${SSHD_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"

# Backup current config
cp "${SSHD_CONFIG}" "${BACKUP}"
echo "✓ Backup saved to ${BACKUP}"

if [[ -f "./etc/ssh/sshd_config" ]]; then
  cp "./etc/ssh/sshd_config" "${SSHD_CONFIG}"
  echo "✓ Config copied from local folder"
else
  repo_owner="${REPO_OWNER:-JOduMonT}"
  repo_branch="${REPO_BRANCH:-main}"
  URL="https://raw.githubusercontent.com/${repo_owner}/ubuntu/refs/heads/${repo_branch}/etc/ssh/sshd_config"
  # Download — fail loudly if it doesn't work
  curl -fsSL "${URL}" -o "${SSHD_CONFIG}"
  echo "✓ Config downloaded"
fi

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
