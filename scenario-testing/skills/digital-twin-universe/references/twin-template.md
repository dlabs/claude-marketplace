# Digital Twin Templates

Reference templates for the 4 files that make up a digital twin.

## twin.json Template

```json
{
  "name": "{service-name}",
  "version": 1,
  "base_url": "http://localhost:{port}",
  "description": "Behavioral clone of {Service Display Name} API",
  "endpoints_covered": 0,
  "state_entities": [],
  "chaos_modes": ["latency", "error_429", "error_500", "timeout"],
  "discovered_from": [],
  "auth": {
    "type": "{none|bearer|api_key|oauth2}",
    "validation": "{strict|permissive}",
    "tokens": {
      "valid": ["test-token-valid"],
      "expired": ["test-token-expired"]
    }
  },
  "port_range": {
    "preferred": 9001,
    "fallback": [9002, 9003, 9004, 9005]
  }
}
```

## routes.yaml Template

```yaml
# ═══════════════════════════════════════════════
# {Service Name} Twin — API Routes
# ═══════════════════════════════════════════════
#
# Only includes endpoints discovered in the codebase.
# Each route defines: method, path, schemas, state effects, errors.

base_path: /{api-prefix}
content_type: application/json

auth:
  header: Authorization
  format: "Bearer {token}"
  required: true  # set per-route if some are public

routes:
  # ── Resource CRUD ──────────────────────────
  - method: POST
    path: /{resource}
    description: "Create a new {resource}"
    auth_required: true
    request_schema:
      # Fields your code actually sends
      name: string
      # ... add fields as discovered
    response_schema:
      id: string
      # ... matching fields
      created_at: datetime
    state_effects:
      - create: {entity}
    errors:
      - code: 400
        condition: "Validation failure: missing required fields"
        body: '{"error": "Bad Request", "message": "{field} is required"}'
      - code: 401
        condition: "Missing or invalid auth token"
        body: '{"error": "Unauthorized"}'
      - code: 409
        condition: "Duplicate resource"
        body: '{"error": "Conflict", "message": "Resource already exists"}'
      - code: 429
        condition: "Rate limit exceeded"
        headers:
          Retry-After: "60"
        body: '{"error": "Too Many Requests"}'

  - method: GET
    path: /{resource}/{id}
    description: "Get {resource} by ID"
    auth_required: true
    response_schema:
      id: string
      name: string
      # ... all fields
    errors:
      - code: 404
        condition: "Resource not found"
        body: '{"error": "Not Found"}'

  - method: PUT
    path: /{resource}/{id}
    description: "Update {resource}"
    auth_required: true
    request_schema:
      # Partial update fields
    response_schema:
      # Updated resource
    state_effects:
      - update: {entity}
    errors:
      - code: 404
        condition: "Resource not found"
      - code: 409
        condition: "Concurrent modification"

  - method: DELETE
    path: /{resource}/{id}
    description: "Delete {resource}"
    auth_required: true
    state_effects:
      - delete: {entity}
    errors:
      - code: 404
        condition: "Resource not found"
      - code: 409
        condition: "Resource has dependencies"

  # ── List / Search ──────────────────────────
  - method: GET
    path: /{resource}
    description: "List {resources} with optional filtering"
    auth_required: true
    query_params:
      page: { type: integer, default: 1 }
      per_page: { type: integer, default: 20, max: 100 }
      sort: { type: string, default: "created_at" }
      order: { type: string, enum: [asc, desc], default: "desc" }
      # ... filter params as discovered
    response_schema:
      data: array
      pagination:
        page: integer
        per_page: integer
        total: integer
        total_pages: integer
```

## state-machine.yaml Template

