# d.labs Claude Marketplace

A collection of Claude Code plugins by [d.labs](https://dlabs.si).

## Available Plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| [blueprint-dev](./blueprint-dev) | Planning-first, design-driven development workflow with A/B design variants, architecture robustness checks, trunk-based development enforcement, agent team swarms, compound knowledge accumulation, browser testing, feature video walkthroughs, and git worktree management. | 1.2.0 |

## Installation

Install a plugin directly from GitHub:

```bash
claude plugin add https://github.com/dlabs/claude-marketplace/tree/main/blueprint-dev
```

Or clone and install locally:

```bash
git clone https://github.com/dlabs/claude-marketplace.git
claude plugin add ./claude-marketplace/blueprint-dev
```

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
