#!/usr/bin/env bash
set -euo pipefail

if [[ -f "./install_advantage.sh" ]]; then
  bash "./install_advantage.sh"
else
  repo_owner="${REPO_OWNER:-JOduMonT}"
  repo_branch="${REPO_BRANCH:-main}"
  curl -fsSL "https://raw.githubusercontent.com/${repo_owner}/ubuntu/refs/heads/${repo_branch}/install_advantage.sh" | bash
fi

pro enable usg
apt install -y usg

## ref: https://discourse.ubuntu.com/t/cis-compliance-with-usg-for-ubuntu-24-04-lts/56178/1
usg generate-tailoring cis_level1_server hardening.xml
usg audit --tailoring-file hardening.xml

# `usg fix` applies CIS Level-1 changes IN PLACE — can lock you out of SSH,
# disable services, or otherwise leave the box unbootable. NEVER run it
# unattended. Audit output above lists what `fix` would actually change.
read -rp "About to run usg fix — this can lock you out. Continue? [yN] " ans
[[ "${ans,,}" == "y" ]] || { echo "Aborted before usg fix."; exit 1; }

usg fix --tailoring-file hardening.xml
