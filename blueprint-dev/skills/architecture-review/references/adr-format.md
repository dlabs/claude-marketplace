# ADR Format — MADR (Markdown Any Decision Records)

ADRs are stored at `.blueprint/adrs/{NNNN}-{title}.md`

## Numbering

- 4-digit zero-padded: `0001`, `0002`, `0003`
- Sequential (never reuse numbers)
- Title slug in kebab-case

## Template

```markdown
# {NNNN}. {Decision Title}

**Date**: {YYYY-MM-DD}
**Status**: Proposed | Accepted | Deprecated | Superseded by {NNNN}
**Deciders**: {who was involved}

## Context and Problem Statement

{1-3 paragraphs describing the situation and why a decision is needed}

## Decision Drivers

- {driver 1}
- {driver 2}
- {driver 3}

## Considered Options

### Option 1: {Name}
{Description}

**Pros:**
- {advantage}

**Cons:**
- {disadvantage}

### Option 2: {Name}
...

### Option 3: {Name}
...

## Decision Outcome

**Chosen option**: "{Option N}" because {justification}.

### Positive Consequences
- {outcome}

### Negative Consequences
- {trade-off}

## Technical Design

### Component Architecture
{Components and relationships}

### Data Model
{Schema changes}

### API Design
{Endpoints and contracts}

### Key Flows
{Important interaction sequences}

## Security Review Summary
{Findings from security-sentinel — appended during /architect}

## Performance Review Summary
{Findings from performance-oracle — appended during /architect}

## Data Integrity Review Summary
{Findings from data-integrity-guardian — appended during /architect}

## Implementation Notes
- {Guidance for implementors}
```

## Status Lifecycle

```
Proposed → Accepted → [Deprecated | Superseded by {NNNN}]
```

- **Proposed**: Under discussion, not yet decided
- **Accepted**: Decision made, implementation can proceed
- **Deprecated**: Decision is no longer relevant
- **Superseded**: Replaced by a newer ADR (link to it)

## File Examples

```
.blueprint/adrs/
├── 0001-use-postgresql-for-primary-database.md
├── 0002-adopt-event-sourcing-for-audit-trail.md
├── 0003-use-redis-for-session-management.md
└── 0004-switch-to-app-router.md (supersedes 0002)
```
