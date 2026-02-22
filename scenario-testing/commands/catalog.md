---
name: st:catalog
description: List, search, and manage the scenario catalog — view scenarios by domain, check twin coverage, and show catalog health
argument-hint: (optional search term or domain filter)
---

# /scenario-testing:st:catalog

View and manage the scenario catalog.

## Usage

```
/scenario-testing:st:catalog                       # Show full catalog overview
/scenario-testing:st:catalog "auth"                 # Filter to auth domain
/scenario-testing:st:catalog --search "login"       # Search scenarios by keyword
/scenario-testing:st:catalog --health               # Show catalog health metrics
```

## Workflow

### Default View — Catalog Overview

Read `.scenarios/catalog.json` and present:

```
═══════════════════════════════════════════════════════
  SCENARIO CATALOG
═══════════════════════════════════════════════════════

  Scenarios: 8 across 3 domains
  Twins: 4 services configured

  Domain: auth (3 scenarios)
  ────────────────────────────────────────────
    sso-login           v2   Services: okta
    password-reset      v1   Services: —
    mfa-enrollment      v1   Services: okta

  Domain: onboarding (2 scenarios)
  ────────────────────────────────────────────
    first-project-setup v1   Services: —
    team-invite-flow    v1   Services: slack

  Domain: integrations (3 scenarios)
  ────────────────────────────────────────────
    slack-to-jira       v1   Services: slack, jira
    sheets-export       v1   Services: google-sheets
    drive-upload        v1   Services: google-drive

  Twins Available:
  ────────────────────────────────────────────
    okta           v1   Port: 9001   Endpoints: 8
    jira           v1   Port: 9002   Endpoints: 12
    slack          v1   Port: 9003   Endpoints: 9
    google-sheets  v1   Port: 9004   Endpoints: 7

  Missing Twins:
    google-drive — needed by integrations/drive-upload
    → Run /scenario-testing:st:twin "google-drive" to build

═══════════════════════════════════════════════════════
```

### Health View (`--health`)

```
═══════════════════════════════════════════════════════
  CATALOG HEALTH
═══════════════════════════════════════════════════════

  Structure
    Scenarios with all required fields:     8/8  ✓
    Scenarios with anti-patterns defined:   7/8  ⚠
    Scenarios with chaos configured:        5/8
    Twin coverage for referenced services:  3/4  ⚠

  Satisfaction Coverage
    Scenarios with at least 1 run:          6/8
    Scenarios never run:                    2/8  ⚠
      - onboarding/team-invite-flow
      - integrations/drive-upload

  Freshness
    Most recent run: 2026-02-20 (today)
    Scenarios not run in 14+ days:          1/8
      - auth/mfa-enrollment (last: 2026-02-01)

  Recommendations:
    1. Add anti-patterns to onboarding/first-project-setup
    2. Build google-drive twin for integrations/drive-upload
    3. Run auth/mfa-enrollment — stale by 19 days
    4. Run onboarding/team-invite-flow — never validated

═══════════════════════════════════════════════════════
```

### Search View (`--search TERM`)

Search scenario IDs, intents, and domains for a keyword:

```
Search results for "login":
  auth/sso-login (v2) — "Log in to the application using SSO"
  auth/mfa-enrollment (v1) — "Enroll in MFA after first login"
```

## Options

| Flag | Description |
|------|-------------|
| `"domain"` | Filter to a specific domain |
| `--search TERM` | Search scenarios by keyword |
| `--health` | Show catalog health and recommendations |

## Notes

- This command is read-only — it doesn't modify the catalog
- Health checks are useful before a validation run to ensure the catalog is in good shape
- Missing twins are highlighted to prompt building them before running scenarios
