---
name: ds:section
description: Create, edit, or list product sections. Each section gets a spec with title, overview, user flows, and UI requirements.
argument-hint: 'create "Section Title"' or 'edit section-id' or 'list'
---

# /design-studio:ds:section

Manage product sections — create new section specs, edit existing ones, or list all sections with their completion status.

## Usage

```
/design-studio:ds:section create "User Authentication"
/design-studio:ds:section create                        # (will ask for title)
/design-studio:ds:section edit user-authentication
/design-studio:ds:section list
```

## Prerequisites

- Run `/design-studio:ds:product` first — sections map to roadmap entries
- If `product-overview.md` and `product-roadmap.md` don't exist, inform the user and suggest running `ds:product` first

## Workflow

### Step 1: Parse Subcommand

The argument determines the action:

- **`create "Title"`** or **`create`** — create a new section
- **`edit {section-id}`** — refine an existing section's spec
- **`list`** — show all sections with status
- **No argument** — show the list and ask what to do

### Step 2: Handle Subcommand

#### create

1. If a title is provided, use it. Otherwise, show the roadmap sections that don't have directories yet and let the user choose or type a new title.

2. Slugify the title to create the section ID:
   ```
   "User Authentication" → "user-authentication"
   ```
   Slugification: lowercase, replace non-alphanumeric with hyphens, trim leading/trailing hyphens.

3. Create the section directory:
   ```bash
   mkdir -p .design/product/sections/{section-id}
   ```

4. If `sections/{section-id}/spec.md` already exists, ask whether to refine or overwrite.

5. Invoke the **section-planner** agent to conduct interactive spec definition:
   - Pass the section title, section ID
   - Pass the product overview, roadmap, and data shape paths for context
   - The agent produces `sections/{section-id}/spec.md`

6. Present results:
   ```
   Section created!

     .design/product/sections/{id}/spec.md — {title}

   User flows: {N}
   UI requirements: {N}

   Next: /design-studio:ds:section create "{next roadmap section}"
         or /design-studio:ds:section list to see all sections
   ```

7. Append to `.design/DESIGN_NOTES.md`:
   ```markdown
   ## Section: {title} — {date}

   **ID:** {section-id}
   **User flows:** {count}
   **UI requirements:** {count}
   ```

#### edit

1. Verify the section directory exists. If not, show available sections and ask the user to choose.

2. Read the existing `spec.md`.

3. Invoke the **section-planner** agent in refinement mode:
   - Pass the existing spec content
   - Let the user specify what to change
   - The agent updates `spec.md`

4. Present the updated spec.

#### list

1. Read the roadmap to get expected sections.
2. Scan `.design/product/sections/` for existing directories.
3. For each section, check:
   - Does `spec.md` exist?
   - Does `data.json` exist?
   - How many files in `screen-designs/`?

4. Present:
   ```
   Product Sections
   ================

   | # | Section | Spec | Data | Screens | Status |
   |---|---------|------|------|---------|--------|
   | 1 | User Authentication | yes | no | 1 | partial |
   | 2 | Dashboard | yes | yes | 0 | partial |
   | 3 | Project Management | no | no | 0 | not started |

   {N} of {total roadmap sections} sections defined.

   Next: /design-studio:ds:section create "{first missing section}"
   ```

## Notes

- Section IDs must match the slugified roadmap titles for the viewer to link them
- The `list` subcommand shows which roadmap sections still need specs
- Use `create` without a title to see roadmap suggestions
- Section specs can be refined with `edit` at any time
- After creating all sections, use `/ds:design-status` to see overall progress
