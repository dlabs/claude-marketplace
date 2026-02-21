#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════
# Scenario Testing — Initialize Catalog
# ═══════════════════════════════════════════════════════
#
# Creates the .scenarios/ directory structure and
# initial configuration files.
#
# Usage: bash init-catalog.sh [--storage holdout|in-repo]

set -euo pipefail

STORAGE="${1:-holdout}"
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
SCENARIOS_DIR="${PROJECT_ROOT}/.scenarios"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# ── Check for existing catalog ───────────────────────
if [ -d "$SCENARIOS_DIR" ]; then
  echo "[scenario-testing] Catalog already exists at ${SCENARIOS_DIR}"
  echo "Use --force to reinitialize (destructive)."
  exit 1
fi

# ── Create directory structure ───────────────────────
echo "[scenario-testing] Initializing scenario catalog..."

mkdir -p "${SCENARIOS_DIR}/catalog"
mkdir -p "${SCENARIOS_DIR}/twins"
mkdir -p "${SCENARIOS_DIR}/runs"
mkdir -p "${SCENARIOS_DIR}/reports/history"

# ── Write config.json ────────────────────────────────
cat > "${SCENARIOS_DIR}/config.json" << EOF
{
  "\$schema": "scenario-config",
  "version": 1,
  "storage": "${STORAGE}",
  "thresholds": {
    "global_minimum": 0.80,
    "domains": {},
    "scenarios": {}
  },
  "defaults": {
    "trajectories_per_scenario": 50,
    "judge_model": "opus",
    "judge_temperature": 0.0,
    "chaos_profile": "gentle"
  },
  "judge_overrides": {},
  "twin_port_start": 9001,
  "report_format": "terminal"
}
EOF

# ── Write catalog.json ───────────────────────────────
cat > "${SCENARIOS_DIR}/catalog.json" << EOF
{
  "\$schema": "catalog",
  "version": 1,
  "updated_at": "${TIMESTAMP}",
  "domains": {},
  "twins": [],
  "stats": {
    "total_scenarios": 0,
    "total_twins": 0,
    "total_domains": 0,
    "last_run": null,
    "last_satisfaction": null
  }
}
EOF

# ── Configure gitignore ──────────────────────────────
if [ "$STORAGE" = "holdout" ]; then
  GITIGNORE="${PROJECT_ROOT}/.gitignore"
  if [ -f "$GITIGNORE" ]; then
    # Check if .scenarios/ is already in gitignore
    if ! grep -qF ".scenarios/" "$GITIGNORE" 2>/dev/null; then
      echo "" >> "$GITIGNORE"
      echo "# Scenario testing catalog (holdout — not committed)" >> "$GITIGNORE"
      echo ".scenarios/" >> "$GITIGNORE"
      echo "[scenario-testing] Added .scenarios/ to .gitignore (holdout mode)"
    fi
  else
    echo "# Scenario testing catalog (holdout — not committed)" > "$GITIGNORE"
    echo ".scenarios/" >> "$GITIGNORE"
    echo "[scenario-testing] Created .gitignore with .scenarios/ (holdout mode)"
  fi
else
  echo "[scenario-testing] In-repo mode — .scenarios/ will be committed"
fi

# ── Done ─────────────────────────────────────────────
echo "[scenario-testing] Catalog initialized at ${SCENARIOS_DIR}"
echo ""
echo "Next steps:"
echo "  /scenario-testing:st:scenario \"your first user story\"   — Author a scenario"
echo "  /scenario-testing:st:twin \"service-name\"                 — Build a digital twin"
echo "  /scenario-testing:st:catalog                              — View the catalog"
