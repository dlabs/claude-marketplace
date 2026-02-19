---
name: ds:design-refine
description: Refine a picked design variant with feedback. Creates a new session with 3-4 variants that iterate on the chosen design.
argument-hint: Feedback for refinement (e.g., "make the CTA bigger, reduce whitespace")
---

# /design-studio:ds:design-refine

Iterate on a picked design variant by providing feedback. Creates a new session with 3-4 variants that refine the chosen design according to your feedback, each interpreting the feedback differently.

## Usage

```
/design-studio:ds:design-refine "make the CTA bigger, reduce whitespace"
/design-studio:ds:design-refine "try a dark version of this"
/design-studio:ds:design-refine "simplify the header, add more social proof"
/design-studio:ds:design-refine   # (will ask for feedback)
```

## Prerequisites

- Must have a session with a picked variant (`chosen.html` exists)
- Run `/design-studio:ds:design` then `/design-studio:ds:design-pick` first

## Workflow

### Step 1: Find the Parent Session

Read `.design/sessions/` to find the most recent session with `chosen.html`. Scan from newest to oldest:

1. If a session has `chosen.html`, use it as the parent
2. If no session has `chosen.html`, inform the user:
   ```
   No picked design found. Pick a variant first:
     /design-studio:ds:design-pick <letter>
   ```
   Then stop.

Read the parent session's `manifest.json` to get:
- `session` — the parent session ID
- `picked_variant` — the variant letter that was picked
- `prompt` — the original description

### Step 2: Get Feedback

If the user provided feedback as an argument, use it. Otherwise, ask:
```
Refining session {parent-session-id}, variant {letter} ({approach}).

What would you like to change? Describe what to adjust, add, or remove.
```

### Step 3: Create New Session

Create a new session for the refinement:
```bash
SESSION_ID=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/manage-session.sh create)
```

### Step 4: Generate Refinement Variants

Use the **variant-generator** agent in **refinement mode** by passing:

- **Base design**: Full content of `{parent-session}/chosen.html`
- **Refinement feedback**: The user's feedback text
- **Parent session ID**: For manifest linkage
- **Parent variant letter**: For manifest linkage
- **Locked tokens** (from `.design/tokens.json` if they exist)
- **Brand context** (from `.design/brand.json` if it exists)

The variant-generator will:
- Analyze the base design's structure, layout, and content
- Apply the feedback as modifications
- Generate 3-4 variants that each interpret the feedback differently
- Preserve elements the user didn't mention changing
- Write variants to `.design/sessions/{new-session-id}/`

### Step 5: Present Results

Show the user:

```
Refinement session: {new-session-id}
  Parent: {parent-session-id}, variant {letter}
  Feedback: "{feedback text}"

| Variant | Approach | Description |
|---------|----------|-------------|
| A | interpretation-1 | Description of how feedback was applied |
| B | interpretation-2 | Description of how feedback was applied |
| C | interpretation-3 | Description of how feedback was applied |

Files:
  .design/sessions/{new-session-id}/variant-a.html
  .design/sessions/{new-session-id}/variant-b.html
  .design/sessions/{new-session-id}/variant-c.html

Open in browser to compare, then:
  /design-studio:ds:design-pick <letter>       — Pick and extract tokens
  /design-studio:ds:design-refine "more..."    — Refine again
```

### Step 6: Update Design Notes

Append to `.design/DESIGN_NOTES.md`:
```markdown
## Refinement: {new-session-id} — {date}

**Parent:** {parent-session-id}, variant {letter}
**Feedback:** {feedback text}
**Variants:** {count}
```

## Refinement Chain

Multiple refinements create a chain:

```
Session 001 (original) → picked B
  └─ Session 002 (refinement: "bigger CTA") → picked A
       └─ Session 003 (refinement: "darker theme") → exploring
```

Each refinement session's manifest includes `parent_session` and `parent_variant` fields, enabling the chain to be reconstructed.

Use `/design-studio:ds:design-status` to see the full refinement chain.

## Notes

- Refinement creates a **new session** — the parent session is never modified
- You can refine multiple times, creating a chain of iterations
- Each refinement variant interprets the feedback differently — "bigger CTA" might mean wider button, full-width button, or floating sticky button
- Elements not mentioned in the feedback are preserved from the parent design
- Locked tokens remain as constraints during refinement
- You can still run `/design-studio:ds:design "something new"` for a fresh exploration at any time
