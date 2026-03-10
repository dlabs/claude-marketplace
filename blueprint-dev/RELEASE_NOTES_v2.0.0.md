# Blueprint-Dev v2.0.0 Release Notes

**Release Date**: 2026-03-10
**Previous Version**: 1.3.0

---

## Overview

v2.0.0 is a skill infrastructure upgrade that aligns all skills with Claude Code Skill 2.0 best practices and introduces an evaluation framework for skill quality benchmarking. No breaking changes to commands, agents, or workflows.

Three major themes:

1. **Skill Frontmatter Compliance** — All 15 skills now use the full set of available frontmatter fields (`user-invocable`, `disable-model-invocation`, `allowed-tools`, `argument-hint`) for precise control over visibility and behavior
2. **Eval Framework** — New evaluation infrastructure for testing skill quality with prompt-criteria pairs, fixtures, and benchmark reports
3. **New Skills** — `eval-runner` for running eval suites, `pr-workflow` as a unified PR lifecycle reference

### What Changed

| Component | v1.3.0 | v2.0.0 | Delta |
|-----------|--------|--------|-------|
| Agents | 26 | 26 | — |
| Commands | 21 | 21 | — |
| Skills | 13 | 15 | +2 (eval-runner, pr-workflow) |
| Evals | 0 | 5 | +5 (agent-browser, git-worktree, lightweight-planning, stack-detection, trunk-based-dev) |

---

## 1. Skill Frontmatter Compliance

### The Problem

In v1.3.0, all 13 skills used only `name` and `description` in frontmatter — none leveraged the full set of available fields. This caused:

- **False-positive auto-loading**: Saying "batch" in conversation could auto-load `batch-integration` (an internal reference doc, not an actionable skill)
- **User confusion**: All 13 skills appeared as user-invocable, even though only 2 (`agent-browser`, `git-worktree`) are meant for direct invocation
- **No tool restrictions**: Skills could reference any tool, even when they should only use specific ones (e.g., `agent-browser` should only use Bash)
- **Fragile paths**: `git-worktree` used 16 occurrences of `${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/` instead of the portable `${CLAUDE_SKILL_DIR}/scripts/`

### The Solution

Every skill now declares its full metadata:

#### `user-invocable: false` (11 skills)

These reference-only skills are consumed by agents and commands — users invoke the corresponding `/bp:*` commands instead:

| Skill | Consumed By | User Invokes Instead |
|-------|-------------|---------------------|
| ab-testing | design-variant-generator, ab-test-engineer | `/bp:design`, `/bp:ab-decide` |
| architecture-review | swarm-coordinator, architecture agents | `/bp:architect` |
| batch-integration | batch command internals | `/bp:batch` |
| claude-md-learning | claude-md-advisor agent | `/bp:discover` |
| compound-knowledge | 5-agent compound swarm | `/bp:compound` |
| lightweight-planning | go command triage logic | `/bp:go` |
| planning-methodology | requirements-analyst, research-scout | `/bp:plan` |
| simplify-integration | build/go command internals | `/simplify` |
| stack-detection | stack-detective agent | `/bp:discover` |
| swarm-orchestration | swarm-coordinator agent | `/bp:team-*`, `/bp:lfg` |
| trunk-based-dev | trunk-guard, trunk-implementor | enforced via hooks/agents |

**Remaining user-invocable:** `agent-browser`, `git-worktree` — operational skills users legitimately invoke directly.

#### `disable-model-invocation: true` (3 skills)

Prevents false-positive auto-loading when keyword matching triggers on common words:

| Skill | Prevents |
|-------|----------|
| batch-integration | Auto-loading when user says "batch" |
| simplify-integration | Auto-loading when user says "simplify" |
| eval-runner | Auto-loading when user says "eval" or "test" |

#### `allowed-tools` (2 skills)

Restricts tool usage to enforce correct patterns:

| Skill | Allowed Tools | Reason |
|-------|--------------|--------|
| agent-browser | `Bash` | Reinforces "DO NOT use Playwright MCP" rule |
| git-worktree | `Bash` | Only needs Bash for worktree-manager.sh |

#### `argument-hint` (3 skills)

Shows usage hints in skill listings:

| Skill | Hint |
|-------|------|
| agent-browser | `[url]` |
| git-worktree | `[create\|list\|cleanup] [branch-name]` |
| eval-runner | `[skill-name\|all]` |

#### `${CLAUDE_SKILL_DIR}` Migration

