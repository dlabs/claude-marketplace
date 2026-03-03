# Team Catalog

Predefined team compositions for swarm commands.

---

## team-design

**Purpose**: Create and evaluate A/B design variants

| Order | Agent | Role | Dependencies |
|-------|-------|------|-------------|
| 1 | design-variant-generator | Create 2-3 variants | None |
| 2a | design-critic | Evaluate variants | Needs variants from step 1 |
| 2b | ab-test-engineer | Wire up flags + tracking | Needs variants from step 1 |

**Pattern**: Sequential-then-Parallel
**Output**: Variant files in source tree + critique + test plan

---

## team-architecture

**Purpose**: Comprehensive architecture review

| Order | Agent | Role | Dependencies |
|-------|-------|------|-------------|
| 1a | architecture-strategist | Core design + ADR | None |
| 1b | security-sentinel | OWASP review | None |
| 1c | performance-oracle | Performance analysis | None |
| 1d | data-integrity-guardian | Data layer review | None |

**Pattern**: All Parallel
**Output**: ADR with merged security/performance/data assessments

---

## team-review

**Purpose**: Multi-faceted code review

| Order | Agent | Role | Dependencies |
|-------|-------|------|-------------|
| 1a | code-quality-reviewer | Style + conventions | None |
| 1b | test-coverage-analyst | Test completeness | None |
| 1c | trunk-guard | TBD compliance | None |
| 1d | pattern-recognizer | Anti-patterns + SOLID | None |

**Pattern**: All Parallel
**Output**: Unified P1/P2/P3 review report

---

## team-compound

**Purpose**: Document solved problem for knowledge base

| Order | Agent | Role | Dependencies |
|-------|-------|------|-------------|
| 1a | context-analyzer | Problem metadata | None |
| 1b | solution-extractor | Root cause + fix | None |
| 1c | related-docs-finder | Cross-references | None |
| 1d | prevention-strategist | Prevention measures | None |
| 1e | category-classifier | YAML frontmatter | None |
| 2 | (coordinator) | Assemble document | Needs all step 1 outputs |

**Pattern**: Parallel-then-Assembly
**Output**: `docs/solutions/{category}/{filename}.md`

---

## team-full-swarm

**Purpose**: Complete design → architecture → review pipeline

| Order | Team | Agents | Pattern |
|-------|------|--------|---------|
| 1 | team-design | design-variant-generator, design-critic, ab-test-engineer | Sequential-then-Parallel |
| 2 | team-architecture | architecture-strategist, security-sentinel, performance-oracle, data-integrity-guardian | All Parallel |
| 3 | team-review | code-quality-reviewer, test-coverage-analyst, trunk-guard, pattern-recognizer | All Parallel |

**Pattern**: Sequential teams with approval gates between each
**Output**: All deliverables from all teams

---

## team-go

**Purpose**: Lightweight plan+build for small-to-medium work

| Order | Step | Agent/Action | Dependencies |
|-------|------|-------------|-------------|
| 1 | Read context | (inline) stack profile + CLAUDE.md | None |
| 2 | Triage scope | (inline) auto-classify small/medium/escalate | None |
| 3 | Quick plan | (inline) bullets or lite plan doc | None |
| 4 | Confirm | (gate) user approval | Needs triage from step 2 |
| 5 | Implement | lean-implementor | Needs plan from step 3 |
| 6 | Self-check | (inline) tests + linting | Needs implementation from step 5 |
| 7 | Present | (inline) summary + next steps | Needs self-check from step 6 |

**Pattern**: Sequential (mostly inline, one agent)
**Output**: Implemented change + suggestion to run `/simplify` and `/bp:ship`

---

## Built-In Skill Integration

Blueprint-dev integrates with two built-in Claude Code commands:

### /simplify

Runs 3 agents (reuse, quality, efficiency) and auto-fixes issues in your code.

| Integration Point | Command | Behavior |
|-------------------|---------|----------|
| Automatic | `/bp:build` (Step 5.5) | Runs after implementation, before presenting |
| Automatic | `/bp:lfg` (Phase 5) | Runs after build phase implementation |
| Suggested | `/bp:review` (Step 5) | Offered as next step for P2/P3 findings |
| Suggested | `/bp:go` (Step 7) | Suggested before `/bp:ship` |
| Suggested | `/bp:lfg` (Phase 6) | Offered after review findings |

### /batch

Decomposes large changes into parallel worktree workers, each creating a PR.

| Integration Point | Command | Behavior |
|-------------------|---------|----------|
| Wrapper | `/bp:batch` | Adds project context, conventions, batch manifest |
| Recommended by | scope-sentinel | When plan involves same pattern across 10+ files |

---

## Full Pipeline (lfg)

**Purpose**: End-to-end development workflow

| Phase | Command | Teams/Agents | Gate |
|-------|---------|-------------|------|
| 1 | discover | stack-detective, claude-md-advisor | Auto |
| 2 | plan | requirements-analyst, research-scout, scope-sentinel | Approval |
| 3 | design | team-design | Approval |
| 4 | architect | team-architecture | Approval |
| 5 | build | trunk-implementor, feature-flag-engineer | Approval |
| 6 | review | team-review | Approval |
| 7 | ship | trunk-guard (final) | Approval |
| 8 | compound | team-compound | Auto |

**Pattern**: Sequential phases with user approval gates
**Output**: Full feature development lifecycle deliverables

**Post-pipeline utilities** (optional, not gated):

| Command | Purpose | Dependencies |
|---------|---------|-------------|
| `bp:test-browser` | E2e browser tests on PR-affected pages | `agent-browser` CLI |
| `bp:feature-video` | Record video walkthrough for PR documentation | `agent-browser` + `ffmpeg` |

These are standalone commands, not agent swarms. They can be run after any phase (typically after `build`, `review`, or `ship`).

---

## Agent Count Summary

| Team | Agents | Parallel | Sequential |
|------|--------|----------|-----------|
| team-design | 3 | 2 | 1 |
| team-architecture | 4 | 4 | 0 |
| team-review | 4 | 4 | 0 |
| team-compound | 5+coordinator | 5 | 1 |
| team-full-swarm | 11 | varies | 3 teams |
| team-go | 1 (lean-implementor) | 0 | 1 |
| Full pipeline | 27 (all) | varies | 8 phases |
