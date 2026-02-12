---
name: bp:team-compound
description: Compound knowledge team swarm — parallel problem analysis, solution capture, cross-referencing, prevention, and classification
---

# /blueprint-dev:bp:team-compound

Run the compound knowledge team swarm to document a solved problem.

## Usage

```
/blueprint-dev:bp:team-compound
/blueprint-dev:bp:team-compound "fixed token refresh race condition"
```

## Team Composition

| Order | Agent | Role |
|-------|-------|------|
| 1a (parallel) | context-analyzer | Problem metadata extraction |
| 1b (parallel) | solution-extractor | Root cause + code changes |
| 1c (parallel) | related-docs-finder | Cross-references in knowledge base |
| 1d (parallel) | prevention-strategist | Prevention measures |
| 1e (parallel) | category-classifier | YAML frontmatter tags |
| 2 (sequential) | coordinator | Assemble final document |

## Workflow

Use the **swarm-coordinator** to orchestrate:

1. **Parallel extraction** — all 5 agents analyze the conversation simultaneously
2. **Assembly** — coordinator combines outputs into final document
3. **Save** — write to `docs/solutions/{category}/{filename}.md`
4. **Present** — show summary and offer post-compound options

## Output

`docs/solutions/{category}/{symptom}-{module}-{date}.md` with validated YAML frontmatter.

## Notes

- All extraction agents run in parallel for speed
- The coordinator assembles after all agents complete
- Same as `/blueprint-dev:bp:compound` but explicitly invokes the swarm coordinator
