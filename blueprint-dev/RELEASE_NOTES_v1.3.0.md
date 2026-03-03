# Blueprint-Dev v1.3.0 Release Notes

**Release Date**: 2026-03-03
**Previous Version**: 1.2.0

---

## Overview

v1.3.0 introduces three major capabilities to blueprint-dev:

1. **Lightweight workflows** (`/bp:go`) — A fast lane for bug fixes, UI tweaks, and medium features that don't need the full 8-phase pipeline
2. **Built-in `/simplify` integration** — Automatic code simplification woven into the build, review, and lfg workflows
3. **Built-in `/batch` integration** (`/bp:batch`) — Parallel codebase-wide changes using worktrees, wrapped with project context and tracking

These additions address two gaps in v1.2.0: the lack of a lightweight path for small work, and the absence of integration with Claude Code's powerful built-in `/simplify` and `/batch` commands.

### What Changed

| Component | v1.2.0 | v1.3.0 | Delta |
|-----------|--------|--------|-------|
| Agents | 25 | 26 | +1 (lean-implementor) |
| Commands | 19 | 21 | +2 (/bp:go, /bp:batch) |
| Skills | 10 | 13 | +3 (simplify-integration, batch-integration, lightweight-planning) |

---

## 1. New Command: `/bp:go` — The Fast Lane

### The Problem

In v1.2.0, every task — from fixing a date format bug to adding a CSV export — was funneled through the same heavyweight pipeline:

```
/bp:plan → /bp:build → /bp:review → /bp:ship
```

That's 3 sequential planning agents (requirements-analyst, research-scout, scope-sentinel), mandatory feature flags, strict <400 LOC limits, and enforced 1-2 day branch lifetimes. For a 20-line bug fix, this is like going through airport security to cross the street.

### The Solution

`/bp:go` is a single adaptive command that combines planning and building for small-to-medium work:

```bash
# Fix a bug (small tweak)
/blueprint-dev:bp:go "fix date format on invoice PDF"

# Add a medium feature
/blueprint-dev:bp:go "add CSV export to reports API"

# Quick improvement
/blueprint-dev:bp:go "add pagination to activity feed"
```

### How It Works

**Step 1: Read Context** — Reads the stack profile and CLAUDE.md (no agent needed).

**Step 2: Triage Scope** — Auto-classifies the task inline using a decision matrix:

| Signal | Small Tweak | Medium Feature | Escalate |
|--------|-------------|----------------|----------|
| Files changed | 1-5 | 5-15 | 15+ |
| New endpoints | 0-1 | 2-4 | 5+ |
| New DB models | 0 | 1-2 | 3+ |
| LOC estimate | <200 | 200-600 | >600 |

**Step 3: Quick Plan** — Small tweaks get 3-5 inline bullets. Medium features get a lightweight plan doc (`.blueprint/plans/{date}-{slug}-lite.md`).

**Step 4: Confirm** — Single approval gate. Option to escalate if the task is bigger than expected.

**Step 5: Implement** — The new **lean-implementor** agent builds the change with relaxed TBD practices.

**Step 6-7: Self-Check and Present** — Verify tests/linting pass, then show results and suggest `/simplify`.

### Adaptive Behavior

`/bp:go` adapts its ceremony to the scope:

| Aspect | Small Tweak | Medium Feature |
|--------|-------------|----------------|
| Planning | 3-5 inline bullets | Lightweight plan doc (`-lite.md`) |
| Research | Quick codebase grep | Codebase search + `docs/solutions/` check |
| Feature flags | Skip | Only for significant new user-facing behavior |
| PR size limit | No enforcement | Soft guidance at 600 LOC |
| Branching | Current branch OK | Feature branch recommended |
| Tests | Proportional to change | Required (unit + integration) |

### Escalation Triggers

`/bp:go` automatically recommends switching to the full pipeline when:

- Architecture decisions are needed (new systems, data stores)
- A/B testing or design variants are involved
- Scope exceeds 600 LOC
- Security, performance, or data migration concerns arise

