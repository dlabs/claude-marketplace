---
name: eval-runner
description: "Run evaluation suites against blueprint-dev skills. Benchmarks skill performance, tracks pass rates, and validates skill quality after changes."
disable-model-invocation: true
argument-hint: "[skill-name|all]"
---

# Eval Runner

Run evaluation suites to benchmark and validate blueprint-dev skills. Evals test that skills produce the expected behavior — correct tool usage, proper classification, adherence to constraints.

## How It Works

1. Read eval definitions from `${CLAUDE_SKILL_DIR}/../evals/`
2. For each eval suite, load the `eval.yaml` config
3. For each prompt in the suite, spawn a test agent with the skill loaded
4. Collect responses and check against criteria
5. Produce a benchmark report

## Eval Structure

```
evals/
  config.yaml              # Global config (priority, classification)
  <skill-name>/
    eval.yaml              # Eval definition with prompts + criteria
    prompts/
      <test-name>.md       # Individual test prompts
    fixtures/              # Optional test data
      <file>
```

## Running Evals

### Single Skill
```
/bp:eval agent-browser
```

### All Skills
```
/bp:eval all
```

### By Priority
```
/bp:eval --priority high
```

## Eval Definition Format

Each `eval.yaml` defines:

```yaml
name: skill-name
skill: skill-name
classification: capability_uplift | encoded_preference

prompts:
  - name: test-name
    file: prompts/test-name.md
    fixtures:              # Optional
      - fixtures/file.json
    criteria:
      - type: contains | not_contains | matches_regex
        value: "expected string or pattern"
        reason: "Why this matters"
```

## Criteria Types

| Type | Description |
|------|-------------|
| `contains` | Response must contain the value |
| `not_contains` | Response must NOT contain the value |
| `matches_regex` | Response must match the regex pattern |

## Execution Strategy

- **Parallel by default**: Each prompt runs as an independent agent
- **Skill loaded**: The target skill is loaded into the test agent's context
- **No side effects**: Evals should not modify files or run destructive commands
- **Timeout**: 30 seconds per prompt (configurable in config.yaml)

## Report Format

```
=== Blueprint-Dev Eval Report ===

agent-browser (Capability Uplift - HIGH)
  [PASS] navigate-and-click (3/3 criteria)
  [PASS] fill-form (3/3 criteria)
  [PASS] anti-playwright (4/4 criteria)

git-worktree (Capability Uplift - HIGH)
  [PASS] create-worktree (3/3 criteria)
  [FAIL] anti-raw-git (2/3 criteria)
    - FAILED: not_contains "git worktree add"

Summary: 4/5 passed (80%)
```

## Skill Classifications

- **Capability Uplift**: Teaches techniques Claude doesn't know natively. Evals focus on correct tool/pattern usage. Strict pass criteria.
- **Encoded Preference**: Encodes team/project preferences. Evals focus on classification accuracy and compliance. Standard pass criteria.

## When to Run Evals

- After modifying a skill's SKILL.md
- After updating skill descriptions
- Before version bumps
- As part of CI for the plugin repository
