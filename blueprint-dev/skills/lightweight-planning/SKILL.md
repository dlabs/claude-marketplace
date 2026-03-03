---
name: lightweight-planning
description: Lightweight planning methodology for small-to-medium work — scope triage, adaptive process, and right-sized ceremony for bug fixes, UI tweaks, and medium features.
---

# Lightweight Planning

Right-size the process to the work. Not every change needs 8 phases and 18 agents.

## Philosophy

The full blueprint-dev pipeline (`/bp:lfg`) is optimized for complex, brand-new features that need requirements decomposition, design variants, architecture review, and formal code review. But most day-to-day development is smaller:

- Fix a date format bug
- Add a CSV export endpoint
- Update a form validation rule
- Add a new column to an admin table

These tasks deserve a fast lane — enough process to catch mistakes, not so much that the ceremony exceeds the work.

## Scope Triage

Every `/bp:go` invocation starts with an automatic scope triage. No agent needed — the command evaluates the task inline.

### Decision Matrix

| Signal | Small Tweak | Medium Feature | Escalate to /bp:plan |
|--------|-------------|----------------|----------------------|
| Files changed | 1-5 | 5-15 | 15+ |
| New endpoints | 0-1 | 2-4 | 5+ |
| New DB models | 0 | 1-2 | 3+ |
| LOC estimate | <200 | 200-600 | >600 |

### Escalation Triggers

`/bp:go` recommends switching to the heavyweight pipeline when:

- Task needs **architecture decisions** (new systems, data stores, service boundaries)
- Task involves **A/B testing or design variants**
- Scope triage estimates **>600 LOC**
- **Security concerns** (auth, payments, PII handling)
- **Performance concerns** (new DB queries on hot paths, caching strategy)
- **Data migration** (schema changes affecting existing data)

## Adaptive Behavior

| Aspect | Small Tweak | Medium Feature |
|--------|-------------|----------------|
| Planning | Inline 3-5 bullet points | Lightweight plan doc (`.blueprint/plans/{date}-{slug}-lite.md`) |
| Research | Quick codebase grep | Codebase search + `docs/solutions/` check |
| Feature flags | Skip | Only for significant new user-facing behavior |
| PR size limit | No enforcement | Soft guidance at 600 LOC |
| Branching | Optional (current branch OK) | Feature branch recommended |
| Artifacts | None | Lightweight plan doc only |
| Tests | Proportional to change | Required (unit + integration as needed) |

## Lightweight Plan Doc Template

For medium features, `/bp:go` creates a lightweight plan at `.blueprint/plans/{date}-{slug}-lite.md`:

```markdown
# {Feature Name} (Lite Plan)

**Date**: {YYYY-MM-DD}
**Scope**: {Small Tweak | Medium Feature}
**Estimated LOC**: {number}

## What
{1-2 sentence description of the change}

## Why
{1 sentence on the motivation}

## How
- {Implementation bullet 1}
- {Implementation bullet 2}
- {Implementation bullet 3}

## Files
- {file1} — {what changes}
- {file2} — {what changes}

## Tests
- {Test 1 description}
- {Test 2 description}
```

## Comparison with Full Planning

| Aspect | /bp:plan (Full) | /bp:go (Lightweight) |
|--------|-----------------|----------------------|
| Agents | 3 sequential (requirements-analyst → research-scout → scope-sentinel) | 0 (inline triage) |
| Output | Full plan doc with FR-XXX requirements, research findings, scope assessment | Inline bullets or lite plan doc |
| Duration | 5-15 minutes | 30 seconds |
| Artifacts | `.blueprint/plans/{date}-{feature}.md` | None or `.blueprint/plans/{date}-{slug}-lite.md` |
| Scope guard | scope-sentinel agent | Built-in escalation triggers |
| Research | research-scout searches docs/solutions/ | Quick grep (medium) or skip (small) |

## See Also

- `skills/lightweight-planning/references/triage-examples.md` — concrete examples calibrating the triage
- `commands/go.md` — the `/bp:go` command that uses this methodology
- `agents/lean-implementor.md` — the implementor agent used by `/bp:go`
