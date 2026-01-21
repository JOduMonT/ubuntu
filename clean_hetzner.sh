curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/clean_install.sh|bash
packages=(eatmydata ed fuse3 groff-base hc-utils hdparm htop ibverbs-providers inetutils-telnet lshw numactl pastebinit powermgmt-base psmisc rsync run-one secureboot-db sosreport tcpdump tpm-udev trace-cmd ubuntu-pro* unminimize vim-* xxd zerofree)
for package in "${packages[@]}"; do apt purge -y "$package"; done
apt autoremove --purge -y
