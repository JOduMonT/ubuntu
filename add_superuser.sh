# ADD SUPER USER
useradd -g users -mNs /bin/bash $USER
cp -r /root/.ssh /home/$USER/
chown -R $USER: /home/$USER/.ssh

usermod -aG sudo $USER
echo "$USER ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/90-$USER-users"


# ENABLE BYOBU
sudo -nu $USER byobu-enable
sudo -nu $USER echo "set -sg escape-time 50" > /home/$USER/.config/byobu/.tmux.conf
