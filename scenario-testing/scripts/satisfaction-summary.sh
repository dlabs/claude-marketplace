#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════
# Scenario Testing — Satisfaction Summary
# ═══════════════════════════════════════════════════════
#
# Generates a quick satisfaction summary from the latest
# report. Used for terminal display and CI integration.
#
# Usage: bash satisfaction-summary.sh [--format terminal|json|ci]
#
# Exit codes:
#   0 — all thresholds pass
#   1 — at least one threshold fails

set -euo pipefail

FORMAT="${1:-terminal}"
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
SCENARIOS_DIR="${PROJECT_ROOT}/.scenarios"
REPORT_FILE="${SCENARIOS_DIR}/reports/latest.json"

# ── Check for report ─────────────────────────────────
if [ ! -f "$REPORT_FILE" ]; then
  echo "[scenario-testing] No satisfaction report found."
  echo "Run /scenario-testing:st:validate to generate one."
  exit 0
fi

# ── Parse report (lightweight, no jq) ────────────────
OVERALL=$(grep -o '"satisfaction":[0-9.]*' "$REPORT_FILE" | head -1 | cut -d: -f2)
TOTAL=$(grep -o '"total_trajectories":[0-9]*' "$REPORT_FILE" | head -1 | cut -d: -f2)
SATISFACTORY=$(grep -o '"satisfactory_trajectories":[0-9]*' "$REPORT_FILE" 2>/dev/null | head -1 | cut -d: -f2 || echo "?")
PASS=$(grep -o '"pass":[a-z]*' "$REPORT_FILE" | head -1 | cut -d: -f2)
DATE=$(grep -o '"generated_at":"[^"]*"' "$REPORT_FILE" | head -1 | cut -d'"' -f4 | cut -dT -f1)

# ── Output based on format ───────────────────────────
case "$FORMAT" in
  terminal)
    echo "═══════════════════════════════════════════════"
    echo "  SATISFACTION SUMMARY — ${DATE}"
    echo "═══════════════════════════════════════════════"
    echo ""
    if [ "$PASS" = "true" ]; then
      echo "  Overall: ${OVERALL} (${SATISFACTORY}/${TOTAL} trajectories)  [PASS]"
    else
      echo "  Overall: ${OVERALL} (${SATISFACTORY}/${TOTAL} trajectories)  [FAIL]"
    fi
    echo ""
    echo "  For full report: /scenario-testing:st:report"
    echo "═══════════════════════════════════════════════"
    ;;

  json)
    # Output raw report
    cat "$REPORT_FILE"
    ;;

  ci)
    # Simple one-line output for CI
    if [ "$PASS" = "true" ]; then
      echo "PASS satisfaction=${OVERALL} trajectories=${TOTAL}"
      exit 0
    else
      echo "FAIL satisfaction=${OVERALL} trajectories=${TOTAL}"
      exit 1
    fi
    ;;

  *)
    echo "Unknown format: ${FORMAT}"
    echo "Usage: satisfaction-summary.sh [--format terminal|json|ci]"
    exit 1
    ;;
esac

# ── Exit code ────────────────────────────────────────
if [ "$PASS" = "true" ]; then
  exit 0
else
  exit 1
fi
