# d.labs Claude Marketplace

A collection of Claude Code plugins by [d.labs](https://dlabs.si).

## Available Plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| [blueprint-dev](./blueprint-dev) | Planning-first, design-driven development workflow with A/B design variants, architecture robustness checks, trunk-based development enforcement, agent team swarms, and compound knowledge accumulation. | 1.0.0 |

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
- **17 slash commands** — full pipeline from `/discover` to `/compound`
- **8 skills** — reference knowledge for planning, A/B testing, trunk-based dev, and more
- **3 hooks** — automatic stack detection, TBD enforcement, and knowledge capture prompts

### Quick Start

```bash
# 1. Detect your stack
/blueprint-dev:discover

# 2. Plan a feature
/blueprint-dev:plan "add user authentication"

# 3. Or run the full pipeline
/blueprint-dev:lfg "add user authentication"
```

See the full [Blueprint-Dev Guide](./blueprint-dev/GUIDE.md) for detailed usage.

## License

MIT
