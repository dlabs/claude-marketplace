---
name: bp:build
description: Implement feature with trunk-based development practices — short-lived branch, feature flags, small PRs
argument-hint: Feature to implement
---

# /blueprint-dev:bp:build

Implement the planned feature following trunk-based development practices.

## Usage

```
/blueprint-dev:bp:build "user auth"
/blueprint-dev:bp:build   # (implements the most recent plan)
```

## Prerequisites

- Recommended: run `/blueprint-dev:bp:plan` first
- Recommended: run `/blueprint-dev:bp:architect` for significant features
- Optional: run `/blueprint-dev:bp:design` for UI features with A/B variants

## Workflow

### Step 1: Prepare
Read context from prior phases:
- `.blueprint/stack-profile.json` — project conventions
- `.blueprint/plans/` — latest plan doc
- `.blueprint/adrs/` — architecture decisions
- `CLAUDE.md` — project-specific rules

### Step 2: Branch
Use the **trunk-implementor** agent to create a short-lived feature branch:
```
git checkout -b feature/{slug}
```

### Step 3: Implement
The trunk-implementor builds the feature:
- Following project conventions from the stack profile
- Writing tests alongside implementation
- Wrapping new user-facing behavior in feature flags
- Making small, logical commits

### Step 4: Feature Flags
Use the **feature-flag-engineer** agent to:
- Create the feature flag (using detected provider)
- Configure rollout plan
- Document the flag in the registry

### Step 5: Self-Review
Before presenting to the user, verify:
- [ ] All planned requirements implemented
- [ ] Tests pass
- [ ] Linting passes
- [ ] Type checking passes (if applicable)
- [ ] Feature flagged
- [ ] PR size < 400 LOC (or explain split plan)

### Step 6: Present
Show the user:
1. **What was built** — summary of changes
2. **Files modified** — list with brief descriptions
3. **Tests added** — coverage of requirements
4. **Feature flag** — flag name and rollout plan
5. **Next steps**: Run `/blueprint-dev:bp:review` for multi-agent review, or `/blueprint-dev:bp:ship` to merge

## Notes

- If the feature is too large for one PR, the implementor will suggest splitting
- Feature flags use the provider detected in the stack profile
- All code ships to trunk behind flags — deployable at all times
- Run `/blueprint-dev:bp:review` before `/blueprint-dev:bp:ship` for comprehensive review
