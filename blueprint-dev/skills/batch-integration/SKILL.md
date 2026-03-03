---
name: batch-integration
description: Reference for how the built-in /batch command integrates with blueprint-dev workflows — parallel codebase-wide changes using worktrees with project context.
---

# /batch Integration

How the built-in `/batch` command fits into blueprint-dev workflows.

## What /batch Does

`/batch` is a built-in Claude Code command that performs codebase-wide changes in parallel:

1. **Decomposes** a large change into independent units of work
2. **Spawns parallel workers** in isolated git worktrees
3. Each worker implements its unit, runs `/simplify`, and creates a PR
4. **Returns** a summary of all PRs created

This is ideal for repetitive, pattern-based changes that touch many files but follow the same transformation logic.

## When to Use /bp:batch vs /bp:build

| Signal | Use `/bp:build` | Use `/bp:batch` |
|--------|-----------------|-----------------|
| Files affected | 1-15 | 10+ (same pattern) |
| Change pattern | Unique per file | Same transformation repeated |
| Dependencies between changes | Yes | No (independent units) |
| Examples | Add a new feature, refactor a module | Rename API field across all endpoints, migrate from v1 to v2 SDK, add logging to all controllers |
| Planning needed | Yes (requirements, architecture) | Minimal (pattern is known) |
| Review strategy | Single `/bp:review` | `/bp:review` per PR or batch review |

## /bp:batch vs Raw /batch

`/bp:batch` is a blueprint-dev wrapper around the built-in `/batch`. It adds project context:

| Feature | Raw `/batch` | `/bp:batch` |
|---------|-------------|-------------|
| Stack conventions | No | Reads `.blueprint/stack-profile.json` |
| Project rules | No | Reads `CLAUDE.md` |
| Plan/ADR context | No | Reads `.blueprint/plans/`, `.blueprint/adrs/` |
| Batch manifest | No | Creates `.blueprint/batches/{date}-{slug}.md` |
| Post-batch review | No | Offers `/bp:review` on completed PRs |
| /simplify | Each worker runs it | Same (inherited from /batch) |

## TBD Compliance

`/batch` naturally aligns with trunk-based development:

- Each worker creates a **small, focused PR** (one transformation unit)
- PRs are **independently reviewable and mergeable**
- Changes are **isolated in worktrees** — no interference between workers
- Each PR targets trunk (main/master)

This is better TBD practice than a single massive PR touching 50 files.

## Workflow

```
/bp:batch "migrate all API endpoints from v1 to v2 SDK"
    │
    ├── Step 1: Read project context (stack profile, CLAUDE.md, plans)
    ├── Step 2: Invoke built-in /batch with project context
    │     ├── /batch decomposes into units
    │     ├── Spawns parallel worktree workers
    │     ├── Each worker: implement → /simplify → create PR
    │     └── Returns summary
    ├── Step 3: Create batch manifest at .blueprint/batches/
    └── Step 4: Show summary, offer /bp:review on PRs
```

## Batch Manifest

Each batch run creates a manifest at `.blueprint/batches/{date}-{slug}.md`:

```markdown
# Batch: {description}

**Date**: {YYYY-MM-DD}
**Units**: {count}
**PRs created**: {count}

## Units
| # | Description | PR | Status |
|---|-------------|-----|--------|
| 1 | {unit desc} | #{pr} | created |
| 2 | {unit desc} | #{pr} | created |

## Context Used
- Stack profile: .blueprint/stack-profile.json
- CLAUDE.md conventions applied
```

## Rules for Agents

- **scope-sentinel**: When a plan involves the same pattern repeated across 10+ files, recommend `/bp:batch` instead of `/bp:build`
- **trunk-implementor**: If the implementation involves repetitive changes across many files, suggest `/bp:batch` as an alternative
