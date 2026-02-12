# Planning Templates

---

## PRD Template (Product Requirements Document)

```markdown
# PRD: {Feature Name}

**Author**: {name}
**Date**: {YYYY-MM-DD}
**Status**: Draft / In Review / Approved

## Problem Statement
{What problem does this solve? Who experiences it? How often?}

## Proposed Solution
{High-level description of the solution}

## Success Metrics
- **Primary**: {metric that defines success}
- **Secondary**: {supporting metrics}
- **Guardrails**: {metrics that must not degrade}

## User Stories
- As a {role}, I want to {action} so that {benefit}
- As a {role}, I want to {action} so that {benefit}

## Requirements
{Link to or embed the requirements analyst output}

## Out of Scope
{Explicitly state what this does NOT include}

## Timeline
- **Phase 1**: {dates} — {scope}
- **Phase 2**: {dates} — {scope}

## Open Questions
- {Question that needs answering before implementation}
```

---

## Technical Spec Template

```markdown
# Tech Spec: {Feature Name}

**Date**: {YYYY-MM-DD}
**Plan reference**: `.blueprint/plans/{plan-file}.md`

## Architecture

### Overview
{How this feature fits into the existing architecture}

### Data Model Changes
{New tables, columns, relationships — or "None"}

### API Changes
{New endpoints, modified endpoints — or "None"}

### UI Changes
{New components, modified views — or "None"}

## Implementation Approach

### Approach: {Name}
**Chosen because**: {rationale from research-scout}
**Trade-offs**: {what we're accepting}

### Key Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| {topic} | {choice} | {why} |

## Dependencies
- {dependency}: {status}

## Test Plan
| Scenario | Type | Priority |
|----------|------|----------|
| {scenario} | Unit/Integration/E2E | P1/P2/P3 |

## Rollout Plan
- Feature flag: `{flag-name}`
- Rollout stages: {dev → staging → 10% → 50% → 100%}
- Rollback plan: {how to revert}

## Security Considerations
{Authentication, authorization, data protection — or "N/A"}

## Performance Considerations
{Expected load, caching strategy, query optimization — or "N/A"}
```

---

## Scope Boundary Template

```markdown
# Scope Boundary: {Feature Name}

**Date**: {YYYY-MM-DD}

## IN Scope
- {Specific deliverable 1}
- {Specific deliverable 2}
- {Specific deliverable 3}

## OUT of Scope (explicitly)
- {Thing that might seem related but is NOT included}
- {Future enhancement explicitly deferred}

## Deferred to v2
- {Enhancement that will come later}
- {Nice-to-have cut from v1}

## Acceptance Criteria for "Done"
- [ ] {Criteria 1}
- [ ] {Criteria 2}
- [ ] All tests pass
- [ ] Code review approved
- [ ] Feature flag in place
```

---

## Plan File Naming Convention

Plans are saved to `.blueprint/plans/` with the format:
```
{YYYY-MM-DD}-{feature-slug}.md
```

Examples:
- `2026-02-10-user-authentication.md`
- `2026-02-10-settings-page-redesign.md`
- `2026-02-10-api-rate-limiting.md`
