---
name: ds:data-shape
description: Model your data entities and relationships through interactive conversation. Produces data-shape.md with entities and relationship descriptions.
argument-hint: Optional seed (e.g., "users, projects, tasks with assignments")
---

# /design-studio:ds:data-shape

Define the data model for your product through interactive Q&A. Produces `data-shape/data-shape.md` with entity definitions and their relationships.

## Usage

```
/design-studio:ds:data-shape "users, projects, tasks with assignments"
/design-studio:ds:data-shape "products, orders, customers, reviews"
/design-studio:ds:data-shape   # (starts modeling from product context)
```

## Prerequisites

- Run `/design-studio:ds:product` first — the data shape is derived from the product's features and roadmap
- If `product-overview.md` and `product-roadmap.md` don't exist, inform the user and suggest running `ds:product` first

## Workflow

### Step 1: Check Prerequisites

Verify `.design/product/product-overview.md` and `.design/product/product-roadmap.md` exist. If not:
```
Product definition not found.
Run /design-studio:ds:product first to define your product overview and roadmap.
```

Ensure the data-shape directory exists:
```bash
mkdir -p .design/product/data-shape
```

### Step 2: Check Existing Data Shape

If `.design/product/data-shape/data-shape.md` already exists, ask the user:

1. **Refine** — update specific entities or relationships
2. **Start fresh** — discard the existing data shape and start over
3. **View** — display the current data model, don't change anything

### Step 3: Invoke Data Shape Planner

Use the **data-shape-planner** agent to conduct interactive entity/relationship modeling.

Pass the agent:
- The user's seed description (if provided as an argument)
- Whether this is a new data shape or a refinement
- The existing data-shape.md path (if refining)

The agent will:
1. Read the product overview and roadmap for context
2. Suggest initial entities based on the product's features
3. Conduct batched Q&A to refine entities and relationships
4. Present the data model for user approval
5. Write `data-shape/data-shape.md`

### Step 4: Present Results

```
Data shape defined!

  .design/product/data-shape/data-shape.md — {N} entities, {M} relationships

Entities: User, Organization, Project, Task, Comment
Relationships: {M} connections defined

Next: /design-studio:ds:shell to define your app shell and navigation
```

### Step 5: Append to Design Notes

Add a data shape entry to `.design/DESIGN_NOTES.md`:

```markdown
## Data Shape — {date}

**Entities:** {entity names}
**Relationships:** {count}
```

## Notes

- Data shape modeling is informed by the product overview and roadmap
- The agent suggests initial entities from the product context — you refine from there
- Entity names use PascalCase (User, TaskComment, ProjectMember)
- Run `ds:data-shape` again to refine an existing data model
- After data shape, continue with `/ds:shell` to define your app shell
