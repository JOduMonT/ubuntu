./bootstrap.sh || exit
apt install -y etckeeper

curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/clean_install.sh|bash
curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/install_advantage.sh|bash
curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/secure_sshd.sh|bash

curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
