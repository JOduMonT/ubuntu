#!/usr/bin/env bash
# rclone-bisync.sh — Bidirectional synchronization between local directory and Google Drive.
# Uses rclone bisync for robust two-way sync with safety gates and error resilience.
# Compatible with systemd automation.
#
# Usage:
#   rclone-bisync.sh              # Standard scheduled sync
#   rclone-bisync.sh --resync     # Run initial synchronization/baseline setup
#   rclone-bisync.sh --dry-run    # Preview changes without modifying files

set -euo pipefail

# --- Configurations and Defaults ---
CONFIG_FILE="/etc/default/rclone-bisync"

# Source configurations if present
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
fi

# Sensible defaults (can be overridden in /etc/default/rclone-bisync)
LOCAL_DIR="${RCLONE_LOCAL_DIR:-$HOME}"
REMOTE_DIR="${RCLONE_REMOTE_DIR:-gdrive:}"
RCLONE_CONFIG_PATH="${RCLONE_CONFIG_PATH:-$HOME/.config/rclone/rclone.conf}"

# Sync configurations
CONFLICT_RESOLVE="${RCLONE_CONFLICT_RESOLVE:-newer}"
MAX_DELETE="${RCLONE_MAX_DELETE:-50}" # Abort if more than 50% of files are deleted
RCLONE_FILTER_FILE="${RCLONE_FILTER_FILE:-$HOME/.config/rclone/rclone-filters.txt}"
EXTRA_FLAGS="${RCLONE_EXTRA_FLAGS:-}"

# Check-access safety feature
# Ensures both local and remote are fully accessible before running sync
CHECK_ACCESS="${RCLONE_CHECK_ACCESS:-true}"
TEST_FILE_NAME="RCLONE_TEST"

log() {
  echo "[$(date -Iseconds)] [rclone-bisync] $*"
}

error() {
  echo "[$(date -Iseconds)] [rclone-bisync] [ERROR] $*" >&2
}

# --- Sanity Checks ---
if ! command -v rclone &>/dev/null; then
  error "rclone command not found. Please install rclone first."
  exit 1
fi

if [[ ! -f "$RCLONE_CONFIG_PATH" ]]; then
  error "Rclone config file not found at $RCLONE_CONFIG_PATH."
  error "Please run 'rclone config' to set up your Google Drive remote."
  exit 1
fi

# Ensure local directory exists
mkdir -p "$LOCAL_DIR"

# Parse arguments
MODE="sync"
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
  --resync)
    MODE="resync"
    shift
    ;;
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  *)
    error "Unknown argument: $arg"
    log "Usage: $0 [--resync] [--dry-run]"
    exit 1
    ;;
  esac
done

# --- Check-Access Setup ---
if [[ "$CHECK_ACCESS" == "true" ]]; then
  LOCAL_TEST_FILE="$LOCAL_DIR/$TEST_FILE_NAME"

  if [[ "$MODE" == "resync" ]]; then
    log "Initializing safety test files for check-access..."
    # Create test file locally
    touch "$LOCAL_TEST_FILE"
    # Create test file on remote
    rclone --config "$RCLONE_CONFIG_PATH" touch "$REMOTE_DIR/$TEST_FILE_NAME"
  else
    # Standard sync check
    if [[ ! -f "$LOCAL_TEST_FILE" ]]; then
      error "Local safety file '$LOCAL_TEST_FILE' is missing."
      error "If this is your first run, please run with the --resync flag first."
      exit 1
    fi

    # Verify remote safety file exists
    if ! rclone --config "$RCLONE_CONFIG_PATH" lsf "$REMOTE_DIR/$TEST_FILE_NAME" &>/dev/null; then
      error "Remote safety file '$TEST_FILE_NAME' is missing on $REMOTE_DIR."
      error "The remote might be unmounted, disconnected, or needs initialization via --resync."
      exit 1
    fi
  fi
fi

# --- Build Rclone Command ---
RCLONE_CMD=(
  rclone bisync
  "$LOCAL_DIR"
  "$REMOTE_DIR"
  --config "$RCLONE_CONFIG_PATH"
  --conflict-resolve "$CONFLICT_RESOLVE"
  --max-delete "$MAX_DELETE"
  --verbose
  --resilient
)

# Append check-access if enabled
if [[ "$CHECK_ACCESS" == "true" ]]; then
  RCLONE_CMD+=(--check-access)
fi

# Append filter file if configured and exists
if [[ -n "$RCLONE_FILTER_FILE" && -f "$RCLONE_FILTER_FILE" ]]; then
  RCLONE_CMD+=(--filters-file "$RCLONE_FILTER_FILE")
fi

# Append dry-run if requested
if [[ "$DRY_RUN" == "true" ]]; then
  RCLONE_CMD+=(--dry-run)
  log "Running in DRY RUN mode. No files will be modified."
fi

# Handle first run/resync mode
if [[ "$MODE" == "resync" ]]; then
  RCLONE_CMD+=(--resync)
  log "Performing initial synchronization (resync) to establish baseline..."
else
  log "Performing standard bidirectional synchronization..."
fi

# Add any additional flags configured by user
if [[ -n "$EXTRA_FLAGS" ]]; then
  # shellcheck disable=SC2206
  RCLONE_CMD+=($EXTRA_FLAGS)
fi

# --- Execution ---
log "Executing: ${RCLONE_CMD[*]}"
if "${RCLONE_CMD[@]}"; then
  log "Synchronization completed successfully."
else
  EXIT_CODE=$?
  error "Synchronization failed with exit code $EXIT_CODE."
  error "Check rclone outputs above for details."
  exit "$EXIT_CODE"
fi
