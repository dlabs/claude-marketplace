---
name: team-review
description: Review team swarm — parallel code quality, test coverage, TBD compliance, and pattern analysis
---

# /blueprint-dev:team-review

Run the review team swarm for a comprehensive parallel code review.

## Usage

```
/blueprint-dev:team-review
/blueprint-dev:team-review --files src/auth/
```

## Team Composition

| Order | Agent | Role |
|-------|-------|------|
| 1a (parallel) | code-quality-reviewer | Style, patterns, conventions |
| 1b (parallel) | test-coverage-analyst | Test completeness, gaps, edge cases |
| 1c (parallel) | trunk-guard | Branch age, PR size, TBD compliance |
| 1d (parallel) | pattern-recognizer | Anti-patterns, SOLID, refactoring |

## Workflow

Use the **swarm-coordinator** to orchestrate:

1. **Parallel review** — all 4 agents review simultaneously
2. **Aggregate** — coordinator merges into unified report:
   - P1/P2/P3 findings from all agents
   - Deduplicated (same issue from multiple agents kept once at highest priority)
   - TBD compliance status
   - Test coverage map
3. **Present** — summary table + detailed findings

## Output

`.blueprint/reviews/{date}-review.md` with unified P1/P2/P3 findings.

## Notes

- All agents run in parallel for maximum speed
- Findings are attributed to their source agent
- The same as `/blueprint-dev:review` but explicitly invokes the swarm coordinator
