---
name: planning-methodology
description: Structured planning methodology for decomposing features into testable requirements, researching approaches, and guarding scope. Templates for PRD, spec, and scope documents.
---

# Planning Methodology

This skill provides the planning framework used by the blueprint-dev planning phase. Philosophy: **50%+ of development time should be in planning and design**.

## When to Use

- `/blueprint-dev:bp:plan` — full planning workflow
- When any agent needs to understand the planning approach
- When generating or reviewing requirements documents

## Planning Flow

```
User Request → Requirements Analysis → Research → Scope Guard → Approved Plan
```

### 1. Requirements Analysis
The `requirements-analyst` agent decomposes the feature request:
- Functional requirements with acceptance criteria (Given/When/Then)
- Non-functional requirements (performance, security, accessibility)
- Dependencies and risk assessment
- Size estimation and phase splitting
- Test strategy outline

### 2. Research
The `research-scout` agent investigates before building:
- Internal: existing code patterns, past solutions (docs/solutions/)
- External: libraries, community approaches, framework patterns
- Produces evidence-based recommendation

### 3. Scope Guard
The `scope-sentinel` agent reviews the plan:
- Flags scope creep (features not asked for)
- Flags YAGNI violations (premature abstractions)
- Suggests simplifications
- Produces a clean scope boundary

## Templates

See `references/templates.md` for:
- PRD template (Product Requirements Document)
- Technical spec template
- Scope boundary template

## Quality Checks

A good plan:
- [ ] Every requirement traces to a user need
- [ ] Every requirement has testable acceptance criteria
- [ ] Research was done before choosing an approach
- [ ] Scope sentinel approved (no creep flags unresolved)
- [ ] Size estimate is realistic
- [ ] Dependencies are identified and their status known
- [ ] Risks have mitigation strategies
