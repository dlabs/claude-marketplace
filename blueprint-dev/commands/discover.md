---
name: bp:discover
description: Detect project stack, profile technologies, and suggest CLAUDE.md improvements
---

# /blueprint-dev:bp:discover

Deep-analyze the current project to detect its technology stack, conventions, and architecture. Produces a stack profile and suggests CLAUDE.md improvements.

## Workflow

### Step 1: Stack Detection
Use the **stack-detective** agent to analyze the project. The agent will:
- Read all package manifests and config files
- Analyze directory structure and code patterns
- Detect frameworks, tools, testing, CI/CD, feature flags
- Write results to `.blueprint/stack-profile.json`

Create the `.blueprint/` directory first if it doesn't exist:
```
mkdir -p .blueprint
```

### Step 2: CLAUDE.md Suggestions
Use the **claude-md-advisor** agent to:
- Read the stack profile from Step 1
- Compare against existing CLAUDE.md (if any)
- Generate targeted suggestions in `.blueprint/claude-md-suggestions.md`

### Step 3: Present Results
Show the user:
1. **Stack Summary** — detected technologies in a clean table
2. **Key Findings** — anything notable (version mismatches, missing configs, unusual patterns)
3. **CLAUDE.md Suggestions** — top 5-10 prioritized suggestions with copy-pasteable content

### Step 4: Offer Next Steps
- "Review and apply CLAUDE.md suggestions"
- "Run `/blueprint-dev:bp:plan` to start planning a feature"
- "Run `/blueprint-dev:bp:architect` to review architecture"

## Example Output

```
Stack Profile: .blueprint/stack-profile.json

| Category      | Detected                        |
|---------------|---------------------------------|
| Language      | TypeScript                      |
| Framework     | Next.js 14 (App Router)         |
| Styling       | Tailwind CSS v3                 |
| State         | Zustand + TanStack Query        |
| Database      | PostgreSQL + Prisma             |
| Testing       | Vitest + Playwright             |
| CI/CD         | GitHub Actions                  |
| Deployment    | Vercel                          |
| Feature Flags | PostHog                         |

5 CLAUDE.md suggestions generated → .blueprint/claude-md-suggestions.md
```

## Notes
- This command is idempotent — safe to run multiple times
- Stack profile is read by all other blueprint-dev agents
- CLAUDE.md suggestions are **never** auto-applied — user must review and approve
