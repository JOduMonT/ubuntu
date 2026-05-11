# ref: https://wiki.archlinux.org/title/Etckeeper#Automatic_push_to_remote_repo
# Pushing your etckeeper repository to a publicly accessible remote repository can expose sensitive data such as password hashes or private keys. Proceed with caution.
apt update
apt install -y etckeeper
sed -i 's/^PUSH_REMOTE=""/PUSH_REMOTE="origin"/g' /etc/etckeeper/etckeeper.conf

exit 0

REPO="" # Use a Private Repo
USERNAME="" # Your GitHub username
TOKEN="" # [Use a Classic Token as Password](https://github.com/settings/tokens)

etckeeper vcs remote add origin https://${USERNAME}:${TOKEN}@github.com/${USERNAME}/${REPO}.git
