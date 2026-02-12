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

---

## Agent Count Summary

| Team | Agents | Parallel | Sequential |
|------|--------|----------|-----------|
| team-design | 3 | 2 | 1 |
| team-architecture | 4 | 4 | 0 |
| team-review | 4 | 4 | 0 |
| team-compound | 5+coordinator | 5 | 1 |
| team-full-swarm | 11 | varies | 3 teams |
| Full pipeline | 26 (all) | varies | 8 phases |
