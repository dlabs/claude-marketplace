# Scenario Testing

Probabilistic scenario validation for agentic software. Replaces rigid boolean tests with LLM-judged user-story scenarios, satisfaction scoring across observed trajectories, and a Digital Twin Universe for behavioral clones of third-party services.

## Why Scenario Testing?

Traditional testing breaks down in agentic software:

- **Tests are too rigid** — when your software includes agent loops and LLM calls, evaluating success requires judgment, not string matching.
- **Tests can be reward-hacked** — a test stored next to the code can be lazily rewritten to match the code. The model can cheat.
- **"Test" is ambiguous** — unit tests, integration tests, e2e tests, and manual QA all answer different questions. None of them answer: *does this software satisfy the user?*

Scenario testing introduces **scenarios** — end-to-end user stories stored outside the codebase (like a holdout set in model training), validated by an LLM-as-judge, and scored probabilistically.

## Quick Start

### Install

```bash
claude plugin add ./scenario-testing
```

### 5-Minute Walkthrough

```bash
# 1. Initialize the scenario catalog
/scenario-testing:st:init

# 2. Author your first scenario from a user story
/scenario-testing:st:scenario "user logs in with SSO and sees their dashboard"

# 3. Build a digital twin for any third-party service you depend on
/scenario-testing:st:twin "okta"

# 4. Run the scenario (produces 50 trajectories by default)
/scenario-testing:st:run "sso-login"

# 5. Judge the trajectories and compute satisfaction
/scenario-testing:st:satisfy

# 6. View the report
/scenario-testing:st:report
```

Or run the full pipeline in one command:

```bash
/scenario-testing:st:validate
```

## What's Inside

| Component | Count | Description |
|-----------|-------|-------------|
| Commands  | 10    | Slash commands for every workflow phase |
| Agents    | 6     | Specialized AI agents for authoring, judging, and running scenarios |
| Skills    | 3     | Reference knowledge for methodology, twins, and metrics |
| Hooks     | 1     | Scenario catalog validation on session start |
| Scripts   | 3     | Catalog management, initialization, satisfaction reporting |

---

## Core Concepts

### Scenario

A structured user story describing a real-world workflow. Written in YAML, not code.

```yaml
id: slack-to-jira
domain: integrations
version: 1

persona:
  role: project-manager
  expertise: non-technical
  goals: "Track bugs reported in Slack as Jira tickets without manual copy-paste"

context:
  state:
    slack_channel: "#bug-reports"
    jira_project: "PROJ"
    message: "Login page is broken for Safari users. Blank white screen after Sign In."
  services:
    - slack
    - jira

intent: "Create a well-structured Jira ticket from this Slack message"

satisfaction_criteria:
  - "Ticket title is concise and descriptive (not the raw Slack message)"
  - "Description includes reproduction context (Safari, blank screen)"
  - "Priority is set appropriately (High or Medium)"
  - "Labels include relevant tags (browser-specific, login, regression)"
  - "The Slack message is linked or referenced in the ticket"

anti_patterns:
  - "Raw Slack message dumped as ticket title"
  - "Missing priority or defaulting to lowest priority"
  - "Ticket created in wrong project"
  - "Agent asks more than 2 clarifying questions before acting"

chaos:
  - type: latency
    target: jira
    delay_ms: 3000
    probability: 0.1
```

Key parts:
- **Persona** — who is the user?
- **Context** — what is the starting state?
- **Intent** — what does the user want?
- **Satisfaction criteria** — what outcomes would satisfy the user? (multiple valid outcomes allowed)
- **Anti-patterns** — what outcomes would definitely NOT satisfy the user?
- **Chaos** (optional) — injected failures and edge cases

### Trajectory

A single observed execution path through a scenario. Running a scenario 50 times produces 50 trajectories. Each trajectory records the actions taken, state transitions, and final outcome.

### Satisfaction

The fraction of trajectories that an LLM judge deems "satisfactory":

```
satisfaction = satisfactory_trajectories / total_trajectories
```

This replaces the boolean pass/fail of traditional tests with a probabilistic score:

```
Traditional:    pass / fail
Scenario:       0.88 satisfaction (44/50 trajectories satisfactory)
```

You can set thresholds per domain — auth must be > 0.95, onboarding can be > 0.75.

### Digital Twin

A behavioral clone of a third-party service (Okta, Jira, Slack, Google Sheets, etc.). Instead of mocking with static fixtures, twins replicate APIs, state machines, edge cases, and failure modes as local HTTP servers.

