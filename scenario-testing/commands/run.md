---
name: st:run
description: Execute scenarios and record trajectories — run against the codebase with digital twins substituted for real services
argument-hint: Scenario ID, domain name, or blank for full catalog
---

# /scenario-testing:st:run

Execute scenarios and record trajectories.

## Usage

```
/scenario-testing:st:run "sso-login"              # Run one scenario
/scenario-testing:st:run --domain auth             # Run all scenarios in a domain
/scenario-testing:st:run                            # Run all scenarios in the catalog
/scenario-testing:st:run --count 100               # Override trajectory count
/scenario-testing:st:run --chaos-profile hostile    # Override chaos profile
```

## Workflow

### Step 1: Determine Scope
Parse the argument to determine which scenarios to run:
- Specific scenario ID → run just that scenario
- `--domain {name}` → run all scenarios in that domain
- No argument → run all scenarios in the catalog

### Step 2: Verify Prerequisites
- Check `.scenarios/catalog.json` exists (suggest `/st:init` if not)
- Load target scenarios
- Check that required twins exist for referenced services
- If twins are missing, warn and offer to build them (`/st:twin`)

### Step 3: Create Run
The **trajectory-runner** agent:
1. Creates a run directory at `.scenarios/runs/{date}-{seq}/`
2. Writes an initial `run-manifest.json`
3. Configures the environment (twins, chaos, seed data)

### Step 4: Execute Trajectories
For each scenario:
- Run N trajectories (from `--count`, scenario config, or default 50)
- Each trajectory records events, API calls, state transitions, outcomes
- Chaos is injected per the scenario's chaos config (or `--chaos-profile` override)

Present progress:
```
Running scenarios...
  auth/sso-login:      [████████████████████] 50/50 trajectories
  auth/password-reset:  [██████████░░░░░░░░░░] 25/50 trajectories
  integrations/slack-to-jira: [░░░░░░░░░░░░░░░░░░░░] 0/50 trajectories
```

### Step 5: Finalize
After all trajectories are recorded:
- Update `run-manifest.json` with completion time and summary
- Present results:

```
Run complete: 2026-02-20-001

Scenarios: 3
Trajectories: 150
Duration: 12m 34s

Next: Run /scenario-testing:st:satisfy to judge trajectories and compute satisfaction.
```

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `--count N` | Trajectories per scenario | 50 (from config) |
| `--domain NAME` | Run only scenarios in this domain | all |
| `--chaos-profile NAME` | Override chaos profile (gentle/moderate/hostile) | from config |
| `--parallel N` | Run N trajectories in parallel | 1 |

## Notes

- Runs are append-only — each run creates a new directory, never overwrites previous runs
- The run ID format is `{YYYY-MM-DD}-{seq}` where seq is auto-incremented per day
- If a trajectory errors out (e.g., twin not reachable), the error is recorded as an event and the trajectory continues
- Trajectories within a scenario are independent — no shared state