### Example: Small Tweak

```bash
/blueprint-dev:bp:go "fix date format on invoice PDF"
```

1. Triage: **Small tweak** (1-2 files, ~20 LOC)
2. Plan: "Change date format in invoice template, update test assertion"
3. Implement: lean-implementor fixes the format and test
4. Present: Changes shown, suggests `/simplify` then `/bp:ship`
5. Total time: **2-5 minutes**

### Example: Medium Feature

```bash
/blueprint-dev:bp:go "add CSV export to reports API"
```

1. Triage: **Medium feature** (6-8 files, ~300 LOC)
2. Plan: Creates `.blueprint/plans/2026-03-03-csv-export-lite.md`
3. Implement: lean-implementor creates endpoint, CSV builder, tests on a feature branch
4. Present: Suggests `/simplify` then `/bp:ship`
5. Total time: **10-20 minutes**

### Choosing the Right Command

| Scenario | Command |
|----------|---------|
| Bug fix, UI tweak, small endpoint | `/bp:go` |
| Medium iteration (5-15 files, 200-600 LOC) | `/bp:go` |
| New feature from scratch | `/bp:lfg` |
| Architecture decisions needed | `/bp:lfg` (needs `/bp:architect`) |
| A/B testing needed | `/bp:lfg` (needs `/bp:design`) |
| Same change across 10+ files | `/bp:batch` |

---

## 2. New Agent: `lean-implementor`

### The Problem

The `trunk-implementor` agent practices trunk-based development "religiously." It enforces mandatory feature flags, hard <400 LOC PR limits, 1-2 day branch lifetimes, and stacked PR splitting. These are excellent practices for significant features, but overkill for fixing a date format.

### The Solution

`lean-implementor` is a pragmatic counterpart to `trunk-implementor`:

| Aspect | trunk-implementor | lean-implementor |
|--------|-------------------|------------------|
| Voice | "TBD religiously" | "Pragmatic senior dev" |
| Feature flags | Mandatory for user-facing | Only if significant and risky |
| PR size | Hard <400 LOC | Soft guidance at 600 LOC |
| Branch age | <2 days enforced | Not checked |
| Branching | Always `feature/{slug}` from trunk | Optional for small tweaks |
| Tests | Required (unit + integration) | Required (proportional to change) |
| Stacked PRs | Yes, with splitting guidance | No |

### Design Philosophy

The lean-implementor follows "right-size the process to the work":

- A bug fix gets a test that reproduces the bug and verifies the fix. No integration test suite.
- A new admin-only feature skips the feature flag. It's not risky or user-facing.
- A one-file change stays on the current branch. Creating `feature/fix-typo` is noise.
- Code quality stays high regardless. Clean code doesn't need ceremony.

### Escalation

If the task grows beyond medium scope during implementation, the lean-implementor suggests switching to `/bp:build` with the full `trunk-implementor`.

---

## 3. `/simplify` Integration

### The Problem

Claude Code's built-in `/simplify` command runs 3 specialized agents — reuse detection, code quality, and efficiency analysis — and auto-fixes the issues it finds. This is a powerful tool, but in v1.2.0, blueprint-dev didn't know it existed. Users had to remember to run it manually.

### The Solution

`/simplify` is now woven into the build, review, and lfg workflows at strategic points:

### Where It Runs Automatically

**`/bp:build` — Step 5.5 (new step)**

After the trunk-implementor finishes and passes self-review, `/simplify` runs automatically:

```
Step 3: Implement (trunk-implementor)
Step 5: Self-Review (checklist)
Step 5.5: /simplify  ◄── NEW: auto-fixes reuse, quality, efficiency
         Re-verify tests + linting
Step 6: Present (now mentions /simplify was already run)
```

This catches issues while the code is fresh — existing utilities you could've reused, redundant state, sequential awaits that could be parallel.

**`/bp:lfg` — Phase 5 (Build)**

The full pipeline now runs `/simplify` after the build phase implementation, before the review gate. This means the review agents see cleaner code and can focus on judgment calls rather than mechanical issues.

