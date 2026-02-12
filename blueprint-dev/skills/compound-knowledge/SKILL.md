---
name: compound-knowledge
description: Problem documentation methodology for compounding team knowledge. Captures solved problems with structured metadata for searchability, pattern detection, and prevention.
---

# Compound Knowledge

This skill provides the methodology for documenting solved problems so they compound into team knowledge over time. Every solved problem becomes a searchable, referenceable document that helps prevent recurrence and informs future work.

## When to Use

- `/blueprint-dev:compound` — after solving a problem
- Auto-suggested by the Stop hook when confirmation phrases are detected
- Manually when a developer wants to document a significant debugging session

## Knowledge Loop

```
Solve problem → /compound → docs/solutions/ → /plan reads solutions → avoids repeating mistakes
```

The research-scout agent (used in `/plan`) searches `docs/solutions/` before planning new features. This closes the loop — past learnings compound into future plans.

## 5-Agent Parallel Swarm

| Agent | Extracts | Output |
|-------|----------|--------|
| context-analyzer | Problem metadata: module, symptom, environment, timeline | Problem Context section |
| solution-extractor | Root cause, code changes, verification | Root Cause + Solution sections |
| related-docs-finder | Cross-references in docs/solutions/ | Related Solutions section |
| prevention-strategist | Tests, lint rules, monitoring to prevent recurrence | Prevention section |
| category-classifier | Category, severity, tags for searchability | YAML frontmatter |

## Document Structure

```markdown
---
title: "Brief description"
date: YYYY-MM-DD
category: {enum}
severity: {enum}
module: {name}
tags: [tag1, tag2, tag3]
root_cause: "One-line root cause"
prevention: "One-line prevention"
---

## Problem Context
{From context-analyzer}

## Root Cause
{From solution-extractor}

## Solution
{From solution-extractor}

## Prevention Strategy
{From prevention-strategist}

## Related Solutions
{From related-docs-finder}
```

## References

- `references/yaml-schema.md` — YAML frontmatter enum validation
- `references/category-taxonomy.md` — Category definitions and tagging guidelines
