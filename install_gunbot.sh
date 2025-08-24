apt update
apt install -y curl

scripts=(install_tools.sh clean_install.sh install_nodejs.sh)
for script in "${scripts[@]}"; do curl -fsSL "https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/$script"|bash; done

packages=("unzip")
for package in "${packages[@]}"; do apt install -y "$package"; done

## Install PM2
### ensure to install nodejs before: https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/install_nodejs.sh
npm i -g pm2
pm2 install pm2-logrotate

## https://www.gunbot.com/downloads/
mkdir gunbot
cd gunbot
wget https://gunthy.org/downloads/gunthy_linux.zip
unzip gunthy_linux.zip

# monitoring
# create account: https://pm2.io
# link gunbot with it
