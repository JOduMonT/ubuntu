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

# INSTALL ubuntu advantage (Expanded Security Maintenance + Livepatch service)
## https://ubuntu.com/pro/tutorial
## https://ubuntu.com/pro/dashboard
apt install -y ubuntu-advantage-tools

# REBOOT
reboot
