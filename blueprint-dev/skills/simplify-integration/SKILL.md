---
name: simplify-integration
description: Reference for how the built-in /simplify command integrates with blueprint-dev workflows — when it runs, what it checks, and how it complements review agents.
---

# /simplify Integration

How the built-in `/simplify` command fits into blueprint-dev workflows.

## What /simplify Does

`/simplify` is a built-in Claude Code command that runs 3 specialized agents on your code:

| Agent | Focus | Examples |
|-------|-------|---------|
| **Reuse** | Finds existing utilities you could use instead of new code | Project already has `formatDate()` but you wrote a new one |
| **Quality** | Spots hacky patterns, redundant state, copy-paste code | Duplicated validation logic, unnecessary wrapper functions |
| **Efficiency** | Identifies unnecessary work, missed concurrency, hot-path bloat | Sequential awaits that could be parallel, unused computations |

After analysis, `/simplify` **auto-fixes** the issues it finds. It modifies your code directly.

## When /simplify Runs in Blueprint-Dev

### Automatic (built into the workflow)

**`/bp:build`** — Step 5.5 runs `/simplify` after implementation, before presenting results. This catches reuse opportunities and quality issues while the code is fresh.

**`/bp:go`** — Step 7 suggests running `/simplify` after implementation completes.

### Suggested (user-initiated)

**`/bp:review`** — Step 5 offers `/simplify` as a next step for auto-fixing P2/P3 quality and efficiency findings.

**`/bp:lfg`** — Phase 5 (Build) runs `/simplify` after implementation. Phase 6 (Review) suggests it for remaining findings.

## How /simplify Complements Review Agents

`/simplify` and blueprint-dev's review agents serve different purposes:

| Aspect | /simplify | /bp:review agents |
|--------|-----------|-------------------|
| **Action** | Auto-fixes code | Reports findings |
| **Scope** | Reuse, quality, efficiency | Quality, tests, TBD, patterns |
| **Output** | Modified source files | P1/P2/P3 review report |
| **When** | During/after build | After build, before ship |
| **Overlap** | DRY violations, redundant code | Same issues + architecture, conventions |

**They are complementary, not redundant:**
- `/simplify` handles the mechanical fixes (DRY, efficiency, reuse)
- Review agents handle judgment calls (architecture, conventions, test coverage, TBD compliance)
- Running `/simplify` first reduces noise in the review report — fewer P2/P3 findings for reviewers to wade through

## Workflow Integration

```
/bp:build
    │
    ├── Step 3: Implement (trunk-implementor)
    ├── Step 5: Self-Review (checklist)
    ├── Step 5.5: /simplify ◄── auto-fixes reuse, quality, efficiency
    ├── Re-verify tests + linting
    └── Step 6: Present results

/bp:review
    │
    ├── Step 2: 4 parallel review agents
    ├── Step 4: Present P1/P2/P3 findings
    └── Step 5: Offer next steps
         └── "Run /simplify to auto-fix P2/P3 findings" ◄──
```

## Rules for Agents

- **trunk-implementor**: Run `/simplify` after implementation, before marking complete
- **lean-implementor**: Suggest `/simplify` in the present step
- **code-quality-reviewer**: When flagging DRY violations or redundant code as P2/P3, add: "Auto-fixable with `/simplify`"
- **pattern-recognizer**: When flagging efficiency issues or code smells as P2/P3, add: "Auto-fixable with `/simplify`"
