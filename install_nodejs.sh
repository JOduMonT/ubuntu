# https://github.com/nodesource/distributions?tab=readme-ov-file#ubuntu-versions
# choose your version
## NODE=24

curl -sL https://deb.nodesource.com/setup_24.x | bash -
apt install -y nodejs

npm install -g npm@latest

chown root:sudo /usr/bin/ /usr/lib/node_modules/
chmod 775 /usr/bin/ /usr/lib/node_modules/
