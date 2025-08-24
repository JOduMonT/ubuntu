scripts=("install_tools.sh" "clean_install.sh")
for script in $scripts; do curl -fsSL "https://raw.githubusercontent.com/JOduMonT/ubuntu/refs/heads/main/$script"|bash; done
curl -fsSL https://cloudron.io/cloudron-setup|bash
