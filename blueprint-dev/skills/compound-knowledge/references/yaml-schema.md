# YAML Frontmatter Schema

Validation rules for compound knowledge document frontmatter.

## Required Fields

| Field | Type | Constraint |
|-------|------|-----------|
| `title` | string | 5-100 characters, descriptive |
| `date` | date | ISO 8601 format (YYYY-MM-DD) |
| `category` | enum | See categories below |
| `severity` | enum | See severities below |
| `module` | string | Lowercase, kebab-case |
| `tags` | array | 3-7 lowercase strings |
| `root_cause` | string | Single sentence summary |
| `prevention` | string | Single sentence summary |

## Category Enum

```yaml
category:
  - build-errors         # Compilation, bundling, dependency resolution
  - test-failures        # Test suite failures, flaky tests
  - runtime-errors       # Exceptions, crashes in running code
  - performance-issues   # Slow queries, memory leaks, latency
  - database-issues      # Migrations, schema, data corruption
  - security-issues      # Vulnerabilities, auth bugs, exposure
  - ui-bugs              # Visual glitches, layout, interaction
  - integration-issues   # API failures, service communication
  - logic-errors         # Wrong business logic, calculations, state
```

## Severity Enum

```yaml
severity:
  - critical   # System down, data loss, security breach
  - high       # Major feature broken, significant user impact
  - medium     # Degraded experience, workaround available
  - low        # Cosmetic issue, minor inconvenience
```

## Example Valid Frontmatter

```yaml
---
title: "Token refresh race condition causing 401 errors on page load"
date: 2026-02-10
category: runtime-errors
severity: high
module: authentication
tags: [jwt, token-refresh, race-condition, axios, interceptor]
root_cause: "Token refresh and API call racing on page load when token is near expiry"
prevention: "Add token refresh queue with mutex lock to serialize refresh requests"
---
```

## Validation Rules

1. `title` must not start with articles (a, an, the) — start with the key noun
2. `date` must be a valid date, not in the future
3. `category` must exactly match one of the enum values
4. `severity` must exactly match one of the enum values
5. `module` should be a recognizable area of the codebase
6. `tags` must be 3-7 items, all lowercase, hyphen-separated words
7. `root_cause` must be a single sentence (no periods in the middle)
8. `prevention` must be a single sentence describing an actionable strategy
