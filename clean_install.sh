#!/usr/bin/env bash

# Strip a fresh Ubuntu server install down to a lean base.
#
# Drift note (2026-05-21): the canonical purge list now lives here AND in
# cloud-init/clean_install. The two are kept in sync by hand because their
# *formats* differ (this is a bash script run interactively after first
# login; cloud-init/clean_install is cloud-config YAML run at first boot).
# When you change one, change the other.
#
# Differences from the cloud-init version, ON PURPOSE:
#   - no `apt dist-upgrade -y` here (the interactive caller may want to
#     defer that until after Pro is attached — see install_advantage.sh).
#   - no `2>/dev/null || true` around apt purge — fail loudly when run
#     interactively so the operator sees what's actually missing.
#
# NOT a `set -euo pipefail` script: `apt purge` returning non-zero for an
# already-absent package is expected and shouldn't abort the loop.

rm -rf /var/lib/apt/lists/*
mkdir -p /var/lib/apt/lists/partial
apt update
apt install -y etckeeper ubuntu-advantage-tools
packages=(
  accountsservice alsa-* amd64-microcode apport* avahi-* bind9-* bluez*
  btrfs-progs cloud-init cloud-guest-utils command-not-found* containerd
  crda cryptsetup* cups cups-* dig dmeventd dmidecode dmsetup doc-base
  docker.io docker-doc docker-compose docker-compose-v2 eatmydata ed eject
  fonts-* firmware-* fontconfig fuse3 fwupd fwupd-signed geoip-database
  groff-base hc-utils hdparm htop ibverbs* inetutils-telnet inputattach
  intel-microcode joystick landscape-common landscape-client laptop-detect
  libbluetooth* libnss-mdns linux-firmware lshw lvm2 lxd* info irqbalance
  man-db manpages* mdadm memtest86+ modemmanager motd-news-config
  multipath-tools nslookup ntfs-3g numactl open-iscsi os-prober overlayroot
  packagekit pastebinit pciutils pipewire* plymouth
  plymouth-theme-ubuntu-text podman-docker popularity-contest
  powermgmt-base ppp pppconfig pppoeconf psmisc pulseaudio* python3-babel
  python3-bcrypt python3-botocore python3-jmespath python3-pip-whl
  python3-s3transfer rfkill runc rsync run-one s3transfer secureboot-db
  sosreport sg3-utils* snapd tcpdump thermald thin-provisioning-tools
  tpm-udev trace-cmd ubuntu-docs ubuntu-release-upgrader-core
  ubuntu-report udisks2 unminimize update-motd upower usbutils xfsprogs
  vim-* xauth xdg-user-dirs xxd wpasupplicant wireless* whoopsie zerofree
)
for package in "${packages[@]}"; do apt purge -y "$package"; done
apt autoremove --purge -y
