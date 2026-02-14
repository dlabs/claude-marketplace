---
name: ds:design-pick
description: Pick a design variant, extract tokens, and archive rejected variants
argument-hint: Variant letter (a, b, c, or d)
---

# /design-studio:ds:design-pick

Pick a variant from the most recent design session. Extracts design tokens from the chosen variant's CSS custom properties and archives rejected variants.

## Usage

```
/design-studio:ds:design-pick b
/design-studio:ds:design-pick a
```

## Prerequisites

- Must have run `/design-studio:ds:design` first (needs an active session with variants)

## Workflow

### Step 1: Find the Latest Session

Read `.design/sessions/` to find the most recent session directory (sorted by name, last one wins). Verify it has:
- `manifest.json`
- At least 2 `variant-*.html` files
- No existing `chosen.html` (if already picked, ask user to confirm re-pick)

### Step 2: Validate the Choice

Check that the specified variant exists:
- Argument should be a single letter (a-d)
- The corresponding `variant-{letter}.html` must exist in the session directory
- Show the variant's description from `manifest.json` and ask: "Pick variant {letter} ({description})?"

### Step 3: Archive the Session

Run the pick script:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/manage-session.sh pick {session-id} {variant-letter}
```

This:
- Moves rejected variants to `{session}/rejected/`
- Copies chosen variant to `{session}/chosen.html`
- Updates `manifest.json` with pick metadata

### Step 4: Extract Tokens

Use the **token-extractor** agent to:
- Parse `chosen.html`'s `:root {}` CSS custom properties
- Categorize into colors, typography, spacing, radii, shadows
- Check for conflicts with existing locked tokens
- Write `.design/tokens.json`

### Step 5: Present Results

Show the user:

```
Picked: Variant {letter} — {approach} ({description})

Tokens extracted:
  Colors:     {count} values
  Typography: {count} values
  Spacing:    {count} values
  Radii:      {count} values
  Shadows:    {count} values

Tokens locked at .design/tokens.json
Future /ds:design runs will use these tokens as constraints.

Next steps:
  /design-studio:ds:design-ship          — Convert to Next.js components
  /design-studio:ds:design "new thing"   — Explore more with locked tokens
  /design-studio:ds:design-status        — View workspace state
```

## Notes

- Picking a variant locks its tokens — future design sessions will use them as constraints
- Rejected variants are archived, not deleted — you can find them in `{session}/rejected/`
- You can re-pick by running this command again on the same session
- To unlock tokens for a fresh exploration, tell Claude to unlock them conversationally
