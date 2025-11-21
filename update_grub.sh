sudo cp /etc/default/grub /etc/default/grub.backup
sudo sed -i 's/^GRUB_CMDLINE_LINUX="\(.*\)"$/GRUB_CMDLINE_LINUX="\1 apparmor=1 security=apparmor cgroup_enable=memory swapaccount=1"/' /etc/default/grub
sudo update-grub
