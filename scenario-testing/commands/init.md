---
name: st:init
description: Initialize the scenario catalog, config, and directory structure for a new project
argument-hint: (no arguments)
---

# /scenario-testing:st:init

Initialize the scenario-testing workspace for a new project.

## Usage

```
/scenario-testing:st:init
```

## Workflow

### Step 1: Check for Existing Catalog
- Check if `.scenarios/` directory exists
- If it does, show current status and ask: "Reinitialize (destructive) or cancel?"
- If not, proceed with creation

### Step 2: Create Directory Structure
Create the following directories:

```
.scenarios/
├── catalog/
├── twins/
├── runs/
└── reports/
    └── history/
```

### Step 3: Create Config
Write `.scenarios/config.json` with default settings:

```json
{
  "$schema": "scenario-config",
  "version": 1,
  "storage": "holdout",
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
```

### Step 4: Create Catalog Index
Write `.scenarios/catalog.json`:

```json
{
  "$schema": "catalog",
  "version": 1,
  "updated_at": "{now}",
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
```

### Step 5: Configure Gitignore
Ask the user about storage mode:
1. **Holdout (recommended)** — add `.scenarios/` to `.gitignore`. Scenarios are not visible to the codebase.
2. **In-repo** — don't gitignore. Scenarios are committed and shared with the team.

If holdout mode and `.gitignore` exists, append `.scenarios/` to it.

### Step 6: Present Next Steps
Show the user:
```
Scenario catalog initialized at .scenarios/

Next steps:
  /scenario-testing:st:scenario "your first user story"   — Author a scenario
  /scenario-testing:st:twin "service-name"                 — Build a digital twin
  /scenario-testing:st:catalog                              — View the catalog
```

## Notes

- This command is idempotent if no catalog exists — safe to run multiple times
- The `.scenarios/` directory is created in the project root (where `CLAUDE.md` lives, or the git root)
- If `.blueprint/stack-profile.json` exists (from blueprint-dev), suggest relevant domains based on detected integrations
