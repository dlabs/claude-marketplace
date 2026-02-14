#!/usr/bin/env bash
# init-workspace.sh — Initialize or check the .design/ workspace
# Usage:
#   bash init-workspace.sh              # Create workspace + prompt for gitignore
#   bash init-workspace.sh --check-only # Report workspace status (for SessionStart hook)

set -euo pipefail

PROJECT_ROOT="${PWD}"
DESIGN_DIR="${PROJECT_ROOT}/.design"
CONFIG_FILE="${DESIGN_DIR}/config.json"
SESSIONS_DIR="${DESIGN_DIR}/sessions"
TOKENS_FILE="${DESIGN_DIR}/tokens.json"
GITIGNORE="${PROJECT_ROOT}/.gitignore"

# ── Check-only mode (SessionStart hook) ──
if [[ "${1:-}" == "--check-only" ]]; then
  if [[ ! -d "$DESIGN_DIR" ]]; then
    echo "[design-studio] No workspace found. Run /design-studio:ds:design-init to set up."
    exit 0
  fi

  # Count sessions
  SESSION_COUNT=0
  if [[ -d "$SESSIONS_DIR" ]]; then
    SESSION_COUNT=$(find "$SESSIONS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  fi

  # Check tokens
  TOKENS_STATUS="none"
  if [[ -f "$TOKENS_FILE" ]]; then
    if command -v python3 &>/dev/null; then
      LOCKED=$(python3 -c "import json; print(json.load(open('$TOKENS_FILE')).get('locked', False))" 2>/dev/null || echo "false")
    else
      LOCKED=$(grep -o '"locked":\s*true' "$TOKENS_FILE" 2>/dev/null && echo "true" || echo "false")
    fi
    if [[ "$LOCKED" == "True" || "$LOCKED" == "true" ]]; then
      TOKENS_STATUS="locked"
    else
      TOKENS_STATUS="unlocked"
    fi
  fi

  # Check brand
  BRAND_FILE="${DESIGN_DIR}/brand.json"
  BRAND_STATUS="none"
  if [[ -f "$BRAND_FILE" ]]; then
    if command -v python3 &>/dev/null; then
      BRAND_NAME=$(python3 -c "import json; print(json.load(open('$BRAND_FILE')).get('identity', {}).get('name', 'defined'))" 2>/dev/null || echo "defined")
    else
      BRAND_NAME="defined"
    fi
    BRAND_STATUS="defined (${BRAND_NAME})"
  fi

  # Find latest session
  LATEST=""
  if [[ -d "$SESSIONS_DIR" ]]; then
    LATEST=$(ls -1 "$SESSIONS_DIR" 2>/dev/null | sort -r | head -1)
  fi

  # Check if latest session has a chosen variant
  PHASE="ready"
  if [[ -n "$LATEST" ]]; then
    if [[ -f "${SESSIONS_DIR}/${LATEST}/chosen.html" ]]; then
      PHASE="picked (${LATEST})"
    elif [[ -f "${SESSIONS_DIR}/${LATEST}/manifest.json" ]]; then
      PHASE="exploring (${LATEST})"
    fi
  fi

  echo "[design-studio] Workspace: ${SESSION_COUNT} sessions, tokens: ${TOKENS_STATUS}, brand: ${BRAND_STATUS}, status: ${PHASE}."
  exit 0
fi

# ── Full initialization mode ──
echo "Initializing design-studio workspace..."

# Create directories
mkdir -p "$SESSIONS_DIR"

# Create config if it doesn't exist
if [[ ! -f "$CONFIG_FILE" ]]; then
  cat > "$CONFIG_FILE" << 'CONFIGEOF'
{
  "version": "0.1.0",
  "gitignore_mode": "all",
  "created_at": "TIMESTAMP"
}
CONFIGEOF
  # Replace timestamp
  if command -v python3 &>/dev/null; then
    TIMESTAMP=$(python3 -c "from datetime import datetime, timezone; print(datetime.now(timezone.utc).isoformat())")
  else
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  fi
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/TIMESTAMP/$TIMESTAMP/" "$CONFIG_FILE"
  else
    sed -i "s/TIMESTAMP/$TIMESTAMP/" "$CONFIG_FILE"
  fi
fi

# Create DESIGN_NOTES.md if it doesn't exist
if [[ ! -f "${DESIGN_DIR}/DESIGN_NOTES.md" ]]; then
  cat > "${DESIGN_DIR}/DESIGN_NOTES.md" << 'NOTESEOF'
# Design Notes

Auto-generated log of design decisions made through design-studio.

---

NOTESEOF
fi

echo "Workspace initialized at .design/"
echo "  Sessions directory: .design/sessions/"
echo "  Config: .design/config.json"
echo ""
echo "Next: Configure gitignore with /design-studio:ds:design-init"
