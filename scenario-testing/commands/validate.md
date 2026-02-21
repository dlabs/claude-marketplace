---
name: st:validate
description: Full validation pipeline — run all scenarios, judge trajectories, and report satisfaction in one command
argument-hint: (optional domain filter or scenario ID)
---

# /scenario-testing:st:validate

Run the full validation pipeline in one command: execute → judge → report.

## Usage

```
/scenario-testing:st:validate                           # Full catalog validation
/scenario-testing:st:validate --domain auth              # Validate one domain
/scenario-testing:st:validate "sso-login"                # Validate one scenario
/scenario-testing:st:validate --count 100                # Override trajectory count
/scenario-testing:st:validate --chaos-profile hostile     # Override chaos
```

## Workflow

This command chains three commands sequentially:

### Step 1: Catalog Health Check
Before running, check:
- All referenced twins exist
- All scenarios have valid structure
- Warn about any issues (but don't block)

### Step 2: Run (`/st:run`)
Execute scenarios and record trajectories. See `commands/run.md` for details.

### Step 3: Judge (`/st:satisfy`)
Judge all trajectories from the run. See `commands/satisfy.md` for details.

### Step 4: Report (`/st:report`)
Generate and display the satisfaction report. If a previous run exists, automatically include comparison data.

### Step 5: Threshold Check
Check satisfaction scores against configured thresholds:
- If all pass → "All scenarios meet satisfaction thresholds."
- If any fail → highlight failing scenarios with scores and thresholds

### Step 6: Present Summary

```
═══════════════════════════════════════════════════════
  VALIDATION COMPLETE — 2026-02-20
═══════════════════════════════════════════════════════

  Overall Satisfaction: 0.91     [PASS — threshold: 0.80]
  Scenarios: 8 run, 7 passing, 1 failing
  Trajectories: 400 run, 364 satisfactory

  Failing:
    payments/checkout-flow   0.93 (target: 0.98)

  vs. Previous (2026-02-19):
    Overall: +0.02 improvement

═══════════════════════════════════════════════════════
```

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `--domain NAME` | Validate only this domain | all |
| `--count N` | Trajectories per scenario | 50 |
| `--chaos-profile NAME` | Override chaos profile | from config |
| `--format json` | JSON output for CI | terminal |
| `--output PATH` | Write report to file | stdout |

## Notes

- This is the most common command for regression validation — run after code changes
- Equivalent to running `/st:run → /st:satisfy → /st:report` manually
- For CI pipelines, use `--format json --output satisfaction.json` and parse the result
- Exit code reflects pass/fail if run programmatically (future: when scripts support this)
