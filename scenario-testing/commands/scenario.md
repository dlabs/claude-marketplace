---
name: st:scenario
description: Author a new scenario from a user story — translates natural language into structured YAML with persona, criteria, and anti-patterns
argument-hint: User story to convert into a scenario
---

# /scenario-testing:st:scenario

Author a new scenario from a natural-language user story.

## Usage

```
/scenario-testing:st:scenario "user logs in with SSO and sees their dashboard"
/scenario-testing:st:scenario "team lead exports monthly report to Google Sheets"
/scenario-testing:st:scenario   # (will ask for the user story)
```

## Workflow

### Step 1: Gather Input
If no argument provided, ask the user:
- "Describe the user story you want to validate"
- "What domain does this belong to?" (suggest existing domains from catalog, or create new)

### Step 2: Check for Duplicates
Use the **scenario-author** agent to:
- Read `.scenarios/catalog.json` for existing scenarios
- Search existing scenarios for similar intents
- If a similar scenario exists, ask: "A similar scenario already exists ({id}). Create a new one, or extend the existing one?"

### Step 3: Author the Scenario
The **scenario-author** agent produces a structured YAML scenario:
- Identifies the persona from the user story
- Maps the context (starting state, services needed)
- Writes the intent as a clear 1-2 sentence goal
- Defines satisfaction criteria (3-5 specific, judgeable outcomes)
- Defines anti-patterns (3-5 catastrophic failure modes)
- Configures chaos if external services are involved

Output: `.scenarios/catalog/{domain}/{id}.scenario.yaml`

### Step 4: Review the Scenario
The **scenario-reviewer** agent reviews the authored scenario:
- Checks structure completeness
- Evaluates criteria quality (specific? flexible? user-centered?)
- Evaluates anti-pattern quality
- Flags ambiguity
- Produces a review report

### Step 5: Present for Approval
Show the user:
1. **Scenario summary** — id, domain, persona, intent
2. **Satisfaction criteria** — what success looks like
3. **Anti-patterns** — what failure looks like
4. **Review findings** — any issues the reviewer flagged
5. **Services needed** — which twins are required (and whether they exist)

Ask: "Approve this scenario? (approve / revise / reject)"

### Step 6: Save and Index
If approved:
- Write the scenario YAML to `.scenarios/catalog/{domain}/{id}.scenario.yaml`
- Update `.scenarios/catalog.json` with the new scenario entry
- If services are listed but twins don't exist, suggest: "Run `/scenario-testing:st:twin {service}` to build the missing twin"

## Notes

- Both agents (scenario-author and scenario-reviewer) run sequentially — the reviewer needs the author's output
- Scenarios start at version 1
- The domain directory is auto-created if it doesn't exist
- If `.scenarios/` doesn't exist, suggest running `/scenario-testing:st:init` first
