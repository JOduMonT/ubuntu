# LIST installed packages
apt list --installed > installed.1st
apt update

# INSTALL etckeeper
apt install -y etckeeper

# PURGE
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
  python3-babel \
  python3-bcrypt \
  python3-botocore \
  python3-jmespath \
  python3-pip-whl \
  python3-s3transfer \
  runc \
  sg3-utils* \
  snapd \
  thin-provisioning-tools \
  ubuntu-docs \
  ubuntu-report \
  xfsprogs \
  whoopsie
apt autoremove --purge -y

# UPGRADE
apt dist-upgrade -y

# INSTALL Docker
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

# ADD USER Docker
useradd -g docker -mNs /bin/bash -u 911 docker
cp -r /root/.ssh /home/docker/
chown -R docker:docker /home/docker/.ssh

# ENABLE BYOBU for Docker user
sudo -nu docker byobu-enable
sudo -nu docker echo "set -sg escape-time 50" > /home/docker/.config/byobu/.tmux.conf

# SECURE ssh daemon
curl -s https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/etc/ssh/sshd_config -o /etc/ssh/sshd_config

# INSTALL ubuntu advantage (Expanded Security Maintenance + Livepatch service)
## https://ubuntu.com/pro/tutorial
## https://ubuntu.com/pro/dashboard
apt install -y ubuntu-advantage-tools

# TWEAKS: Hetzner CX22 (2 vCPU | 4 GB | NVME SSD 40 GB)
sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT="consoleblank=0 systemd.show_status=true console=tty1 console=ttyS0 processor.max_cstate=1 intel_idle.max_cstate=0 hpet=enable clocksource=tsc"|' /etc/default/grub
sed -i 's|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX="elevator=deadline"|' /etc/default/grub
update-grub

echo  \
  "## Memory and Performance Tweaks (optimized for 4GB RAM)
# Reduce swappiness for better memory performance
vm.swappiness=5

# Optimize network buffer sizes (reduced for smaller system)
net.core.rmem_max=8388608
net.core.wmem_max=8388608

# Improve TCP performance for trading applications
net.ipv4.tcp_congestion_control=bbr

## Network Optimization Parameters (adjusted for 2 vCPU)
# Increase network receive queue (reduced for smaller system)
net.core.netdev_max_backlog=2500

# Optimize connection tracking (reduced for 4GB RAM)
net.netfilter.nf_conntrack_max=524288

## Additional optimizations for trading
# TCP window scaling for better throughput
net.ipv4.tcp_window_scaling=1

# Enable TCP fast open for reduced latency
net.ipv4.tcp_fastopen=3

# Optional: disable TCP slow start for low latency
net.ipv4.tcp_slow_start_after_idle=0
  " | tee /etc/sysctl.d/tweak.conf
sysctl -p

# REBOOT
reboot
