---
name: bp:review
description: Multi-agent parallel code review — quality, tests, TBD compliance, and pattern analysis
---

# /blueprint-dev:bp:review

Run a comprehensive code review using 4 parallel specialist agents. Produces a unified review report with P1/P2/P3 findings.

## Usage

```
/blueprint-dev:bp:review
/blueprint-dev:bp:review --files src/auth/
```

## Workflow

### Step 1: Determine Scope
Identify what to review:
- If on a feature branch: review changes from `main...HEAD`
- If files specified: review those files
- If no branch/files: ask the user what to review

### Step 2: Parallel Review
Launch four agents **in parallel** using the Task tool:

1. **code-quality-reviewer** — style, patterns, clean code, conventions
2. **test-coverage-analyst** — test completeness, gaps, edge cases
3. **trunk-guard** — branch age, PR size, CI status, TBD compliance
4. **pattern-recognizer** — anti-patterns, SOLID violations, refactoring opportunities

### Step 3: Aggregate Results
Collect all findings and merge into a unified review report at `.blueprint/reviews/{date}-review.md`:

```markdown
# Code Review: {branch or scope}

**Date**: {YYYY-MM-DD}
**Reviewers**: code-quality, test-coverage, trunk-guard, pattern-recognizer

## P1 — Must Fix
{All P1 findings across all agents}

## P2 — Should Fix
{All P2 findings across all agents}

## P3 — Consider
{All P3 findings across all agents}

## TBD Compliance
{trunk-guard's compliance report}

## Test Coverage
{test-coverage-analyst's coverage map}

## Summary
| Agent | P1 | P2 | P3 |
|-------|----|----|-----|
| Quality | {n} | {n} | {n} |
| Tests | {n} | {n} | {n} |
| TBD | {n} | {n} | {n} |
| Patterns | {n} | {n} | {n} |
| **Total** | {n} | {n} | {n} |
```

### Step 4: Present Results
Show the user:
1. **P1 blockers** — must fix before merging (if any)
2. **P2 recommendations** — should fix (with effort estimates)
3. **P3 suggestions** — consider for future improvement
4. **TBD compliance** — branch health and merge readiness
5. **Test coverage** — requirements coverage map and gaps

### Step 5: Offer Next Steps
- "Fix P1 issues and re-run `/blueprint-dev:bp:review`"
- "Run `/blueprint-dev:bp:ship` when ready to merge"
- "Run `/blueprint-dev:bp:compound` if this fixed a bug worth documenting"

## Notes

- The 4 agents run in parallel for speed — no dependencies between them
- All agents read the stack profile to adapt their review standards
- P1/P2/P3 priority is consistent across all agents
- Review results are saved for reference, not just displayed
