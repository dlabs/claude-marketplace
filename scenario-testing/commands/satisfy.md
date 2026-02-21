---
name: st:satisfy
description: Judge trajectories from the latest run using LLM-as-judge — compute satisfaction scores per scenario, domain, and overall
argument-hint: Run ID (optional, defaults to latest)
---

# /scenario-testing:st:satisfy

Judge trajectories and compute satisfaction scores.

## Usage

```
/scenario-testing:st:satisfy                        # Judge the latest run
/scenario-testing:st:satisfy "2026-02-20-001"       # Judge a specific run
/scenario-testing:st:satisfy --rejudge               # Re-judge already judged trajectories
```

## Workflow

### Step 1: Identify the Run
- If no argument, find the most recent run in `.scenarios/runs/`
- If argument provided, use that run ID
- Read the run manifest to understand scope

### Step 2: Load Scenarios
For each scenario referenced in the run:
- Read the scenario YAML (for satisfaction criteria and anti-patterns)
- Load the appropriate judge configuration (scenario-specific > domain > default)
- Load judge prompts from `skills/satisfaction-metrics/references/judge-prompt-template.md`

### Step 3: Judge Trajectories
The **satisfaction-judge** agent evaluates each trajectory:

For each trajectory file in `.scenarios/runs/{run-id}/trajectories/`:
1. Skip if already judged (unless `--rejudge`)
2. Load the trajectory events and final state
3. Apply the judge evaluation process:
   - Anti-pattern check → any match = unsatisfactory
   - Satisfaction criteria match → at least one needed
   - Persona judgment → would the persona accept this?
4. Write judgment to `.scenarios/runs/{run-id}/judgments/{trajectory-id}.json`

Present progress:
```
Judging trajectories for run 2026-02-20-001...
  auth/sso-login:              [████████████████████] 50/50 judged
  integrations/slack-to-jira:  [██████████░░░░░░░░░░] 25/50 judged
```

### Step 4: Compute Satisfaction
After all trajectories are judged:

Per scenario:
```
satisfaction(scenario) = satisfactory / total
```

Per domain:
```
satisfaction(domain) = mean(scenario satisfactions)
```

Overall:
```
satisfaction(overall) = weighted_mean(domain satisfactions)
```

### Step 5: Write Report Data
- Write satisfaction summary to the run manifest
- Write the report to `.scenarios/reports/latest.json`
- Archive to `.scenarios/reports/history/{date}.json`
- Check thresholds from `.scenarios/config.json`

### Step 6: Present Results
Show a summary:
```
Satisfaction Report — Run 2026-02-20-001

Overall: 0.91 (137/150 satisfactory)

  auth:              0.96  [PASS — threshold: 0.95]
    sso-login:       0.96  (48/50)
    password-reset:  0.96  (48/50)
  integrations:      0.82  [WARN — threshold: 0.85]
    slack-to-jira:   0.82  (41/50)

Failing: integrations/slack-to-jira (0.82 < 0.85)
  Most common failure: ticket title was raw Slack message (6 trajectories)

For full report: /scenario-testing:st:report
```

## Options

| Flag | Description |
|------|-------------|
| `--rejudge` | Re-judge all trajectories, overwriting existing judgments |

## Notes

- Judgments are idempotent — re-running without `--rejudge` skips already-judged trajectories
- The judge uses temperature 0 for consistency
- Each trajectory is judged independently (no cross-trajectory comparison)
- The satisfaction-judge agent handles all judgment — this command orchestrates the process
