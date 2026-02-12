---
name: bp:team-design
description: Design team swarm — variant generation, critique, and A/B test setup
argument-hint: Feature to design
---

# /blueprint-dev:bp:team-design

Run the design team swarm to create, evaluate, and wire up A/B design variants.

## Usage

```
/blueprint-dev:bp:team-design "checkout flow"
/blueprint-dev:bp:team-design
```

## Team Composition

| Order | Agent | Role |
|-------|-------|------|
| 1 (sequential) | design-variant-generator | Create 2-3 production variants |
| 2a (parallel) | design-critic | Evaluate variants on design principles |
| 2b (parallel) | ab-test-engineer | Wire up flags, tracking, test plan |

## Workflow

Use the **swarm-coordinator** to orchestrate:

1. **Generate variants** (sequential — must complete first)
   - design-variant-generator creates 2-3 real component variants
   - Waits for completion before proceeding

2. **Evaluate + Wire up** (parallel — both run on the variants)
   - design-critic evaluates usability, accessibility, hypothesis quality
   - ab-test-engineer creates flags, tracking, PLAN.md

3. **Aggregate** — coordinator merges results and presents:
   - Variant files created (paths)
   - Design critique comparison matrix
   - A/B test plan with metrics and rollout config

## Notes

- This is the same as `/blueprint-dev:bp:design` but explicitly invokes the swarm coordinator
- Variants are real production code, not mockups
- All code ships to trunk behind feature flags
