apt update
apt install -y curl unzip

curl -fsSL "https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/clean_install.sh|bash
curl -fsSL "https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/install_nodejs.sh|bash

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
