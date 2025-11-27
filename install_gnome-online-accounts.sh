# GOAL: install and run GOA in XCFE
# ref: https://askubuntu.com/questions/733061/gnome-online-accounts-goa-with-xubuntu

sudo apt install -y gnome-control-center gnome-online-accounts
env XDG_CURRENT_DESKTOP=GNOME gnome-control-center
