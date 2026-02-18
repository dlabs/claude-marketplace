---
name: ds:shell
description: Define your app shell, navigation, and layout through interactive conversation. Produces shell/spec.md with overview, navigation items, and layout pattern.
argument-hint: Optional seed (e.g., "sidebar nav with dashboard, settings, and profile")
---

# /design-studio:ds:shell

Define the application shell — navigation structure, layout pattern, and responsive behavior — through interactive Q&A. Produces `shell/spec.md`.

## Usage

```
/design-studio:ds:shell "sidebar nav with dashboard, settings, and profile"
/design-studio:ds:shell "top navigation bar with centered content"
/design-studio:ds:shell   # (starts from product context)
```

## Prerequisites

- Run `/design-studio:ds:product` first — the shell navigation is derived from the roadmap sections
- If `product-overview.md` and `product-roadmap.md` don't exist, inform the user and suggest running `ds:product` first

## Workflow

### Step 1: Check Prerequisites

Verify `.design/product/product-overview.md` and `.design/product/product-roadmap.md` exist. If not:
```
Product definition not found.
Run /design-studio:ds:product first to define your product overview and roadmap.
```

Ensure the shell directory exists:
```bash
mkdir -p .design/product/shell
```

### Step 2: Check Existing Shell

If `.design/product/shell/spec.md` already exists, ask the user:

1. **Refine** — update specific aspects of the shell
2. **Start fresh** — discard the existing shell spec and start over
3. **View** — display the current shell spec, don't change anything

### Step 3: Invoke Shell Planner

Use the **shell-planner** agent to conduct interactive shell definition.

Pass the agent:
- The user's seed description (if provided as an argument)
- Whether this is a new shell or a refinement
- The existing spec.md path (if refining)

The agent will:
1. Read the product overview, roadmap, and optionally data shape for context
2. Suggest navigation items based on the roadmap sections
3. Conduct Q&A about layout preferences
4. Present the shell spec for user approval
5. Write `shell/spec.md`

### Step 4: Present Results

```
Shell defined!

  .design/product/shell/spec.md — {layout type}, {N} navigation items

Navigation:
  - Dashboard
  - My Tasks
  - Projects
  - ...

Next: /design-studio:ds:section create "{title}" to start defining feature sections
```

### Step 5: Append to Design Notes

Add a shell entry to `.design/DESIGN_NOTES.md`:

```markdown
## Shell Specification — {date}

**Layout:** {layout type}
**Navigation items:** {count}
**Responsive:** {strategy}
```

## Notes

- Shell navigation items are suggested from the product roadmap
- You can add utility items (Settings, Help, Profile) beyond the roadmap sections
- The shell spec is used by section screen designs as layout context
- Run `ds:shell` again to refine the shell
- After the shell, create sections with `/ds:section create "{title}"`