`git-worktree/SKILL.md` — 16 occurrences of `${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/` replaced with `${CLAUDE_SKILL_DIR}/scripts/`.

`${CLAUDE_SKILL_DIR}` resolves to the skill's own directory, making paths self-contained and portable. Commands and hooks continue using `${CLAUDE_PLUGIN_ROOT}` (they don't have a skill-dir concept).

---

## 2. Description Optimization

### Differentiated Overlapping Skills

Two planning skills had similar descriptions that could cause confusion:

**lightweight-planning** (v1.3.0): "Lightweight planning methodology for small-to-medium work..."
**lightweight-planning** (v2.0.0): "Fast-lane planning for bug fixes, UI tweaks, and features under 600 LOC. Scope triage, adaptive process, right-sized ceremony. Use for small-to-medium changes that don't need full requirements decomposition."

**planning-methodology** (v1.3.0): "Structured planning methodology for decomposing features..."
**planning-methodology** (v2.0.0): "Full planning framework for complex features needing requirements decomposition, research, and scope analysis. For tasks with 15+ files, 5+ endpoints, architecture decisions, or security concerns."

The threshold is now explicit: under 600 LOC goes to lightweight, 15+ files or 5+ endpoints goes to full planning.

### Trigger Keywords Added

Descriptions now include domain-specific terms for better matching:

| Skill | Added Keywords |
|-------|---------------|
| ab-testing | feature flags, variant comparison, statistical significance, experiment |
| architecture-review | ADR, architecture decision, system design, scalability assessment |
| claude-md-learning | CLAUDE.md improvement, project configuration, AI instructions |
| compound-knowledge | postmortem, lessons learned, debugging documentation, solved problem |
| stack-detection | technology detection, framework identification, project type analysis |
| swarm-orchestration | multi-agent coordination, parallel agents, team workflow |

### Negative Signals Added

Two skills now include explicit "not for" guidance:

- **architecture-review**: "Not for code review or implementation — for architectural decisions only"
- **compound-knowledge**: "Not for general documentation — specifically for post-debugging problem capture"

---

## 3. Dynamic Context Injection

Three skills now inject live environment data when loaded, using the `!`command`` syntax:

| Skill | Injection | Purpose |
|-------|-----------|---------|
| stack-detection | `cat .blueprint/stack-profile.json` | Agents see current stack without reading the file |
| git-worktree | `git worktree list` | Agents see existing worktrees before creating new ones |
| trunk-based-dev | `git branch --show-current` | Agents know the current branch for compliance checks |

This eliminates a common failure pattern where agents would spend a tool call reading environment state that the skill could have provided upfront.

---

## 4. Eval Framework

### The Problem

Skills in v1.3.0 had no way to verify their effectiveness. After editing a skill, you couldn't tell if you'd broken its core behavior — there were no tests, no benchmarks, no quality gates.

### The Solution

A new evaluation framework at `evals/` with:

- **Global config** (`evals/config.yaml`) — skill classification, priority ordering, execution defaults
- **Per-skill eval suites** — prompt-criteria pairs that validate expected behavior
- **Fixtures** — sample project files for stack detection tests
- **Classification system** — "Capability Uplift" vs "Encoded Preference" with different rigor levels

### Directory Structure

```
evals/
  config.yaml                          # Global eval config
  agent-browser/
    eval.yaml                          # 3 test prompts
    prompts/
      navigate-and-click.md
      fill-form.md
      anti-playwright.md               # Verify NO Playwright MCP usage
  git-worktree/
    eval.yaml                          # 2 test prompts
    prompts/
      create-worktree.md
      anti-raw-git.md                  # Verify uses manager script
  lightweight-planning/
    eval.yaml                          # 3 test prompts
    prompts/
      small-bug-triage.md
      medium-feature-triage.md
      escalation-trigger.md
  stack-detection/
    eval.yaml                          # 2 test prompts + fixtures
    prompts/
      detect-nextjs.md
      detect-fastapi.md
    fixtures/
      sample-package.json              # Next.js + Prisma + TypeScript
      sample-requirements.txt          # FastAPI + SQLAlchemy + Pydantic
  trunk-based-dev/
    eval.yaml                          # 2 test prompts
    prompts/
      branch-compliance.md
      pr-split-suggestion.md
```

### Skill Classification

