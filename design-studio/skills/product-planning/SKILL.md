---
name: product-planning
description: Guided product planning workflow. Define your product (overview + roadmap), model data entities, specify the app shell, and create feature sections — all through interactive conversation that produces viewer-compatible structured markdown.
---

# Product Planning

This skill provides the complete lifecycle for defining a product before design exploration begins. Through interactive conversation, agents help users define what they're building, model the data, plan the navigation, and spec out each feature section. All output is structured markdown that the design-studio-app viewer reads and displays.

## Lifecycle

```
PRODUCT (/ds:product) → DATA SHAPE (/ds:data-shape) → SHELL (/ds:shell) → SECTIONS (/ds:section)
```

Product planning feeds into the existing design system workflow:

```
PRODUCT PLANNING → BRAND (optional) → EXPLORE → DECIDE → SHIP
```

### 1. PRODUCT

`/design-studio:ds:product` uses the **product-planner** agent to define:
- Product name, description, and value proposition
- Problems the product solves with solutions
- Key features list
- Ordered roadmap of sections to build

Outputs:
- `.design/product/product-overview.md`
- `.design/product/product-roadmap.md`

### 2. DATA SHAPE

`/design-studio:ds:data-shape` uses the **data-shape-planner** agent to define:
- Data entities with descriptions (PascalCase names)
- Relationships between entities with cardinality

Output:
- `.design/product/data-shape/data-shape.md`

### 3. SHELL

`/design-studio:ds:shell` uses the **shell-planner** agent to define:
- App shell overview and design approach
- Navigation items (mapped from roadmap sections)
- Layout pattern with responsive behavior

Output:
- `.design/product/shell/spec.md`

### 4. SECTIONS

`/design-studio:ds:section` uses the **section-planner** agent to define individual feature sections:
- Section spec with title, overview, user flows, and UI requirements
- Each section maps to a roadmap entry

Output per section:
- `.design/product/sections/{id}/spec.md`

## Phase Gates

The viewer tracks progress across 5 phases:

| Phase | Requirement | Command |
|-------|------------|---------|
| Product | `product-overview.md` + `product-roadmap.md` exist | `ds:product` |
| Data Shape | `data-shape/data-shape.md` exists | `ds:data-shape` |
| Design System | `tokens.json` exists | `ds:brand` or `ds:design-pick` |
| Shell | `shell/spec.md` exists | `ds:shell` |
| Sections | At least one section directory under `sections/` | `ds:section` |

Use `/design-studio:ds:design-status` to see current phase progress.

## Workspace Structure

```
.design/
  product/
    product-overview.md       # Product name, description, problems, features
    product-roadmap.md        # Ordered section list
    data-shape/
      data-shape.md           # Entities + relationships
    shell/
      spec.md                 # App shell, navigation, layout
    sections/
      {section-id}/
        spec.md               # Section spec (title, overview, flows, requirements)
        data.json             # Optional sample data
        screen-designs/       # Optional screen design HTML files
          {name}.html
```

## References

- `references/product-overview-schema.md` — product-overview.md format, parser behavior, field rules
- `references/product-roadmap-schema.md` — product-roadmap.md format, slugification rules, size guidelines
- `references/data-shape-schema.md` — data-shape.md format, entity/relationship patterns
- `references/shell-spec-schema.md` — shell spec.md format, navigation and layout guidelines
- `references/section-spec-schema.md` — section spec.md format, directory structure, matching roadmap entries

## Key Principles

- **Parser compatibility**: All output must round-trip through the viewer's parsers. Agents read the reference files for exact format specs.
- **Slugification consistency**: Section IDs are slugified from titles (lowercase, non-alphanumeric → hyphen, trim hyphens). Must match between roadmap and section directories.
- **Interactive discovery**: Agents conduct batched Q&A (2-3 questions per round) rather than dumping a questionnaire.
- **Context building**: Each phase reads output from prior phases — data shape references the product, shell references the roadmap, sections reference everything.
- **Safe re-runs**: Commands check for existing files and offer to refine rather than overwrite.