With twins you can:
- Validate at volumes exceeding production limits
- Test failure modes that are dangerous or impossible against live services
- Run thousands of scenarios per hour without rate limits or API costs
- Inject chaos (latency spikes, partial failures, schema changes) safely

### Catalog

The collection of all scenarios, organized by domain. Lives at `.scenarios/catalog/` and is indexed by `.scenarios/catalog.json`.

---

## Commands Reference

### Pipeline Commands

| Command | Description | Agents Used |
|---------|-------------|-------------|
| `st:init` | Initialize catalog, config, and directory structure | — |
| `st:scenario "story"` | Author a new scenario from a user story | scenario-author, scenario-reviewer |
| `st:twin "service"` | Build a digital twin for a third-party service | twin-builder, twin-validator |
| `st:run` | Execute scenarios and record trajectories | trajectory-runner |
| `st:satisfy` | Judge trajectories and compute satisfaction scores | satisfaction-judge |
| `st:report` | Generate and display the satisfaction report | — |

### Management Commands

| Command | Description |
|---------|-------------|
| `st:catalog` | List, search, and manage the scenario catalog |
| `st:review "scenario"` | Review and refine an existing scenario |
| `st:chaos "twin"` | Configure chaos injection for a twin |
| `st:validate` | Full pipeline: run all scenarios, judge, report |

All commands are prefixed with `/scenario-testing:` (e.g., `/scenario-testing:st:init`).

---

## Detailed Command Usage

### st:init — Initialize the Catalog

```bash
/scenario-testing:st:init
```

Creates the `.scenarios/` directory structure and default configuration. Asks whether to use **holdout mode** (gitignored, recommended) or **in-repo mode** (committed, shared with team).

**Directory structure created:**

```
.scenarios/
├── catalog.json                    # Index of all scenarios and twins
├── config.json                     # Thresholds, defaults, storage mode
├── catalog/                        # Scenario YAML files by domain
│   ├── auth/
│   ├── onboarding/
│   └── integrations/
├── twins/                          # Digital twin definitions
│   ├── okta/
│   │   ├── twin.json
│   │   ├── routes.yaml
│   │   ├── state-machine.yaml
│   │   └── chaos.yaml
│   └── jira/
├── runs/                           # Trajectory recordings per run
│   └── 2026-02-20-001/
│       ├── run-manifest.json
│       ├── trajectories/
│       └── judgments/
└── reports/                        # Satisfaction reports
    ├── latest.json
    └── history/
```

### st:scenario — Author a Scenario

```bash
# From a user story
/scenario-testing:st:scenario "user logs in with SSO and sees their dashboard"

# For a multi-service workflow
/scenario-testing:st:scenario "team lead exports monthly report to Google Sheets"

# Interactive (will prompt for the story)
/scenario-testing:st:scenario
```

The **scenario-author** agent translates natural language into structured YAML. It identifies the persona, maps required services, writes satisfaction criteria, and defines anti-patterns. The **scenario-reviewer** agent then reviews the scenario for completeness, ambiguity, and testability.

You approve, revise, or reject the scenario before it's saved.

**Example output:**

```
Scenario authored: integrations/slack-to-jira (v1)

Persona:     project-manager (non-technical)
Intent:      Create a Jira ticket from a Slack bug report
Criteria:    5 satisfaction criteria defined
Anti-patt:   4 anti-patterns defined
Services:    slack, jira (twins needed)

Review: PASS — criteria are specific and judgeable, anti-patterns are observable

Approve this scenario? (approve / revise / reject)
```

### st:twin — Build a Digital Twin

```bash
/scenario-testing:st:twin "jira"
/scenario-testing:st:twin "okta"
/scenario-testing:st:twin "google-sheets"
```

The **twin-builder** agent scans your codebase to discover which API endpoints you call, then generates a behavioral clone with:
- Route definitions for discovered endpoints
- A state machine for entity transitions
- Chaos modes based on the service's known failure patterns

The **twin-validator** agent verifies route coverage, state machine validity, schema accuracy, and chaos realism.

### st:run — Execute Scenarios

```bash
# Run one scenario
/scenario-testing:st:run "sso-login"

# Run all scenarios in a domain
/scenario-testing:st:run --domain auth

# Run entire catalog with 100 trajectories per scenario
/scenario-testing:st:run --count 100

# Run with aggressive chaos injection
/scenario-testing:st:run --chaos-profile hostile
```

The **trajectory-runner** agent executes each scenario N times, substituting twins for real services. Each trajectory records events, API calls, state transitions, and the final outcome.

**Options:**

