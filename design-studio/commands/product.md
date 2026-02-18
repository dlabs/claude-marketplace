---
name: ds:product
description: Define your product through interactive conversation. Produces product overview (name, description, problems, features) and roadmap (ordered section list).
argument-hint: Optional seed description (e.g., "task management app for remote teams")
---

# /design-studio:ds:product

Define your product through interactive Q&A. Produces `product-overview.md` (name, description, problems & solutions, key features) and `product-roadmap.md` (ordered list of sections to build).

## Usage

```
/design-studio:ds:product "task management app for remote teams"
/design-studio:ds:product "e-commerce platform for handmade goods"
/design-studio:ds:product   # (starts discovery from scratch)
```

## Prerequisites

- Run `/design-studio:ds:design-init` first if no `.design/` workspace exists (the command will prompt if missing)

## Workflow

### Step 1: Initialize Workspace

Check if `.design/` exists. If not, run the init script:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-workspace.sh
```

Ensure `.design/product/` directory exists:
```bash
mkdir -p .design/product
```

### Step 2: Check Existing Product

If `.design/product/product-overview.md` already exists, ask the user:

1. **Refine** — update specific aspects of the existing product definition
2. **Start fresh** — discard the existing definition and start over
3. **View** — just display the current product summary, don't change anything

If "View," read and display the existing overview + roadmap, then exit.
If "Start fresh," proceed as if no product exists.
If "Refine," pass the existing files to the agent for targeted updates.

### Step 3: Invoke Product Planner

Use the **product-planner** agent to conduct interactive product discovery.

Pass the agent:
- The user's seed description (if provided as an argument)
- Whether this is a new product or a refinement
- The existing product-overview.md and product-roadmap.md paths (if refining)

The agent will:
1. Conduct batched Q&A (2-3 questions per round, ~3-4 rounds)
2. Present a product summary for user approval
3. Write `product-overview.md` and `product-roadmap.md`

### Step 4: Present Results

Show the complete output:

```
Product definition complete!

  .design/product/product-overview.md    — Product name, description, problems & solutions, features
  .design/product/product-roadmap.md     — Roadmap with {N} sections

Roadmap:
  1. Section One
  2. Section Two
  3. ...

Next: /design-studio:ds:data-shape to model your data entities
```

### Step 5: Append to Design Notes

Add a product definition entry to `.design/DESIGN_NOTES.md`:

```markdown
## Product Definition — {date}

**Product:** {name}
**Description:** {one-line summary}
**Roadmap sections:** {count}
**Key features:** {count}
```

## Notes

- Product definition takes ~5-10 minutes of interactive Q&A
- The product-planner will ask for your approval before writing any files
- Roadmap section titles will become directory names (slugified) when creating sections with `ds:section`
- Run `ds:product` again to refine an existing product definition
- Use `/ds:design-status` to check product planning progress
- After product definition, continue with `/ds:data-shape` to model your data