```yaml
# ═══════════════════════════════════════════════
# {Service Name} Twin — State Machine
# ═══════════════════════════════════════════════
#
# Defines entities, their states, and valid transitions.
# This is what makes a twin different from a mock.

entities:
  {entity_name}:
    description: "{What this entity represents}"
    initial_state: {initial}
    states:
      - name: {state_1}
        description: "{When the entity is in this state}"
      - name: {state_2}
        description: "{When the entity is in this state}"

    transitions:
      - from: {state_1}
        to: {state_2}
        trigger: "{API call or condition that causes this transition}"
        side_effects:
          - "{what else happens — e.g., webhook fired, related entity updated}"
      - from: {state_2}
        to: {state_1}
        trigger: "{reverse transition trigger}"

    constraints:
      - "{Business rule — e.g., 'Cannot delete while in active state'}"
      - "{Validation rule — e.g., 'Name must be unique within project'}"

    relationships:
      - entity: {other_entity}
        type: {belongs_to|has_many|has_one}
        constraint: "{e.g., 'Cannot delete parent with active children'}"

# ── Global Constraints ───────────────────────
global_constraints:
  max_entities_per_account: 1000
  rate_limits:
    requests_per_minute: 60
    burst: 10
  eventual_consistency:
    delay_ms: 500   # reads may not reflect writes for this duration
```

## chaos.yaml Template

```yaml
# ═══════════════════════════════════════════════
# {Service Name} Twin — Chaos Configuration
# ═══════════════════════════════════════════════
#
# Each mode can be enabled per-scenario or globally.
# Probability is per-request (0.0 = never, 1.0 = always).

chaos_modes:
  latency:
    description: "Add random latency to responses"
    config:
      min_ms: 100
      max_ms: 5000
      distribution: "normal"  # normal | uniform | exponential
    default_probability: 0.0
    per_route_overrides: {}   # route_path: probability

  error_429:
    description: "Rate limit exceeded (429)"
    config:
      retry_after_seconds: 60
      headers:
        Retry-After: "60"
        X-RateLimit-Remaining: "0"
      body: '{"error": "rate_limit_exceeded", "message": "Too many requests"}'
    default_probability: 0.0

  error_500:
    description: "Internal server error (500)"
    config:
      body: '{"error": "internal_error", "message": "An unexpected error occurred"}'
    default_probability: 0.0

  error_503:
    description: "Service unavailable (503)"
    config:
      retry_after_seconds: 30
      body: '{"error": "service_unavailable", "message": "Service temporarily unavailable"}'
    default_probability: 0.0

  timeout:
    description: "Connection timeout — no response sent"
    config:
      timeout_ms: 30000
    default_probability: 0.0

  partial_response:
    description: "Truncated response body (simulates network interruption)"
    config:
      truncate_at_percent: 50
    default_probability: 0.0

  stale_data:
    description: "Return data from N seconds ago (simulates eventual consistency)"
    config:
      staleness_seconds: 30
    default_probability: 0.0

  auth_expired:
    description: "Return 401 as if token has expired"
    config:
      body: '{"error": "token_expired", "message": "Access token has expired"}'
    default_probability: 0.0

# ── Chaos Profiles ───────────────────────────
# Named presets for common testing scenarios
profiles:
  gentle:
    description: "Light chaos — occasional latency and rare errors"
    overrides:
      latency: { probability: 0.05, config: { max_ms: 1000 } }
      error_500: { probability: 0.01 }

  moderate:
    description: "Moderate chaos — regular latency, occasional errors and rate limits"
    overrides:
      latency: { probability: 0.15, config: { max_ms: 3000 } }
      error_429: { probability: 0.05 }
      error_500: { probability: 0.03 }
      timeout: { probability: 0.02 }

  hostile:
    description: "Hostile environment — frequent failures across all modes"
    overrides:
      latency: { probability: 0.30, config: { max_ms: 5000 } }
      error_429: { probability: 0.10 }
      error_500: { probability: 0.08 }
      error_503: { probability: 0.05 }
      timeout: { probability: 0.05 }
      partial_response: { probability: 0.03 }
      auth_expired: { probability: 0.05 }
```

## Port Assignment Convention

Twins are assigned ports starting from 9001:

| Port | Service |
|------|---------|
| 9001 | First twin (alphabetical by name) |
| 9002 | Second twin |
| ... | ... |

Ports are auto-assigned and recorded in `twin.json`. If a port is in use, the next in the fallback range is tried.
