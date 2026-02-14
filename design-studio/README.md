# design-studio

Code-first design exploration for Claude Code. Build a brand identity through interactive discovery, generate standalone HTML variants from text descriptions, compare in browser, extract tokens, ship as Next.js.

## Quick Start

```bash
claude plugin add ./design-studio

/design-studio:ds:design-init
/design-studio:ds:brand "SaaS developer tool, clean and technical"
# Answer Q&A, review brand guide + showcase pages
/design-studio:ds:design "pricing page with 3 tiers"
# Open HTML files in browser, compare
/design-studio:ds:design-pick b
/design-studio:ds:design-ship
```

## How It Works

**Brand** (optional) — Build a brand identity through interactive Q&A. Get a style guide and showcase pages that prove the brand works in practice.

**Explore** — Describe what you want. Get 3-4 standalone HTML files that open in any browser. Each explores a different layout, interaction, or hierarchy. Brand tokens and personality guide the output.

**Decide** — Pick the variant you like. Design tokens (colors, fonts, spacing) are extracted and locked for consistency across future explorations.

**Ship** — Convert to production Next.js components that follow your project's conventions. Dry-run first, write after confirmation.

## Commands

| Command | Purpose |
|---------|---------|
| `ds:brand` | Build brand identity through interactive discovery |
| `ds:design` | Generate HTML variants from a description |
| `ds:design-pick` | Pick a variant and extract design tokens |
| `ds:design-ship` | Convert chosen variant to Next.js |
| `ds:design-init` | Set up workspace and gitignore |
| `ds:design-status` | Show workspace state |

## What's Inside

| Component | Count |
|-----------|-------|
| Agents | 5 (brand-builder, brand-showcase-generator, variant-generator, token-extractor, nextjs-converter) |
| Commands | 6 |
| Skills | 1 (design-system with 6 references) |
| Hooks | 1 (SessionStart workspace check) |
| Scripts | 3 (init-workspace, manage-session, manage-brand) |

## Key Features

- **Brand discovery** — build a coherent brand identity through interactive Q&A before designing
- **Zero build step** — HTML variants use Tailwind CDN, open in any browser
- **Token persistence** — picked tokens constrain future variants for design consistency
- **Convention-aware shipping** — converter reads your project and matches existing patterns
- **Safe by default** — dry-run before writing, never overwrites existing files

See [GUIDE.md](GUIDE.md) for the complete user guide.
