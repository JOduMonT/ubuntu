#!/usr/bin/env bash
# verify.sh — tiny post-install assertion helper.
#
# Usage:   verify.sh <tool-label> <command-to-run-and-check>
# Exits:   0 if the command succeeds, 1 if it fails or is missing.
#
# Examples:
#   ./verify.sh node     "node --version"
#   ./verify.sh sshd     "sshd -t"
#   ./verify.sh etckeep  "etckeeper vcs status"
#
# Designed to be cheap to call from the tail of any installer. Keep the
# command short and side-effect-free.

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "[verify] usage: verify.sh <tool-label> <command>" >&2
  exit 1
fi

label="$1"
shift
cmd="$*"

if output=$(bash -c "$cmd" 2>&1); then
  echo "[verify] OK   $label  → $cmd"
  return 0 2>/dev/null || exit 0
fi

echo "[verify] FAIL $label  → $cmd" >&2
echo "$output" | sed 's/^/[verify]   /' >&2
exit 1
