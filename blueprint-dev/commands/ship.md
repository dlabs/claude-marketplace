---
name: bp:ship
description: Final gates check and merge to trunk — TBD compliance, CI status, PR creation
---

# /blueprint-dev:bp:ship

Run final shipping gates and merge the feature to trunk. Creates a PR if not already open.

## Usage

```
/blueprint-dev:bp:ship
/blueprint-dev:bp:ship --force  # skip non-critical warnings
```

## Prerequisites

- Must be on a feature branch (not main/master/trunk)
- Recommended: run `/blueprint-dev:bp:review` first

## Workflow

### Step 1: Final TBD Check
Use the **trunk-guard** agent for a final compliance check:
- Branch age
- PR size
- CI status
- Feature flag coverage
- Up-to-date with trunk

### Step 2: Gate Decision

| trunk-guard verdict | Action |
|--------------------|--------|
| APPROVE | Proceed to Step 3 |
| WARN | Show warnings, ask user to confirm |
| BLOCK | Show blockers, do not proceed |

### Step 3: Create/Update PR
If no PR exists for this branch:
- Create a PR using `gh pr create`
- Generate PR title and description from plan/review docs
- Include test plan from review

If PR already exists:
- Update the PR description if needed
- Check that all CI checks pass

### Step 4: Ship Manifest
Create `.blueprint/ships/{date}-{branch}.md`:

```markdown
# Ship Manifest: {branch-name}

**Date**: {YYYY-MM-DD}
**PR**: #{number}
**Branch**: {branch} → {trunk}

## Changes Summary
{Brief summary of what was shipped}

## Review Status
- Code quality: {pass/warn}
- Test coverage: {pass/warn}
- TBD compliance: {pass/warn}
- Pattern analysis: {pass/warn}

## Feature Flags
- {flag name}: {status}

## Files Changed
{count} files changed, {additions} additions, {deletions} deletions

## Related Documents
- Plan: {path}
- ADR: {path}
- Review: {path}
```

### Step 5: Offer Next Steps
- "Merge the PR when CI passes"
- "Run `/blueprint-dev:bp:compound` to document any problems solved"
- "Monitor feature flag rollout"

## Notes

- Ship does NOT auto-merge — it creates/verifies the PR
- The user makes the final merge decision
- Ship manifests provide an audit trail of what was shipped and when
- Always runs trunk-guard as a final gate, even if `/review` was already run
