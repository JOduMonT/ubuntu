./bootstrap.sh || exit

# Add cloudflare gpg key
mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add this repo to your apt repositories
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | tee /etc/apt/sources.list.d/cloudflared.list

# install cloudflared
apt update
apt install -y cloudflared

# What Next ?
# 1. create a tunnel: https://one.dash.cloudflare.com/
#    - go to Network -> Tunnels
# 2. connect the tunnel
#    - sudo cloudflared service install YOUR_TOKEN
# 3. manage the access
#    - go to Access -> Applications
#    - go to Access -> Policies