### Where It's Suggested

**`/bp:review` — Step 5 (Offer Next Steps)**

After the 4 review agents produce their P1/P2/P3 findings, `/simplify` is now offered as a next step:

```
Next steps:
- "Fix P1 issues and re-run /bp:review"
- "Run /simplify to auto-fix P2/P3 code quality and efficiency findings"  ◄── NEW
- "Run /bp:ship when ready to merge"
```

**`/bp:go` — Step 7 (Present)**

After the lean-implementor finishes, `/simplify` is suggested before shipping.

**`/bp:lfg` — Phase 6 (Review)**

After the review phase, `/simplify` is offered to auto-fix remaining P2/P3 findings.

### How `/simplify` Complements Review Agents

They serve different purposes and are complementary, not redundant:

| Aspect | /simplify | /bp:review agents |
|--------|-----------|-------------------|
| **Action** | Auto-fixes code | Reports findings |
| **Scope** | Reuse, quality, efficiency | Quality, tests, TBD, patterns |
| **Output** | Modified source files | P1/P2/P3 review report |
| **Overlap** | DRY violations, redundant code | Same + architecture, conventions |

Running `/simplify` first reduces noise in the review report — fewer P2/P3 findings for the review agents to report, so human attention is saved for issues that require judgment.

### Agent Updates

Two review agents now explicitly call out auto-fixable issues:

- **code-quality-reviewer** (rule 7): When flagging DRY violations or redundant code as P2/P3, notes "Auto-fixable with `/simplify`"
- **pattern-recognizer** (rule 7): When flagging code smells or efficiency issues as P2/P3, notes "Auto-fixable with `/simplify`"

The **trunk-implementor** now includes `/simplify` in its workflow:
- Section 4 (Code Quality): "After implementation, run `/simplify` to catch reuse opportunities, hacky patterns, and efficiency improvements"
- Section 5 (Implementation Checklist): New item `[ ] /simplify pass completed`

---

## 4. New Command: `/bp:batch` — Parallel Codebase-Wide Changes

### The Problem

Some tasks aren't a single feature — they're the same transformation applied across many files:

- Rename an API field across 25 endpoints
- Migrate from SDK v1 to v2 across all services
- Add logging to every controller action
- Update a deprecated API pattern everywhere it appears

In v1.2.0, this meant either one massive PR (bad TBD practice) or manually running `/bp:build` once per file (tedious).

### The Solution

`/bp:batch` wraps Claude Code's built-in `/batch` command with project context and tracking:

```bash
/blueprint-dev:bp:batch "migrate all API endpoints from v1 to v2 SDK"
/blueprint-dev:bp:batch "add request logging to all controller actions"
/blueprint-dev:bp:batch "rename 'user_id' to 'account_id' across all models and endpoints"
```

### How It Works

1. **Read Context** — Gathers stack profile, CLAUDE.md, plans, and ADRs
2. **Invoke /batch** — Passes the task + project context to the built-in `/batch`
   - `/batch` decomposes the change into independent units
   - Spawns parallel workers in isolated git worktrees
   - Each worker implements, runs `/simplify`, and creates a PR
3. **Create Batch Manifest** — Tracks the operation at `.blueprint/batches/{date}-{slug}.md`
4. **Post-Batch** — Shows summary, offers `/bp:review` on individual PRs

### What `/bp:batch` Adds Over Raw `/batch`

| Feature | Raw `/batch` | `/bp:batch` |
|---------|-------------|-------------|
| Stack conventions | No | Reads `.blueprint/stack-profile.json` |
| Project rules | No | Reads `CLAUDE.md` |
| Plan/ADR context | No | Reads `.blueprint/plans/`, `.blueprint/adrs/` |
| Batch manifest | No | Creates `.blueprint/batches/{date}-{slug}.md` |
| Post-batch review | No | Offers `/bp:review` on completed PRs |

### TBD Compliance

`/bp:batch` naturally aligns with trunk-based development better than a single large PR:

