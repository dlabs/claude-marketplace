---
name: team-architecture
description: Architecture team swarm — parallel security, performance, data integrity, and core architecture review
argument-hint: System to review
---

# /blueprint-dev:team-architecture

Run the architecture team swarm for a comprehensive parallel architecture review.

## Usage

```
/blueprint-dev:team-architecture "payment system"
/blueprint-dev:team-architecture
```

## Team Composition

| Order | Agent | Role |
|-------|-------|------|
| 1a (parallel) | architecture-strategist | Core design + ADR |
| 1b (parallel) | security-sentinel | OWASP, auth, injection review |
| 1c (parallel) | performance-oracle | N+1, caching, bottleneck analysis |
| 1d (parallel) | data-integrity-guardian | Schema, migrations, constraints |

## Workflow

Use the **swarm-coordinator** to orchestrate:

1. **Parallel review** — all 4 agents analyze simultaneously
2. **Aggregate** — coordinator merges into unified ADR:
   - Core architecture design
   - Security assessment summary
   - Performance assessment summary
   - Data integrity assessment summary
3. **Conflict resolution** — if agents disagree, flag for user

## Notes

- All agents run in parallel for maximum speed
- Results are merged into a single ADR at `.blueprint/adrs/`
- P1 findings from any agent should be addressed before building
