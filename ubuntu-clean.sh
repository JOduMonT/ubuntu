apt list --installed > installed.1st
for pkg in aspell* bolt btrfs* containerd cryptsetup* dmeventd dmidecode dmsetup docker.io docker-doc docker-compose docker-compose-v2 fonts* lvm2 lxd* mdadm nftables* ntfs* open-iscsi overlayroot podman-docker runc snap* sg3-utils* telnet thin-provisioning* tnftp usb-* wamerican wireless* xfsprogs; do sudo apt purge -y $pkg; done
apt autoremove --purge -y
byobu-enable
reboot
