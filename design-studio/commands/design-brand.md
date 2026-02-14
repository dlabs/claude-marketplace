---
name: ds:brand
description: Build a Minimum Viable Brand through interactive discovery. Produces brand identity, design tokens, and a visual brand guide.
argument-hint: Optional seed description (e.g., "SaaS for developers, clean and technical")
---

# /design-studio:ds:brand

Build a brand identity through interactive Q&A, reference analysis, and synthesis. Produces `brand.json` (full identity), `tokens.json` (visual subset), `brand-guide.html` (style reference), and showcase pages (brand in action).

## Usage

```
/design-studio:ds:brand "SaaS developer tool, clean and technical"
/design-studio:ds:brand "e-commerce for handmade ceramics"
/design-studio:ds:brand   # (starts discovery from scratch)
```

## Prerequisites

- Run `/design-studio:ds:design-init` first if no `.design/` workspace exists (the command will prompt if missing)

## Workflow

### Step 1: Initialize Workspace

Check if `.design/` exists. If not, run the init script:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-workspace.sh
```

### Step 2: Check Existing Brand

If `.design/brand.json` already exists, ask the user:

1. **Refine** — update specific aspects of the existing brand
2. **Start fresh** — discard the existing brand and start over
3. **View guide** — just open the brand guide, don't change anything

If "View guide," show the file path to `brand-guide.html` and exit.
If "Start fresh," proceed as if no brand exists.
If "Refine," pass the existing brand to the agent for targeted updates.

### Step 3: Invoke Brand Builder

Use the **brand-builder** agent to conduct interactive brand discovery.

Pass the agent:
- The user's seed description (if provided as an argument)
- Whether this is a new brand or a refinement
- The existing brand.json path (if refining)

The agent will:
1. Conduct batched Q&A (2-3 questions per round, ~3-4 rounds)
2. Gather reference material (URLs via WebFetch, images via Read)
3. Present a brand summary for user approval
4. Write brand.json, derive tokens.json, generate brand-guide.html

### Step 4: Generate Showcase Pages

After the brand-builder completes, invoke the **brand-showcase-generator** agent to create 2-3 showcase pages.

Pass the agent:
- The brand.json path

The agent will:
1. Read brand.json for identity, personality, and visual tokens
2. Select 2-3 page types appropriate to the industry
3. Generate self-contained HTML pages in `.design/brand-showcase/`
4. Write a manifest.json listing the pages

### Step 5: Present Results

Show the complete output:

```
Brand identity complete!

  .design/brand.json               — Full brand identity
  .design/tokens.json              — Design tokens (locked, derived from brand)
  .design/brand-guide.html         — Visual style guide

Showcase pages:
  .design/brand-showcase/landing-page.html     — Hero, features, social proof
  .design/brand-showcase/pricing-page.html     — Three-tier pricing, FAQ
  .design/brand-showcase/features-page.html    — Feature grid, integrations

Open brand-guide.html and the showcase pages in your browser.
Then /ds:design to create specific pages with this brand identity.
```

## Brand Outputs

| File | Purpose | Derived? |
|------|---------|----------|
| `brand.json` | Full brand identity (personality, voice, visual, audience) | No — source of truth |
| `tokens.json` | Visual design tokens for variant generation | Yes — from brand.json |
| `brand-guide.html` | Standalone visual style reference | Yes — from brand.json |
| `brand-showcase/*.html` | Real pages demonstrating the brand | Yes — from brand.json |

## Gitignore Behavior

In `tokens-only` gitignore mode:
- `brand.json` and `tokens.json` are tracked (brand identity persists)
- `brand-guide.html` and `brand-showcase/` are ignored (they're derived and regenerable)

In `all` mode:
- Everything in `.design/` is ignored

## Notes

- Brand discovery takes ~5-10 minutes of interactive Q&A
- You can paste URLs and images at any point during the conversation
- The brand-builder will ask for your approval before writing any files
- Tokens derived from brand are locked with `source_brand: true`
- Future `/ds:design` runs will use brand tokens and personality for variant generation
- Run `/ds:brand` again to refine an existing brand
- Use `/ds:design-status` to check brand state
