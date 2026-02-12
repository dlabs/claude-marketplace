---
name: bp:plan
description: Deep planning with requirements decomposition, research, and scope guard
argument-hint: Feature or task to plan
---

# /blueprint-dev:bp:plan

Deep planning workflow for a feature or task. Produces a structured plan with requirements, research findings, and scope boundary.

## Usage

```
/blueprint-dev:bp:plan "add user authentication"
/blueprint-dev:bp:plan "redesign settings page"
/blueprint-dev:bp:plan   # (will ask what to plan)
```

## Workflow

### Step 1: Requirements Analysis
Use the **requirements-analyst** agent to decompose the feature request:
- Break into functional requirements with Given/When/Then acceptance criteria
- Identify non-functional requirements
- Map dependencies and risks
- Estimate size and suggest phase splitting
- Outline test strategy

Output: `.blueprint/plans/{date}-{feature-slug}.md`

### Step 2: Research
Use the **research-scout** agent to investigate:
- Search existing codebase for reusable patterns
- Search `docs/solutions/` for related past problems (compound knowledge)
- Evaluate libraries and external approaches
- Produce evidence-based recommendation

Output: Appended as "Research Findings" section to the plan doc

### Step 3: Scope Guard
Use the **scope-sentinel** agent to review:
- Flag any scope creep or YAGNI violations
- Suggest simplifications
- Produce clean scope boundary

Output: Appended as "Scope Assessment" section to the plan doc

### Step 4: Present for Approval
Show the user:
1. **Plan summary** — what will be built
2. **Key decisions** — approach chosen and why
3. **Scope flags** — anything the scope sentinel flagged
4. **Research highlights** — most important findings
5. **Next steps** — proceed to `/blueprint-dev:bp:design` or `/blueprint-dev:bp:architect`

## Notes

- If `.blueprint/stack-profile.json` doesn't exist, suggest running `/blueprint-dev:bp:discover` first
- Plans are cumulative — running `/plan` again creates a new plan, doesn't overwrite old ones
- The research-scout's search of `docs/solutions/` closes the compound knowledge loop
- All three agents run sequentially because each builds on the previous output
