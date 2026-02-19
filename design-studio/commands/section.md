---
name: ds:section
description: Create, edit, design, pick, or list product sections. Each section gets a spec with title, overview, user flows, and UI requirements. Design generates screen variants scoped to a section.
argument-hint: 'create "Title"' or 'design "Section" "screen"' or 'pick "Section" "screen" b' or 'list'
---

# /design-studio:ds:section

Manage product sections — create specs, design screen variants, pick screen designs, or list all sections with their status.

## Usage

```
/design-studio:ds:section create "User Authentication"
/design-studio:ds:section create                        # (will ask for title)
/design-studio:ds:section edit user-authentication
/design-studio:ds:section design "User Auth" "login"
/design-studio:ds:section design "User Auth" "signup" "minimal, email-first"
/design-studio:ds:section pick "User Auth" "login" b
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
- **`design "Section" "screen" ["description"]`** — generate screen design variants for a section
- **`pick "Section" "screen" <letter>`** — pick a screen design variant
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

#### design

Generate screen design variants scoped to a section. This bridges product planning (section specs) with visual design exploration.

1. Parse arguments: `design "Section Title or ID" "screen name" ["optional description"]`
   - Resolve the section: match against section directory names or titles (case-insensitive, partial match OK)
   - If the section can't be found, show available sections and ask the user to choose
   - Slugify the screen name: `"login"` stays `login`, `"Forgot Password"` becomes `forgot-password`

2. Validate section has `spec.md`:
   ```
   Error: Section "user-auth" has no spec.md — run ds:section create first.
   ```

3. Check for existing screen designs:
   - If `.drafts/{screen-slug}/` exists with unpicked variants (no `chosen.html`):
     ```
     Screen "login" already has unpicked drafts in section "User Auth".
       A — centered-card: Centered login card...
       B — split-panel: Split-panel with branding...
       C — stepper-flow: Progressive login...

     What would you like to do?
       1. Pick one first (/ds:section pick "User Auth" "login" <letter>)
       2. Overwrite and redesign
       3. Cancel
     ```
   - If `screen-designs/{screen-slug}.html` already exists (previously picked):
     ```
     Screen "login" already has a picked design in section "User Auth".
       File: .design/product/sections/user-auth/screen-designs/login.html

     What would you like to do?
       1. Redesign (creates new drafts, existing pick is preserved until new pick)
       2. Cancel
     ```

4. Create the drafts directory:
   ```bash
   DRAFTS_DIR=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/manage-screen-designs.sh create {section-id} {screen-slug})
   ```

5. Invoke the **screen-designer** agent to generate 3 HTML variants.

   Pass the agent:
   - Section ID and screen name slug
   - Path to section `spec.md`
   - Path to shell `spec.md` (if it exists)
   - Path to `tokens.json` (if it exists)
   - Path to `brand.json` (if it exists)
   - The optional description from the user (if provided)

6. Present results:
   ```
   Screen designs for "User Auth" → login
   =============================================

   | Variant | Approach | Description |
   |---------|----------|-------------|
   | A | centered-card | Centered login card with email/password fields |
   | B | split-panel | Left branding panel, right login form |
   | C | stepper-flow | Multi-step login with progressive disclosure |

   Files: .design/product/sections/user-auth/screen-designs/.drafts/login/

   Open in browser to compare, then pick:
     /design-studio:ds:section pick "User Auth" "login" <letter>
   ```

7. Append to `.design/DESIGN_NOTES.md`:
   ```markdown
   ## Screen Design: {section-title} → {screen-name} — {date}

   **Section:** {section-id}
   **Screen:** {screen-slug}
   **Description:** {description or "from spec"}
   **Variants:** 3
   ```

#### pick

Pick a screen design variant, copy it to the canonical location, and archive rejects.

1. Parse arguments: `pick "Section Title or ID" "screen name" <variant-letter>`
   - Resolve the section (same matching as `design`)
   - Slugify the screen name

2. Validate:
   - Section directory exists
   - Drafts directory exists for this screen
   - Variant letter file exists

3. Run the pick script:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/manage-screen-designs.sh pick {section-id} {screen-slug} {variant-letter}
   ```

   This:
   - Copies chosen variant to `screen-designs/{screen-slug}.html`
   - Copies chosen variant to `.drafts/{screen-slug}/chosen.html`
   - Moves rejected variants to `.drafts/{screen-slug}/rejected/`
   - Updates `.drafts/{screen-slug}/manifest.json` with pick metadata

4. Present results:
   ```
   Picked: Variant {letter} — {approach} ({description})

   Screen design: .design/product/sections/{section-id}/screen-designs/{screen-slug}.html

   Next:
     /design-studio:ds:section design "{section}" "{next screen}"  — Design another screen
     /design-studio:ds:section list                                — See all sections
     /design-studio:ds:design-status                               — Full workspace status
   ```

5. Append to `.design/DESIGN_NOTES.md`:
   ```markdown
   ## Screen Pick: {section-title} → {screen-name} — {date}

   **Picked:** Variant {letter} — {approach}
   **File:** screen-designs/{screen-slug}.html
   ```

#### list

1. Read the roadmap to get expected sections.
2. Scan `.design/product/sections/` for existing directories.
3. For each section, check:
   - Does `spec.md` exist?
   - Does `data.json` exist?
   - How many `.html` files in `screen-designs/` (excluding `.drafts/`)?
   - How many unpicked draft sets in `screen-designs/.drafts/` (directories without `chosen.html`)?

4. Present:
   ```
   Product Sections
   ================

   | # | Section | Spec | Data | Screens | Drafts | Status |
   |---|---------|------|------|---------|--------|--------|
   | 1 | User Authentication | yes | no | 2 | 0 | partial |
   | 2 | Dashboard | yes | yes | 0 | 1 | partial |
   | 3 | Project Management | no | no | 0 | 0 | not started |

   {N} of {total roadmap sections} sections defined.

   Next: /design-studio:ds:section create "{first missing section}"
   ```

   - **Screens** column: count of picked screen designs (`.html` files in `screen-designs/`)
   - **Drafts** column: count of unpicked draft sets (directories in `.drafts/` without `chosen.html`)
   - If there are unpicked drafts, suggest picking them in the "Next" recommendation

## Notes

- Section IDs must match the slugified roadmap titles for the viewer to link them
- The `list` subcommand shows which roadmap sections still need specs and unpicked drafts
- Use `create` without a title to see roadmap suggestions
- Section specs can be refined with `edit` at any time
- Screen names are slugified: `"Forgot Password"` becomes `forgot-password`
- The `design` subcommand reads the section spec to drive screen content — no need to describe features manually
- The optional description in `design` provides additional direction beyond what's in the spec
- After picking all screen designs, use `/ds:design-status` to see overall progress
