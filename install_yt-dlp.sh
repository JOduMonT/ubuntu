#!/usr/bin/env bash
set -euo pipefail

## https://github.com/yt-dlp/yt-dlp/wiki/Installation
sudo add-apt-repository -y ppa:tomtomtom/yt-dlp # Add ppa repo to apt
sudo apt update                                 # Update package list
sudo apt install -y yt-dlp                      # Install yt-dlp
