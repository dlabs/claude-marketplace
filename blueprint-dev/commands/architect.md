---
name: bp:architect
description: Architecture robustness check with parallel security, performance, and data integrity reviews. Produces ADR.
argument-hint: System or feature to architect
---

# /blueprint-dev:bp:architect

Run a comprehensive architecture review using 4 parallel specialist agents. Produces an Architecture Decision Record (ADR) with security, performance, and data integrity assessments.

## Usage

```
/blueprint-dev:bp:architect "auth system"
/blueprint-dev:bp:architect "payment processing"
/blueprint-dev:bp:architect   # (reviews the most recent plan)
```

## Prerequisites

- Recommended: run `/blueprint-dev:bp:plan` first to have requirements defined
- Recommended: have `.blueprint/stack-profile.json` from `/blueprint-dev:bp:discover`

## Workflow

### Step 1: Architecture Design
Use the **architecture-strategist** agent to:
- Evaluate options for the proposed feature/system
- Design the core architecture (components, data model, API, flows)
- Write an ADR in MADR format at `.blueprint/adrs/{NNNN}-{title}.md`

### Step 2: Parallel Robustness Review
Launch three agents **in parallel** using the Task tool:

1. **security-sentinel** — OWASP review, auth, injection, XSS
2. **performance-oracle** — N+1 queries, caching, bottlenecks, scaling
3. **data-integrity-guardian** — schema, migrations, constraints, transactions

Each agent reviews the architecture design from Step 1 and produces findings.

### Step 3: Merge Results
Append the three review summaries to the ADR:
- Security Review Summary section
- Performance Review Summary section
- Data Integrity Review Summary section

### Step 4: Present Assessment
Show the user:
1. **Architecture decision** — chosen option and rationale
2. **Security findings** — P1/P2/P3 with fixes
3. **Performance findings** — bottlenecks and optimizations
4. **Data integrity findings** — schema and migration safety
5. **Consolidated action items** — all P1 items across all reviews

### Step 5: Offer Next Steps
- "Address P1 findings before proceeding"
- "Run `/blueprint-dev:bp:build` to start implementation"
- "Run `/blueprint-dev:bp:design` to create design variants"

## Notes

- The parallel review pattern reduces total time compared to sequential reviews
- ADRs are permanent records — they're not deleted, only superseded by newer ones
- If there are P1 security findings, strongly recommend addressing them before building
- The architecture-strategist runs first because the reviewers need a design to review
