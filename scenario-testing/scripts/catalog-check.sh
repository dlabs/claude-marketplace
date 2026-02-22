#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════
# Scenario Testing — Catalog Check (SessionStart Hook)
# ═══════════════════════════════════════════════════════
#
# Runs on session start. Checks for a scenario catalog
# and reports its status. Fast — completes in <2 seconds.

set -euo pipefail

# Find the project root (git root or current directory)
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
SCENARIOS_DIR="${PROJECT_ROOT}/.scenarios"
CATALOG_FILE="${SCENARIOS_DIR}/catalog.json"
REPORTS_DIR="${SCENARIOS_DIR}/reports"

# ── No catalog found ─────────────────────────────────
if [ ! -f "$CATALOG_FILE" ]; then
  echo "[scenario-testing] No scenario catalog found. Run /scenario-testing:st:init to create one."
  exit 0
fi

# ── Parse catalog stats ──────────────────────────────
# Use lightweight parsing — no jq dependency required
TOTAL_SCENARIOS=0
TOTAL_TWINS=0
TOTAL_DOMAINS=0
LAST_SATISFACTION=""

# Count scenarios by searching for .scenario.yaml files
if [ -d "${SCENARIOS_DIR}/catalog" ]; then
  TOTAL_SCENARIOS=$(find "${SCENARIOS_DIR}/catalog" -name "*.scenario.yaml" 2>/dev/null | wc -l | tr -d ' ')
fi

# Count domains by listing directories in catalog/
if [ -d "${SCENARIOS_DIR}/catalog" ]; then
  TOTAL_DOMAINS=$(find "${SCENARIOS_DIR}/catalog" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
fi

# Count twins by listing directories in twins/
if [ -d "${SCENARIOS_DIR}/twins" ]; then
  TOTAL_TWINS=$(find "${SCENARIOS_DIR}/twins" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
fi

# Check for latest satisfaction report
if [ -f "${REPORTS_DIR}/latest.json" ]; then
  # Extract overall satisfaction with grep (no jq needed)
  LAST_SATISFACTION=$(grep -o '"overall_satisfaction":[^,}]*' "${REPORTS_DIR}/latest.json" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' ')
  LAST_DATE=$(grep -o '"generated_at":"[^"]*"' "${REPORTS_DIR}/latest.json" 2>/dev/null | head -1 | cut -d'"' -f4 | cut -dT -f1)
fi

# ── Report status ────────────────────────────────────
if [ -n "$LAST_SATISFACTION" ] && [ -n "$LAST_DATE" ]; then
  echo "[scenario-testing] Scenario catalog: ${TOTAL_SCENARIOS} scenarios across ${TOTAL_DOMAINS} domains, ${TOTAL_TWINS} twins configured."
  echo "Last satisfaction run: ${LAST_DATE} — overall satisfaction: ${LAST_SATISFACTION}"
  echo "Run /scenario-testing:st:report for details."
else
  echo "[scenario-testing] Scenario catalog: ${TOTAL_SCENARIOS} scenarios across ${TOTAL_DOMAINS} domains, ${TOTAL_TWINS} twins configured."
  echo "No satisfaction data yet. Run /scenario-testing:st:validate to measure satisfaction."
fi
