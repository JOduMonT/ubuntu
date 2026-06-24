#!/usr/bin/env bash
set -euo pipefail

./bootstrap.sh || exit
apt install -y unzip

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
run_script "install_nodejs.sh"

## Install PM2
### ensure to install nodejs before: https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/install_nodejs.sh
npm i -g pm2
pm2 install pm2-logrotate

## https://www.gunbot.com/downloads/
mkdir gunbot
cd gunbot
wget https://gunthy.org/downloads/gunthy_linux.zip
unzip gunthy_linux.zip

# monitoring
# create account: https://pm2.io
# link gunbot with it
