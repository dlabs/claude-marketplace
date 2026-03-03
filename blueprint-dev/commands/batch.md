---
name: bp:batch
description: Parallel codebase-wide changes using worktrees — wraps built-in /batch with project conventions, stack profile, and batch manifests
argument-hint: Codebase-wide change to apply
---

# /blueprint-dev:bp:batch

Apply the same transformation across many files in parallel. Blueprint-dev wrapper around the built-in `/batch` that adds project context, conventions, and tracking.

**When to use `/bp:batch` vs `/bp:build`:**
- `/bp:build` = single focused feature, files have dependencies between them
- `/bp:batch` = same pattern repeated across 10+ independent files

## Usage

```
/blueprint-dev:bp:batch "migrate all API endpoints from v1 to v2 SDK"
/blueprint-dev:bp:batch "add request logging to all controller actions"
/blueprint-dev:bp:batch "rename 'user_id' to 'account_id' across all models and endpoints"
```

## Prerequisites

- Recommended: run `/blueprint-dev:bp:discover` first (or have a stack profile from a prior session)
- The built-in `/batch` command must be available in your Claude Code version

## Workflow

### Step 1: Read Context
Gather project context to pass to batch workers:
- `.blueprint/stack-profile.json` — project conventions, framework, testing setup
- `CLAUDE.md` — project-specific rules and patterns
- `.blueprint/plans/` — relevant plan docs (if the batch is part of a larger effort)
- `.blueprint/adrs/` — architecture decisions that affect the transformation

Summarize the relevant context into a concise brief that each worker will receive.

### Step 2: Invoke Built-In /batch
Pass the task to the built-in `/batch` command along with project context:
- The transformation description from the user
- Project conventions summary from Step 1
- Any constraints (e.g., "follow existing patterns in `src/api/v2/users.ts` as a reference")

`/batch` handles:
- Decomposing the change into independent units
- Spawning parallel workers in isolated git worktrees
- Each worker implements its unit, runs `/simplify`, and creates a PR
- Returning a summary of all completed units

### Step 3: Create Batch Manifest
After `/batch` completes, create a manifest at `.blueprint/batches/{date}-{slug}.md`:

```markdown
# Batch: {description}

**Date**: {YYYY-MM-DD}
**Units**: {total count}
**PRs created**: {count}
**Context**: {stack profile summary}

## Units
| # | Description | PR | Status |
|---|-------------|-----|--------|
| 1 | {unit desc} | #{pr} | {status} |
| 2 | {unit desc} | #{pr} | {status} |

## Project Context Applied
- Stack: {framework} ({language})
- Conventions: {key conventions followed}
- Reference files: {files used as transformation examples}

## Post-Batch Actions
- [ ] Review PRs (individually or batch review)
- [ ] Merge approved PRs
- [ ] Verify CI passes on all PRs
```

### Step 4: Post-Batch
Show the user:
1. **Summary** — how many units completed, how many PRs created
2. **Batch manifest** — location of the tracking document
3. **Next steps**:
   - Run `/blueprint-dev:bp:review` on individual PRs for detailed review
   - Merge PRs that look good
   - Re-run failed units individually with `/blueprint-dev:bp:build`

## Notes

- Each batch worker creates a small, focused PR — this is naturally TBD-compliant
- Workers run `/simplify` automatically as part of the built-in `/batch` flow
- The batch manifest at `.blueprint/batches/` tracks the operation for future reference
- If some units fail, the successful ones still produce valid PRs — handle failures individually
- For changes where files depend on each other, use `/blueprint-dev:bp:build` instead