- Each worker creates a **small, focused PR** (one transformation unit)
- PRs are **independently reviewable and mergeable**
- Changes are **isolated in worktrees** — no interference between workers

25 small PRs > 1 massive 1000-line PR.

### Example

```bash
/blueprint-dev:bp:batch "rename 'user_id' to 'account_id' across all API endpoints"
```

1. Reads stack profile (Rails + PostgreSQL), CLAUDE.md for naming conventions
2. `/batch` decomposes into 25 units (one per endpoint)
3. 25 parallel workers: rename field, update model, fix tests, run `/simplify`, create PR
4. Batch manifest: `.blueprint/batches/2026-03-03-rename-user-id.md`
5. Summary: "25 units completed, 25 PRs created"

### Scope Sentinel Integration

The **scope-sentinel** agent (rule 7) now recommends `/bp:batch` when reviewing plans that involve the same transformation repeated across 10+ files.

---

## 5. New Skills (3)

### `simplify-integration`

Reference documentation for how `/simplify` integrates with blueprint-dev. Covers:
- What `/simplify` does (3 agents: reuse, quality, efficiency)
- Where it runs automatically vs. where it's suggested
- How it complements review agents (complementary, not redundant)
- Rules for each agent regarding `/simplify`

### `batch-integration`

Reference documentation for how `/batch` integrates with blueprint-dev. Covers:
- What `/batch` does (decompose, parallel worktrees, PRs)
- Decision table: `/bp:batch` vs `/bp:build`
- What `/bp:batch` adds over raw `/batch`
- TBD compliance benefits
- Batch manifest format

### `lightweight-planning`

Methodology skill for the lightweight planning approach used by `/bp:go`. Covers:
- Philosophy: "Right-size the process to the work"
- Scope triage decision matrix
- Escalation triggers
- Adaptive behavior table (small vs. medium)
- Lightweight plan doc template (`-lite.md` suffix)
- Comparison with full planning methodology

Includes `references/triage-examples.md` with concrete calibration examples:
- **Small tweaks**: Fix date format (20 LOC), add aria-label (5 LOC), fix N+1 query (15 LOC)
- **Medium features**: CSV export (300 LOC), pagination (250 LOC), email notifications (400 LOC)
- **Escalate**: Real-time WebSockets (800+ LOC), multi-tenant isolation (1000+ LOC), payment integration (800+ LOC)

---

## 6. Modified Agents (4)

### `trunk-implementor`

Two additions:
- **Section 4 (Code Quality)**: "After implementation, run `/simplify` to catch reuse opportunities, hacky patterns, and efficiency improvements"
- **Section 5 (Implementation Checklist)**: New item `[ ] /simplify pass completed`

### `code-quality-reviewer`

New rule 7: "Suggest `/simplify` for auto-fixable issues — when flagging DRY violations, redundant code, or efficiency problems as P2/P3, note that `/simplify` can auto-fix them"

### `pattern-recognizer`

New rule 7: "Suggest `/simplify` for auto-fixable issues — when flagging code smells, DRY violations, or efficiency problems as P2/P3, note that `/simplify` can auto-fix them"

### `scope-sentinel`

New rule 7: "Recommend `/bp:batch` for repetitive patterns — when the scope involves the same transformation repeated across 10+ files, recommend `/bp:batch` instead of `/bp:build` for parallel execution in isolated worktrees"

---

## 7. Modified Commands (3)

### `build.md`

- **New Step 5.5 (Simplify)**: Runs `/simplify` after self-review, before presenting results
- **Updated Step 6 (Present)**: Now includes item 5 confirming `/simplify` was already run

### `review.md`

- **Updated Step 5 (Offer Next Steps)**: Added "Run `/simplify` to auto-fix P2/P3 code quality and efficiency findings"

### `lfg.md`

- **Updated Phase 5 (Build)**: Notes that `/simplify` runs after implementation
- **Updated Phase 6 (Review)**: Offers `/simplify` after review findings
- **New section**: "When to Use `/bp:lfg` vs `/bp:go` vs `/bp:batch`" decision table

