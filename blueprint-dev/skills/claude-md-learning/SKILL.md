---
name: claude-md-learning
description: Analyzes detected stack profiles and suggests targeted CLAUDE.md improvements. Never auto-writes to CLAUDE.md — stages suggestions for user review.
---

# CLAUDE.md Learning

This skill enables intelligent suggestions for improving a project's CLAUDE.md file based on detected technology stack and observed patterns.

## When to Use

- After `/blueprint-dev:discover` produces a stack profile
- When the `claude-md-advisor` agent needs to generate context-aware suggestions
- When compound knowledge docs reveal patterns that should be codified in CLAUDE.md

## Philosophy

CLAUDE.md is the **single most impactful file** for AI-assisted development quality. A well-crafted CLAUDE.md:
- Eliminates 80% of "AI got confused" issues
- Ensures consistent code style across AI interactions
- Documents tribal knowledge that doesn't belong in code comments
- Evolves as the project grows

## Suggestion Categories

Use the section catalog in `references/section-catalog.md` to categorize and prioritize suggestions.

## Key Principles

1. **Never auto-write** — always stage in `.blueprint/claude-md-suggestions.md`
2. **Specific over generic** — "Use pnpm, not npm" beats "Use the right package manager"
3. **Commands over descriptions** — include actual CLI commands
4. **Stack-adaptive** — only suggest what's relevant to the detected stack
5. **Incremental** — don't overwhelm with 50 suggestions; prioritize the top 5-10
6. **Respect existing** — don't suggest what's already covered
