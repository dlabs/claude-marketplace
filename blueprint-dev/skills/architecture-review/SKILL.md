---
name: architecture-review
description: Multi-agent architecture review combining core architecture design with parallel security, performance, and data integrity assessments. Produces ADRs in MADR format.
---

# Architecture Review

This skill provides a comprehensive architecture review using a parallel agent team. The architecture-strategist designs the core architecture, while security-sentinel, performance-oracle, and data-integrity-guardian independently evaluate their respective concerns.

## When to Use

- `/blueprint-dev:bp:architect` — full architecture review
- Before implementing significant features or system changes
- When making technology or pattern decisions that affect the system long-term

## Agent Team

| Agent | Focus | Runs |
|-------|-------|------|
| architecture-strategist | Core design, patterns, ADR authoring | First (produces the design) |
| security-sentinel | OWASP, auth, injection, XSS | Parallel with others |
| performance-oracle | N+1, caching, bottlenecks, scaling | Parallel with others |
| data-integrity-guardian | Schema, migrations, constraints, transactions | Parallel with others |

## Flow

```
architecture-strategist (design)
    ↓
[security-sentinel | performance-oracle | data-integrity-guardian] (parallel review)
    ↓
Merged assessment with ADR
```

## ADR Format

Uses MADR (Markdown Any Decision Records). See `references/adr-format.md`.

## Architecture Patterns

See `references/patterns-catalog.md` for common patterns the strategist considers.

## Key Principles

1. **Appropriate complexity** — the simplest architecture that meets requirements
2. **Document trade-offs** — every decision has pros and cons
3. **ADRs are permanent** — once accepted, superseded but not deleted
4. **Parallel review** — security, performance, and data integrity are independent concerns
