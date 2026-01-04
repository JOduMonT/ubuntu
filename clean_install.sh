apt update
apt install -y etckeeper
packages=(apport* btrfs-progs containerd cryptsetup* dmeventd dmidecode dmsetup doc-base docker.io docker-doc docker-compose docker-compose-v2 lvm2 lxd* info man-db manpages* mdadm multipath-tools open-iscsi overlayroot podman-docker popularity-contest python3-babel python3-bcrypt python3-botocore python3-jmespath python3-pip-whl python3-s3transfer runc sg3-utils* snapd thin-provisioning-tools ubuntu-docs ubuntu-report xfsprogs whoopsie)
for package in "${packages[@]}"; do apt purge -y "$package"; done
apt autoremove --purge -y
