apt list --installed > installed.1st

apt update

packages=(etckeeper sudo)
for package in "${packages[@]}"; do apt install -y "$package"; done
