---
name: design
description: Create 2-3 production A/B design variants with feature flags, tracking, and test plan
argument-hint: Component or feature to design
---

# /blueprint-dev:design

Create production-quality A/B design variants for a feature. Generates real code in the source tree with feature flags, analytics tracking, and a documented test plan.

## Usage

```
/blueprint-dev:design "login page"
/blueprint-dev:design "settings dashboard"
/blueprint-dev:design   # (will ask what to design)
```

## Prerequisites

- Run `/blueprint-dev:discover` first (or have `.blueprint/stack-profile.json`)
- Recommended: run `/blueprint-dev:plan` first to have requirements defined

## Workflow

### Step 1: Generate Variants
Use the **design-variant-generator** agent to create 2-3 production-quality design variants in the source tree. Each variant:
- Is a fully functional component following project conventions
- Differs in at least 1 meaningful UX dimension (layout, interaction, hierarchy, density, navigation)
- Includes a documented design hypothesis

### Step 2: Design Critique
Use the **design-critic** agent to evaluate variants on:
- Usability heuristics (Nielsen's 10)
- Information architecture
- Interaction design
- Accessibility
- Hypothesis quality

Present the critique to the user with a comparison matrix.

### Step 3: Wire Up A/B Test
Use the **ab-test-engineer** agent to:
- Create the feature flag integration (auto-detected from stack profile)
- Create the variant wrapper component
- Set up analytics tracking events
- Write the test plan document (`docs/ab-tests/{test-name}/PLAN.md`)
- Register the test in the A/B test registry

### Step 4: Present Results
Show the user:
1. **Variants created** — file paths and descriptions
2. **Design critique** — comparison matrix and key findings
3. **Test plan** — hypothesis, metrics, sample size, timeline
4. **Next steps**: Ship to trunk (code is behind flags), or iterate on variants

## Notes

- All variants ship to trunk behind feature flags — no long-lived branches
- The control variant (Variant A) is always the current/simpler approach
- Use `/blueprint-dev:ab-status` to check active tests
- Use `/blueprint-dev:ab-decide` when results are available
- Use `/blueprint-dev:ab-cleanup` to remove losing variant after decision
