# ref: https://wiki.archlinux.org/title/Etckeeper#Automatic_push_to_remote_repo
# Pushing your etckeeper repository to a publicly accessible remote repository can expose sensitive data such as password hashes or private keys. Proceed with caution.
REPO="" # Use a Private Repo
USERNAME="" # Your GitHub username
PASSWORD="" # [Use a Classic Token as Password](https://github.com/settings/tokens)

apt update
apt install -y etckeeper
sed -i 's/^PUSH_REMOTE=""/PUSH_REMOTE="origin"/g' /etc/etckeeper/etckeeper.conf

exit 0

cd /etc
git remote add origin ${REPO}
git branch -M main
git push -u origin main