---

## 8. Documentation Updates

### `GUIDE.md`

- Updated component counts (26 agents, 21 commands, 13 skills)
- Added "Lightweight & Batch Commands" table to Commands Reference
- Added `/bp:go` to End-to-End table
- Updated "You Don't Always Need Every Phase" table with `/bp:go` and `/bp:batch` shortcuts
- Added Use Case 8: Quick Iteration with `/bp:go` (small tweak + medium feature examples)
- Added Use Case 9: Codebase-Wide Migration with `/bp:batch`
- Renumbered Use Case 10 (formerly 8): Parallel Development with Worktrees
- Added "/simplify Integration" section in Advanced Usage
- Updated Custom Phase Ordering with `/bp:go`, `/bp:batch`, and `/bp:review` examples
- Updated agent organization chart (BUILD group: 2 → 3 agents, includes lean-implementor)
- Added `batches/` to `.blueprint/` directory structure

### `team-catalog.md`

- Added `team-go` entry (lightweight: inline triage → lean-implementor → `/simplify`)
- Added "Built-In Skill Integration" section documenting where `/simplify` and `/batch` integrate
- Updated agent count summary (added team-go row, updated total from 26 to 27)

### `plugin.json`

- Version: `1.2.0` → `1.3.0`
- Description: Added "lightweight fast-lane workflows, code simplification, and parallel batch operations"
- Keywords: Added `code-simplification`, `batch-operations`, `lightweight-workflow`

---

## Files Summary

### New Files (7)

| File | Type | Purpose |
|------|------|---------|
| `commands/go.md` | Command | Lightweight plan+build for small-to-medium work |
| `commands/batch.md` | Command | Blueprint-dev wrapper around built-in `/batch` |
| `agents/lean-implementor.md` | Agent | Pragmatic implementor with relaxed TBD |
| `skills/simplify-integration/SKILL.md` | Skill | `/simplify` integration reference |
| `skills/batch-integration/SKILL.md` | Skill | `/batch` integration reference |
| `skills/lightweight-planning/SKILL.md` | Skill | Lightweight planning methodology |
| `skills/lightweight-planning/references/triage-examples.md` | Reference | Scope triage calibration examples |

### Modified Files (10)

| File | Type | Changes |
|------|------|---------|
| `commands/build.md` | Command | Added Step 5.5 (Simplify), updated Step 6 |
| `commands/review.md` | Command | Added `/simplify` to next steps |
| `commands/lfg.md` | Command | Added `/simplify` to phases 5-6, added command comparison table |
| `agents/trunk-implementor.md` | Agent | Added `/simplify` to code quality + checklist |
| `agents/code-quality-reviewer.md` | Agent | Added rule 7 (suggest `/simplify`) |
| `agents/pattern-recognizer.md` | Agent | Added rule 7 (suggest `/simplify`) |
| `agents/scope-sentinel.md` | Agent | Added rule 7 (recommend `/bp:batch`) |
| `skills/swarm-orchestration/references/team-catalog.md` | Reference | Added team-go, built-in skills section |
| `GUIDE.md` | Docs | Updated counts, tables, use cases, advanced usage |
| `.claude-plugin/plugin.json` | Metadata | Version 1.3.0, description, keywords |

---

## Migration Guide

No breaking changes. v1.3.0 is fully backward-compatible with v1.2.0 workflows.

### For Existing Users

- All existing commands work exactly as before
- `/bp:build` now includes an additional Step 5.5 (`/simplify`) — this is automatic and requires no user action
- `/bp:review` offers one additional next step option
- No configuration changes needed

### Getting Started with New Features

```bash
# Try the fast lane for your next bug fix
/blueprint-dev:bp:go "fix the broken pagination on dashboard"

# Try batch for a codebase-wide rename
/blueprint-dev:bp:batch "rename 'userId' to 'accountId' across all API endpoints"

# /simplify is automatic in /bp:build — just use it as before
/blueprint-dev:bp:build "user settings page"
# (Step 5.5 now runs /simplify automatically)
```
