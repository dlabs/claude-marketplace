#!/usr/bin/env bash
# manage-screen-designs.sh — Screen design draft lifecycle management
# Usage:
#   bash manage-screen-designs.sh create <section-id> <screen-name>   # Create drafts directory
#   bash manage-screen-designs.sh pick <section-id> <screen-name> <variant>  # Pick variant, archive rejects

set -euo pipefail

PROJECT_ROOT="${PWD}"
DESIGN_DIR="${PROJECT_ROOT}/.design"
SECTIONS_DIR="${DESIGN_DIR}/product/sections"

# ── Helpers ──
get_timestamp() {
  if command -v python3 &>/dev/null; then
    python3 -c "from datetime import datetime, timezone; print(datetime.now(timezone.utc).isoformat())"
  else
    date -u +"%Y-%m-%dT%H:%M:%SZ"
  fi
}

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

validate_section() {
  local section_id="$1"
  local section_dir="${SECTIONS_DIR}/${section_id}"

  if [[ ! -d "$section_dir" ]]; then
    echo "Error: Section '${section_id}' not found at ${section_dir}" >&2
    exit 1
  fi

  if [[ ! -f "${section_dir}/spec.md" ]]; then
    echo "Error: Section '${section_id}' has no spec.md — run ds:section create first" >&2
    exit 1
  fi
}

# ── Create subcommand ──
cmd_create() {
  local section_id="${1:-}"
  local screen_name="${2:-}"

  if [[ -z "$section_id" || -z "$screen_name" ]]; then
    echo "Error: Usage: manage-screen-designs.sh create <section-id> <screen-name>" >&2
    exit 1
  fi

  validate_section "$section_id"

  local screen_slug
  screen_slug=$(slugify "$screen_name")

  local drafts_dir="${SECTIONS_DIR}/${section_id}/screen-designs/.drafts/${screen_slug}"

  mkdir -p "$drafts_dir"
  echo "$drafts_dir"
}

# ── Pick subcommand ──
cmd_pick() {
  local section_id="${1:-}"
  local screen_name="${2:-}"
  local variant="${3:-}"

  if [[ -z "$section_id" || -z "$screen_name" || -z "$variant" ]]; then
    echo "Error: Usage: manage-screen-designs.sh pick <section-id> <screen-name> <variant-letter>" >&2
    exit 1
  fi

  validate_section "$section_id"

  local screen_slug
  screen_slug=$(slugify "$screen_name")

  local section_dir="${SECTIONS_DIR}/${section_id}"
  local drafts_dir="${section_dir}/screen-designs/.drafts/${screen_slug}"
  local screen_designs_dir="${section_dir}/screen-designs"

  if [[ ! -d "$drafts_dir" ]]; then
    echo "Error: No drafts found for screen '${screen_slug}' in section '${section_id}'" >&2
    echo "  Expected: ${drafts_dir}" >&2
    exit 1
  fi

  local chosen_file="variant-${variant}.html"
  if [[ ! -f "${drafts_dir}/${chosen_file}" ]]; then
    echo "Error: Variant '${variant}' not found (expected ${drafts_dir}/${chosen_file})" >&2
    exit 1
  fi

  # Create rejected directory
  mkdir -p "${drafts_dir}/rejected"

  # Move non-chosen variants to rejected/
  for f in "${drafts_dir}"/variant-*.html; do
    local basename
    basename=$(basename "$f")
    if [[ "$basename" != "$chosen_file" ]]; then
      mv "$f" "${drafts_dir}/rejected/"
    fi
  done

  # Copy chosen variant to chosen.html in drafts (for reference)
  cp "${drafts_dir}/${chosen_file}" "${drafts_dir}/chosen.html"

  # Copy chosen variant to screen-designs/{screen-name}.html (the canonical location)
  cp "${drafts_dir}/${chosen_file}" "${screen_designs_dir}/${screen_slug}.html"

  # Update manifest.json with pick metadata
  if [[ -f "${drafts_dir}/manifest.json" ]] && command -v python3 &>/dev/null; then
    python3 -c "
import json
with open('${drafts_dir}/manifest.json', 'r') as f:
    manifest = json.load(f)
manifest['picked_variant'] = '${variant}'
manifest['picked_at'] = '$(get_timestamp)'
with open('${drafts_dir}/manifest.json', 'w') as f:
    json.dump(manifest, f, indent=2)
" 2>/dev/null || true
  fi

  echo "Variant ${variant} picked for ${section_id}/${screen_slug}"
  echo "  Screen design: ${screen_designs_dir}/${screen_slug}.html"
  echo "  Chosen copy: ${drafts_dir}/chosen.html"
  echo "  Rejected variants moved to: ${drafts_dir}/rejected/"
}

# ── Main dispatch ──
case "${1:-}" in
  create)
    cmd_create "${2:-}" "${3:-}"
    ;;
  pick)
    cmd_pick "${2:-}" "${3:-}" "${4:-}"
    ;;
  *)
    echo "Usage: manage-screen-designs.sh {create|pick}" >&2
    echo "  create <section-id> <screen-name>           — Create drafts directory for a screen" >&2
    echo "  pick <section-id> <screen-name> <variant>   — Pick a variant, archive rejects" >&2
    exit 1
    ;;
esac
