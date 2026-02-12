---
name: bp:team-full-swarm
description: Full swarm — sequential design, architecture, and review teams with approval gates
argument-hint: Feature to develop
---

# /blueprint-dev:bp:team-full-swarm

Run the complete multi-team swarm: design → architecture → review, with approval gates between each.

## Usage

```
/blueprint-dev:bp:team-full-swarm "dashboard redesign"
/blueprint-dev:bp:team-full-swarm
```

## Team Pipeline

```
team-design → [approval gate] → team-architecture → [approval gate] → team-review
```

### Phase 1: team-design
| Agent | Role |
|-------|------|
| design-variant-generator | Create 2-3 variants |
| design-critic | Evaluate variants |
| ab-test-engineer | Wire up flags + tracking |

**Gate**: "Approve design variants?"

### Phase 2: team-architecture
| Agent | Role |
|-------|------|
| architecture-strategist | Core design + ADR |
| security-sentinel | Security review |
| performance-oracle | Performance review |
| data-integrity-guardian | Data integrity review |

**Gate**: "Approve architecture? Address P1 findings?"

### Phase 3: team-review
| Agent | Role |
|-------|------|
| code-quality-reviewer | Code quality |
| test-coverage-analyst | Test coverage |
| trunk-guard | TBD compliance |
| pattern-recognizer | Pattern analysis |

**Gate**: "Review complete. Ready to ship?"

## Total Agents: 11

Use the **swarm-coordinator** to manage:
- Sequential team execution
- Result passing between teams
- Approval gates at each boundary
- Unified final report

## Notes

- Each team runs its internal agents in parallel
- Teams run sequentially because later teams review earlier teams' output
- User can stop at any gate and resume later
- All artifacts are saved for reference
