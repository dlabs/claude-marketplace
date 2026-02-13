# Blueprint-Dev: The Complete Guide

A planning-first, design-driven development workflow for Claude Code.

---

## Table of Contents

1. [Introduction](#introduction)
2. [Philosophy](#philosophy)
3. [Installation & Setup](#installation--setup)
4. [The Pipeline](#the-pipeline)
5. [Commands Reference](#commands-reference)
6. [Use Cases](#use-cases)
7. [Advanced Usage](#advanced-usage)
8. [Architecture Deep Dive](#architecture-deep-dive)
9. [Customization](#customization)

---

## Introduction

Blueprint-dev is a Claude Code plugin that enforces a disciplined, planning-first approach to software development. Instead of jumping straight to code, it structures your workflow through eight distinct phases — each powered by specialized AI agents that collaborate, review each other's work, and accumulate knowledge over time.

### What It Does

- **Detects your stack** automatically and adapts all agents to your specific frameworks, tools, and conventions
- **Plans before coding** with requirements decomposition, research, and scope guarding
- **Creates production A/B design variants** — real code, not mockups — wired with feature flags and analytics
- **Reviews architecture** with parallel security, performance, and data integrity agents
- **Enforces trunk-based development** through hooks, agents, and documented conventions
- **Compounds team knowledge** by documenting every solved problem in a searchable format that feeds back into future planning

### What It Contains

| Component | Count | Description |
|-----------|-------|-------------|
| Agents | 25 | Specialized AI agents, all running on Opus |
| Commands | 17 | Slash commands for every workflow phase |
| Skills | 8 | Reference knowledge with templates and patterns |
| Hooks | 1 | Automatic stack detection on session start |
| Scripts | 1 | Fast stack detection for session startup |

### Who It's For

- Solo developers who want senior-engineering-level process without the team
- Teams using Claude Code who want consistent, documented workflows
- Projects where design decisions, architecture trade-offs, and solved problems need to be recorded — not lost in chat history
- Anyone practicing trunk-based development who wants automated guardrails

---

## Philosophy

### 50%+ Time in Planning & Design

The core belief behind blueprint-dev is that most bugs, rewrites, and wasted effort come from insufficient planning. The plugin's pipeline deliberately front-loads thinking:

```
[====== Planning & Design (50%+) ======][== Build ==][= Review =][Ship]
```

By the time you write code, you've already:
- Decomposed requirements into testable specs
- Researched existing solutions and libraries
- Guarded against scope creep
- Created production design variants with hypotheses
- Reviewed architecture for security, performance, and data integrity

### Design Through Production Code

A/B variants in blueprint-dev are not wireframes, sketches, or prototypes. They are **fully functional production components** that ship to trunk behind feature flags. This means:

- Variants follow your project's actual conventions
- They include real error handling, loading states, and accessibility
- Analytics tracking fires at interaction points from day one
- Winners are determined by data, not opinions
- Cleanup is a simple PR that removes the losing code

### Knowledge Compounds Over Time

Every problem you solve with blueprint-dev can be documented through `/compound`. Those documents live at `docs/solutions/` with structured YAML frontmatter. When you plan a new feature with `/plan`, the research-scout agent searches those documents automatically. Past learnings feed directly into future planning — your team gets smarter with every solved problem.

### Stack-Agnostic, Convention-Aware

Blueprint-dev doesn't care if you're building a Next.js app, a Laravel monolith, or a Rails API. It auto-detects your stack and adapts:

- Agent prompts reference your specific framework's patterns
- Code templates use your detected feature flag provider
- Review standards match your linting and testing setup
- Architecture suggestions respect your existing patterns

---

## Installation & Setup

### Install the Plugin

```bash
# From the directory containing blueprint-dev/
claude plugin add ./blueprint-dev

# Or specify the plugin directory directly
claude --plugin-dir ./blueprint-dev
```

### What Happens on First Session

When you start a Claude Code session with blueprint-dev installed, the **SessionStart hook** automatically runs `detect-stack.sh`. This is a fast (< 2 seconds) check that scans for common files:

```
[blueprint-dev] Detected stack: php/composer, laravel, docker, phpunit, pennant.
Run /blueprint-dev:bp:discover for full profile + CLAUDE.md suggestions.
```

This quick detection gives agents baseline context. For a complete stack profile, run `/blueprint-dev:bp:discover`.

### First-Time Workflow

```bash
# 1. Detect your full stack and get CLAUDE.md suggestions
/blueprint-dev:bp:discover

# 2. Review suggestions at .blueprint/claude-md-suggestions.md
# Copy relevant sections to your CLAUDE.md

# 3. Start planning your first feature
/blueprint-dev:bp:plan "add user authentication"
```

### Directory Structure Created

Blueprint-dev creates two directory structures in your project:

**`.blueprint/`** — temporary working state (add to `.gitignore`):
```
.blueprint/
├── stack-profile.json          # Detected stack and conventions
├── claude-md-suggestions.md    # Suggested CLAUDE.md improvements
├── plans/                      # Feature plans
├── adrs/                       # Architecture Decision Records
├── reviews/                    # Code review reports
└── ships/                      # Ship manifests
```

**`docs/`** — permanent knowledge (commit to repo):
```
docs/
├── ab-tests/{test-name}/
│   ├── PLAN.md                 # A/B test hypothesis and metrics
│   └── DECISION.md             # Post-test results and decision
└── solutions/{category}/
    └── {symptom}-{module}-{date}.md   # Compound knowledge docs
```

---

## The Pipeline

Blueprint-dev's core workflow is an 8-phase pipeline. Each phase produces artifacts that subsequent phases consume.

```
discover → plan → design → architect → build → review → ship → compound
```

### Phase Flow

```
                                        ┌─────────────┐
                                        │  discover    │ Auto-detect stack
                                        └──────┬──────┘
                                               │
                                        ┌──────▼──────┐
                                        │    plan      │ Requirements + research + scope
                                        └──────┬──────┘
                                               │ [approval gate]
                                        ┌──────▼──────┐
                                        │   design     │ A/B variants + flags + tracking
                                        └──────┬──────┘
                                               │ [approval gate]
                                        ┌──────▼──────┐
                                        │  architect   │ ADR + security/perf/data reviews
                                        └──────┬──────┘
                                               │ [approval gate]
                                        ┌──────▼──────┐
                                        │    build     │ Code + tests + feature flags
                                        └──────┬──────┘
                                               │ [approval gate]
                                        ┌──────▼──────┐
                                        │   review     │ 4 parallel review agents
                                        └──────┬──────┘
                                               │ [approval gate]
                                        ┌──────▼──────┐
                                        │    ship      │ PR + ship manifest
                                        └──────┬──────┘
                                               │
                                        ┌──────▼──────┐
                                        │  compound    │ Document what was learned
                                        └─────────────┘
```

### You Don't Always Need Every Phase

The pipeline is modular. Common shortcuts:

| Scenario | Phases Used |
|----------|------------|
| Quick bug fix | build → review → ship → compound |
| Backend-only feature | discover → plan → architect → build → review → ship |
| UI experiment | discover → plan → design → build → review → ship |
| Full feature | All 8 phases via `/blueprint-dev:bp:lfg` |

---

## Commands Reference

### Core Pipeline Commands

| Command | Purpose | Agents |
|---------|---------|--------|
| `/blueprint-dev:bp:discover` | Detect stack, produce profile, suggest CLAUDE.md updates | stack-detective, claude-md-advisor |
| `/blueprint-dev:bp:plan "feature"` | Decompose requirements, research, guard scope | requirements-analyst, research-scout, scope-sentinel |
| `/blueprint-dev:bp:design "feature"` | Create 2-3 production A/B variants with flags + tracking | design-variant-generator, design-critic, ab-test-engineer |
| `/blueprint-dev:bp:architect "system"` | Architecture design + parallel robustness review | architecture-strategist, security-sentinel, performance-oracle, data-integrity-guardian |
| `/blueprint-dev:bp:build` | Implement with TBD practices and feature flags | trunk-implementor, feature-flag-engineer |
| `/blueprint-dev:bp:review` | Parallel multi-agent code review | code-quality-reviewer, test-coverage-analyst, trunk-guard, pattern-recognizer |
| `/blueprint-dev:bp:ship` | Final gates check + PR creation | trunk-guard |
| `/blueprint-dev:bp:compound` | Document solved problem for knowledge base | context-analyzer, solution-extractor, related-docs-finder, prevention-strategist, category-classifier |

### A/B Testing Commands

| Command | Purpose |
|---------|---------|
| `/blueprint-dev:bp:ab-status` | Show table of all active A/B tests with duration and status |
| `/blueprint-dev:bp:ab-decide "test-name"` | Analyze results, determine winner, produce cleanup plan |
| `/blueprint-dev:bp:ab-cleanup "test-name"` | Remove losing variant, promote winner, clean up flags |

### Team Swarm Commands

| Command | Agents | Pattern |
|---------|--------|---------|
| `/blueprint-dev:bp:team-design` | 3 agents | Sequential-then-parallel |
| `/blueprint-dev:bp:team-architecture` | 4 agents | All parallel |
| `/blueprint-dev:bp:team-review` | 4 agents | All parallel |
| `/blueprint-dev:bp:team-compound` | 5 agents | Parallel-then-assembly |
| `/blueprint-dev:bp:team-full-swarm` | 11 agents | 3 sequential teams |

### End-to-End

| Command | Purpose |
|---------|---------|
| `/blueprint-dev:bp:lfg "feature"` | Full pipeline with approval gates between every phase |

---

## Use Cases

### Use Case 1: New Feature from Scratch

You're adding user authentication to a Next.js application.

```bash
# Start with the full pipeline
/blueprint-dev:bp:lfg "user authentication with email and OAuth"
```

**What happens:**

1. **Discover** detects Next.js 14 (App Router), Prisma, PostHog, Vitest. Produces stack profile. Suggests CLAUDE.md additions for auth patterns.

2. **Plan** decomposes into:
   - FR-001: Email/password registration
   - FR-002: Login with session management
   - FR-003: OAuth (Google, GitHub) integration
   - FR-004: Protected routes middleware
   - Research-scout finds that the project already has a `useCurrentUser` hook. Scope-sentinel flags FR-003 as deferrable to v2.

3. **Design** creates two login page variants:
   - Variant A (Control): Traditional stacked form with email/password fields
   - Variant B (Challenger): Split layout with social login prominent, email as secondary
   - Both are real `LoginPage.tsx` components with PostHog feature flags and tracking events
   - PLAN.md documents: "We believe prominent social login will increase registration rate by 15% because OAuth reduces friction"

4. **Architect** produces ADR-0001:
   - Chose NextAuth.js with Prisma adapter
   - Security-sentinel flags: add rate limiting on login endpoint, enforce CSRF tokens
   - Performance-oracle notes: session validation should use Redis cache, not DB lookup per request
   - Data-integrity-guardian reviews the User schema migration

5. **Build** implements on `feature/auth`:
   - NextAuth config, User model, Prisma migration
   - Login page variants behind `ab_login_page` flag
   - Tests for registration, login, protected routes
   - Feature flag: `feature_protected_routes` (off by default)

6. **Review** — 4 agents in parallel find:
   - P1: Missing rate limit on `/api/auth/login`
   - P2: Password validation allows weak passwords
   - P3: Consider adding `aria-live` region for login errors

7. **Ship** — after fixing P1, creates PR with full context. Ship manifest records everything.

8. **Compound** — the rate limiting oversight gets documented:
   ```yaml
   category: security-issues
   root_cause: "No rate limiting on auth endpoints"
   prevention: "Add rate-limit middleware check to architecture review checklist"
   ```

---

### Use Case 2: A/B Test a Dashboard Redesign

You want to test whether a card-based dashboard outperforms the current table view.

```bash
# Create the variants
/blueprint-dev:bp:design "dashboard main view"
```

**Generated files:**
```
src/modules/dashboard/ab-tests/dashboard-layout/
├── variant-a.tsx              # Current: table-based layout (control)
├── variant-b.tsx              # New: card-based layout (challenger)
├── ab-test-wrapper.tsx        # PostHog flag-gated wrapper
├── tracking.ts                # Events: viewed, interacted, completed_action
├── types.ts                   # Shared DashboardProps interface
└── README.md                  # Design hypothesis per variant

docs/ab-tests/dashboard-layout/
└── PLAN.md                    # Hypothesis, metrics, sample size, timeline
```

**Two weeks later, check results:**
```bash
/blueprint-dev:bp:ab-status
```
```
| Test             | Variants              | Duration | Status |
|------------------|-----------------------|----------|--------|
| dashboard-layout | control, variant-b    | 14 days  | active |
```

**Analyze and decide:**
```bash
/blueprint-dev:bp:ab-decide "dashboard-layout"
```
You provide the metrics from PostHog. The design-decision-analyst determines Variant B (cards) won with p=0.02 and a 12% increase in task completion rate. It writes `DECISION.md` with a cleanup plan.

**Clean up:**
```bash
/blueprint-dev:bp:ab-cleanup "dashboard-layout"
```
Promotes `variant-b.tsx` to `DashboardView.tsx`, removes the wrapper, tracking, and feature flag. Clean codebase.

---

### Use Case 3: Inherited Codebase Onboarding

You've just joined a project and need to understand the stack.

```bash
/blueprint-dev:bp:discover
```

**Output:**
```
Stack Profile: .blueprint/stack-profile.json

| Category      | Detected                          |
|---------------|-----------------------------------|
| Language      | PHP 8.3                           |
| Framework     | Laravel 11 (Inertia + Vue 3)      |
| Package Mgr   | Composer + pnpm                   |
| Database      | PostgreSQL + Eloquent             |
| Testing       | PHPUnit + Pest + Cypress          |
| CI/CD         | GitHub Actions                    |
| Feature Flags | Laravel Pennant                   |
| Monorepo      | Yes (packages/ directory)         |

8 CLAUDE.md suggestions generated → .blueprint/claude-md-suggestions.md
```

The suggestions include:
- "Use `php artisan test --parallel` for tests"
- "Feature flags via Pennant: `Feature::active('name')`"
- "Inertia pages at `resources/js/Pages/`, shared props in `HandleInertiaRequests`"
- "Packages follow `packages/{vendor}/{name}` structure"

Now every agent in blueprint-dev adapts to this Laravel+Inertia+Vue stack.

---

### Use Case 4: Post-Bug-Fix Documentation

You just spent 2 hours debugging a race condition in token refresh logic.

```bash
/blueprint-dev:bp:compound "token refresh race condition on page load"
```

**5 agents run in parallel:**

- **context-analyzer** extracts: module=authentication, symptom=intermittent 401 on page load, severity=high
- **solution-extractor** captures: root cause was concurrent refresh requests, fix was a mutex lock on the refresh queue
- **related-docs-finder** finds a similar issue documented 3 months ago with session timeouts
- **prevention-strategist** writes a regression test and suggests adding a "concurrent request" section to the testing checklist
- **category-classifier** tags: `runtime-errors`, `[jwt, token-refresh, race-condition, axios]`

**Result:** `docs/solutions/runtime-errors/token-refresh-race-authentication-2026-02-10.md`

Next time someone runs `/blueprint-dev:bp:plan` for anything touching authentication, the research-scout will find this document and warn about the token refresh race condition.

---

### Use Case 5: Architecture Review for a Risky Change

You're adding real-time notifications and want to validate the approach.

```bash
/blueprint-dev:bp:architect "real-time notification system"
```

**4 agents run in parallel:**

- **architecture-strategist** writes ADR-0003: chose Server-Sent Events over WebSockets (simpler, sufficient for unidirectional notifications)
- **security-sentinel** flags: notification payloads must not leak data to wrong users; add user-scoped event channels
- **performance-oracle** notes: fan-out to 10k concurrent connections needs Redis pub/sub, not in-process; suggests connection pooling
- **data-integrity-guardian** reviews the notifications table schema: needs `read_at` nullable timestamp, composite index on `(user_id, read_at)`

**Result:** `.blueprint/adrs/0003-real-time-notifications-via-sse.md` with all findings merged.

---

### Use Case 6: Quick Review Before Merging

You've written code and want a thorough review before shipping.

```bash
/blueprint-dev:bp:review
```

**4 agents run in parallel on your branch:**

```
Code Quality Review
├── P1: SQL query built with string concatenation (injection risk) — auth/login.php:42
├── P2: Duplicate validation logic in 2 controllers — should extract to FormRequest
└── P3: Consider extracting magic number 30 to named constant — config/session.php:15

Test Coverage Analysis
├── Requirements covered: 8/10 (80%)
├── Missing: FR-007 (password reset flow), FR-009 (rate limiting)
└── Edge case gap: empty email input not tested

TBD Compliance
├── Branch age: 1 day (PASS)
├── PR size: 287 lines (PASS)
└── Feature flag: new endpoints flagged (PASS)

Pattern Analysis
├── P2: Controller is doing too much — extract service class for business logic
└── Positive: Good use of repository pattern in UserRepository
```

---

## Advanced Usage

### Running the Full Pipeline with `/lfg`

The `/blueprint-dev:bp:lfg` command chains all 8 phases with approval gates. At each gate, you can:

1. **Approve** — continue to the next phase
2. **Iterate** — re-run the current phase with adjustments
3. **Skip** — skip a phase (e.g., skip `/design` for backend-only work)
4. **Stop** — halt and resume later with individual commands

```bash
/blueprint-dev:bp:lfg "settings page with notification preferences"
```

The pipeline preserves all artifacts. If you stop at phase 5, you can later run:
```bash
/blueprint-dev:bp:review     # picks up where you left off
/blueprint-dev:bp:ship       # when review passes
```

### Team Swarms for Parallel Agent Work

Team commands spawn multiple agents simultaneously for maximum throughput:

```bash
# 4 architecture agents analyze in parallel
/blueprint-dev:bp:team-architecture "payment processing"

# 4 review agents review in parallel
/blueprint-dev:bp:team-review

# Full design → architecture → review pipeline
/blueprint-dev:bp:team-full-swarm "checkout flow"
```

**How parallel execution works:**

The swarm-coordinator manages:
- **Sequencing** — agents that need prior output run first (design-variant-generator before design-critic)
- **Parallelism** — independent agents run simultaneously (all 4 review agents at once)
- **Aggregation** — results are merged, deduplicated, and conflicts flagged
- **Conflict resolution** — when agents disagree, the coordinator flags it for your decision rather than auto-resolving

### Compound Knowledge as a Feedback Loop

The compound knowledge system creates a self-reinforcing learning cycle:

```
                    ┌──────────────────────────────────────────┐
                    │                                          │
                    ▼                                          │
               /plan                                          │
          research-scout ──── searches ────► docs/solutions/   │
                    │                              ▲          │
                    │                              │          │
                    ▼                              │          │
            build & debug                          │          │
                    │                              │          │
                    ▼                              │          │
             /compound ──── writes to ─────────────┘          │
                    │                                          │
                    └──────────────────────────────────────────┘
```

**Making it work well:**

1. Run `/blueprint-dev:bp:compound` after every significant bug fix or debugging session
2. After compounding, consider promoting critical patterns to CLAUDE.md Required Reading
3. Periodically review `docs/solutions/` for recurring patterns that indicate systemic issues

**Searching compound knowledge manually:**
```bash
# Find all race condition solutions
grep -r "race-condition" docs/solutions/

# Find all auth-related issues
grep -r "module: authentication" docs/solutions/

# Find critical issues
grep -r "severity: critical" docs/solutions/
```

### A/B Testing Lifecycle Management

The full A/B testing lifecycle spans multiple commands:

```
/design          Create variants + flags + tracking + PLAN.md
    │
    │ (ship to trunk behind flags)
    │ (monitor analytics for planned duration)
    │
/ab-status       Check which tests are running and for how long
    │
/ab-decide       Analyze results → DECISION.md with cleanup plan
    │
/ab-cleanup      Promote winner, remove loser, clean flags
```

**Variant differentiation rules** — variants must differ in at least one meaningful UX dimension:

| Dimension | Example |
|-----------|---------|
| Layout | Grid vs. list, sidebar vs. inline |
| Interaction | Modal vs. inline edit, wizard vs. single form |
| Information hierarchy | What's primary vs. secondary vs. hidden |
| Information density | Minimal/scannable vs. comprehensive |
| Navigation | Tabs vs. accordion, scroll vs. pagination |

Color swaps, font changes, and icon changes alone are **not** sufficient differentiators.

**Auto-detected feature flag providers:**

| Provider | Detection | Variant Selection |
|----------|-----------|-------------------|
| PostHog | `posthog-js` in package.json | `posthog.getFeatureFlag('key')` |
| LaunchDarkly | `launchdarkly-*` in package.json | `ldClient.variation('key', default)` |
| Unleash | `unleash-client` in package.json | `unleash.getVariant('key')` |
| Laravel Pennant | `laravel/pennant` in composer.json | `Feature::value('key')` |
| Rails Flipper | `flipper` in Gemfile | `Flipper.enabled?(:key, actor)` |
| Env-based | (fallback) | `process.env.AB_TEST_NAME` |

### Trunk-Based Development Enforcement

Blueprint-dev enforces TBD at two layers:

**Layer 1: Agent guards (explicit checks)**
The `trunk-guard` agent runs during `/review` and `/ship`:
```
TBD Compliance Report
| Check       | Status | Details              |
|-------------|--------|----------------------|
| Branch age  | PASS   | 6 hours              |
| PR size     | WARN   | 450 lines (target <400) |
| Tests       | PASS   | All passing          |
| Feature flags| PASS  | New endpoints flagged |
```

**Layer 2: Conventions (documented)**
The `claude-md-advisor` suggests TBD rules for your CLAUDE.md. Example suggestion:
```markdown
## Trunk-Based Development
- Feature branches: `feature/{slug}`, max 2 days
- PR size: <400 lines changed
- All new user-facing behavior behind feature flags
- Tests and linting must pass on every commit
```

**PR splitting guidance when code is too large:**

| Feature Size | Strategy |
|-------------|----------|
| < 200 LOC | Single PR |
| 200-600 LOC | 2 PRs: backend + frontend |
| 600+ LOC | 3+ PRs: data model, then backend logic, then frontend, then integration |

### CLAUDE.md as a Living Document

Blueprint-dev treats CLAUDE.md as the highest-leverage file in your project. The `claude-md-advisor` generates suggestions but **never auto-writes** — you review and cherry-pick.

**Sources of CLAUDE.md suggestions:**

1. **Stack detection** — framework-specific conventions (e.g., "Use App Router, not Pages" for Next.js 14)
2. **Compound knowledge** — prevention strategies from documented problems
3. **Architecture decisions** — key ADR outcomes that affect coding patterns
4. **Review patterns** — recurring review findings that should become conventions

**Promoting compound knowledge to CLAUDE.md:**

After `/compound` documents a critical pattern, you can promote it:
```markdown
## Required Reading
- `docs/solutions/runtime-errors/token-refresh-race-authentication-2026-02-10.md`
  — Token refresh must use a mutex lock. Never fire parallel refresh requests.
```

### Custom Phase Ordering

You don't have to follow the full pipeline. Common partial workflows:

```bash
# Quick fix: just build, review, ship
/blueprint-dev:bp:build
/blueprint-dev:bp:review
/blueprint-dev:bp:ship

# Research-heavy: plan extensively, then build
/blueprint-dev:bp:discover
/blueprint-dev:bp:plan "complex data migration"
/blueprint-dev:bp:architect "migration strategy"
/blueprint-dev:bp:build

# Design-led: focus on the user experience
/blueprint-dev:bp:plan "onboarding flow"
/blueprint-dev:bp:design "onboarding flow"
/blueprint-dev:bp:ab-status  # check after a week
/blueprint-dev:bp:ab-decide "onboarding-flow"

# Review-only: just review existing code
/blueprint-dev:bp:review
/blueprint-dev:bp:team-review  # or use the team swarm for parallel agents
```

---

## Architecture Deep Dive

### Agent Organization

The 25 agents are organized into 8 functional groups:

```
DISCOVERY (2)          PLANNING (3)           DESIGN (4)
├── stack-detective    ├── requirements-analyst├── design-variant-generator
└── claude-md-advisor  ├── research-scout      ├── design-critic
                       └── scope-sentinel      ├── ab-test-engineer
                                               └── design-decision-analyst

ARCHITECTURE (4)       BUILD (2)              REVIEW (4)
├── architecture-      ├── trunk-implementor   ├── code-quality-reviewer
│   strategist         └── feature-flag-       ├── test-coverage-analyst
├── security-sentinel      engineer            ├── trunk-guard
├── performance-oracle                         └── pattern-recognizer
└── data-integrity-
    guardian

COMPOUND (5)                    ORCHESTRATION (1)
├── context-analyzer            └── swarm-coordinator
├── solution-extractor
├── related-docs-finder
├── prevention-strategist
└── category-classifier
```

### How Agents Adapt to Your Stack

Every agent reads `.blueprint/stack-profile.json` at the start of its work. The profile contains:

```json
{
  "primary_language": "typescript",
  "framework": { "name": "next.js", "version": "14.2", "variant": "app-router" },
  "feature_flags": { "provider": "posthog" },
  "testing": { "unit": { "framework": "vitest" } },
  "conventions": { "file_naming": "kebab-case", "api_style": "rest" }
}
```

This means:
- The **code-quality-reviewer** checks for Next.js App Router patterns (Server Components, `use client`, streaming)
- The **ab-test-engineer** generates PostHog-specific wrapper code
- The **trunk-implementor** creates Vitest tests, not Jest tests
- The **security-sentinel** checks for Next.js-specific XSS vectors

### Swarm Orchestration Patterns

The swarm-coordinator uses four patterns:

**Sequential**: A must finish before B starts
```
requirements-analyst → research-scout → scope-sentinel
```

**All Parallel**: All agents run simultaneously
```
[security-sentinel | performance-oracle | data-integrity-guardian | architecture-strategist]
```

**Sequential-then-Parallel**: One creates, many evaluate
```
design-variant-generator → [design-critic | ab-test-engineer]
```

**Parallel-then-Assembly**: Many extract, one assembles
```
[context-analyzer | solution-extractor | related-docs-finder | prevention-strategist | category-classifier] → coordinator assembles document
```

### Hooks Architecture

One hook runs automatically:

| Hook | Event | Type | Purpose |
|------|-------|------|---------|
| SessionStart | Session begins | `command` | Run `detect-stack.sh` for quick stack detection |

The SessionStart hook is a **command** type (runs a shell script) for speed — it completes in under 2 seconds and gives all agents baseline stack context.

### Artifact Flow Between Phases

```
/discover
    └── .blueprint/stack-profile.json ──────────────────────┐
    └── .blueprint/claude-md-suggestions.md                 │
                                                            │
/plan                                                       │
    ├── reads: stack-profile.json ◄─────────────────────────┤
    ├── reads: docs/solutions/**/*.md (compound knowledge)  │
    └── writes: .blueprint/plans/{date}-{feature}.md ───┐   │
                                                        │   │
/design                                                 │   │
    ├── reads: stack-profile.json ◄─────────────────────┼───┤
    ├── reads: plans/ ◄─────────────────────────────────┘   │
    ├── writes: src/.../ab-tests/{name}/ (variant code)     │
    └── writes: docs/ab-tests/{name}/PLAN.md                │
                                                            │
/architect                                                  │
    ├── reads: stack-profile.json ◄─────────────────────────┤
    ├── reads: plans/                                       │
    └── writes: .blueprint/adrs/{NNNN}-{title}.md           │
                                                            │
/build                                                      │
    ├── reads: stack-profile.json ◄─────────────────────────┤
    ├── reads: plans/, adrs/                                │
    └── writes: source code + tests on feature branch       │
                                                            │
/review                                                     │
    ├── reads: stack-profile.json ◄─────────────────────────┘
    └── writes: .blueprint/reviews/{date}-review.md

/ship
    └── writes: .blueprint/ships/{date}-{branch}.md

/compound
    └── writes: docs/solutions/{category}/{filename}.md
                        │
                        └──── read by /plan's research-scout (knowledge loop)
```

---

## Customization

### Adapting to Your Workflow

**Skip phases you don't need.** The pipeline is modular — you can run any command independently without running prior phases. The agents will use whatever context exists and work with what they have.

**Adjust the hooks.** Modify `hooks/hooks.json` to change the SessionStart behavior or add additional lifecycle hooks.

**Customize the compound categories.** The category taxonomy in `skills/compound-knowledge/references/category-taxonomy.md` can be extended with project-specific categories.

**Extend the fingerprints.** The stack detection fingerprints in `skills/stack-detection/references/fingerprints.md` cover 100+ technologies. Add your own for internal tools or uncommon stacks.

### Key Files to Know

| File | Purpose | When to Modify |
|------|---------|---------------|
| `.claude-plugin/plugin.json` | Plugin manifest | Only if changing plugin structure |
| `hooks/hooks.json` | Automatic triggers | To adjust enforcement level |
| `scripts/detect-stack.sh` | Quick stack detection | To add detection for uncommon tools |
| `skills/*/references/*.md` | Reference knowledge | To add templates, patterns, fingerprints |
| Agent `.md` files | Agent behavior | To tune review standards, output formats |

### Integrating with Existing Workflows

Blueprint-dev doesn't replace your existing tools — it layers on top:

- **Git workflow**: Works with any Git hosting (GitHub, GitLab, Bitbucket). The trunk-guard checks `main`/`master`/`trunk` as the base branch.
- **CI/CD**: Agents check CI status but don't run CI themselves. Your existing pipeline handles builds.
- **Feature flags**: Auto-detects and uses your existing provider. Never introduces a new one.
- **Testing**: Writes tests in your existing framework and follows your existing conventions.
- **Linting**: Reviews against your configured linter, doesn't impose its own rules.