| Flag | Description | Default |
|------|-------------|---------|
| `--count N` | Trajectories per scenario | 50 |
| `--domain NAME` | Run only scenarios in this domain | all |
| `--chaos-profile NAME` | Override chaos (gentle/moderate/hostile) | from config |
| `--parallel N` | Run N trajectories concurrently | 1 |

### st:satisfy — Judge Trajectories

```bash
# Judge the latest run
/scenario-testing:st:satisfy

# Judge a specific run
/scenario-testing:st:satisfy "2026-02-20-001"

# Re-judge previously judged trajectories
/scenario-testing:st:satisfy --rejudge
```

The **satisfaction-judge** agent evaluates each trajectory against the scenario's satisfaction criteria and anti-patterns:

1. **Anti-pattern check** — any match = unsatisfactory
2. **Satisfaction criteria match** — at least one must match
3. **Persona judgment** — would the persona accept this outcome?

A trajectory is satisfactory only if it matches at least one criterion, violates no anti-patterns, and would be acceptable to the described persona.

**Example output:**

```
Satisfaction Report — Run 2026-02-20-001

Overall: 0.91 (137/150 satisfactory)

  auth:              0.96  [PASS — threshold: 0.95]
    sso-login:       0.96  (48/50)
    password-reset:  0.96  (48/50)
  integrations:      0.82  [WARN — threshold: 0.85]
    slack-to-jira:   0.82  (41/50)

Failing: integrations/slack-to-jira (0.82 < 0.85)
  Most common failure: ticket title was raw Slack message (6 trajectories)
```

### st:report — View Satisfaction Report

```bash
# Latest report
/scenario-testing:st:report

# Compare to a previous run
/scenario-testing:st:report --compare-to 2026-02-15

# 30-day trend
/scenario-testing:st:report --trend --days 30

# JSON output for CI pipelines
/scenario-testing:st:report --format json --output satisfaction.json

# Filter to one domain
/scenario-testing:st:report --domain auth
```

**Comparison example:**

```
COMPARISON: 2026-02-20 vs 2026-02-15

Overall: 0.91 → was 0.89 (+0.02)

Scenario              Current  Previous  Delta
sso-login             0.96     0.97      -0.01
password-reset        0.95     0.90      +0.05
slack-to-jira         0.86     0.82      +0.04

Improvements: 2    Regressions: 0    Stable: 1
```

**Trend example:**

```
30-Day Satisfaction Trend

Date       | Auth  | Onboard | Integr. | Overall
2026-01-22 | 0.92  | 0.81    | 0.88    | 0.87
2026-01-29 | 0.94  | 0.83    | 0.89    | 0.89
2026-02-05 | 0.94  | 0.87    | 0.91    | 0.91
2026-02-12 | 0.95  | 0.88    | 0.85    | 0.89
2026-02-19 | 0.96  | 0.90    | 0.92    | 0.93
```

### st:catalog — Browse the Catalog

```bash
# Full catalog overview
/scenario-testing:st:catalog

# Filter to a domain
/scenario-testing:st:catalog "auth"

# Search by keyword
/scenario-testing:st:catalog --search "login"

# Show catalog health and recommendations
/scenario-testing:st:catalog --health
```

Health mode highlights missing twins, scenarios that have never been run, stale scenarios, and incomplete anti-patterns.

### st:review — Review a Scenario

```bash
/scenario-testing:st:review "sso-login"
```

The **scenario-reviewer** agent performs a full quality review: structure completeness, criteria specificity, anti-pattern quality, and persona appropriateness. If the scenario has been run before, the review includes satisfaction data — which criteria are rarely matched (too rigid?) and which anti-patterns are frequently triggered (too broad?).

Changes require your approval, and the version is bumped automatically.

### st:chaos — Configure Chaos

```bash
# Interactive configuration
/scenario-testing:st:chaos "jira"

# Apply a named profile
/scenario-testing:st:chaos "jira" --profile hostile

# Set specific failure probabilities
/scenario-testing:st:chaos "jira" --latency 0.1 --error-429 0.05

# Reset all chaos to defaults
/scenario-testing:st:chaos --reset
```

**Available chaos modes:**

| Mode | Description |
|------|-------------|
| `latency` | Random response delay (100-5000ms) |
| `error_429` | Rate limit exceeded |
| `error_500` | Internal server error |
| `error_503` | Service unavailable |
| `timeout` | Connection timeout |
| `partial_response` | Truncated response body |
| `stale_data` | Return stale/outdated data |
| `auth_expired` | Token expired error |

**Built-in profiles:**

