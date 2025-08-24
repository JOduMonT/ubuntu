apt list --installed > installed.1st

apt update

packages=(curl etckeeper sudo)
for package in "${packages[@]}"; do apt install -y "$package"; done
