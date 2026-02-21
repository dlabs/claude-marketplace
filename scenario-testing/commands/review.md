---
name: st:review
description: Review and refine an existing scenario — check quality, update criteria, bump version
argument-hint: Scenario ID to review
---

# /scenario-testing:st:review

Review and refine an existing scenario.

## Usage

```
/scenario-testing:st:review "sso-login"
/scenario-testing:st:review "slack-to-jira"
/scenario-testing:st:review   # (will list scenarios to choose from)
```

## Workflow

### Step 1: Load the Scenario
- If no argument, show the catalog and let the user pick
- Read the scenario YAML file
- Read the latest satisfaction data for this scenario (if any)

### Step 2: Review
The **scenario-reviewer** agent performs a full review:
- Structure completeness
- Satisfaction criteria quality (specific, flexible, user-centered, independent)
- Anti-pattern quality (clear, observable, specific)
- Persona appropriateness
- Ambiguity detection
- Chaos configuration assessment

### Step 3: Satisfaction Context
If the scenario has been run before, include satisfaction data:
- Current satisfaction score
- Most common failure reasons (from judgments)
- Which criteria are rarely matched (possibly too rigid)
- Which anti-patterns are frequently matched (possibly too broad)

### Step 4: Present Review
Show the full review report with:
1. Structure assessment
2. Criteria quality table
3. Anti-pattern quality table
4. Satisfaction data insights (if available)
5. Specific recommendations for improvement

### Step 5: Iterate (Optional)
If the user wants to make changes:
- Apply suggested improvements
- Bump the version number
- Add a changelog entry
- Re-run the review to verify improvements

### Step 6: Save
Write the updated scenario YAML and update the catalog index.

## Notes

- Review doesn't change the scenario unless the user approves changes
- Version bumps preserve satisfaction history — you can compare scores across versions
- Running review after a satisfaction run is especially valuable — the judgment data reveals weaknesses in the scenario