| Profile | Description |
|---------|-------------|
| `gentle` | 5% latency, 1% server errors |
| `moderate` | 15% latency, 5% rate limits, 3% errors, 2% timeouts |
| `hostile` | 30% latency, 10% rate limits, 8% errors, 5% timeouts |

### st:validate — Full Pipeline

```bash
# Validate entire catalog
/scenario-testing:st:validate

# Validate one domain
/scenario-testing:st:validate --domain auth

# Validate one scenario with 100 trajectories
/scenario-testing:st:validate "sso-login" --count 100

# CI-friendly output
/scenario-testing:st:validate --format json --output satisfaction.json
```

Chains `st:run` → `st:satisfy` → `st:report` in one command with threshold checking. This is the most common command for regression validation after code changes.

---

## Examples

### Example 1: Validating an Agentic Feature

You've built an agent that creates Jira tickets from Slack messages. Traditional tests verify API calls happen, but can't judge whether the resulting ticket is *good*.

```bash
# Author the scenario
/scenario-testing:st:scenario "user asks agent to create Jira ticket from Slack message"

# Build twins for the services involved
/scenario-testing:st:twin "slack"
/scenario-testing:st:twin "jira"

# Run 50 trajectories, judge them, and report
/scenario-testing:st:run --count 50
/scenario-testing:st:satisfy
/scenario-testing:st:report
```

**Result:**

```
Scenario: slack-to-jira
Trajectories: 50
Satisfaction: 0.88 (44/50)

Failure analysis:
  - 3 trajectories: ticket title was raw Slack message (anti-pattern matched)
  - 2 trajectories: priority defaulted to 'Low' despite clear urgency signals
  - 1 trajectory: Jira latency caused timeout, ticket not created

Recommendation: satisfaction is below 0.90 threshold. Focus on title
summarization and priority inference.
```

### Example 2: Regression Check After Refactoring

You've refactored the auth module. Unit tests pass. Now validate user-facing behavior.

```bash
# Run all auth scenarios (written weeks ago, stored in holdout .scenarios/)
/scenario-testing:st:run --domain auth --count 100

# Judge and compare to the last run
/scenario-testing:st:satisfy
/scenario-testing:st:report --compare-to 2026-02-15
```

**Output:**

```
Domain: auth
Scenarios: 3 (sso-login, password-reset, mfa-enrollment)

Current run:     0.96 satisfaction (288/300 trajectories)
Previous run:    0.94 satisfaction (282/300 trajectories)
Delta:           +0.02 (improvement)

Per-scenario breakdown:
| Scenario        | Current | Previous | Delta  |
|-----------------|---------|----------|--------|
| sso-login       | 0.98    | 0.97     | +0.01  |
| password-reset  | 0.95    | 0.90     | +0.05  |
| mfa-enrollment  | 0.94    | 0.95     | -0.01  |

Verdict: Overall satisfaction improved. MFA enrollment slight regression
warrants investigation.
```

### Example 3: Scaling Past API Rate Limits with Twins

You integrate with Google Sheets and need to validate at scale, but Google's API has aggressive rate limits.

```bash
# Build a twin that replicates the Google Sheets API endpoints you use
/scenario-testing:st:twin "google-sheets"

# Configure chaos: 5% quota exceeded, 2% timeout
/scenario-testing:st:chaos "google-sheets" --quota-exceeded 0.05 --timeout 0.02

# Author the scenario and run 500 trajectories (impossible against the real API)
/scenario-testing:st:scenario "user exports monthly report to Google Sheets"
/scenario-testing:st:run --count 500
/scenario-testing:st:satisfy
/scenario-testing:st:report
```

**Result:**

```
Scenario: export-to-sheets
Trajectories: 500
Satisfaction: 0.93 (465/500)

Chaos impact:
  - quota_exceeded (25 injected): 20/25 handled gracefully (retry + backoff)
  - timeout (10 injected): 7/10 handled gracefully, 3/10 no user feedback

Recommendation: Add user-visible progress indicator for retry scenarios.
```

### Example 4: CI Integration

Run scenario validation as part of your CI pipeline:

```bash
/scenario-testing:st:validate --format json --output satisfaction.json
```

Parse `satisfaction.json` in your CI to fail the build if satisfaction drops below thresholds. The `satisfaction-summary.sh` script provides a quick alternative:

```bash
bash scripts/satisfaction-summary.sh --format ci
# Output: PASS satisfaction=0.91 trajectories=1500
# Exit code: 0 (pass) or 1 (fail)
```

---

## Configuration

### Thresholds

Set per-domain and per-scenario satisfaction thresholds in `.scenarios/config.json`:

