---
name: st:chaos
description: Configure chaos injection for a digital twin — set failure probabilities, choose profiles, and customize failure modes
argument-hint: Twin service name
---

# /scenario-testing:st:chaos

Configure chaos injection for a digital twin.

## Usage

```
/scenario-testing:st:chaos "jira"                                  # Interactive configuration
/scenario-testing:st:chaos "jira" --profile hostile                 # Apply a named profile
/scenario-testing:st:chaos "jira" --latency 0.1 --error-429 0.05   # Set specific modes
/scenario-testing:st:chaos --reset                                  # Reset all twins to defaults
```

## Workflow

### Step 1: Load Twin
- Read `.scenarios/twins/{service}/chaos.yaml`
- Read `.scenarios/twins/{service}/twin.json` for context
- Show current chaos configuration

### Step 2: Configure (Interactive)
Present the available chaos modes and current probabilities:

```
Chaos Configuration: jira

Mode              Current   Description
────────────────  ────────  ──────────────────────────
latency           0.00      Random response delay (100-5000ms)
error_429         0.00      Rate limit exceeded
error_500         0.00      Internal server error
error_503         0.00      Service unavailable
timeout           0.00      Connection timeout
partial_response  0.00      Truncated response body
stale_data        0.00      Return stale data
auth_expired      0.00      Token expired error

Profiles:
  gentle    — latency: 0.05, error_500: 0.01
  moderate  — latency: 0.15, error_429: 0.05, error_500: 0.03, timeout: 0.02
  hostile   — latency: 0.30, error_429: 0.10, error_500: 0.08, timeout: 0.05
```

Ask: "Apply a profile, set individual modes, or reset?"

### Step 3: Apply Configuration
- Update `chaos.yaml` with new probabilities
- If per-route overrides are requested, configure those too

### Step 4: Verify
Show the updated configuration and suggest:
```
Chaos updated for jira.

To test: /scenario-testing:st:run "slack-to-jira" --count 10
```

## Options

| Flag | Description |
|------|-------------|
| `--profile NAME` | Apply a named chaos profile (gentle/moderate/hostile) |
| `--latency PROB` | Set latency injection probability |
| `--error-429 PROB` | Set rate limit error probability |
| `--error-500 PROB` | Set server error probability |
| `--timeout PROB` | Set timeout probability |
| `--reset` | Reset all chaos to defaults (0.0) |

## Notes

- Chaos is per-twin, not per-scenario. Scenarios can override twin chaos in their `chaos` section.
- Probabilities are 0.0-1.0, applied per-request during trajectory runs
- Profiles are defined in the twin's `chaos.yaml`
- Custom profiles can be added to `chaos.yaml` manually
