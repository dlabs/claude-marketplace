---
name: swarm-orchestration
description: Orchestration patterns for multi-agent team workflows — team definitions, sequencing rules, result aggregation, and conflict resolution.
---

# Swarm Orchestration

This skill provides the orchestration framework for running predefined multi-agent teams. The swarm-coordinator agent uses these patterns to spawn, sequence, and aggregate agent workflows.

## When to Use

- `/blueprint-dev:bp:team-*` commands — predefined team swarms
- `/blueprint-dev:bp:lfg` — full pipeline orchestration
- When the swarm-coordinator needs to understand team composition

## Team Catalog

See `references/team-catalog.md` for predefined teams and their compositions.

## Orchestration Patterns

### Sequential
Agents run one after another, each using the previous agent's output.
```
A → B → C
```
Use when: Agent B needs Agent A's output to function.

### Parallel
All agents run simultaneously on the same input.
```
[A, B, C] → merge
```
Use when: Agents are independent and evaluate different aspects.

### Sequential-then-Parallel
One agent produces output, then multiple agents review it in parallel.
```
A → [B, C, D] → merge
```
Use when: One agent creates, multiple agents evaluate.

### Pipeline
Teams run sequentially, each team's output feeds the next.
```
team-design → team-architecture → team-review
```
Use when: Full workflow execution with approval gates between phases.

## Result Aggregation Rules

1. **Deduplicate**: If multiple agents flag the same issue, keep one with the highest priority
2. **Standardize priorities**: Ensure P1/P2/P3 meanings are consistent across agents
3. **Attribute**: Every finding shows which agent produced it
4. **Conflicts**: Flag when agents disagree for user resolution

## Approval Gates

For the full pipeline (`/blueprint-dev:bp:lfg`), insert user approval gates between phases:
- After planning: "Approve plan before designing?"
- After design: "Approve variants before architecture review?"
- After architecture: "Approve architecture before building?"
- After review: "Approve for shipping?"
