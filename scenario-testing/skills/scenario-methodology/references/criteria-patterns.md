# Patterns for Satisfaction Criteria and Anti-Patterns

This reference provides patterns and examples for writing effective satisfaction criteria and anti-patterns. Good criteria are the difference between useful scenario validation and noise.

## The Goldilocks Principle

Criteria must be:
- **Specific enough** to judge — an LLM can determine if the criterion is met from the trajectory
- **Flexible enough** to allow valid variation — multiple correct implementations can satisfy the criterion
- **User-centered** — describe what the user experiences, not what the code does

```
TOO VAGUE:    "The feature works correctly"
TOO RIGID:    "Response body contains exactly {\"status\": \"ok\", \"userId\": 42}"
JUST RIGHT:   "User sees a confirmation message with their project name within 3 seconds"
```

## Satisfaction Criteria Patterns

### Outcome Patterns

Describe what the user observes after the interaction:

```yaml
# State change visible to user
- "The new project appears in the user's project list"
- "The invited team member receives an email within 1 minute"
- "The exported file is available for download"

# Information presented
- "User sees their dashboard with accurate project counts"
- "Error message explains what went wrong and suggests a fix"
- "Search results include the expected item in the first 5 results"

# Quality of generated content
- "Ticket title is concise (under 80 characters) and descriptive of the issue"
- "Summary captures the key points without fabricating details"
- "Labels are relevant to the content (not generic or empty)"
```

### Behavioral Patterns

Describe how the system behaves during the interaction:

```yaml
# Response time
- "Page loads within 2 seconds on standard connection"
- "Agent responds with initial acknowledgment within 5 seconds"

# Graceful handling
- "System retries the failed request and succeeds without user intervention"
- "User is informed of the delay and given option to cancel"
- "Partial failure does not corrupt previously saved data"

# Interaction quality
- "Agent asks at most 2 clarifying questions before taking action"
- "Navigation requires no more than 3 clicks from dashboard"
- "Form pre-fills known information (name, email from profile)"
```

### Negative-Space Patterns

Describe what should NOT happen (often more useful than what should):

```yaml
# Data integrity
- "No duplicate records are created"
- "Original data is not modified or deleted"
- "User A cannot see User B's private data"

# User experience
- "No raw error messages, stack traces, or JSON shown to user"
- "No infinite loading spinners or unresponsive UI"
- "No unexpected logouts or session losses during the workflow"
```

## Anti-Pattern Patterns

### Critical Failures

Always include these for safety-critical scenarios:

```yaml
anti_patterns:
  # Security
  - "Credentials or tokens are exposed in the UI or logs"
  - "User can access data belonging to another account"
  - "Session is not invalidated after password change"

  # Data corruption
  - "Data is written to wrong record or account"
  - "Partial write leaves data in inconsistent state"
  - "Delete operation affects more records than intended"

  # User experience
  - "Unhandled exception or raw error shown to user"
  - "Application becomes unresponsive (hangs for >30 seconds)"
  - "User loses unsaved work without warning"
```

### Agentic Anti-Patterns

Specific to software with agent/LLM components:

```yaml
anti_patterns:
  # Agent behavior
  - "Agent enters infinite loop (same action repeated >3 times)"
  - "Agent hallucinates data that doesn't exist in the context"
  - "Agent takes destructive action without user confirmation"
  - "Agent ignores explicit user instruction"

  # Communication
  - "Agent asks more than 3 clarifying questions before any action"
  - "Agent provides no explanation of what it did"
  - "Agent claims success when the action actually failed"
  - "Agent responds with internal debugging output"

  # Scope
  - "Agent modifies resources outside the requested scope"
  - "Agent makes API calls to services not relevant to the task"
  - "Agent creates resources the user didn't ask for"
```

### Integration Anti-Patterns

For scenarios involving third-party services:

```yaml
anti_patterns:
  # API misuse
  - "API is called with invalid or expired credentials"
  - "Rate limit hit without retry logic"
  - "Request sent to wrong endpoint or with wrong HTTP method"

  # Error handling
  - "API error is silently swallowed (user thinks action succeeded)"
  - "Retry loop continues indefinitely (no backoff, no max retries)"
  - "Error from service A propagates as unrelated error to user"

  # State
  - "Resource created in external service but local state not updated"
  - "Local state updated but external service call failed"
  - "Stale data shown after mutation (cache not invalidated)"
```

## Composing Criteria for Complex Scenarios

For multi-step workflows, structure criteria around phases:

```yaml
satisfaction_criteria:
  # Phase 1: Input
  - "User can provide input in natural language without needing specific syntax"

  # Phase 2: Processing
  - "System acknowledges receipt and shows progress"
  - "Processing completes within 30 seconds"

  # Phase 3: Output
  - "Result is presented in a format the user can immediately use"
  - "Result is accurate and relevant to the input"

  # Phase 4: Follow-up
  - "User can modify the result with follow-up instructions"
  - "History of the interaction is preserved for reference"
```

## Testing Your Criteria

Before finalizing a scenario, mentally run these checks:

1. **Can an LLM judge this?** — Give the criterion and a hypothetical trajectory to an LLM. Can it determine match/no-match?
2. **Does it allow valid variation?** — Think of 3 different correct implementations. Would all 3 match?
3. **Is it user-centered?** — Does it describe what the user observes, or what the code does internally?
4. **Is it independent?** — Can this criterion be evaluated without needing to evaluate other criteria first?
5. **Is it stable?** — Would this criterion still be valid if the implementation changed but the user experience stayed the same?
