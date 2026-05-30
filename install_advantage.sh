#!/usr/bin/env bash
# Ubuntu Pro setup — ESM + Livepatch (+ optional FIPS / USG hardening)
# ref: https://ubuntu.com/pro/tutorial
# ref: https://ubuntu.com/pro/dashboard
#
# Run as root. Re-run safe — checks state before acting.

set -euo pipefail

# ── Helpers ───────────────────────────────────────────────────────────────────
info() { echo "  ✓ $*"; }
warn() { echo "  ! $*"; }
section() {
  echo ""
  echo "── $* ──────────────────────────────────────────────"
}

# ── 1. Install / update ubuntu-advantage-tools ────────────────────────────────
section "1. ubuntu-advantage-tools"
apt-get update -qq
apt-get install -y ubuntu-advantage-tools
PRO_VERSION=$(pro version 2>/dev/null || echo "unknown")
info "pro version: ${PRO_VERSION}"

# ── 2. Attach to Ubuntu Pro ───────────────────────────────────────────────────
section "2. Pro attach"
if pro status 2>/dev/null | grep -q "^Account:"; then
  info "Already attached — skipping"
  pro status
else
  # Get token from dashboard: https://ubuntu.com/pro/dashboard
  read -rsp "Ubuntu Pro token (input hidden): " PRO_TOKEN
  echo ""
  pro attach "${PRO_TOKEN}"
  unset PRO_TOKEN
  info "Attached successfully"
fi

# ── 3. dist-upgrade NOW (ESM repos are active, so patches are complete) ───────
section "3. Full upgrade with ESM repos active"
apt-get dist-upgrade -y
info "Upgrade complete"

# ── 4. Enable core Pro services ───────────────────────────────────────────────
section "4. Core services"

enable_if_not() {
  local service="$1"
  if pro status --format json | python3 -c "
import sys, json
s = json.load(sys.stdin)
svcs = {x['name']: x['status'] for x in s.get('services', [])}
sys.exit(0 if svcs.get('${service}') == 'enabled' else 1)
" 2>/dev/null; then
    info "${service} already enabled"
  else
    pro enable "${service}" --assume-yes && info "${service} enabled" ||
      warn "${service} failed to enable — check: pro status"
  fi
}

enable_if_not esm-infra # ESM for Ubuntu base packages
enable_if_not esm-apps  # ESM for Ubuntu universe packages
enable_if_not livepatch # Kernel live patching (no reboot for kernel CVEs)

# ── 5. Optional: FIPS + USG hardening ────────────────────────────────────────
section "5. Optional hardening"
echo "  FIPS:  cryptographic module certification (requires reboot, changes kernel)"
echo "  USG:   Ubuntu Security Guide / CIS / DISA-STIG hardening"
echo "  ref:   https://ubuntu.com/tutorials/using-the-ubuntu-pro-client-to-enable-fips"
echo ""
read -rp "Enable FIPS updates? [y/N] " ENABLE_FIPS
read -rp "Enable USG (CIS hardening)? [y/N] " ENABLE_USG

if [[ "${ENABLE_FIPS,,}" == "y" ]]; then
  enable_if_not fips-updates
  warn "FIPS enabled — a reboot is required to activate the FIPS kernel"
else
  info "FIPS skipped"
fi

if [[ "${ENABLE_USG,,}" == "y" ]]; then
  enable_if_not usg
  info "USG enabled — run 'sudo usg fix cis_level1_server' to apply a profile"
else
  info "USG skipped"
fi

# ── 6. Summary ────────────────────────────────────────────────────────────────
section "6. Final status"
pro status

echo ""
info "Done. Dashboard: https://ubuntu.com/pro/dashboard"
if [[ "${ENABLE_FIPS,,}" == "y" ]]; then
  warn "Reboot required to activate FIPS kernel"
fi

# Post-install assertion (best-effort — non-fatal if verify.sh is absent)
if [[ -x ./verify.sh ]]; then
  ./verify.sh pro "pro version" || true
fi
