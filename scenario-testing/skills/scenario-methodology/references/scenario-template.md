# Scenario YAML Template

This is the reference template for authoring scenarios. Every scenario follows this structure.

## Full Template

```yaml
# ═══════════════════════════════════════════════
# Scenario: {Human-readable title}
# ═══════════════════════════════════════════════

id: {kebab-case-identifier}          # Required. Unique across catalog.
domain: {category}                    # Required. Groups related scenarios.
version: 1                            # Required. Integer, bump on changes.

# ── Who is the user? ──────────────────────────
persona:
  role: {job-title-or-role}           # e.g., "project-manager", "developer", "end-user"
  expertise: {technical-level}        # "non-technical", "intermediate", "technical", "expert"
  goals: "{what they care about}"     # Natural language, 1-2 sentences

# ── What is the starting state? ───────────────
context:
  state:
    # Key-value pairs describing the initial conditions
    # Examples:
    #   logged_in: true
    #   project_count: 3
    #   pending_invites: 0
    #   environment: "production"
  services:                           # List of digital twins needed
    - {service-name}                  # Must match a twin in .scenarios/twins/
  data:                               # Optional: seed data for twins
    {service}:
      # Service-specific seed data
      # e.g., jira: { projects: [{ key: "PROJ", name: "Project" }] }

# ── What does the user want? ──────────────────
intent: "{1-2 sentence description of the user's goal}"

# ── How does the interaction unfold? ──────────
steps:                                # Ordered but flexible
  - user: "{action the user takes}"
  - agent: "{expected agent behavior — descriptive, not prescriptive}"
  - user: "{follow-up action}"
  - system: "{observable system event}"

# ── What outcomes satisfy the user? ───────────
satisfaction_criteria:
  - "{specific, judgeable outcome 1}"
  - "{specific, judgeable outcome 2}"
  - "{specific, judgeable outcome 3}"
  # At least ONE must be matched for "satisfactory"

# ── What outcomes definitely don't? ───────────
anti_patterns:                        # Optional but recommended
  - "{clearly wrong outcome 1}"
  - "{clearly wrong outcome 2}"
  # ANY match = "unsatisfactory" regardless of criteria

# ── What failures to inject? ─────────────────
chaos:                                # Optional
  - type: {latency|error|timeout|partial_response}
    target: {service-name}
    # Type-specific config:
    delay_ms: 3000                    # for latency
    code: 429                         # for error
    probability: 0.1                  # chance of injection per request

# ── Composition ──────────────────────────────
composed_from:                        # Optional
  - {domain}/{scenario-id}
  - {domain}/{scenario-id}
composition_type: sequential          # sequential | parallel | conditional

# ── Custom judge ─────────────────────────────
judge_config:                         # Optional
  system_prompt: |
    {Custom system prompt for the LLM judge}
  strict_mode: false                  # true = any anti-pattern match is fatal
  model: opus                         # Override judge model
  temperature: 0.0

# ── Changelog ────────────────────────────────
changelog:                            # Required after version > 1
  - version: 1
    date: {YYYY-MM-DD}
    changes: "Initial scenario"
```

## Minimal Template

The bare minimum for a valid scenario:

```yaml
id: sso-login
domain: auth
version: 1

persona:
  role: employee
  expertise: non-technical
  goals: "Access the application quickly via company SSO"

context:
  state:
    sso_provider: okta
    user_exists: true

intent: "Log in to the application using SSO"

steps:
  - user: "Clicks 'Sign in with SSO' button"
  - system: "Redirects to Okta login page"
  - user: "Enters corporate credentials"
  - system: "Redirects back to application, user is logged in"

satisfaction_criteria:
  - "User is logged in and sees their dashboard within 5 seconds"
  - "User's name and role are displayed correctly"
  - "Session persists across page refreshes"
```

## Field Documentation

### id
- Format: kebab-case, 3-50 characters
- Must be unique across the entire catalog
- Convention: `{verb}-{noun}` or `{noun}-{action}` (e.g., `sso-login`, `export-to-sheets`, `invite-team-member`)

### domain
- Groups related scenarios for aggregate reporting
- Convention: short, plural nouns (e.g., `auth`, `onboarding`, `integrations`, `payments`)
- New domains are auto-created when first used

### version
- Starts at 1, incremented on any change to the scenario content
- Satisfaction history is tracked per version
- Reports can compare satisfaction across versions

### persona
- Drives the judge's evaluation — "would THIS user be satisfied?"
- More specific personas produce more useful satisfaction data
- Consider writing the same scenario with different personas to test accessibility

### context.services
- Each service listed must have a corresponding twin in `.scenarios/twins/`
- If a service is listed but no twin exists, the scenario-runner will warn and offer to build one

### satisfaction_criteria
- Written in natural language, specific enough for an LLM to evaluate
- Multiple criteria = multiple valid success paths
- The judge needs to match at least ONE criterion for "satisfactory"

### anti_patterns
- The inverse of satisfaction criteria — things that are always wrong
- The judge checks these first — any match = "unsatisfactory" immediately
- Common anti-patterns: raw errors shown to user, infinite loops, data corruption, wrong-account access

### chaos
- Probability is per-request (0.0 to 1.0)
- Multiple chaos conditions can be active simultaneously
- Set probability to 1.0 for deterministic failure testing
- Set probability to 0.0 (or omit) to disable