| Classification | Description | Eval Rigor | Skills |
|---------------|-------------|------------|--------|
| Capability Uplift | Teaches techniques Claude doesn't know natively | Strict — correct tool/pattern usage required | agent-browser, git-worktree, stack-detection |
| Encoded Preference | Encodes team/project preferences | Standard — classification accuracy focus | lightweight-planning, trunk-based-dev, planning-methodology, compound-knowledge, ab-testing, architecture-review, swarm-orchestration, batch-integration, simplify-integration, claude-md-learning |

### Eval Priority

| Priority | Skills | Reason |
|----------|--------|--------|
| HIGH | agent-browser, git-worktree, stack-detection, lightweight-planning | Core capabilities and critical triage accuracy |
| MEDIUM | trunk-based-dev, planning-methodology, compound-knowledge | Rule compliance and structure quality |
| LOW | ab-testing, architecture-review, swarm-orchestration, batch-integration, simplify-integration, claude-md-learning | Consumed by commands, lower direct impact |

### Example: Anti-Playwright Eval

The `agent-browser` skill teaches Claude to use Vercel's `agent-browser` CLI instead of Playwright MCP tools. The eval verifies this:

```yaml
name: anti-playwright
prompt: "Navigate to https://example.com and click the first link"
criteria:
  - contains: "agent-browser"           # Must use the CLI
  - not_contains: "mcp__plugin_playwright"  # Must NOT use Playwright
  - not_contains: "browser_navigate"     # Must NOT use Playwright navigate
  - contains: "snapshot"                 # Must use snapshot-based selection
```

---

## 5. New Skills (2)

### `eval-runner`

Internal skill for running evaluation suites against blueprint-dev skills.

| Field | Value |
|-------|-------|
| `disable-model-invocation` | `true` |
| `argument-hint` | `[skill-name\|all]` |

Covers: reading eval definitions from `evals/`, spawning parallel test agents, collecting results, producing benchmark reports.

### `pr-workflow`

Unified reference connecting the full pull request lifecycle — branch creation, implementation, `/simplify`, code review, and merge following trunk-based-dev rules.

| Field | Value |
|-------|-------|
| `user-invocable` | `false` |

Covers: lifecycle stages (branch → implement → simplify → review → ship → merge), decision matrix by PR size, splitting guidance, rollback strategies.

---

## 6. Modified Skills (13)

All 13 existing skills received frontmatter updates. Skills with content changes beyond frontmatter:

| Skill | Changes |
|-------|---------|
| git-worktree | `allowed-tools: Bash`, `argument-hint`, `${CLAUDE_SKILL_DIR}` migration, dynamic worktree injection |
| agent-browser | `allowed-tools: Bash`, `argument-hint: "[url]"` |
| stack-detection | `user-invocable: false`, dynamic stack profile injection, trigger keywords |
| trunk-based-dev | `user-invocable: false`, dynamic branch injection |
| lightweight-planning | `user-invocable: false`, updated description with scope thresholds |
| planning-methodology | `user-invocable: false`, updated description with size thresholds |
| architecture-review | `user-invocable: false`, trigger keywords, negative signal |
| compound-knowledge | `user-invocable: false`, trigger keywords, negative signal |

---

## 7. Documentation Updates

### `GUIDE.md`

- Updated component counts (26 agents, 21 commands, **15 skills**, 5 evals)
- Added "Skill Eval Framework" section in Advanced Usage
- Added "PR Workflow Lifecycle" section in Advanced Usage
- Added "Skill Frontmatter and Visibility" section in Architecture Deep Dive
- Added "Dynamic Context Injection" section in Architecture Deep Dive
- Added `evals/*/eval.yaml` to Key Files table
- Added `eval-reports/` to `.blueprint/` directory structure

### `plugin.json`

- Version: `1.3.0` → `2.0.0`
- Description: Added "skill eval framework"
- Keywords: Added `evals`

---

## Files Summary

### New Files (22)

