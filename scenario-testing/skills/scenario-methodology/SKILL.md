---
name: scenario-methodology
description: Framework for authoring, structuring, and managing scenarios — end-to-end user stories validated probabilistically by LLM-as-judge. Covers the holdout principle, scenario anatomy, versioning, composition, and anti-reward-hacking patterns.
---

# Scenario Methodology

This skill provides the conceptual and practical framework for scenario-based validation. A scenario is not a test — it is a structured user story that describes what a user wants to accomplish and what outcomes would satisfy them.

## When to Use

- `/scenario-testing:st:scenario` — authoring new scenarios
- `/scenario-testing:st:review` — reviewing and refining scenarios
- `/scenario-testing:st:catalog` — managing the scenario catalog
- When any agent needs to understand what a scenario is and how to write one

## Key Distinction: Scenario vs. Test

| Aspect | Traditional Test | Scenario |
|--------|-----------------|----------|
| **Stored** | In the codebase | Outside the codebase (holdout) |
| **Written in** | Code (assertions) | YAML (natural language criteria) |
| **Evaluator** | Test runner (boolean) | LLM-as-judge (probabilistic) |
| **Measures** | Correctness | Satisfaction |
| **Deterministic** | Yes (same input → same result) | No (same scenario → distribution of trajectories) |
| **Reward-hackable** | Yes (code can be shaped to pass) | Resistant (holdout + LLM judgment) |
| **Who understands it** | Developers | Anyone (product, design, QA, developers) |

## The Holdout Principle

Scenarios are stored outside the codebase by default (`.scenarios/` is gitignored). This mirrors the holdout set concept in machine learning:

1. **Training data** = your codebase, including unit and integration tests
2. **Holdout data** = your scenarios, stored separately
3. **Evaluation** = running scenarios against the code and measuring satisfaction

The model (code) is developed against training data (tests) but validated against holdout data (scenarios). This prevents overfitting — the code can't be shaped to trivially pass scenarios it doesn't see.

### When to Use In-Repo Scenarios

Not all scenarios need to be holdout. Use in-repo storage when:
- The team needs to collaboratively edit scenarios
- Scenarios are tied to specific features and should version with the code
- You trust the development process not to game the scenarios

Configure via `.scenarios/config.json`:
```json
{
  "storage": "in-repo"  // or "holdout" (default)
}
```

## Scenario Anatomy

Every scenario has 7 required sections and 2 optional sections:

### Required

1. **id** — unique identifier, kebab-case (e.g., `sso-login`, `export-to-sheets`)
2. **domain** — category grouping (e.g., `auth`, `onboarding`, `integrations`)
3. **version** — integer version number, bumped on changes
4. **persona** — who is the user (role, expertise, goals)
5. **context** — starting state (data, permissions, environment, services)
6. **intent** — what the user wants to accomplish (1-2 sentences)
7. **satisfaction_criteria** — list of outcomes that would satisfy the user

### Optional

8. **anti_patterns** — outcomes that would definitely NOT satisfy the user
9. **chaos** — failure conditions to inject during execution

### Writing Satisfaction Criteria

Good criteria are:
- **Specific enough to judge** — "Ticket has a descriptive title" is judgeable; "Ticket is good" is not
- **Flexible enough to allow valid variation** — "Priority is set appropriately (High or Medium for regression bugs)" allows judgment; "Priority is exactly High" is too rigid
- **User-centered** — describe what the user would notice, not what the code does internally
- **Independent** — each criterion can be evaluated separately

### Writing Anti-Patterns

Anti-patterns are the inverse of satisfaction criteria — they describe outcomes that are clearly wrong:
- "Raw error message shown to user"
- "Agent enters infinite retry loop"
- "Data is written to wrong account"
- "User is asked more than 3 clarifying questions before any action"

A trajectory that matches ANY anti-pattern is automatically judged "unsatisfactory", regardless of satisfaction criteria matches.

## Scenario Lifecycle

```
Draft → Review → Active → Versioned
                   ↑          │
                   └──────────┘ (update + version bump)
```

1. **Draft** — authored via `/st:scenario`, may be incomplete
2. **Review** — reviewed via `/st:review` by the scenario-reviewer agent
3. **Active** — in the catalog, used for validation runs
4. **Versioned** — updated with changelog, satisfaction history preserved per version

## Composition

Scenarios can be composed for complex workflows:

- **Sequential** — scenario A's end state is scenario B's start state
- **Parallel** — scenarios A and B run independently, overall satisfaction is the aggregate
- **Conditional** — scenario B only runs if scenario A's satisfaction meets a threshold

## References

- `references/scenario-template.md` — YAML template with field documentation
- `references/criteria-patterns.md` — Patterns for writing effective satisfaction criteria and anti-patterns
