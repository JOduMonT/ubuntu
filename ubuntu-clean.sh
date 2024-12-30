apt list --installed > installed.1st
for pkg in aspell* bolt btrfs* containerd cryptsetup* dmeventd dmidecode dmsetup docker.io docker-doc docker-compose docker-compose-v2 fonts* lvm2 lxd* mdadm nftables* ntfs* open-iscsi overlayroot podman-docker runc snap* sg3-utils* telnet thin-provisioning* tnftp usb-* wamerican wireless* xfsprogs; do sudo apt purge -y $pkg; done
apt autoremove --purge -y

---
exit 0
apt update
apt install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
apt full-upgrade -y
deluser lxd
delgroup lxd
groupadd docker
useradd -mru 999 -s /bin/bash -g docker docker
byobu-enable
reboot

---
exit 0
wget https://cloudron.io/cloudron-setup
chmod +x ./cloudron-setup
./cloudron-setup
byobu-enable
reboot
