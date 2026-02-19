---
name: design-system
description: Code-first design exploration workflow. Product Planning → Section Design → Brand (optional) → Explore (HTML variants) → Refine → Decide (extract tokens) → Ship (Next.js components). Covers section screen design, brand discovery, variant generation, iterative refinement, token management, and production conversion.
---

# Design System

This skill provides the complete lifecycle for code-first design exploration. Variants are standalone HTML files — not mockups or prototypes — that open directly in any browser. Tokens extracted from chosen variants persist across sessions, creating a consistent design language. An optional brand discovery phase builds a coherent visual identity before exploration begins.

## Lifecycle

```
PRODUCT PLANNING (/ds:product, /ds:data-shape, /ds:shell, /ds:section)
    → SECTION DESIGN (per section) (/ds:section design, /ds:section pick)
    → BRAND (optional) (/ds:brand)
    → EXPLORE (/ds:design)
        → refine loop (/ds:design-refine)
    → DECIDE (/ds:design-pick)
    → SHIP (/ds:design-ship)
```

### Pre. PRODUCT PLANNING (recommended)

Define what you're building before exploring how it looks. See `skills/product-planning/SKILL.md` for the full product planning lifecycle.

Commands: `/ds:product` → `/ds:data-shape` → `/ds:shell` → `/ds:section`

Outputs:
- `.design/product/product-overview.md` — Product name, description, problems, features
- `.design/product/product-roadmap.md` — Ordered section list
- `.design/product/data-shape/data-shape.md` — Data entities and relationships
- `.design/product/shell/spec.md` — App shell, navigation, layout
- `.design/product/sections/{id}/spec.md` — Feature section specs

### 0a. SECTION DESIGN (per section)

After product planning defines section specs, design each section's screens. This bridges specs (what to build) with visual design (how it looks).

`/design-studio:ds:section design "Section" "screen"` uses the **screen-designer** agent to create 3 HTML screen variants:
- Each variant includes app shell chrome (sidebar, top bar) from the shell spec
- Content is driven by the section spec's user flows and UI requirements
- Variants differ in layout, interaction pattern, or information hierarchy
- CSS custom properties enable consistent design language across screens

`/design-studio:ds:section pick "Section" "screen" <letter>` selects a variant:
- Copies chosen variant to `screen-designs/{screen-name}.html`
- Archives rejected variants to `.drafts/{screen-name}/rejected/`

Section design outputs:
- `.design/product/sections/{id}/screen-designs/{screen}.html` — picked screen designs
- `.design/product/sections/{id}/screen-designs/.drafts/{screen}/` — variant drafts with manifest

See `references/screen-design-spec.md` for the screen design HTML boilerplate, manifest schema, and quality rules.

### 0b. BRAND (optional)

`/design-studio:ds:brand` uses the **brand-builder** agent to create a Minimum Viable Brand through interactive Q&A:
- Batched questions (2-3 per round) about business, audience, personality, and visual direction
- Reference gathering — analyze URLs (WebFetch) and images (multimodal) for visual patterns
- Synthesis into `brand.json` — full identity including personality, voice, visual principles, and visual tokens
- Derives `tokens.json` from brand (locked with `source_brand: true`)
- Generates `brand-guide.html` — standalone style reference using the brand's own tokens

After brand discovery, the **brand-showcase-generator** agent creates 2-3 HTML showcase pages demonstrating the brand in real page contexts (landing page, pricing, features, etc.).

Brand outputs:
- `.design/brand.json` — full brand identity (source of truth)
- `.design/tokens.json` — derived visual tokens (auto-locked)
- `.design/brand-guide.html` — visual style guide
- `.design/brand-showcase/` — showcase pages with manifest

### 1. EXPLORE

`/design-studio:ds:design` uses the **variant-generator** agent to create 3-4 standalone HTML files. Each variant:
- Is a self-contained `.html` file with Tailwind CDN — no build step
- Differs in layout, weight, hierarchy, or interaction pattern
- Uses CSS custom properties for all design values (enables token extraction)
- Respects locked tokens from previous sessions as constraints

### 1b. REFINE (optional, repeatable)

After picking a variant, iterate on it with feedback. `/design-studio:ds:design-refine "feedback"` uses the **variant-generator** agent in refinement mode:
- Reads the picked `chosen.html` as the base design
- Creates a new session with 3-4 variants that interpret the feedback differently
- Preserves elements not mentioned in the feedback
- Each refinement creates a parent→child chain tracked in manifests

Refinement loop:
```
EXPLORE (/ds:design) → pick → REFINE (/ds:design-refine) → pick → REFINE → ... → DECIDE
```

The refinement manifest includes `parent_session`, `parent_variant`, and `refinement_prompt` fields for chain tracking.

