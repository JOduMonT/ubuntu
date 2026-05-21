#!/usr/bin/env bash
set -euo pipefail

sudo apt install -y ffmpeg pipx
pipx install openai-whisper
