# Variant Specification

Complete specification for standalone HTML design variants generated during the Explore phase.

---

## HTML Boilerplate Template

Every variant MUST use this exact boilerplate structure:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="variant" content="VARIANT_ID" data-session="SESSION_ID" data-approach="APPROACH_NAME">
  <title>VARIANT_TITLE</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            primary: 'var(--color-primary)',
            'primary-hover': 'var(--color-primary-hover)',
            secondary: 'var(--color-secondary)',
            background: 'var(--color-background)',
            surface: 'var(--color-surface)',
            'text-primary': 'var(--color-text)',
            'text-muted': 'var(--color-text-muted)',
            border: 'var(--color-border)',
            success: 'var(--color-success)',
            error: 'var(--color-error)',
          },
          fontFamily: {
            sans: 'var(--text-font-sans)',
            mono: 'var(--text-font-mono)',
          },
          borderRadius: {
            sm: 'var(--radius-sm)',
            md: 'var(--radius-md)',
            lg: 'var(--radius-lg)',
            xl: 'var(--radius-xl)',
          },
          boxShadow: {
            sm: 'var(--shadow-sm)',
            md: 'var(--shadow-md)',
            lg: 'var(--shadow-lg)',
          },
        },
      },
    }
  </script>
  <style>
    :root {
      /* ── Colors ── */
      --color-primary: #6366f1;
      --color-primary-hover: #4f46e5;
      --color-secondary: #f59e0b;
      --color-background: #ffffff;
      --color-surface: #f8fafc;
      --color-text: #0f172a;
      --color-text-muted: #64748b;
      --color-border: #e2e8f0;
      --color-success: #22c55e;
      --color-error: #ef4444;

      /* ── Typography ── */
      --text-font-sans: 'Inter', system-ui, -apple-system, sans-serif;
      --text-font-mono: 'JetBrains Mono', ui-monospace, monospace;
      --text-xs: 0.75rem;
      --text-sm: 0.875rem;
      --text-base: 1rem;
      --text-lg: 1.125rem;
      --text-xl: 1.25rem;
      --text-2xl: 1.5rem;
      --text-3xl: 1.875rem;
      --text-4xl: 2.25rem;

      /* ── Spacing ── */
      --space-unit: 4px;
      --space-1: 0.25rem;
      --space-2: 0.5rem;
      --space-3: 0.75rem;
      --space-4: 1rem;
      --space-5: 1.25rem;
      --space-6: 1.5rem;
      --space-8: 2rem;
      --space-10: 2.5rem;
      --space-12: 3rem;
      --space-16: 4rem;
      --space-20: 5rem;
      --space-24: 6rem;

      /* ── Radii ── */
      --radius-sm: 0.25rem;
      --radius-md: 0.375rem;
      --radius-lg: 0.5rem;
      --radius-xl: 0.75rem;
      --radius-full: 9999px;

      /* ── Shadows ── */
      --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
      --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
      --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
    }

    body {
      font-family: var(--text-font-sans);
      background-color: var(--color-background);
      color: var(--color-text);
    }
  </style>
</head>
<body>
  <!-- Variant content here -->

  <script>
    // Vanilla JS for interactive elements (toggles, tabs, etc.)
  </script>
