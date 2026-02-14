# Design Studio: The Complete Guide

A code-first design exploration workflow for Claude Code.

---

## Table of Contents

1. [Introduction](#introduction)
2. [Installation & Setup](#installation--setup)
3. [Brand Discovery](#brand-discovery)
4. [The Three Phases](#the-three-phases)
5. [Commands Reference](#commands-reference)
6. [Token Management](#token-management)
7. [Workspace Structure](#workspace-structure)
8. [Tips & Patterns](#tips--patterns)

---

## Introduction

Design Studio is a Claude Code plugin that provides a code-first design exploration workflow. Optionally build a brand identity through interactive discovery, then describe what you want, get 3-4 standalone HTML variants to compare in a browser, pick one, extract design tokens, and ship it as production Next.js code.

### What It Does

- **Builds brand identity** (optional) through interactive Q&A, URL analysis, and image analysis
- **Generates HTML variants** from text descriptions — each a self-contained file that opens in any browser
- **Extracts design tokens** from your chosen variant into a structured `tokens.json`
- **Converts to Next.js** production components that follow your project's conventions
- **Persists design language** across sessions through locked tokens

### What It Contains

| Component | Count | Description |
|-----------|-------|-------------|
| Agents | 5 | Brand builder, brand showcase generator, variant generator, token extractor, Next.js converter |
| Commands | 6 | Brand, design, pick, ship, init, status |
| Skills | 1 | Design system workflow with 6 reference files |
| Hooks | 1 | Workspace status check on session start |
| Scripts | 3 | Workspace init, session management, brand management |

### Who It's For

- Solo developers building Next.js apps who want to explore visual directions quickly
- Developers without a dedicated designer who want to see options before committing
- Anyone who wants design tokens extracted from visual exploration, not configured manually

---

## Installation & Setup

### Install the Plugin

```bash
# From the marketplace directory
claude plugin add ./design-studio
```

### First Session

When you start a Claude Code session with design-studio installed, you'll see:

```
[design-studio] No workspace found. Run /design-studio:ds:design-init to set up.
```

### Quick Start

```bash
# 1. Set up the workspace
/design-studio:ds:design-init

# 2. Generate variants
/design-studio:ds:design "pricing page with 3 tiers, dark theme"

# 3. Open the HTML files in your browser and compare

# 4. Pick the one you like
/design-studio:ds:design-pick b

# 5. Ship to Next.js
/design-studio:ds:design-ship
```

---

## Brand Discovery

### Why Brand First?

Without a brand identity, each design exploration starts from zero — variants have random visual languages, content uses generic tone, and there's no coherent thread connecting pages. Brand discovery solves this by establishing personality, voice, visual principles, and a token system before you explore.

**Brand discovery is optional.** You can skip straight to `/ds:design` if you already have a visual direction or just want to explore freely.

### The Brand Workflow

```
/design-studio:ds:brand "SaaS developer tool, clean and technical"
```

**What happens:**

1. **Interactive Q&A** (3-4 rounds, 2-3 questions each) — covers business positioning, audience, personality/voice, and visual direction
2. **Reference gathering** — paste URLs for visual pattern extraction, share images for mood analysis
3. **Synthesis** — the agent combines your answers and references into a complete brand identity
4. **Approval** — review the full brand summary before anything is written
5. **Output** — writes `brand.json`, derives `tokens.json`, generates `brand-guide.html`
6. **Showcase pages** — 2-3 HTML pages demonstrating the brand in real contexts (landing, pricing, features, etc.)

### Brand Outputs

| File | Purpose |
|------|---------|
| `.design/brand.json` | Full brand identity — personality, voice, audience, visual system |
| `.design/tokens.json` | Design tokens derived from brand (auto-locked) |
| `.design/brand-guide.html` | Visual style guide — open in browser to review |
| `.design/brand-showcase/*.html` | Real pages showing the brand in action |

### How Brand Feeds into Design

Once a brand exists:
- `/ds:design` variants use brand tokens as visual constraints
- Content in variants matches brand voice and personality
- `variant-generator` reads brand.json for visual principles and audience context
- `/ds:design-status` shows brand information alongside token and session state

### Refining a Brand

Run `/ds:brand` again on an existing brand to refine it. You can update specific aspects without starting over.

---

## The Three Phases

### Phase 1: Explore

```
/design-studio:ds:design "pricing page with 3 tiers, toggle for monthly/annual"
```

**What happens:**
1. Creates a new session in `.design/sessions/`
2. Generates 3-4 standalone HTML files, each exploring a different design direction
3. Each file uses Tailwind CDN — opens directly in any browser
4. Variants differ in layout, interaction, hierarchy, or density (not just colors)

**Output:**
```
.design/sessions/2026-02-14-001/
├── manifest.json
├── variant-a.html   ← Card grid, minimal, lots of whitespace
├── variant-b.html   ← Comparison table, bold headers, compact
└── variant-c.html   ← Feature-first layout, accordion FAQ
```

Open each file in your browser to compare. No build step needed.

### Phase 2: Decide

```
/design-studio:ds:design-pick b
```

**What happens:**
1. Extracts CSS custom properties from the chosen variant
2. Categorizes into design tokens (colors, typography, spacing, radii, shadows)
3. Writes `tokens.json` to `.design/tokens.json` (locked)
4. Archives rejected variants to `rejected/`

**Token locking:** Future `/ds:design` runs will use these tokens as constraints. Variants will share the same visual language but differ in structure.

### Phase 3: Ship

```
/design-studio:ds:design-ship
```

**What happens:**
1. Scans your Next.js project for conventions (naming, structure, patterns)
2. Shows a dry-run plan of what files will be created
3. After your confirmation, converts the HTML variant to production components
4. Extends `tailwind.config.ts` with design tokens

**Safety:** Nothing is written until you confirm. Existing files are never overwritten.

---

## Commands Reference

| Command | Purpose | Arguments |
|---------|---------|-----------|
| `/design-studio:ds:brand` | Build brand identity | Optional seed description |
| `/design-studio:ds:design` | Generate HTML variants | Text description |
| `/design-studio:ds:design-pick` | Pick variant + extract tokens | Variant letter (a-d) |
| `/design-studio:ds:design-ship` | Convert to Next.js | Optional target path |
| `/design-studio:ds:design-init` | Set up workspace | None |
| `/design-studio:ds:design-status` | Show workspace state | None |

---

## Token Management

### How Tokens Work

Design tokens capture the visual language — colors, fonts, spacing, radii, shadows — in a structured format. They can come from two sources:

1. **Brand-derived** — automatically derived from `brand.json` during brand discovery (`source_brand: true`)
2. **Variant-extracted** — extracted from CSS custom properties in a chosen variant during `/ds:design-pick`

```json
{
  "locked": true,
  "colors": {
    "primary": "#6366f1",
    "background": "#0f172a",
    "text": "#f8fafc"
  },
  "typography": {
    "font-sans": "Inter, system-ui, sans-serif",
    "scale": { "xl": "1.25rem", "2xl": "1.5rem" }
  }
}
```

### Token Lifecycle

```
Brand path:    /ds:brand → brand.json → derive tokens → Tokens locked (source_brand)
Variant path:  /ds:design → Pick variant → Extract tokens → Tokens locked (source_variant)
Both paths:    Tokens locked → Future variants constrained → Pick again → Tokens updated
```

### Working with Locked Tokens

When tokens are locked:
- `/ds:design` variants share the same colors, fonts, spacing
- Variants differ in structure (layout, interaction, hierarchy)
- If your description conflicts with locked tokens, you'll be asked how to proceed

### Unlocking Tokens

Tell Claude conversationally: "unlock the design tokens" or "I want fresh colors for this exploration." The token-extractor will set `"locked": false`.

---

## Workspace Structure

```
.design/                           # Root workspace (in project root)
├── config.json                    # Plugin settings (gitignore mode)
├── brand.json                     # Brand identity (from /ds:brand, optional)
├── brand-guide.html               # Visual style guide (derived from brand.json)
├── brand-showcase/                # Brand showcase pages (derived from brand.json)
│   ├── manifest.json
│   ├── landing-page.html
│   ├── pricing-page.html
│   └── features-page.html
├── tokens.json                    # Design tokens (from brand or variant pick)
├── DESIGN_NOTES.md                # Auto-generated design decision log
└── sessions/
    ├── 2026-02-14-001/            # Session from first exploration
    │   ├── manifest.json          # Session metadata + variant info
    │   ├── chosen.html            # The picked variant
    │   └── rejected/              # Archived rejected variants
    │       ├── variant-a.html
    │       └── variant-c.html
    └── 2026-02-14-002/            # Session from second exploration
        ├── manifest.json
        ├── variant-a.html
        ├── variant-b.html
        └── variant-c.html
```

### Gitignore Options

Configured during `/ds:design-init`:

| Mode | Tracked | Ignored |
|------|---------|---------|
| `all` (default) | Nothing | `.design/` |
| `tokens-only` | `brand.json`, `tokens.json`, `config.json` | `sessions/`, `brand-guide.html`, `brand-showcase/`, `DESIGN_NOTES.md` |
| `none` | Everything | Nothing |

---

## Tips & Patterns

### Iterating on a Direction

Don't like any variant? Describe what you want differently:
```
/design-studio:ds:design "same pricing page but more playful, with illustrations"
```

Like variant B but want changes? Ask Claude directly:
```
"Take variant B from the last session and make the CTA bigger, add a testimonial section"
```

### Starting with a Brand

For the most cohesive results, build a brand first:
```
/design-studio:ds:brand "developer productivity tool, clean and focused"
```
Review the brand guide and showcase pages, then design specific pages:
```
/design-studio:ds:design "dashboard with activity feed and metrics"
```
Variants will use your brand tokens and personality automatically.

### Building a Design System Incrementally

1. Start with a key page: `/ds:design "homepage hero"`
2. Pick → tokens locked
3. Design more pages: `/ds:design "pricing page"` — variants use locked tokens
4. Design components: `/ds:design "settings form"` — same visual language
5. Ship each when ready: `/ds:design-ship`

### Multiple Ship Targets

Ship the same variant to different routes:
```
/design-studio:ds:design-ship src/app/pricing/page.tsx
/design-studio:ds:design-ship src/app/landing/page.tsx
```

### When No Next.js Project Exists

If `/ds:design-ship` can't find a Next.js project, it will offer to generate a standalone React component file instead.
