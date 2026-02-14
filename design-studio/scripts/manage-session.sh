#!/usr/bin/env bash
# manage-session.sh — Session lifecycle management
# Usage:
#   bash manage-session.sh create                    # Create new session directory
#   bash manage-session.sh pick <session> <variant>  # Pick a variant, archive rejects

set -euo pipefail

PROJECT_ROOT="${PWD}"
DESIGN_DIR="${PROJECT_ROOT}/.design"
SESSIONS_DIR="${DESIGN_DIR}/sessions"

# ── Helpers ──
get_date() {
  date -u +"%Y-%m-%d"
}

get_timestamp() {
  if command -v python3 &>/dev/null; then
    python3 -c "from datetime import datetime, timezone; print(datetime.now(timezone.utc).isoformat())"
  else
    date -u +"%Y-%m-%dT%H:%M:%SZ"
  fi
}

# ── Create subcommand ──
cmd_create() {
  local today
  today=$(get_date)

  # Find next sequence number for today
  local seq=1
  while [[ -d "${SESSIONS_DIR}/${today}-$(printf '%03d' $seq)" ]]; do
    seq=$((seq + 1))
  done

  local session_id="${today}-$(printf '%03d' $seq)"
  local session_dir="${SESSIONS_DIR}/${session_id}"

  mkdir -p "$session_dir"
  echo "$session_id"
}

# ── Pick subcommand ──
cmd_pick() {
  local session_id="${1:-}"
  local variant="${2:-}"

  if [[ -z "$session_id" || -z "$variant" ]]; then
    echo "Error: Usage: manage-session.sh pick <session-id> <variant-letter>" >&2
    exit 1
  fi

  local session_dir="${SESSIONS_DIR}/${session_id}"

  if [[ ! -d "$session_dir" ]]; then
    echo "Error: Session '${session_id}' not found at ${session_dir}" >&2
    exit 1
  fi

  local chosen_file="variant-${variant}.html"
  if [[ ! -f "${session_dir}/${chosen_file}" ]]; then
    echo "Error: Variant '${variant}' not found (expected ${session_dir}/${chosen_file})" >&2
    exit 1
  fi

  # Create rejected directory
  mkdir -p "${session_dir}/rejected"

  # Move non-chosen variants to rejected/
  for f in "${session_dir}"/variant-*.html; do
    local basename
    basename=$(basename "$f")
    if [[ "$basename" != "$chosen_file" ]]; then
      mv "$f" "${session_dir}/rejected/"
    fi
  done

  # Copy chosen variant to chosen.html
  cp "${session_dir}/${chosen_file}" "${session_dir}/chosen.html"

  # Update manifest.json with pick metadata
  if [[ -f "${session_dir}/manifest.json" ]] && command -v python3 &>/dev/null; then
    python3 -c "
import json, sys
with open('${session_dir}/manifest.json', 'r') as f:
    manifest = json.load(f)
manifest['picked_variant'] = '${variant}'
manifest['picked_at'] = '$(get_timestamp)'
with open('${session_dir}/manifest.json', 'w') as f:
    json.dump(manifest, f, indent=2)
" 2>/dev/null || true
  fi

  echo "Variant ${variant} picked for session ${session_id}"
  echo "  Chosen: ${session_dir}/chosen.html"
  echo "  Rejected variants moved to: ${session_dir}/rejected/"
}

# ── Main dispatch ──
case "${1:-}" in
  create)
    cmd_create
    ;;
  pick)
    cmd_pick "${2:-}" "${3:-}"
    ;;
  *)
    echo "Usage: manage-session.sh {create|pick}" >&2
    echo "  create                     — Create a new session directory" >&2
    echo "  pick <session> <variant>   — Pick a variant, archive rejects" >&2
    exit 1
    ;;
esac
