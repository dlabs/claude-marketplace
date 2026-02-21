---
name: st:report
description: Display the satisfaction report — per-scenario scores, threshold status, trend analysis, and comparison to previous runs
argument-hint: (optional flags for comparison, trends, format)
---

# /scenario-testing:st:report

Display the satisfaction report.

## Usage

```
/scenario-testing:st:report                           # Latest report
/scenario-testing:st:report --compare-to 2026-02-15   # Compare to a previous run date
/scenario-testing:st:report --trend --days 30          # Show 30-day trend
/scenario-testing:st:report --format json              # JSON output for CI
/scenario-testing:st:report --domain auth              # Filter to one domain
```

## Workflow

### Step 1: Load Report Data
- Read `.scenarios/reports/latest.json`
- If `--compare-to` is specified, also read the historical report for that date
- If `--trend` is specified, read all reports from `.scenarios/reports/history/`

### Step 2: Format Output

#### Default (Terminal)

```
═══════════════════════════════════════════════════════
  SATISFACTION REPORT — 2026-02-20
  Run: 2026-02-20-001
═══════════════════════════════════════════════════════

  Overall: 0.91 (1365/1500 trajectories)     [PASS]

  Domain           Satisfaction  Threshold  Status
  ───────────────  ────────────  ─────────  ──────
  auth             0.96          0.95       PASS
  onboarding       0.87          0.75       PASS
  integrations     0.88          0.85       PASS
  payments         0.93          0.98       FAIL ▼

  ─── Failing Scenarios ────────────────────────────

  payments/checkout-flow     0.93 (target: 0.98)
    7 unsatisfactory trajectories:
    • Timeout during payment confirmation not communicated to user
    • No retry UI shown after transient failure

  ─── Top Improvements ─────────────────────────────

  auth/password-reset        0.95 → (was 0.90 on 2026-02-15)

═══════════════════════════════════════════════════════
```

#### Comparison Mode (`--compare-to`)

```
═══════════════════════════════════════════════════════
  COMPARISON: 2026-02-20 vs 2026-02-15
═══════════════════════════════════════════════════════

  Overall: 0.91 → was 0.89 (+0.02)

  Scenario              Current  Previous  Delta
  ────────────────────  ───────  ────────  ─────
  sso-login             0.96     0.97      -0.01
  password-reset        0.95     0.90      +0.05  ▲
  mfa-enrollment        0.94     0.95      -0.01
  slack-to-jira         0.86     0.82      +0.04  ▲
  checkout-flow         0.93     0.94      -0.01

  Improvements: 2    Regressions: 0    Stable: 3

═══════════════════════════════════════════════════════
```

#### Trend Mode (`--trend --days N`)

```
═══════════════════════════════════════════════════════
  30-DAY SATISFACTION TREND
═══════════════════════════════════════════════════════

  Date       │ Auth  │ Onboard │ Integr. │ Overall
  ───────────┼───────┼─────────┼─────────┼────────
  2026-01-22 │ 0.92  │ 0.81    │ 0.88    │ 0.87
  2026-01-29 │ 0.94  │ 0.83    │ 0.89    │ 0.89
  2026-02-05 │ 0.94  │ 0.87    │ 0.91    │ 0.91
  2026-02-12 │ 0.95  │ 0.88    │ 0.85 ▼  │ 0.89
  2026-02-19 │ 0.96  │ 0.90    │ 0.92    │ 0.93

  Alerts:
    ⚠ Integrations dipped on 2026-02-12
    ✓ All domains currently above thresholds

═══════════════════════════════════════════════════════
```

#### JSON Mode (`--format json`)

Output the raw JSON report from `.scenarios/reports/latest.json` — suitable for CI parsing.

## Options

| Flag | Description |
|------|-------------|
| `--compare-to DATE` | Compare current run to a specific date's run |
| `--trend` | Show satisfaction trend over time |
| `--days N` | How many days of trend to show (default: 30) |
| `--format {terminal\|json}` | Output format |
| `--domain NAME` | Filter to one domain |
| `--output PATH` | Write report to file (for CI) |

## Notes

- If no runs have been judged yet, suggest running `/scenario-testing:st:run` and `/scenario-testing:st:satisfy`
- Reports are generated from judgment data — they don't re-judge
- The `--output` flag writes to a file instead of terminal (useful for CI artifacts)
- JSON format includes all data needed for CI pass/fail decisions
