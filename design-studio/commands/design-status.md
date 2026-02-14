---
name: ds:design-status
description: Show the current state of the design-studio workspace
---

# /design-studio:ds:design-status

Display the current state of the design workspace — sessions, tokens, and available next actions.

## Usage

```
/design-studio:ds:design-status
```

## Workflow

### Step 1: Check Workspace

If `.design/` doesn't exist:
```
No design-studio workspace found.
Run /design-studio:ds:design-init to set up.
```

### Step 2: Read Workspace State

Gather information:
- Read `.design/config.json` for settings
- Read `.design/brand.json` if it exists — extract name, archetype, industry
- Check if `.design/brand-guide.html` exists
- Check if `.design/brand-showcase/` exists and count pages
- List all session directories in `.design/sessions/`
- Read `.design/tokens.json` if it exists — check if `source_brand` is true
- For each session, read `manifest.json` to get status

### Step 3: Present Status

```
Design Studio Workspace
=======================

Config:
  Gitignore mode: {all|tokens-only|none}
  Created: {date}

Brand:
  Status: {defined|not-defined}
  Name: {name}  Archetype: {archetype}
  Industry: {industry}
  Brand guide: .design/brand-guide.html {exists|not generated}
  Showcase pages: {N} pages in .design/brand-showcase/
  Tokens derived from brand: {yes|no}

Tokens:
  Status: {locked|unlocked|none}
  Source: session {id}, variant {letter} (if locked)
  Categories: {N} colors, {N} typography, {N} spacing, {N} radii, {N} shadows

Sessions ({count} total):

| Session | Prompt | Variants | Status |
|---------|--------|----------|--------|
| 2026-02-14-002 | hero section with CTA | 3 | exploring |
| 2026-02-14-001 | pricing page, 3 tiers | 3 | picked (b) |

Next actions:
  /design-studio:ds:design "..."        — Start a new exploration
  /design-studio:ds:design-pick <letter> — Pick from current session
  /design-studio:ds:design-ship          — Ship chosen variant (uses shadcn/ui when detected)
```

### Session Status Values

| Status | Meaning |
|--------|---------|
| `exploring` | Variants generated, none picked yet |
| `picked (X)` | Variant X was picked, tokens extracted |
| `shipped` | Variant was converted to production components |

## Notes

- This is a read-only command — it doesn't modify any files
- Use this to orient yourself before deciding what to do next
- Session list is sorted most-recent-first
