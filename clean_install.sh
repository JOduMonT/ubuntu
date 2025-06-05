apt list --installed > installed.1st
apt update
apt install -y etckeeper

apt purge \
  apport* \
  btrfs-progs \
  containerd \
  cryptsetup* \
  dmeventd \
  dmidecode \
  dmsetup \
  doc-base \
  docker.io \
  docker-doc \
  docker-compose \
  docker-compose-v2 \
  lvm2 \
  lxd* \
  info \
  man-db \
  manpages* \
  mdadm \
  multipath-tools \
  open-iscsi \
  overlayroot \
  podman-docker \
  popularity-contest \
  runc \
  sg3-utils* \
  snapd \
  thin-provisioning-tools \
  ubuntu-docs \
  ubuntu-report \
  xfsprogs \
  whoopsie
apt autoremove --purge -y

apt dist-upgrade -y

apt install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

useradd -g docker -mNs /bin/bash -u 911 docker
cp -r /root/.ssh /home/docker/
chown -R docker:docker /home/docker/.ssh

sudo -nu docker byobu-enable
sudo -nu docker echo "set -sg escape-time 50" > /home/docker/.config/byobu/.tmux.conf

curl -s https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/etc/ssh/sshd_config -o /etc/ssh/sshd_config

reboot
