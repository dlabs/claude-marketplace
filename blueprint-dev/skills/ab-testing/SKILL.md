---
name: ab-testing
description: Production A/B testing lifecycle for design variants. Covers hypothesis formation, feature flag integration, analytics tracking, statistical analysis, and cleanup.
---

# A/B Testing

This skill provides the complete lifecycle for production A/B testing of design variants. Variants are real, production-quality code — not mockups.

## Lifecycle

```
CREATE (/design) → DEPLOY (trunk + flags) → MEASURE (analytics) → DECIDE (/ab-decide) → CLEANUP (/ab-cleanup)
```

### 1. CREATE
`/blueprint-dev:design` uses the design-variant-generator to create 2-3 real component variants, the design-critic to evaluate them, and the ab-test-engineer to wire up flags and tracking.

### 2. DEPLOY
Variants ship to trunk behind feature flags. Compatible with trunk-based development — no long-lived branches needed.

### 3. MEASURE
Analytics tracking fires at key interaction points. Users monitor their analytics dashboard for results.

### 4. DECIDE
`/blueprint-dev:ab-decide` uses the design-decision-analyst to interpret results and recommend a winner based on statistical significance.

### 5. CLEANUP
`/blueprint-dev:ab-cleanup` follows the decision document's cleanup plan to remove the losing variant, promote the winner, and clean up flags/tracking.

## Key Principles

- **Meaningful differences**: Variants must differ in layout, interaction, hierarchy, density, or navigation — not just cosmetics
- **Statistical rigor**: p < 0.05, 80% power, calculated sample sizes
- **Guardrail metrics**: Tests auto-stop if critical metrics degrade
- **Clean cleanup**: Every test ends with a clean codebase — no lingering dead code

## References

- `references/tracking-plan-template.md` — Template for tracking plans
- `references/code-templates.md` — Stack-specific code templates for wrappers, flags, and tracking
