apt update
apt install -y curl

curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/clean_install.sh|bash
curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/install_advantage.sh|bash
curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/secure_sshd.sh|bash

sudo snap install microk8s --classic

# ADD USER Docker
USER=rescue
curl -fsSL "https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/add_superuser.sh"|bash
