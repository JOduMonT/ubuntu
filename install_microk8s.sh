apt update
apt install -y curl

curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/clean_install.sh|bash
curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/install_advantage.sh|bash
curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/secure_sshd.sh|bash
apt install -y snapd

# ADD USER
USER=k8s
curl -fsSL "https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/add_superuser.sh"|bash

sudo -nu $USER sudo snap install microk8s --classic
usermod -aG microk8s $USER
sudo -nu $USER microk8s status