| File | Type | Purpose |
|------|------|---------|
| `skills/eval-runner/SKILL.md` | Skill | Eval suite runner |
| `skills/pr-workflow/SKILL.md` | Skill | PR lifecycle reference |
| `evals/config.yaml` | Eval Config | Global eval settings |
| `evals/agent-browser/eval.yaml` | Eval Suite | agent-browser tests |
| `evals/agent-browser/prompts/navigate-and-click.md` | Eval Prompt | Navigation test |
| `evals/agent-browser/prompts/fill-form.md` | Eval Prompt | Form interaction test |
| `evals/agent-browser/prompts/anti-playwright.md` | Eval Prompt | Anti-pattern test |
| `evals/git-worktree/eval.yaml` | Eval Suite | git-worktree tests |
| `evals/git-worktree/prompts/create-worktree.md` | Eval Prompt | Creation test |
| `evals/git-worktree/prompts/anti-raw-git.md` | Eval Prompt | Anti-pattern test |
| `evals/lightweight-planning/eval.yaml` | Eval Suite | Planning triage tests |
| `evals/lightweight-planning/prompts/small-bug-triage.md` | Eval Prompt | Small scope test |
| `evals/lightweight-planning/prompts/medium-feature-triage.md` | Eval Prompt | Medium scope test |
| `evals/lightweight-planning/prompts/escalation-trigger.md` | Eval Prompt | Escalation test |
| `evals/stack-detection/eval.yaml` | Eval Suite | Stack detection tests |
| `evals/stack-detection/prompts/detect-nextjs.md` | Eval Prompt | Next.js detection |
| `evals/stack-detection/prompts/detect-fastapi.md` | Eval Prompt | FastAPI detection |
| `evals/stack-detection/fixtures/sample-package.json` | Fixture | Next.js project |
| `evals/stack-detection/fixtures/sample-requirements.txt` | Fixture | FastAPI project |
| `evals/trunk-based-dev/eval.yaml` | Eval Suite | TBD compliance tests |
| `evals/trunk-based-dev/prompts/branch-compliance.md` | Eval Prompt | Branch naming test |
| `evals/trunk-based-dev/prompts/pr-split-suggestion.md` | Eval Prompt | PR size test |

### Modified Files (14)

| File | Type | Changes |
|------|------|---------|
| `skills/ab-testing/SKILL.md` | Skill | Frontmatter: `user-invocable: false`, description keywords |
| `skills/agent-browser/SKILL.md` | Skill | Frontmatter: `allowed-tools: Bash`, `argument-hint: "[url]"` |
| `skills/architecture-review/SKILL.md` | Skill | Frontmatter: `user-invocable: false`, description keywords + negative signal |
| `skills/batch-integration/SKILL.md` | Skill | Frontmatter: `user-invocable: false`, `disable-model-invocation: true` |
| `skills/claude-md-learning/SKILL.md` | Skill | Frontmatter: `user-invocable: false`, description keywords |
| `skills/compound-knowledge/SKILL.md` | Skill | Frontmatter: `user-invocable: false`, description keywords + negative signal |
| `skills/git-worktree/SKILL.md` | Skill | Frontmatter: `allowed-tools: Bash`, `argument-hint`, `CLAUDE_SKILL_DIR` migration, dynamic injection |
| `skills/lightweight-planning/SKILL.md` | Skill | Frontmatter: `user-invocable: false`, new description |
| `skills/planning-methodology/SKILL.md` | Skill | Frontmatter: `user-invocable: false`, new description |
| `skills/simplify-integration/SKILL.md` | Skill | Frontmatter: `user-invocable: false`, `disable-model-invocation: true` |
| `skills/stack-detection/SKILL.md` | Skill | Frontmatter: `user-invocable: false`, description keywords, dynamic injection |
| `skills/swarm-orchestration/SKILL.md` | Skill | Frontmatter: `user-invocable: false`, description keywords |
| `skills/trunk-based-dev/SKILL.md` | Skill | Frontmatter: `user-invocable: false`, dynamic injection |
| `.claude-plugin/plugin.json` | Metadata | Version 2.0.0, description, keywords |

---

## Migration Guide

No breaking changes. v2.0.0 is fully backward-compatible with v1.3.0 workflows.

### For Existing Users

- All existing commands and agents work exactly as before
- Skills that were previously user-invocable but shouldn't have been are now hidden — use the corresponding `/bp:*` commands instead
- No configuration changes needed

### What's Different

- Only `agent-browser` and `git-worktree` appear in skill listings (the rest are reference-only)
- Saying "batch" or "simplify" in conversation no longer auto-loads integration docs
- `git-worktree` paths use `${CLAUDE_SKILL_DIR}` (transparent — no user action needed)
- Three skills now show live environment data when loaded (stack profile, worktree list, current branch)

### Verification

```bash
# Verify frontmatter compliance
grep -l 'user-invocable\|disable-model-invocation\|allowed-tools' skills/*/SKILL.md

# Verify CLAUDE_PLUGIN_ROOT removed from skill files
grep -r 'CLAUDE_PLUGIN_ROOT' skills/  # Should return nothing

# Verify eval structure
find evals/ -type f | wc -l  # Should be 20 files
```