### 2. DECIDE

`/design-studio:ds:design-pick` uses the **token-extractor** agent to:
- Parse the chosen variant's `:root {}` CSS custom properties
- Categorize tokens into colors, spacing, typography, radii, shadows
- Write `tokens.json` to `.design/tokens.json`
- Archive rejected variants and keep `chosen.html`

### 3. SHIP

`/design-studio:ds:design-ship` uses the **nextjs-converter** agent to:
- Read `chosen.html` + `tokens.json`
- Scan project conventions (App Router, component patterns, naming)
- Detect installed component libraries (shadcn/ui, Radix UI) and utilities (`cn()`, cva)
- Convert to production Next.js components using detected libraries (e.g., `<Button>`, `<Card>`, `<Tabs>` from shadcn/ui) with proper TypeScript types
- Extend `tailwind.config.ts` with design tokens if needed

## Key Principles

- **Standalone HTML**: Variants must open in any browser with zero setup. Tailwind CDN, inline JS, no external deps beyond CDN links.
- **CSS custom properties as the source of truth**: Every color, spacing value, font, radius, and shadow must be a CSS custom property in `:root {}`. This is what makes token extraction work.
- **Meaningful differentiation**: Variants must differ in layout, interaction, hierarchy, or density — not just color swaps or font changes.
- **Token persistence**: Once tokens are locked via `/ds:design-pick`, future `/ds:design` runs use them as constraints. Variants share the visual language but explore different structures.
- **Convention-following**: Ship phase reads the existing project and matches its patterns — including component libraries like shadcn/ui — never invents new conventions.

## Workspace Structure

```
.design/
├── config.json              # Plugin configuration (gitignore mode, etc.)
├── tokens.json              # Design tokens (from brand or variant pick)
├── DESIGN_NOTES.md          # Auto-generated design decision log
├── product/                 # Product planning (from /ds:product, /ds:data-shape, etc.)
│   ├── product-overview.md  # Product name, description, problems, features
│   ├── product-roadmap.md   # Ordered section list
│   ├── data-shape/
│   │   └── data-shape.md    # Data entities and relationships
│   ├── shell/
│   │   └── spec.md          # App shell, navigation, layout
│   └── sections/
│       ├── user-auth/
│       │   ├── spec.md      # Section spec
│       │   ├── data.json    # Optional sample data
│       │   └── screen-designs/
│       │       ├── login.html       # Picked screen design
│       │       ├── signup.html      # Picked screen design
│       │       └── .drafts/
│       │           ├── login/
│       │           │   ├── manifest.json
│       │           │   ├── chosen.html
│       │           │   └── rejected/
│       │           └── signup/
│       │               ├── manifest.json
│       │               ├── variant-a.html
│       │               ├── variant-b.html
│       │               └── variant-c.html
│       └── dashboard/
│           └── spec.md
├── brand.json               # Full brand identity (optional, from /ds:brand)
├── brand-guide.html         # Visual brand style guide (derived from brand.json)
├── brand-showcase/          # Brand showcase pages (derived from brand.json)
│   ├── manifest.json
│   ├── landing-page.html
│   ├── pricing-page.html
│   └── features-page.html
└── sessions/
    ├── 2026-02-14-001/
    │   ├── manifest.json
    │   ├── variant-a.html
    │   ├── variant-b.html
    │   ├── variant-c.html
    │   ├── chosen.html       # (after pick)
    │   └── rejected/         # (after pick)
    │       ├── variant-a.html
    │       └── variant-c.html
    └── 2026-02-14-002/
        └── ...
```

## References

### Design System References
- `references/brand-schema.md` — brand.json schema, field definitions, token derivation mapping
- `references/brand-questionnaire.md` — Q&A question bank, batching rules, branching logic
- `references/brand-guide-spec.md` — Brand guide HTML template, showcase page template, quality rules
- `references/variant-spec.md` — HTML boilerplate, CSS naming convention, quality rules, manifest schema (includes refinement fields)
- `references/screen-design-spec.md` — Screen design HTML boilerplate with app shell chrome, manifest schema, quality rules
- `references/token-schema.md` — tokens.json schema, category definitions, merge strategy
- `references/nextjs-patterns.md` — Component splitting, Tailwind config, conversion patterns

### Product Planning References (in `skills/product-planning/`)
- `references/product-overview-schema.md` — product-overview.md format and parser behavior
- `references/product-roadmap-schema.md` — product-roadmap.md format and slugification rules
- `references/data-shape-schema.md` — data-shape.md entity/relationship format
- `references/shell-spec-schema.md` — shell spec.md navigation and layout format
- `references/section-spec-schema.md` — section spec.md format and directory structure