</body>
</html>
```

---

## CSS Custom Property Naming Convention

All design values MUST be CSS custom properties in `:root {}` using these prefixes:

| Prefix | Category | Examples |
|--------|----------|----------|
| `--color-*` | Colors | `--color-primary`, `--color-background`, `--color-text-muted` |
| `--text-*` | Typography | `--text-font-sans`, `--text-xl`, `--text-font-mono` |
| `--space-*` | Spacing | `--space-1`, `--space-4`, `--space-unit` |
| `--radius-*` | Border radii | `--radius-sm`, `--radius-lg`, `--radius-full` |
| `--shadow-*` | Box shadows | `--shadow-sm`, `--shadow-md`, `--shadow-lg` |

**Rules:**
- Use kebab-case for all property names
- Color properties always start with `--color-`
- Typography sizes use the Tailwind naming scale (`xs`, `sm`, `base`, `lg`, etc.)
- Spacing uses numeric scale (`--space-1` through `--space-24`)
- Never hardcode values in HTML attributes or inline styles — always reference custom properties

---

## Tailwind CDN Configuration

The `tailwind.config` in the `<script>` tag must map CSS custom properties to Tailwind utilities. This allows using classes like `bg-primary`, `text-text-muted`, `rounded-lg` while keeping values in `:root {}` for extraction.

**Key mapping pattern:**
```javascript
tailwind.config = {
  theme: {
    extend: {
      colors: {
        'token-name': 'var(--color-token-name)',
      },
    },
  },
}
```

---

## Variant Differentiation Rules

Each variant MUST differ in at least one meaningful UX dimension:

**Acceptable differentiators** (use at least 1):

| Dimension | Example A | Example B |
|-----------|-----------|-----------|
| **Layout** | Card grid | Comparison table |
| **Visual weight** | Minimal, lots of whitespace | Bold, dense, high contrast |
| **Information hierarchy** | Feature-first (features prominent, price secondary) | Price-first (price prominent, features below) |
| **Interaction pattern** | Toggle switch for billing period | Tab bar for billing period |
| **Navigation** | Vertical stack with scroll | Horizontal tabs with pagination |

**NOT acceptable as sole differentiator:**
- Color palette changes alone
- Font or font size changes alone
- Icon swaps alone
- Spacing/padding tweaks alone
- Border radius changes alone

**Naming convention for approaches:**
Use descriptive 2-3 word slugs: `clean-minimal`, `bold-gradient`, `card-grid`, `comparison-table`, `feature-first`, `price-prominent`.

---

## Quality Requirements

Every variant must meet ALL of these criteria:

### Responsive Design
- [ ] Looks correct at 375px width (mobile)
- [ ] Looks correct at 768px width (tablet)
- [ ] Looks correct at 1280px width (desktop)
- [ ] Uses Tailwind responsive prefixes (`sm:`, `md:`, `lg:`) appropriately

### Accessibility
- [ ] Semantic HTML elements (`<nav>`, `<main>`, `<section>`, `<article>`, `<button>`)
- [ ] All interactive elements are keyboard-accessible
- [ ] Color contrast meets WCAG 2.1 AA (4.5:1 for normal text, 3:1 for large text)
- [ ] Focus states are visible on all interactive elements
- [ ] Images have `alt` attributes
- [ ] Form inputs have associated `<label>` elements

### Content
- [ ] Uses realistic content (not lorem ipsum)
- [ ] Content length is representative of real-world data
- [ ] Handles both short and long text gracefully

### Interactivity
- [ ] All buttons, toggles, tabs, and interactive elements work
- [ ] Hover states provide visual feedback
- [ ] Active/selected states are clearly distinguished
- [ ] Transitions are smooth (use CSS transitions, not abrupt changes)

### Technical
- [ ] Single self-contained HTML file
- [ ] No external dependencies beyond Tailwind CDN
- [ ] All CSS values are custom properties in `:root {}`
- [ ] File size under 50KB
- [ ] No console errors when opened in browser
- [ ] Valid HTML (no unclosed tags, proper nesting)

---

## Manifest Schema

Each session must have a `manifest.json`:

```json
{
  "session": "2026-02-14-001",
  "prompt": "The original user description",
  "created_at": "2026-02-14T10:30:00Z",
  "tokens_locked": false,
  "locked_token_source": null,
  "parent_session": null,
  "parent_variant": null,
  "refinement_prompt": null,
  "variants": [
    {
      "id": "a",
      "file": "variant-a.html",
      "description": "Short description of the visual approach",
      "approach": "approach-slug",
      "differentiators": ["layout", "hierarchy"]
    },
    {
      "id": "b",
      "file": "variant-b.html",
      "description": "Short description of the visual approach",
      "approach": "approach-slug",
      "differentiators": ["interaction", "density"]
    },
    {
      "id": "c",
      "file": "variant-c.html",
      "description": "Short description of the visual approach",
      "approach": "approach-slug",
      "differentiators": ["layout", "weight"]
    }
  ]
}
```

**Fields:**
- `session`: Session ID in `YYYY-MM-DD-NNN` format
- `prompt`: The original text description from the user
- `created_at`: ISO 8601 timestamp
- `tokens_locked`: Whether locked tokens were used as constraints
- `locked_token_source`: Session ID of the token source (if locked)
- `parent_session`: Session ID of the parent session (refinement only, `null` for original sessions)
- `parent_variant`: Variant letter picked from the parent session (refinement only, `null` for original sessions)
- `refinement_prompt`: The user's refinement feedback (refinement only, `null` for original sessions)
- `variants[].id`: Single letter (`a`, `b`, `c`, `d`)
- `variants[].file`: Filename of the HTML variant
- `variants[].description`: 1-sentence description of the visual approach
- `variants[].approach`: 2-3 word slug for the approach
- `variants[].differentiators`: Array of dimensions this variant explores

### Refinement Fields

The three refinement fields (`parent_session`, `parent_variant`, `refinement_prompt`) are used by `/ds:design-refine` to create iterative design chains:

```json
{
  "session": "2026-02-14-002",
  "prompt": "pricing page with 3 tiers",
  "parent_session": "2026-02-14-001",
  "parent_variant": "b",
  "refinement_prompt": "make the CTA bigger, reduce whitespace"
}
```

- For original sessions (created by `/ds:design`): all three fields are `null`
- For refinement sessions (created by `/ds:design-refine`): all three fields are populated
- Refinement chains can be reconstructed by following `parent_session` links
- `/ds:design-status` uses these fields to display parent→child relationships

---

## Working with Locked Tokens

When `tokens.json` exists and has `"locked": true`:

1. **Read all locked token values** before generating variants
2. **Use locked values in `:root {}`** — do not invent new colors, fonts, or spacing
3. **Variants differ in structure, not visual language** — same palette, different layouts
4. **If the description conflicts with locked tokens** (e.g., tokens are dark theme but user asks for "bright, playful"), flag the conflict to the user and ask whether to:
   - Work within locked tokens
   - Unlock tokens for this session
   - Partially update tokens (e.g., keep spacing but change colors)
