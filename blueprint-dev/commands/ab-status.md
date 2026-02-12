---
name: bp:ab-status
description: Check status of all active A/B tests — shows test names, variants, duration, and flag status
---

# /blueprint-dev:bp:ab-status

Display the status of all active A/B tests in the project.

## Usage

```
/blueprint-dev:bp:ab-status
```

## Workflow

### Step 1: Find A/B Tests
Search for the A/B test registry:
- Look for `src/config/ab-tests.ts` (or `.js`, `.php`, `.rb`, `.py` equivalent)
- Also scan `docs/ab-tests/*/PLAN.md` for test plans
- Check `.blueprint/stack-profile.json` for the feature flag provider

### Step 2: Read Status
For each test found:
- Read the registry entry (name, flag key, variants, status, owner, creation date)
- Read the PLAN.md for hypothesis and metrics
- Check if a DECISION.md exists (means test has been decided)
- Calculate test duration (days since creation)

### Step 3: Present Summary

Display a status table:

```
Active A/B Tests
================

| Test | Variants | Flag Key | Status | Duration | Owner |
|------|----------|----------|--------|----------|-------|
| login-page | control, variant-b | ab_login_page | active | 12 days | @dev |
| settings-dash | control, variant-b, variant-c | ab_settings_dash | active | 3 days | @dev |

Completed Tests (with DECISION.md)
===================================
| Test | Winner | Decided | Cleanup Done? |
|------|--------|---------|---------------|
| onboarding-flow | variant-b | 2026-01-28 | Yes |
```

### Step 4: Suggest Actions

For each active test, suggest:
- If running > planned duration: "Consider running `/blueprint-dev:bp:ab-decide` — test has exceeded planned duration"
- If no PLAN.md: "Missing test plan — run `/blueprint-dev:bp:design` to generate one"
- If DECISION.md exists but cleanup not done: "Run `/blueprint-dev:bp:ab-cleanup` to clean up decided test"
