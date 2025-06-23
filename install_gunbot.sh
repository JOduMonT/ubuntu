## 
sudo apt install -y unzip

## Install PM2
### ensure to install nodejs before: https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/install_nodejs.sh
npm i -g pm2
pm2 install pm2-logrotate

## https://www.gunbot.com/downloads/
mkdir gunbot
cd gunbot
wget https://gunthy.org/downloads/gunthy_linux.zip
unzip gunthy_linux.zip
