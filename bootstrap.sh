#!/usr/bin/env bash
# bootstrap.sh — idempotent baseline that every installer in this repo
# can safely invoke at the top to make the box ready for an install pass.
#
# Side effects only. Sources nothing into the caller's env.
#
# What it does, in order:
#   1. apt update (so subsequent installs see fresh package lists)
#   2. apt install -y curl ca-certificates  (the universal pre-reqs)
#
# Why so small: anything beyond curl/ca-certificates is installer-specific
# (jq for dify, unzip for gunbot, etckeeper for coolify, ...). Adding them
# here would defeat the "one job per script" doctrine.
#
# Usage:   ./bootstrap.sh || exit
# Re-run safe: apt is idempotent and curl/ca-certificates won't reinstall
# if already present at the requested version.

set -euo pipefail

log() { echo "[bootstrap] $*"; }

log "apt update"
apt-get update -qq

log "ensuring curl + ca-certificates"
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl ca-certificates >/dev/null

log "ready"
