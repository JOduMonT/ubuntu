#!/usr/bin/env bash
set -euo pipefail

./bootstrap.sh || exit

# ref: https://kopia.io/docs/installation/#linux-installation-using-apt-debian-ubuntu
curl -s https://kopia.io/signing-key | sudo gpg --dearmor -o /etc/apt/keyrings/kopia-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kopia-keyring.gpg] http://packages.kopia.io/apt/ stable main" | tee /etc/apt/sources.list.d/kopia.list
apt update
apt install -y kopia kopia-ui

# config as service: sudo wget -O /etc/systemd/system/kopia-server.service https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/etc/systemd/system/kopia-server.service
# files to exclude: https://raw.githubusercontent.com/JOduMonT/home-exclusions/refs/heads/master/rsync-homedir-excludes.txt
# use resend to send notification: https://resend.com
