---
name: ds:design-ship
description: Convert a chosen HTML variant into production Next.js components using detected project conventions and component libraries
argument-hint: Optional target path (e.g., src/app/pricing/page.tsx)
---

# /design-studio:ds:design-ship

Convert the most recently picked HTML variant into production Next.js components. Scans project conventions including component libraries (shadcn/ui, Radix UI), proposes a conversion plan, and writes components after confirmation.

## Usage

```
/design-studio:ds:design-ship
/design-studio:ds:design-ship src/app/pricing/page.tsx
```

## Prerequisites

- Must have run `/design-studio:ds:design-pick` first (needs a `chosen.html` in a session)
- Must be in a Next.js project (or at least have a `tailwind.config.*`)

## Workflow

### Step 1: Find the Chosen Variant

Scan `.design/sessions/` for the most recent session with a `chosen.html`. Also read:
- `.design/tokens.json` for design tokens
- `manifest.json` for session metadata

If no chosen variant found, suggest running `/design-studio:ds:design-pick` first.

### Step 2: Detect Project

Check for Next.js project indicators:
- `next.config.ts` / `next.config.js` / `next.config.mjs`
- `src/app/` (App Router) or `src/pages/` (Pages Router)
- `package.json` with `next` dependency

Check for component libraries:
- **shadcn/ui**: Look for `components.json` in the project root and `components/ui/*.tsx` files
- **Radix UI**: Check `package.json` for `@radix-ui/react-*` packages
- **Utilities**: Check for `cn()` in `lib/utils.ts` and `class-variance-authority` in `package.json`

If no Next.js project found:
- Inform the user and offer to generate a standalone React component instead
- Ask where to write the output

### Step 3: Dry Run

Use the **nextjs-converter** agent to analyze the project and produce a conversion plan. The plan should include detected component library info:

```
Conversion Plan:

Detected stack:
  Framework:         Next.js (App Router)
  Component library: shadcn/ui (button, card, tabs, badge, input)
  Styling:           Tailwind CSS v3
  Utilities:         cn() from @/lib/utils

Files to create:
  1. src/app/pricing/page.tsx          — Server Component (page entry)
  2. src/app/pricing/pricing-cards.tsx  — Client Component (uses <Card>, <Badge>)
  3. src/app/pricing/pricing-toggle.tsx — Client Component (uses <Tabs>)

Files to modify:
  1. tailwind.config.ts — extend colors with design tokens

shadcn components used: Card, CardHeader, CardTitle, CardContent, Badge, Tabs, TabsList, TabsTrigger, TabsContent, Button

No existing files will be overwritten.

Conventions detected:
  - App Router with src/ directory
  - kebab-case file names
  - Named exports
  - shadcn/ui with default style
```

If no component library is detected, omit the library-specific lines and show the simpler format.

Present this to the user and **wait for explicit confirmation** before proceeding.

### Step 4: Convert and Write

After confirmation, the **nextjs-converter** agent:
- Creates all planned component files
- Extends `tailwind.config.ts` with design tokens (if needed)
- Updates `.design/DESIGN_NOTES.md` with conversion details

### Step 5: Present Results

Show the user:

```
Shipped! Components created:

  src/app/pricing/page.tsx          — Page entry (Server Component)
  src/app/pricing/pricing-cards.tsx — Interactive cards (Client Component)
  src/app/pricing/pricing-toggle.tsx — Billing toggle (Client Component)
  tailwind.config.ts                — Updated with design tokens

Source: session {session-id}, variant {letter}
Design notes: .design/DESIGN_NOTES.md

Next steps:
  Run your dev server to preview the components
  /design-studio:ds:design-status — View workspace state
```

## Safety Rules

The converter will NEVER:
- Overwrite existing files (proposes alternative names)
- Install new npm packages
- Modify existing components
- Touch layout files (`layout.tsx`, `template.tsx`)
- Modify routing configuration
- Write without user confirmation

## Notes

- The dry-run step shows exactly what will be created — nothing is written until you confirm
- Components follow your project's existing conventions (detected automatically)
- If shadcn/ui is detected, generated components use shadcn primitives (`<Button>`, `<Card>`, `<Tabs>`, etc.) instead of raw HTML elements
- If a shadcn component would be useful but isn't installed, the dry-run suggests installing it
- Tailwind tokens are namespaced to avoid collisions with existing config
- Run `/design-studio:ds:design-ship` again with a different path to ship the same variant to multiple routes
