#!/usr/bin/env bash
set -euo pipefail

apt update
apt install -y ca-certificates curl

# INSTALL Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# ADD USER Docker
USER=docker
if [[ -f "./add_superuser.sh" ]]; then
  bash "./add_superuser.sh"
else
  repo_owner="${REPO_OWNER:-JOduMonT}"
  repo_branch="${REPO_BRANCH:-main}"
  curl -fsSL "https://raw.githubusercontent.com/${repo_owner}/ubuntu/refs/heads/${repo_branch}/add_superuser.sh" | bash
fi