```json
{
  "thresholds": {
    "global_minimum": 0.80,
    "domains": {
      "auth": 0.95,
      "onboarding": 0.75,
      "integrations": 0.85
    },
    "scenarios": {
      "sso-login": 0.98
    }
  },
  "defaults": {
    "trajectories_per_scenario": 50,
    "judge_model": "opus",
    "judge_temperature": 0.0,
    "chaos_profile": "gentle"
  }
}
```

### Storage Mode

- **Holdout (default)** — `.scenarios/` is gitignored. Scenarios are invisible to the codebase, preventing reward hacking.
- **In-repo** — `.scenarios/` is committed. Scenarios are shared with the team for collaborative editing.

### Custom Judges

Override the default judge with domain-specific criteria in any scenario file:

```yaml
judge_config:
  model: opus
  temperature: 0.0
  system_prompt: |
    You are a security-focused judge. Evaluate whether this trajectory
    would satisfy a security-conscious enterprise user. Pay special
    attention to: token handling, session management, data exposure in logs.
  strict_mode: true  # any anti-pattern match = unsatisfactory
```

### Scenario Composition

Compose complex workflows from simpler scenarios:

```yaml
id: onboarding-full
domain: onboarding
composed_from:
  - auth/sso-login
  - onboarding/first-project-setup
  - onboarding/team-invite-flow

composition_type: sequential

satisfaction_criteria:
  - "User completes full onboarding in under 5 minutes of active time"
  - "User ends with a configured project and at least one team member invited"
```

---

## Architecture

### Agent Organization

Six agents in three functional groups:

```
AUTHORING                    EXECUTION                  JUDGMENT
├── scenario-author          ├── trajectory-runner       ├── satisfaction-judge
└── scenario-reviewer        └── twin-builder            └── twin-validator
```

| Agent | Role |
|-------|------|
| **scenario-author** | Translates user stories into structured YAML scenarios |
| **scenario-reviewer** | Reviews scenarios for completeness, ambiguity, and testability |
| **trajectory-runner** | Executes scenarios against the codebase with twins substituted |
| **twin-builder** | Analyzes codebase to discover API usage and generates behavioral clones |
| **twin-validator** | Validates twin behavior against real service documentation |
| **satisfaction-judge** | Evaluates trajectories against criteria and anti-patterns |

### Skills

| Skill | Purpose | References |
|-------|---------|------------|
| **scenario-methodology** | How to write effective scenarios | `scenario-template.md`, `criteria-patterns.md` |
| **satisfaction-metrics** | How to judge and score satisfaction | `judge-prompt-template.md`, `report-schemas.md` |
| **digital-twin-universe** | How to build and validate twins | `twin-template.md`, `common-services.md` |

### Pipeline Flow

```
init → scenario → twin → run → satisfy → report
                                 ↑          │
                                 └──────────┘ (iterate)
```

| Starting Point | Use When |
|---------------|----------|
| `init → scenario` | First-time setup |
| `scenario → run → satisfy → report` | Adding scenarios for existing code |
| `twin → scenario → run → satisfy → report` | New service integration |
| `run → satisfy → report` | Regression check after code changes |
| `report` | Reviewing satisfaction trends |

### Satisfaction Computation

```
Per scenario:   satisfaction(S) = satisfactory_trajectories / total_trajectories
Per domain:     satisfaction(D) = mean(satisfaction(S) for S in domain)
Overall:        satisfaction    = weighted_mean(domain satisfactions, by trajectory count)
```

A trajectory is **satisfactory** when:
1. The outcome matches at least one satisfaction criterion, AND
2. The trajectory violates zero anti-patterns, AND
3. The described persona would consider the outcome acceptable

### How Scenarios Prevent Reward Hacking

Scenarios are stored outside the codebase (holdout mode), describe what the *user* wants (not what the code does), and are judged by an LLM that evaluates satisfaction (not output matching). Chaos injection adds non-determinism that static fixtures cannot anticipate.

---

## Integration with blueprint-dev

If you also use the [blueprint-dev](../blueprint-dev) plugin:

| After this blueprint-dev command | Run this scenario-testing command |
|----------------------------------|-----------------------------------|
| `/blueprint-dev:bp:build` | `/scenario-testing:st:validate` |
| `/blueprint-dev:bp:ship` | `/scenario-testing:st:run --domain affected` |
| `/blueprint-dev:bp:plan` | Reference `.scenarios/reports/latest.json` to identify weak areas |
| `/blueprint-dev:bp:compound` | Author new scenarios for the solved problem |

---

## License

MIT
