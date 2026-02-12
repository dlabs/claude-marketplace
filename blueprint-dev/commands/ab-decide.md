---
name: ab-decide
description: Analyze A/B test results, determine statistical significance, recommend winner, produce cleanup plan
argument-hint: A/B test name
---

# /blueprint-dev:ab-decide

Analyze A/B test results and make a data-driven decision on which variant to promote.

## Usage

```
/blueprint-dev:ab-decide "login-page"
/blueprint-dev:ab-decide   # (will list active tests to choose from)
```

## Workflow

### Step 1: Select Test
If no test name provided, show active tests from `/blueprint-dev:ab-status` and ask user to select one.

### Step 2: Gather Results
Ask the user to provide results data from their analytics platform:
- Primary metric values per variant
- Sample sizes per variant
- Test duration
- Any guardrail metric observations
- Statistical significance (p-value) if available from their tool

### Step 3: Analyze
Use the **design-decision-analyst** agent to:
- Verify statistical significance
- Check guardrail metrics
- Evaluate practical significance
- Make a recommendation

### Step 4: Document Decision
The agent writes `docs/ab-tests/{test-name}/DECISION.md` with:
- Results summary table
- Statistical analysis
- Decision and reasoning
- Concrete cleanup plan (files to modify/delete)
- Learnings for future reference

### Step 5: Present and Confirm
Show the user:
1. **Results analysis** — statistical summary
2. **Recommendation** — which variant to promote (or keep control)
3. **Cleanup plan** — what files will change
4. **Next step**: Run `/blueprint-dev:ab-cleanup` to execute the cleanup

## Notes

- The decision is documented but not executed — `/ab-cleanup` does the actual code changes
- If results are inconclusive, the recommendation will be to keep the control (simpler code)
- The DECISION.md becomes part of the project's permanent knowledge
