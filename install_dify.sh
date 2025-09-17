apt update
apt install -y curl jq

curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/clean_install.sh|bash
curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/install_advantage.sh|bash
curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/secure_sshd.sh|bash
curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/install_docker.sh|bash

## https://docs.dify.ai/en/getting-started/install-self-hosted/docker-compose
git clone --branch "$(curl -s https://api.github.com/repos/langgenius/dify/releases/latest | jq -r .tag_name)" https://github.com/langgenius/dify.git
