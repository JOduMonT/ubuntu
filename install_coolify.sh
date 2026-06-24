#!/usr/bin/env bash
set -euo pipefail

./bootstrap.sh || exit
apt install -y etckeeper

# Helper to execute dependency scripts safely (respects local files, supports custom fork/branch fallback)
run_script() {
  local script="$1"
  if [[ -f "./${script}" ]]; then
    bash "./${script}"
  else
    local repo_owner="${REPO_OWNER:-JOduMonT}"
    local repo_branch="${REPO_BRANCH:-main}"
    curl -fsSL "https://raw.githubusercontent.com/${repo_owner}/ubuntu/refs/heads/${repo_branch}/${script}" | bash
  fi
}

run_script "clean_install.sh"
run_script "install_advantage.sh"
run_script "secure_sshd.sh"

curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
