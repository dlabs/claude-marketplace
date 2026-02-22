---
name: digital-twin-universe
description: Framework for building behavioral clones (digital twins) of third-party services. Covers API surface replication, state machines, chaos injection, and twin composition for validating at volumes and rates impossible against live services.
---

# Digital Twin Universe

This skill provides the framework for building and managing digital twins — behavioral clones of third-party services your software depends on. Twins replicate APIs, state machines, edge cases, and failure modes, enabling scenario validation at scale without hitting rate limits, triggering abuse detection, or accumulating API costs.

## When to Use

- `/scenario-testing:st:twin` — building a new digital twin
- `/scenario-testing:st:chaos` — configuring failure injection
- When any agent needs to understand twin architecture
- When building scenarios that depend on external services

## What Is a Digital Twin?

A digital twin is a local HTTP server that behaves like a third-party service. It is NOT a mock or a stub:

| Aspect | Mock/Stub | Digital Twin |
|--------|-----------|-------------|
| **Scope** | Individual function calls | Full API surface |
| **State** | Stateless (fixed responses) | Stateful (state machine) |
| **Behavior** | Returns hardcoded data | Simulates real service logic |
| **Failures** | Not modeled | Configurable chaos injection |
| **Edge cases** | Manual per-test setup | Built into the twin |
| **Reusable** | Per-test fixture | Across all scenarios |

## Twin Anatomy

Each twin lives at `.scenarios/twins/{service}/` and contains 4 files:

### twin.json — Manifest

```json
{
  "name": "jira",
  "version": 1,
  "base_url": "http://localhost:9001",
  "description": "Behavioral clone of Jira Cloud REST API",
  "endpoints_covered": 12,
  "state_entities": ["project", "issue", "user", "status", "transition"],
  "chaos_modes": ["latency", "error_429", "error_500", "timeout", "partial_response"],
  "discovered_from": [
    "src/services/jira-client.ts",
    "src/integrations/jira/api.ts"
  ]
}
```

### routes.yaml — API Surface

```yaml
routes:
  - method: POST
    path: /rest/api/3/issue
    description: "Create a new issue"
    request_schema:
      fields:
        project: { key: string }
        summary: string
        description: string
        issuetype: { name: string }
        priority: { name: string }
        labels: string[]
    response_schema:
      id: string
      key: string
      self: string
    state_effects:
      - create: issue
    errors:
      - code: 400
        condition: "missing required fields"
      - code: 404
        condition: "project not found"
      - code: 429
        condition: "rate limit exceeded"

  - method: GET
    path: /rest/api/3/issue/{issueKey}
    description: "Get issue by key"
    response_schema:
      id: string
      key: string
      fields:
        summary: string
        status: { name: string }
        priority: { name: string }
    errors:
      - code: 404
        condition: "issue not found"
```

### state-machine.yaml — Internal State

```yaml
entities:
  issue:
    initial_state: open
    transitions:
      - from: open
        to: in_progress
        trigger: "transition API call with transitionId=21"
      - from: in_progress
        to: done
        trigger: "transition API call with transitionId=31"
      - from: in_progress
        to: open
        trigger: "transition API call with transitionId=11"
      - from: done
        to: open
        trigger: "transition API call with transitionId=11"
    constraints:
      - "Cannot transition from done to in_progress directly"
      - "Transition IDs must match the valid set for current state"

  project:
    initial_state: active
    constraints:
      - "Key must be unique, 2-10 uppercase letters"
      - "Cannot delete a project with open issues"
```

### chaos.yaml — Failure Injection

```yaml
chaos_modes:
  latency:
    description: "Add random latency to responses"
    config:
      min_ms: 100
      max_ms: 5000
      distribution: "normal"
    default_probability: 0.0

  error_429:
    description: "Return 429 Too Many Requests"
    config:
      retry_after_seconds: 30
      headers:
        Retry-After: "30"
    default_probability: 0.0

  error_500:
    description: "Return 500 Internal Server Error"
    config:
      body: '{"errorMessages": ["Internal server error"], "errors": {}}'
    default_probability: 0.0

  timeout:
    description: "Connection timeout (no response)"
    config:
      timeout_ms: 30000
    default_probability: 0.0

  partial_response:
    description: "Return truncated response body"
    config:
      truncate_at_percent: 50
    default_probability: 0.0
```

## Building a Twin

The twin-builder agent follows this process:

1. **Discover** — scan the codebase for API calls to the target service
2. **Map** — enumerate the endpoints, request/response schemas, and error handling
3. **Model** — define the state machine (entities, transitions, constraints)
4. **Configure** — set up chaos modes based on the service's known failure patterns
5. **Validate** — the twin-validator agent cross-references with API documentation

## Twin Composition (The Universe)

Multiple twins compose into a "universe" — a complete simulation environment. Twins in the same universe:

- Run on different ports (auto-assigned starting from 9001)
- Share a clock (for coordinated latency simulation)
- Can reference each other (e.g., a Slack twin can trigger a Jira twin event)
- Are all started/stopped together during scenario runs

## Key Principles

- **Behavioral fidelity over completeness** — only replicate the endpoints your code actually calls, not the entire API
- **State machines are essential** — the difference between a twin and a mock is state. Jira tickets move through statuses. Okta tokens expire. Google Sheets cells accumulate writes.
- **Chaos is the differentiator** — twins without chaos are just fancy stubs. The value is in testing how your code handles rate limits, timeouts, and partial failures.
- **Discover from code, validate from docs** — the twin-builder reads your codebase to find what you call; the twin-validator reads API documentation to verify correctness.

## References

- `references/twin-template.md` — Template files for twin creation
- `references/common-services.md` — Patterns and state machines for commonly-twinned services (Okta, Jira, Slack, Google Workspace, Stripe, Twilio)
