---
name: pr-workflow
description: "End-to-end pull request lifecycle reference. Ties together branch creation, implementation, /simplify, code review, and merge following trunk-based-dev rules."
user-invocable: false
---

# PR Workflow Lifecycle

Unified reference connecting the full pull request lifecycle from branch creation to merge. This skill ties together trunk-based-dev rules, simplify-integration, and review workflows into a single coherent process.

## Lifecycle Stages

### 1. Branch Creation
- Create from trunk: `feature/{ticket-or-slug}`
- Use git-worktree for parallel work (optional)
- Branch should be short-lived (<2 days)

### 2. Implementation
- Follow lightweight-planning or planning-methodology (based on scope)
- Keep changes focused — one concern per PR
- Target <400 LOC per PR
- Use feature flags for user-facing behavior

### 3. Pre-Review: Simplify
- Run `/simplify` before requesting review
- Checks for: dead code, unnecessary abstractions, over-engineering
- Fixes found issues automatically where possible
- Complements but does not replace human/agent review

### 4. Code Review
- Run `/bp:review` for multi-agent parallel review
- Agents check: architecture, security, performance, data integrity, code quality
- Address all HIGH severity findings before merge
- MEDIUM findings should be addressed or documented as tech debt

### 5. Ship Gates
- Run `/bp:ship` for final pre-merge checks
- Validates:
  - CI passing
  - Branch age (<2 days)
  - PR size (<400 LOC)
  - No unresolved review comments
  - Feature flags in place for user-facing changes

### 6. Merge
- Squash merge to trunk (default)
- Delete feature branch after merge
- Clean up worktree if used

## Decision Matrix

| Scenario | Action |
|----------|--------|
| PR <200 LOC, single concern | Direct merge after review |
| PR 200-400 LOC, related changes | Review + simplify, then merge |
| PR >400 LOC | Split into stacked PRs before review |
| PR touches auth/payments | Require security-sentinel review |
| PR includes migrations | Require data-integrity-guardian review |

## Splitting Large PRs

When a PR exceeds 400 LOC, split following this order:
1. **Data model** — migrations, schema changes
2. **Backend** — API endpoints, business logic
3. **Frontend** — UI components, client-side logic
4. **Integration** — wiring, feature flag setup, tests

Each split PR should be independently deployable behind feature flags.

## Rollback Plan

Every PR to trunk should have an implicit rollback strategy:
- **Feature-flagged changes**: Turn off the flag
- **Data migrations**: Include reversible migration
- **Config changes**: Previous config is the rollback
- **Infrastructure changes**: Document manual rollback steps in PR description
