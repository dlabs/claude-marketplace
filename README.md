# d.labs Claude Marketplace

A collection of Claude Code plugins by [d.labs](https://dlabs.si).

## Available Plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| [blueprint-dev](./blueprint-dev) | Planning-first, design-driven development workflow with A/B design variants, architecture robustness checks, trunk-based development enforcement, agent team swarms, compound knowledge accumulation, browser testing, git worktree management, lightweight fast-lane workflows, code simplification, parallel batch operations, and skill eval framework. | 2.0.0 |
| [design-studio](./design-studio) | Code-first design exploration workflow. Product planning, section screen design, brand discovery, variant generation, iterative refinement, token extraction, and production Next.js components using your project's component libraries (shadcn/ui, Radix UI). | 0.5.0 |
| [scenario-testing](./scenario-testing) | Probabilistic scenario validation for agentic software. LLM-judged user-story scenarios, satisfaction scoring across observed trajectories, and a Digital Twin Universe for behavioral clones of third-party services. | 0.1.0 |

## Installation

**Step 1:** Add the marketplace:

```bash
claude plugin marketplace add https://github.com/dlabs/claude-marketplace
```

**Step 2:** Install a plugin:

```bash
claude plugin install blueprint-dev
claude plugin install design-studio
claude plugin install scenario-testing
```

This installs with `user` scope by default (available across all projects). To install for a single project only:

```bash
claude plugin install blueprint-dev --scope project
```

**Step 3:** Restart Claude Code for the plugin to take effect.

---

## blueprint-dev

Planning-first, design-driven development workflow for Claude Code.

- **26 specialized agents** — from architecture review to compound knowledge extraction
- **21 slash commands** — full pipeline from `/discover` to `/compound`, plus lightweight fast-lane, batch operations, browser testing, and video walkthroughs
- **15 skills** — reference knowledge for planning, A/B testing, trunk-based dev, browser automation, git worktrees, eval framework, and more
- **5 eval suites** — skill quality benchmarking with prompt-criteria tests
- **1 hook** — automatic stack detection on session start

```bash
/blueprint-dev:bp:discover              # Detect your stack
/blueprint-dev:bp:plan "feature"        # Plan a feature
/blueprint-dev:bp:lfg "feature"         # Full pipeline
/blueprint-dev:bp:go "small task"       # Fast lane for small work
/blueprint-dev:bp:batch "change"        # Parallel codebase-wide changes
/blueprint-dev:bp:test-browser          # Browser tests on affected pages
```

See the full [Blueprint-Dev Guide](./blueprint-dev/GUIDE.md) for detailed usage.

---

## design-studio

Code-first design exploration — from product definition to production components.

- **10 specialized agents** — product planner, brand builder, screen designer, variant generator, and more
- **12 slash commands** — product planning, brand building, screen design, variant picking, token extraction, and Next.js conversion
- **2 skills** — design system patterns and product planning methodology

```bash
/design-studio:product                  # Define your product
/design-studio:design-brand             # Build a Minimum Viable Brand
/design-studio:design "description"     # Generate HTML design variants
/design-studio:design-pick              # Pick a variant and extract tokens
/design-studio:design-ship              # Convert to Next.js components
```

---

## scenario-testing

Probabilistic validation for agentic software — where traditional tests fall short.

- **6 specialized agents** — scenario writers, satisfaction scorers, digital twin builders, and holdout validators
- **10 slash commands** — scenario authoring, execution, satisfaction analysis, and twin management
- **3 skills** — scenario patterns, satisfaction scoring, and digital twin methodology

```bash
/scenario-testing:author "user story"   # Write a scenario from a user story
/scenario-testing:run                   # Execute scenarios against your system
/scenario-testing:score                 # Score satisfaction across trajectories
/scenario-testing:twin "service"        # Create a behavioral clone of a service
```

---

## License

MIT
