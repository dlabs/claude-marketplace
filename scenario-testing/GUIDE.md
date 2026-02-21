# Scenario Testing: The Complete Guide

Probabilistic scenario validation for agentic software.

---

## Table of Contents

1. [Introduction](#introduction)
2. [Philosophy](#philosophy)
3. [Core Concepts](#core-concepts)
4. [Installation & Setup](#installation--setup)
5. [The Pipeline](#the-pipeline)
6. [Commands Reference](#commands-reference)
7. [Use Cases](#use-cases)
8. [Advanced Usage](#advanced-usage)
9. [Architecture Deep Dive](#architecture-deep-dive)
10. [Customization](#customization)

---

## Introduction

Scenario-testing is a Claude Code plugin that replaces rigid, boolean test suites with probabilistic, LLM-judged validation of user stories. It is designed for codebases where agents and LLMs are first-class design primitives — where "the test suite is green" is no longer a sufficient definition of success.

### The Problem

Traditional testing breaks down in agentic software:

1. **Tests are too rigid** — when your software includes agent loops and LLM calls as design primitives, evaluating success requires judgment, not string matching. An LLM-as-judge is the natural evaluator.
2. **Tests can be reward-hacked** — a test stored next to the code it validates can be lazily rewritten to match the code, or the code can be trivially adjusted to pass the test. The model can cheat.
3. **"Test" is ambiguous** — the word covers unit tests, integration tests, e2e tests, property tests, and manual QA. None of these alone answer: "does this software satisfy the user?"

### The Answer

We repurpose the word **scenario** to mean an end-to-end user story that:
- Is stored **outside the codebase** (like a holdout set in model training)
- Can be **intuitively understood** by humans and **flexibly validated** by an LLM
- Produces a **probabilistic satisfaction score**, not a boolean pass/fail

We use the term **satisfaction** to quantify validation: of all the observed trajectories through all the scenarios, what fraction of them likely satisfy the user?

### What It Contains

| Component | Count | Description |
|-----------|-------|-------------|
| Agents | 6 | Specialized AI agents for authoring, judging, and running scenarios |
| Commands | 10 | Slash commands for every workflow phase |
| Skills | 3 | Reference knowledge for methodology, twins, and metrics |
| Hooks | 1 | Scenario catalog validation on session start |
| Scripts | 3 | Catalog management, twin scaffolding, satisfaction reporting |

### Who It's For

- Teams building software with agentic components (LLM calls, agent loops, tool use)
- Projects integrating multiple third-party APIs that need behavioral validation
- Organizations transitioning from boolean test suites to probabilistic quality metrics
- Anyone who has experienced reward-hacking — where tests pass but users aren't satisfied

---

## Philosophy

### From Boolean to Probabilistic

Traditional testing produces a binary signal: green or red. Scenario testing produces a **satisfaction distribution**:

```
Traditional:    ✓ pass / ✗ fail
Scenario:       0.87 satisfaction (174/200 trajectories satisfactory)
```

This shift matters because:
- Agentic software is inherently non-deterministic — the same input can produce different valid outputs
- User satisfaction is a spectrum, not a binary — "mostly works" is different from "completely broken"
- A satisfaction score degrades gracefully — you can set thresholds per scenario (e.g., "auth must be > 0.95, onboarding can be > 0.75")

### The Holdout Principle

Scenarios are stored **outside the codebase** by default, in `.scenarios/` (gitignored) or in a separate repository. This mirrors the holdout set in machine learning:

- The model (your code) never sees the validation data (scenarios) during training (development)
- This prevents reward-hacking — the code can't be shaped to trivially pass scenarios it doesn't have access to
- Scenarios can also be stored in-repo for collaborative editing, but the separation option is the key differentiator

### The Digital Twin Universe

The Digital Twin Universe (DTU) is a collection of behavioral clones of third-party services your software depends on. Instead of mocking Okta, Jira, Slack, or Google Sheets with static fixtures, you build **twins** that replicate their APIs, edge cases, and observable behaviors.

With twins:
- Validate at volumes and rates exceeding production limits
- Test failure modes dangerous or impossible against live services
- Run thousands of scenarios per hour without rate limits, abuse detection, or API costs
- Introduce chaos (latency spikes, partial failures, schema changes) safely

### Satisfaction Over Correctness

We deliberately use "satisfaction" rather than "correctness" because:
- Correctness implies a single right answer — agentic software often has many valid paths
- Satisfaction centers the user — did the trajectory through the scenario produce an outcome the user would accept?
- Satisfaction is measurable empirically — run N trajectories, judge each, compute the fraction

---

## Core Concepts

### Scenario

A scenario is a structured user story describing a real-world workflow. It contains:

- **Persona** — who is the user? (role, expertise, goals)
- **Context** — what is the starting state? (data, permissions, environment)
- **Intent** — what does the user want to accomplish?
- **Steps** — ordered actions the user takes (flexible, not prescriptive)
- **Satisfaction criteria** — what outcomes would satisfy this user? (multiple valid outcomes allowed)
- **Anti-patterns** — what outcomes would definitely NOT satisfy the user?
- **Chaos conditions** (optional) — injected failures, latency, edge cases

Scenarios are written in YAML with natural-language descriptions, not in code.

### Trajectory

A trajectory is a single observed execution path through a scenario. Running a scenario N times produces N trajectories. Each trajectory records:

- The actions taken (API calls, tool invocations, LLM responses)
- The state transitions observed
- The final outcome
- The wall-clock time and token cost

### Satisfaction

Satisfaction is the fraction of trajectories that an LLM judge deems "satisfactory" for the user described in the scenario. It is computed as:

```
satisfaction = satisfactory_trajectories / total_trajectories
```

Each trajectory is judged independently by the satisfaction-judge agent, which considers:
- Did the outcome match any of the satisfaction criteria?
- Did the trajectory avoid all anti-patterns?
- Would the persona described in the scenario consider this outcome acceptable?

### Digital Twin

A digital twin is a behavioral clone of a third-party service. It implements:

- **API surface** — the endpoints your software actually calls
- **State machine** — the internal state transitions (e.g., Jira ticket status flow)
- **Edge cases** — rate limits, validation errors, eventual consistency
- **Chaos modes** — configurable failure injection

Twins are local HTTP servers that your software talks to instead of the real service during scenario runs.

### Catalog

The scenario catalog is the collection of all scenarios, organized by domain. It lives at `.scenarios/catalog/` and is indexed by `.scenarios/catalog.json`.

---

## Installation & Setup

### Install the Plugin

```bash
# From the directory containing scenario-testing/
claude plugin add ./scenario-testing

# Or specify the plugin directory directly
claude --plugin-dir ./scenario-testing
```

### What Happens on First Session

When you start a Claude Code session with scenario-testing installed, the **SessionStart hook** runs `catalog-check.sh`. This checks whether a scenario catalog exists and reports its status:

```
[scenario-testing] Scenario catalog: 12 scenarios across 4 domains, 3 twins configured.
Last satisfaction run: 2026-02-19 — overall satisfaction: 0.91
Run /scenario-testing:st:report for details.
```

If no catalog exists:
```
[scenario-testing] No scenario catalog found. Run /scenario-testing:st:init to create one.
```

### First-Time Workflow

```bash
# 1. Initialize the scenario catalog
/scenario-testing:st:init

# 2. Author your first scenario
/scenario-testing:st:scenario "user logs in with SSO"

# 3. Build a digital twin (if you depend on external services)
/scenario-testing:st:twin "okta"

# 4. Run the scenario and measure satisfaction
/scenario-testing:st:run "user logs in with SSO"

# 5. View the satisfaction report
/scenario-testing:st:report
```

### Directory Structure Created

**`.scenarios/`** — scenario catalog and run history (gitignored by default):
```
.scenarios/
├── catalog.json                    # Index of all scenarios and twins
├── config.json                     # Plugin configuration
├── catalog/
│   ├── auth/
│   │   ├── sso-login.scenario.yaml
│   │   ├── password-reset.scenario.yaml
│   │   └── mfa-enrollment.scenario.yaml
│   ├── onboarding/
│   │   ├── first-project-setup.scenario.yaml
│   │   └── team-invite-flow.scenario.yaml
│   └── integrations/
│       ├── jira-ticket-sync.scenario.yaml
│       └── slack-notification.scenario.yaml
├── twins/
│   ├── okta/
│   │   ├── twin.json               # Twin manifest
│   │   ├── routes.yaml             # API endpoint definitions
│   │   ├── state-machine.yaml      # State transition rules
│   │   └── chaos.yaml              # Failure injection config
│   ├── jira/
│   │   └── ...
│   └── slack/
│       └── ...
├── runs/
│   ├── 2026-02-19-001/
│   │   ├── run-manifest.json       # Run metadata
│   │   ├── trajectories/
│   │   │   ├── sso-login-001.json
│   │   │   ├── sso-login-002.json
│   │   │   └── ...
│   │   └── judgments/
│   │       ├── sso-login-001.json
│   │       └── ...
│   └── 2026-02-20-001/
│       └── ...
└── reports/
    ├── latest.json                 # Most recent satisfaction report
    └── history/
        ├── 2026-02-19.json
        └── 2026-02-20.json
```

---

## The Pipeline

Scenario-testing has a 6-phase pipeline. Each phase builds on the previous.

```
init → scenario → twin → run → satisfy → report
                                  ↑          │
                                  └──────────┘ (iterate)
```

### Phase Flow

```
                                    ┌─────────────┐
                                    │    init      │ Create catalog & config
                                    └──────┬──────┘
                                           │
                                    ┌──────▼──────┐
                                    │  scenario    │ Author & review scenarios
                                    └──────┬──────┘
                                           │
                                    ┌──────▼──────┐
                                    │    twin      │ Build digital twins (optional)
                                    └──────┬──────┘
                                           │
                                    ┌──────▼──────┐
                                    │    run       │ Execute scenarios → trajectories
                                    └──────┬──────┘
                                           │
                                    ┌──────▼──────┐
                                    │   satisfy    │ LLM-judge trajectories → scores
                                    └──────┬──────┘
                                           │
                                    ┌──────▼──────┐
                                    │   report     │ Aggregate & present satisfaction
                                    └─────────────┘
```

### You Don't Always Need Every Phase

| Scenario | Phases Used |
|----------|------------|
| First setup | init → scenario |
| Adding scenarios for existing code | scenario → run → satisfy → report |
| Service integration validation | twin → scenario → run → satisfy → report |
| Regression check after code change | run → satisfy → report |
| Reviewing satisfaction trends | report |

---

## Commands Reference

### Core Pipeline Commands

| Command | Purpose | Agents |
|---------|---------|--------|
| `/scenario-testing:st:init` | Initialize catalog, config, directory structure | — |
| `/scenario-testing:st:scenario "story"` | Author a new scenario from a user story | scenario-author, scenario-reviewer |
| `/scenario-testing:st:twin "service"` | Build a digital twin for a third-party service | twin-builder, twin-validator |
| `/scenario-testing:st:run` | Execute scenarios and record trajectories | trajectory-runner |
| `/scenario-testing:st:satisfy` | Judge trajectories and compute satisfaction scores | satisfaction-judge |
| `/scenario-testing:st:report` | Generate and display satisfaction report | — |

### Management Commands

| Command | Purpose |
|---------|---------|
| `/scenario-testing:st:catalog` | List, search, and manage the scenario catalog |
| `/scenario-testing:st:review "scenario"` | Review and refine an existing scenario |
| `/scenario-testing:st:chaos "twin"` | Configure chaos injection for a twin |
| `/scenario-testing:st:validate` | Full pipeline: run all scenarios → judge → report |

---

## Use Cases

### Use Case 1: Validating an Agentic Feature

You've built an agent that helps users create Jira tickets from Slack messages. Traditional tests can verify the API calls happen, but can't judge whether the resulting ticket is *good*.

```bash
# Author the scenario
/scenario-testing:st:scenario "user asks agent to create Jira ticket from Slack message"
```

**Generated scenario** (`.scenarios/catalog/integrations/slack-to-jira.scenario.yaml`):

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
    message: "Login page is broken for Safari users. They see a blank white screen after clicking 'Sign In'. Started happening after yesterday's deploy."
  services:
    - slack
    - jira

intent: "Create a well-structured Jira ticket from this Slack message with appropriate title, description, priority, and labels"

steps:
  - user: "Mentions the agent in Slack with the message"
  - agent: "Parses the message and creates a Jira ticket"
  - user: "Reviews the created ticket in Jira"

satisfaction_criteria:
  - "Ticket title is concise and descriptive (not the raw Slack message)"
  - "Description includes reproduction context (Safari, blank screen, after Sign In)"
  - "Priority is set appropriately (not critical, not trivial — likely 'High' or 'Medium')"
  - "Labels include relevant tags (e.g., 'browser-specific', 'login', 'regression')"
  - "The Slack message is linked or referenced in the ticket"

anti_patterns:
  - "Raw Slack message dumped as ticket title"
  - "Missing priority or defaulting to lowest priority"
  - "No labels or categorization"
  - "Ticket created in wrong project"
  - "Agent asks the user more than 2 clarifying questions before acting"

chaos:
  - type: latency
    target: jira
    delay_ms: 3000
    probability: 0.1
```

```bash
# Build twins for Slack and Jira
/scenario-testing:st:twin "slack"
/scenario-testing:st:twin "jira"

# Run 50 trajectories
/scenario-testing:st:run --count 50

# Judge and report
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

---

### Use Case 2: Holdout Validation After Refactoring

You've refactored the authentication module. Unit tests pass, but you want to validate user-facing behavior hasn't regressed.

```bash
# Run all auth-domain scenarios (written weeks ago, stored in .scenarios/)
/scenario-testing:st:run --domain auth --count 100

# Judge and compare to previous run
/scenario-testing:st:satisfy
/scenario-testing:st:report --compare-to 2026-02-15
```

**Output:**
```
Domain: auth
Scenarios: 3 (sso-login, password-reset, mfa-enrollment)

Current run (2026-02-20):     0.96 satisfaction (288/300 trajectories)
Previous run (2026-02-15):    0.94 satisfaction (282/300 trajectories)
Delta:                        +0.02 (improvement)

Per-scenario breakdown:
| Scenario        | Current | Previous | Delta  |
|-----------------|---------|----------|--------|
| sso-login       | 0.98    | 0.97     | +0.01  |
| password-reset  | 0.95    | 0.90     | +0.05  |
| mfa-enrollment  | 0.94    | 0.95     | -0.01  |

Verdict: Overall satisfaction improved. MFA enrollment slight regression
warrants investigation.
```

---

### Use Case 3: Digital Twin Universe for Rate-Limited APIs

You integrate with Google Sheets and need to validate at scale, but Google's API has aggressive rate limits.

```bash
# Build the Google Sheets twin
/scenario-testing:st:twin "google-sheets"
```

The twin-builder agent:
1. Reads your codebase to find which Google Sheets API endpoints you call
2. Builds a local HTTP server that replicates those endpoints
3. Implements the state machine (create sheet → add rows → read cells → share)
4. Configures chaos modes (quota exceeded, network timeout, permission denied)

```bash
# Configure chaos: 5% chance of quota exceeded, 2% chance of timeout
/scenario-testing:st:chaos "google-sheets" --quota-exceeded 0.05 --timeout 0.02

# Author scenario
/scenario-testing:st:scenario "user exports monthly report to Google Sheets"

# Run 500 trajectories (impossible against real API)
/scenario-testing:st:run --count 500

# Judge
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
  - timeout (10 injected): 7/10 handled gracefully (retry), 3/10 left user with no feedback

Recommendation: Add user-visible progress indicator for retry scenarios.
```

---

### Use Case 4: Continuous Satisfaction Monitoring

You want to track satisfaction over time, similar to tracking test coverage.

```bash
# Run full validation suite
/scenario-testing:st:validate

# View trend report
/scenario-testing:st:report --trend --days 30
```

**Output:**
```
30-Day Satisfaction Trend

Date       | Auth  | Onboarding | Integrations | Overall
-----------|-------|------------|--------------|--------
2026-01-22 | 0.92  | 0.81       | 0.88         | 0.87
2026-01-29 | 0.94  | 0.83       | 0.89         | 0.89
2026-02-05 | 0.94  | 0.87       | 0.91         | 0.91
2026-02-12 | 0.95  | 0.88       | 0.85 ▼       | 0.89
2026-02-19 | 0.96  | 0.90       | 0.92         | 0.93

Alerts:
  ⚠ Integrations dipped on 2026-02-12 (Jira twin was not updated after API change)
  ✓ All domains currently above minimum thresholds
```

---

## Advanced Usage

### Scenario Composition

Complex workflows can be composed from simpler scenarios:

```yaml
id: onboarding-full
domain: onboarding
composed_from:
  - auth/sso-login
  - onboarding/first-project-setup
  - onboarding/team-invite-flow

composition_type: sequential  # each scenario's end state is the next's start state

satisfaction_criteria:
  - "User completes full onboarding in under 5 minutes of active time"
  - "User ends with a configured project and at least one team member invited"
```

### Custom Judges

Override the default satisfaction-judge with domain-specific judgment criteria:

```yaml
# In the scenario file
judge_config:
  model: opus
  temperature: 0.0
  system_prompt: |
    You are a security-focused judge. Evaluate whether this trajectory
    would satisfy a security-conscious enterprise user. Pay special
    attention to: token handling, session management, data exposure in logs.
  strict_mode: true  # any anti-pattern match = unsatisfactory
```

### Twin Composition

Twins can be composed to simulate multi-service workflows:

```bash
# Build individual twins
/scenario-testing:st:twin "okta"
/scenario-testing:st:twin "jira"
/scenario-testing:st:twin "slack"

# Compose into a universe
# (twins automatically discover each other via .scenarios/twins/)
```

In the scenario, reference multiple services:

```yaml
context:
  services:
    - okta
    - jira
    - slack
  service_config:
    okta:
      chaos:
        - type: latency
          delay_ms: 500
    jira:
      chaos:
        - type: error
          code: 429
          probability: 0.05
```

### Scenario Versioning

Scenarios have explicit version numbers. When you update a scenario, bump the version:

```yaml
id: sso-login
version: 2  # bumped from 1
changelog:
  - version: 2
    date: 2026-02-20
    changes: "Added MFA step after SSO redirect, added anti-pattern for session fixation"
  - version: 1
    date: 2026-02-01
    changes: "Initial scenario"
```

Satisfaction reports track version numbers so you can compare scores across scenario versions.

### Thresholds and Alerts

Configure per-domain and per-scenario satisfaction thresholds:

```json
// .scenarios/config.json
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
    "judge_temperature": 0.0
  }
}
```

### Exporting for CI

Generate a JSON summary suitable for CI pipelines:

```bash
/scenario-testing:st:report --format json --output satisfaction.json
```

The JSON output includes per-scenario scores, threshold pass/fail, and trend data. Your CI can parse this and fail the build if satisfaction drops below thresholds.

---

## Architecture Deep Dive

### Agent Organization

The 6 agents are organized into 3 functional groups:

```
AUTHORING (2)                    EXECUTION (2)                  JUDGMENT (2)
├── scenario-author              ├── trajectory-runner           ├── satisfaction-judge
└── scenario-reviewer            └── twin-builder                └── twin-validator
```

### Agent Roles

**scenario-author** — Translates natural-language user stories into structured YAML scenarios. Identifies the persona, context, intent, satisfaction criteria, and anti-patterns. References existing scenarios to avoid duplication.

**scenario-reviewer** — Reviews authored scenarios for completeness, ambiguity, and testability. Ensures satisfaction criteria are specific enough for LLM judgment. Flags scenarios that are too vague or too rigid.

**trajectory-runner** — Executes scenarios against the codebase (with twins substituted for real services). Records every action, state transition, and outcome. Manages parallel execution for volume runs.

**twin-builder** — Analyzes the codebase to discover which third-party API endpoints are called, then generates behavioral clones (twins) that replicate those endpoints with state machines and chaos injection.

**satisfaction-judge** — Evaluates individual trajectories against scenario satisfaction criteria and anti-patterns. Produces a binary satisfactory/unsatisfactory judgment with reasoning. Uses LLM-as-judge with configurable system prompts.

**twin-validator** — Validates that a twin's behavior matches the real service's documented API. Checks that state transitions are valid, error codes are correct, and edge cases are handled. Cross-references with API documentation.

### How Scenarios Prevent Reward Hacking

The key architectural decision is **separation of concerns**:

```
Codebase (mutable)              Scenarios (holdout)
├── src/                        ├── .scenarios/catalog/
├── tests/                      │   ├── auth/
│   ├── unit/                   │   ├── onboarding/
│   └── integration/            │   └── integrations/
└── ...                         └── .scenarios/twins/
```

- Code can see tests, but scenarios are gitignored by default
- Scenarios describe *what the user wants*, not *what the code does*
- The LLM judge evaluates satisfaction, not correctness — it can't be gamed by matching expected outputs
- Chaos injection introduces non-determinism that fixtures can't anticipate

### Artifact Flow

```
/scenario (author)
    └── .scenarios/catalog/{domain}/{name}.scenario.yaml ────────┐
                                                                  │
/twin (build)                                                     │
    └── .scenarios/twins/{service}/ ──────────────────────┐      │
        ├── twin.json                                     │      │
        ├── routes.yaml                                   │      │
        ├── state-machine.yaml                            │      │
        └── chaos.yaml                                    │      │
                                                          │      │
/run (execute)                                            │      │
    ├── reads: scenarios ◄────────────────────────────────┼──────┘
    ├── reads: twins ◄────────────────────────────────────┘
    └── writes: .scenarios/runs/{date}-{seq}/
        ├── run-manifest.json
        └── trajectories/{scenario}-{n}.json ────────┐
                                                      │
/satisfy (judge)                                      │
    ├── reads: trajectories ◄─────────────────────────┘
    ├── reads: scenario (for satisfaction criteria)
    └── writes: .scenarios/runs/{date}-{seq}/
        └── judgments/{scenario}-{n}.json ────────┐
                                                   │
/report (aggregate)                                │
    ├── reads: judgments ◄─────────────────────────┘
    └── writes: .scenarios/reports/
        ├── latest.json
        └── history/{date}.json
```

### Satisfaction Computation

```
For each scenario S with N trajectories:
  satisfaction(S) = count(judge(t) == "satisfactory" for t in trajectories(S)) / N

For each domain D:
  satisfaction(D) = mean(satisfaction(S) for S in scenarios(D))

Overall:
  satisfaction = weighted_mean(satisfaction(D) for D in domains,
                               weights = trajectory_count(D))
```

The judge evaluates each trajectory independently with:
1. Does the outcome match ANY of the satisfaction criteria? (at least one must match)
2. Does the trajectory violate ANY anti-pattern? (zero must match)
3. Would the described persona consider this outcome acceptable?

A trajectory is "satisfactory" only if (1) AND NOT (2) AND (3).

---

## Customization

### Adapting to Your Project

**Configure storage location.** By default scenarios live in `.scenarios/` (gitignored). To share scenarios across a team, set `storage: "in-repo"` in `.scenarios/config.json` and commit the catalog.

**Adjust thresholds.** Different domains have different acceptable satisfaction levels. Critical paths (auth, payments) should be > 0.95. Exploratory features can be > 0.70.

**Custom twin templates.** Add templates for services specific to your stack in `.scenarios/twins/templates/`.

**Scenario templates.** Add domain-specific scenario templates in `.scenarios/catalog/templates/` to standardize how scenarios are written for your project.

### Key Files to Know

| File | Purpose | When to Modify |
|------|---------|---------------|
| `.claude-plugin/plugin.json` | Plugin manifest | Only if changing plugin structure |
| `.scenarios/config.json` | Thresholds, defaults, storage mode | To tune satisfaction thresholds |
| `.scenarios/catalog.json` | Scenario index | Auto-managed by commands |
| `skills/*/references/*.md` | Reference knowledge | To add templates or patterns |
| Agent `.md` files | Agent behavior | To tune judgment criteria or authoring style |
| `hooks/hooks.json` | Session-start catalog check | To adjust hook behavior |
| `scripts/*.sh` | Utility scripts | To extend automation |

### Integration with blueprint-dev

Scenario-testing complements blueprint-dev's pipeline. Recommended integration points:

- After `/blueprint-dev:bp:build` → run `/scenario-testing:st:validate` to check satisfaction
- After `/blueprint-dev:bp:ship` → run `/scenario-testing:st:run --domain affected` for regression check
- During `/blueprint-dev:bp:plan` → reference `.scenarios/reports/latest.json` to identify weak areas
- After `/blueprint-dev:bp:compound` → author new scenarios for the solved problem to prevent regression

### External Dependencies

Scenario-testing is self-contained for basic usage. Optional external dependencies:

| Tool | Used By | Purpose |
|------|---------|---------|
| `jq` | `st:report` | JSON formatting for terminal output |
| Docker | `st:twin` (optional) | Running twins as isolated containers |
| `curl` | `st:twin` validation | Testing twin endpoints directly |
