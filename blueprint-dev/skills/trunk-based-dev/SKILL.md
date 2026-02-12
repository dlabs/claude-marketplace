---
name: trunk-based-dev
description: Trunk-based development practices with short-lived branches, feature flags, small PRs, and continuous integration. Enforced via hooks and agents.
---

# Trunk-Based Development

This skill documents the trunk-based development practices enforced by blueprint-dev. TBD is a source-control branching model where developers collaborate on code in a single branch called "trunk" (main/master), resist any pressure to create other long-lived development branches, and use feature flags to manage incomplete features.

## Core Rules

### 1. Short-Lived Branches
- Feature branches live **<2 days** maximum
- Branch naming: `feature/{ticket-or-slug}`
- Created from trunk, merged back to trunk
- No branch-to-branch merges

### 2. Small Pull Requests
- Target **<400 lines** of changes
- One concern per PR
- If larger, split into stacked PRs

### 3. Feature Flags
- All new user-facing behavior behind flags
- Flags are off by default
- Gradual rollout: dev → staging → canary → full
- Clean up flags within 2 weeks of full rollout

### 4. Continuous Integration
- All tests pass on every commit
- Linting passes on every commit
- Type checking passes on every commit
- Trunk is always deployable

## Enforcement

### Layer 1: Hooks (automatic, soft)
The PreToolUse hook on Bash commands detects:
- Direct pushes to main/master/trunk → warns
- Branch creation not prefixed with `feature/` → warns
- These are warnings, not blocks

### Layer 2: Agents (explicit, hard)
The `trunk-guard` agent runs during `/review` and `/ship`:
- Checks branch age (warns if >2 days)
- Checks PR size (warns if >400 LOC)
- Checks CI status
- Can block merges if violations are critical

### Layer 3: Conventions (documented)
CLAUDE.md should document TBD rules. The `claude-md-advisor` suggests TBD sections when trunk-based-dev is detected as the workflow.

## Feature Flag Patterns

See `references/flag-patterns.md` for stack-specific feature flag patterns.

## When to Split PRs

| Feature Size | Split Strategy |
|-------------|---------------|
| Small (<200 LOC) | Single PR |
| Medium (200-600 LOC) | 2 PRs: backend + frontend |
| Large (600+ LOC) | 3+ PRs: data model → backend → frontend → integration |

## Compatible with A/B Testing

A/B variants work naturally with TBD:
- All variant code ships to trunk behind feature flags
- No long-lived branches for experiments
- Cleanup is a small PR that removes the losing variant
