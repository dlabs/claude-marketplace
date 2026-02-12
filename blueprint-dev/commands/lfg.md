---
name: lfg
description: End-to-end development pipeline — discover, plan, design, architect, build, review, ship, compound — with approval gates
argument-hint: Feature to develop end-to-end
---

# /blueprint-dev:lfg

Full end-to-end development pipeline. Chains all phases with user approval gates between each.

**LFG** = Let's F***ing Go. The full pipeline from idea to shipped feature.

## Usage

```
/blueprint-dev:lfg "settings page redesign"
/blueprint-dev:lfg "add user authentication"
```

## Pipeline

```
discover → plan → design → architect → build → review → ship → compound
```

### Phase 1: Discover
- Auto-run (no approval needed)
- Detects stack, produces `.blueprint/stack-profile.json`
- Shows CLAUDE.md suggestions

### Phase 2: Plan
- **Agents**: requirements-analyst → research-scout → scope-sentinel
- **Output**: Plan document with requirements, research, scope boundary
- **Gate**: "Approve plan before proceeding to design?"

### Phase 3: Design
- **Agents**: design-variant-generator → [design-critic, ab-test-engineer]
- **Output**: 2-3 production variants with flags, tracking, test plan
- **Gate**: "Approve design variants before architecture review?"
- **Skip condition**: If user says "skip design" (not all features need A/B variants)

### Phase 4: Architect
- **Agents**: [architecture-strategist, security-sentinel, performance-oracle, data-integrity-guardian]
- **Output**: ADR with security/performance/data assessments
- **Gate**: "Approve architecture before building? Any P1 findings to address first?"

### Phase 5: Build
- **Agents**: trunk-implementor, feature-flag-engineer
- **Output**: Code + tests on feature branch, feature flags configured
- **Gate**: "Implementation complete. Ready for review?"

### Phase 6: Review
- **Agents**: [code-quality-reviewer, test-coverage-analyst, trunk-guard, pattern-recognizer]
- **Output**: Unified P1/P2/P3 review report
- **Gate**: "Review complete. Fix P1 issues? Or proceed to ship?"

### Phase 7: Ship
- **Agents**: trunk-guard (final check)
- **Output**: PR created, ship manifest
- **Gate**: "PR ready. Merge when CI passes."

### Phase 8: Compound
- Auto-run (no approval needed)
- **Agents**: [context-analyzer, solution-extractor, related-docs-finder, prevention-strategist, category-classifier]
- **Output**: Knowledge document in `docs/solutions/`
- Only runs if problems were solved during the process

## Gate Behavior

At each gate, the user can:
1. **Approve** — proceed to next phase
2. **Iterate** — re-run the current phase with feedback
3. **Skip** — skip this phase (e.g., skip design for backend-only features)
4. **Stop** — halt the pipeline (all artifacts so far are preserved)

## Notes

- Each phase reads artifacts from prior phases
- Stopping preserves all work done so far — can resume with individual commands
- Estimated total time: 15-45 minutes depending on feature complexity
- Not every feature needs every phase — the user can skip design or compound
