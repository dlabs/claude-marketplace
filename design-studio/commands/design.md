---
name: ds:design
description: Generate 3-4 standalone HTML design variants from a text description. Opens in any browser for comparison.
argument-hint: What to design (e.g., "pricing page with 3 tiers, dark theme")
---

# /design-studio:ds:design

Generate standalone HTML design variants for visual exploration. Each variant is a self-contained file that opens in any browser — no build step, no dependencies.

## Usage

```
/design-studio:ds:design "pricing page with 3 tiers, dark theme"
/design-studio:ds:design "hero section with animated gradient"
/design-studio:ds:design   # (will ask what to design)
```

## Prerequisites

- Run `/design-studio:ds:design-init` first if no `.design/` workspace exists (the command will prompt if missing)

## Workflow

### Step 0: Check Brand Context

Check for brand identity and tokens:

- If `.design/brand.json` exists: note "Using brand identity: {name} ({archetype})" and pass brand.json path to the variant-generator agent
- If neither `.design/brand.json` nor `.design/tokens.json` exists: suggest "No brand identity or tokens found. Run /ds:brand to build a brand first, or continue to explore freely."
- If only `.design/tokens.json` exists (no brand): proceed normally — tokens provide visual constraints without brand personality

### Step 1: Initialize Workspace

Check if `.design/` exists. If not, run the init script:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-workspace.sh
```

### Step 2: Create Session

Create a new session directory:
```bash
SESSION_ID=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/manage-session.sh create)
```

### Step 3: Check Token Constraints

Read `.design/tokens.json` if it exists:
- If `"locked": true`, inform the user that variants will use locked tokens as constraints
- If the description seems to conflict with locked tokens (e.g., dark theme tokens but user asks for "bright, playful"), flag the conflict and ask:
  1. Work within locked tokens
  2. Unlock tokens for this session
  3. Partially update (e.g., keep spacing, new colors)

### Step 4: Generate Variants

Use the **variant-generator** agent to create 3-4 HTML variants in `.design/sessions/{session-id}/`.

Pass the agent:
- The user's description
- The session ID
- Whether tokens are locked and their values
- Any additional constraints from the user

### Step 5: Present Results

Show the user:

```
Session: {session-id}

| Variant | Approach | Description |
|---------|----------|-------------|
| A | clean-minimal | Lots of whitespace, muted palette, card grid |
| B | bold-gradient | High contrast, gradient headers, compact |
| C | feature-first | Features prominent, comparison table layout |

Files:
  .design/sessions/{session-id}/variant-a.html
  .design/sessions/{session-id}/variant-b.html
  .design/sessions/{session-id}/variant-c.html

Open these in your browser to compare, then run:
  /design-studio:ds:design-pick <letter>
```

## Token Constraint Behavior

| Token State | Variant Behavior |
|-------------|-----------------|
| No tokens | Each variant has unique colors, fonts, spacing |
| Locked tokens | All variants share the same visual language, differ in structure |
| Unlocked tokens | Same as no tokens — fresh visual language per variant |

## Notes

- Variants are standalone HTML files — open them directly in your browser
- Each variant uses Tailwind CDN, so they render correctly without any build step
- Interactive elements (toggles, tabs, accordions) work with vanilla JS
- Use `/design-studio:ds:design-status` to check workspace state
- Sessions accumulate in `.design/sessions/` — you can revisit any session
