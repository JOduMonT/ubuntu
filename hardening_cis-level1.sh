curl -fsSL https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/install_advantage.sh|bash

pro enable usg
apt install -y usg

## ref: https://discourse.ubuntu.com/t/cis-compliance-with-usg-for-ubuntu-24-04-lts/56178/1
usg generate-tailoring cis_level1_server hardening.xml
usg audit --tailoring-file hardening.xml
usg fix --tailoring-file hardening.xml
