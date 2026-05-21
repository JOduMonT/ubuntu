#!/usr/bin/env bash
set -euo pipefail

# ADD SUPER USER
#USER=
useradd -g users -mNs /bin/bash ${USER:-rescue}
cp -r /root/.ssh /home/${USER:-rescue}/
chown -R ${USER:-rescue}: /home/${USER:-rescue}/.ssh

usermod -aG sudo ${USER:-rescue}
echo "${USER:-rescue} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/90-${USER:-rescue}-users"


# ENABLE BYOBU
sudo -nu ${USER:-rescue} byobu-enable
sudo -nu ${USER:-rescue} echo "set -sg escape-time 50" > /home/${USER:-rescue}/.config/byobu/.tmux.conf
