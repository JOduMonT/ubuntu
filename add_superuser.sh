USER=docker

# ADD SUPER USER
useradd -g sudo -mNs /bin/bash $USER
cp -r /root/.ssh /home/$USER/
chown -R $USER: /home/$USER/.ssh

# ENABLE BYOBU
sudo -nu $USER byobu-enable
sudo -nu $USER echo "set -sg escape-time 50" > /home/$USER/.config/byobu/.tmux.conf
