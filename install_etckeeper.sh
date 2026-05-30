#!/usr/bin/env bash
# etckeeper setup with SSH deploy key — Ubuntu
# ref: https://wiki.archlinux.org/title/Etckeeper#Automatic_push_to_remote_repo
#
# WARNING: pushing /etc to any remote (even private) can expose sensitive data.
# Review your .gitignore carefully before the first push.
#
# Prerequisites:
#   - A private GitHub repo already created (do NOT init with README)
#   - Run as root (or via sudo)

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
read -rp "GitHub username: " USERNAME
read -rp "GitHub repo name: " REPO
KEY_PATH="/etc/etckeeper/deploy_ed25519"
# ─────────────────────────────────────────────────────────────────────────────

# 1. Install etckeeper
apt update
apt install -y etckeeper

# 2. Enable auto-push (only patch if not already set)
if grep -q '^PUSH_REMOTE=""' /etc/etckeeper/etckeeper.conf; then
    sed -i 's/^PUSH_REMOTE=""/PUSH_REMOTE="origin"/' /etc/etckeeper/etckeeper.conf
    echo "✓ PUSH_REMOTE set to origin"
else
    echo "! PUSH_REMOTE already configured — check /etc/etckeeper/etckeeper.conf manually"
fi

# 3. Generate a dedicated SSH deploy key (no passphrase; used by root in cron)
ssh-keygen -t ed25519 -C "etckeeper@$(hostname)" -f "${KEY_PATH}" -N ""
chmod 600 "${KEY_PATH}"
chmod 644 "${KEY_PATH}.pub"
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  Deploy key public portion (add this to GitHub next):"
echo "══════════════════════════════════════════════════════════════"
cat "${KEY_PATH}.pub"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "→ Go to: https://github.com/${USERNAME}/${REPO}/settings/keys/new"
echo "  Title: etckeeper@$(hostname)"
echo "  Key:   paste the block above"
echo "  ✗ Allow write access  (read-only is enough for push? No — check write)"
echo "  ✓ Allow write access  (etckeeper needs to push)"
echo ""
read -rp "Press Enter once you've added the deploy key to GitHub..."

# 4. Configure SSH to use the deploy key for this specific repo
SSH_CONFIG="/root/.ssh/config"
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Remove any existing etckeeper block to avoid duplicates
sed -i '/^# etckeeper-deploy$/,/^$/d' "${SSH_CONFIG}" 2>/dev/null || true

cat >> "${SSH_CONFIG}" <<EOF

# etckeeper-deploy
Host github-etckeeper
    HostName github.com
    User git
    IdentityFile ${KEY_PATH}
    IdentitiesOnly yes
EOF
chmod 600 "${SSH_CONFIG}"

# 5. Test the SSH connection
echo "Testing SSH connection..."
if ssh -T git@github-etckeeper 2>&1 | grep -q "successfully authenticated"; then
    echo "✓ SSH connection successful"
else
    echo "! SSH test returned above — if you see 'successfully authenticated' it's fine"
fi

# 6. Fetch .gitignore before first commit so secrets are excluded from the start
if [[ -f "./etc/.gitignore" ]]; then
    cp "./etc/.gitignore" /etc/.gitignore
    echo "✓ .gitignore copied from local folder"
else
    repo_owner="${REPO_OWNER:-JOduMonT}"
    repo_branch="${REPO_BRANCH:-main}"
    GITIGNORE_URL="https://raw.githubusercontent.com/${repo_owner}/ubuntu/refs/heads/${repo_branch}/etc/.gitignore"
    echo "Fetching .gitignore from ${GITIGNORE_URL}..."
    if curl -fsSL "${GITIGNORE_URL}" -o /etc/.gitignore; then
        echo "✓ .gitignore installed at /etc/.gitignore"
    else
        echo "✗ Failed to fetch .gitignore — aborting to avoid committing sensitive files"
        exit 1
    fi
fi

# 7. Initial commit (etckeeper may have already done this on install)
if ! git -C /etc log --oneline -1 &>/dev/null; then
    etckeeper init
    etckeeper commit "initial commit"
    echo "✓ Initial commit created"
else
    echo "✓ etckeeper already has commits"
fi

# 8. Add remote using the SSH alias (no token, no plaintext creds)
if git -C /etc remote get-url origin &>/dev/null; then
    echo "! Remote 'origin' already exists:"
    git -C /etc remote get-url origin
    echo "  Remove it first with: etckeeper vcs remote remove origin"
else
    etckeeper vcs remote add origin "git@github-etckeeper:${USERNAME}/${REPO}.git"
    echo "✓ Remote added"
fi

# 9. Initial push
etckeeper vcs push -u origin main \
    || etckeeper vcs push -u origin master  # fallback for older git default

echo ""
echo "✓ Done. etckeeper will now auto-push to github on apt operations."
echo "  Deploy key is at: ${KEY_PATH}"
echo "  SSH alias:        github-etckeeper → github.com"

# Post-install assertion (best-effort — non-fatal if verify.sh is absent)
if [[ -x ./verify.sh ]]; then
    ./verify.sh etckeeper "etckeeper --version" || true
fi
