# ref: https://wiki.archlinux.org/title/Etckeeper#Automatic_push_to_remote_repo
# Pushing your etckeeper repository to a publicly accessible remote repository can expose sensitive data such as password hashes or private keys. Proceed with caution.
apt update
apt install -y etckeeper
sed -i 's/^PUSH_REMOTE=""/PUSH_REMOTE="origin"/g' /etc/etckeeper/etckeeper.conf

exit 0

REPO="" # Use a Private Repo
USERNAME="" # Your GitHub username
PASSWORD="" # [Use a Classic Token as Password](https://github.com/settings/tokens)

cd /etc
git commit -m "left over before etckeeper"
git branch -M main
git remote add origin https://github.com/${USERNAME}/${REPO}.git
git push -u origin main
