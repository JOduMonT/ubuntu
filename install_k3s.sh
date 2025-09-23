apt update
apt install -y curl

curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/clean_install.sh|bash
curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/install_advantage.sh|bash
curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/secure_sshd.sh|bash

curl -sfL https://get.k3s.io | sh -
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
