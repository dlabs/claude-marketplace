# d.labs Claude Marketplace

A collection of Claude Code plugins by [d.labs](https://dlabs.si).

## Available Plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| [blueprint-dev](./blueprint-dev) | Planning-first, design-driven development workflow with A/B design variants, architecture robustness checks, trunk-based development enforcement, agent team swarms, compound knowledge accumulation, browser testing, feature video walkthroughs, and git worktree management. | 1.2.0 |

## Installation

**Step 1:** Add the marketplace:

```bash
claude plugin marketplace add https://github.com/dlabs/claude-marketplace
```

**Step 2:** Install the plugin:

```bash
claude plugin install blueprint-dev
```

This installs with `user` scope by default (available across all projects). To install for a single project only:

```bash
claude plugin install blueprint-dev --scope project
```

**Step 3:** Restart Claude Code for the plugin to take effect.

## What's Inside blueprint-dev

- **25 specialized agents** — from architecture review to compound knowledge extraction
- **19 slash commands** — full pipeline from `/discover` to `/compound`, plus browser testing and video walkthroughs
- **10 skills** — reference knowledge for planning, A/B testing, trunk-based dev, browser automation, git worktrees, and more
- **1 hook** — automatic stack detection on session start

### Quick Start

```bash
# 1. Detect your stack
/blueprint-dev:bp:discover

# 2. Plan a feature
/blueprint-dev:bp:plan "add user authentication"

# 3. Or run the full pipeline
/blueprint-dev:bp:lfg "add user authentication"

# 4. Run browser tests on affected pages
/blueprint-dev:bp:test-browser
```

See the full [Blueprint-Dev Guide](./blueprint-dev/GUIDE.md) for detailed usage.

## License

MIT
