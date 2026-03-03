---
name: bp:go
description: Lightweight plan+build for small-to-medium work — auto-triages scope, plans inline, implements with relaxed TBD, suggests /simplify
argument-hint: What to build or fix
---

# /blueprint-dev:bp:go

Fast-lane development for bug fixes, UI tweaks, small endpoints, and medium features. One command replaces the plan → build → review ceremony for work that doesn't need it.

**When to use `/bp:go` vs `/bp:lfg`:**
- `/bp:lfg` = full ceremony (8 phases, 18+ agents) — new features, architecture changes, A/B tests
- `/bp:go` = fast lane (1 command, 1 agent, `/simplify` for review) — bug fixes, tweaks, medium iterations

## Usage

```
/blueprint-dev:bp:go "fix date format on invoice PDF"
/blueprint-dev:bp:go "add CSV export to reports API"
/blueprint-dev:bp:go "add pagination to activity feed"
```

## Workflow

### Step 1: Read Context
Read available project context:
- `.blueprint/stack-profile.json` — project conventions
- `CLAUDE.md` — project-specific rules
- Relevant source files in the change area

### Step 2: Triage Scope
Auto-classify the task. No agent needed — evaluate inline:

| Signal | Small Tweak | Medium Feature | Escalate |
|--------|-------------|----------------|----------|
| Files changed | 1-5 | 5-15 | 15+ |
| New endpoints | 0-1 | 2-4 | 5+ |
| New DB models | 0 | 1-2 | 3+ |
| LOC estimate | <200 | 200-600 | >600 |

**If any escalation trigger fires**, recommend switching:
- Architecture decisions needed → suggest `/blueprint-dev:bp:plan` + `/blueprint-dev:bp:architect`
- A/B testing needed → suggest `/blueprint-dev:bp:design`
- >600 LOC → suggest `/blueprint-dev:bp:plan` + `/blueprint-dev:bp:build`
- Security/performance/data migration concerns → suggest the full pipeline

Show the triage result to the user before proceeding.

### Step 3: Quick Plan
Based on triage:

**Small tweak**: Present 3-5 inline bullet points summarizing the plan. No plan doc.

**Medium feature**: Create a lightweight plan doc at `.blueprint/plans/{date}-{slug}-lite.md` using the template from the `lightweight-planning` skill. Include:
- What and why (1-2 sentences each)
- Implementation bullets
- Files to change
- Tests to write

### Step 4: Confirm
Single approval gate. Ask the user:
- "Ready to implement?" (proceed)
- "Want to adjust the plan?" (iterate)
- "This looks bigger than expected — escalate to `/bp:plan`?" (only if borderline)

### Step 5: Implement
Use the **lean-implementor** agent to build the change:
- Following project conventions from the stack profile
- Writing tests proportional to the change
- Feature flags only if significant user-facing behavior
- Small, logical commits

### Step 6: Self-Check
Verify before presenting:
- [ ] Tests pass
- [ ] Linting passes
- [ ] Type checking passes (if applicable)

### Step 7: Present
Show the user:
1. **What was built** — summary of changes
2. **Files modified** — list with brief descriptions
3. **Tests added** — what's covered
4. **Next steps**:
   - Run `/simplify` to auto-fix reuse, quality, and efficiency issues
   - Run `/blueprint-dev:bp:ship` to create a PR and merge
   - Run `/blueprint-dev:bp:review` if you want a full multi-agent review

## Notes

- `/bp:go` is designed for speed — it should feel lighter than the full pipeline
- The triage is a guideline, not a gate — the user can override in either direction
- If the task grows during implementation, the lean-implementor will suggest escalating
- For codebase-wide repetitive changes, use `/blueprint-dev:bp:batch` instead
- All artifacts from `/bp:go` are compatible with the full pipeline — you can run `/bp:review` or `/bp:ship` after
