# Token Schema

Complete schema and management rules for `tokens.json` — the design token file that persists across sessions.

---

## Schema

```json
{
  "locked": true,
  "locked_at": "2026-02-14T11:00:00Z",
  "source_session": "2026-02-14-001",
  "source_variant": "b",
  "colors": {
    "primary": "#6366f1",
    "primary-hover": "#4f46e5",
    "secondary": "#f59e0b",
    "background": "#ffffff",
    "surface": "#f8fafc",
    "text": "#0f172a",
    "text-muted": "#64748b",
    "border": "#e2e8f0",
    "success": "#22c55e",
    "error": "#ef4444"
  },
  "typography": {
    "font-sans": "Inter, system-ui, -apple-system, sans-serif",
    "font-mono": "JetBrains Mono, ui-monospace, monospace",
    "scale": {
      "xs": "0.75rem",
      "sm": "0.875rem",
      "base": "1rem",
      "lg": "1.125rem",
      "xl": "1.25rem",
      "2xl": "1.5rem",
      "3xl": "1.875rem",
      "4xl": "2.25rem"
    }
  },
  "spacing": {
    "unit": "4px",
    "scale": {
      "1": "0.25rem",
      "2": "0.5rem",
      "3": "0.75rem",
      "4": "1rem",
      "5": "1.25rem",
      "6": "1.5rem",
      "8": "2rem",
      "10": "2.5rem",
      "12": "3rem",
      "16": "4rem",
      "20": "5rem",
      "24": "6rem"
    }
  },
  "radii": {
    "sm": "0.25rem",
    "md": "0.375rem",
    "lg": "0.5rem",
    "xl": "0.75rem",
    "full": "9999px"
  },
  "shadows": {
    "sm": "0 1px 2px rgba(0, 0, 0, 0.05)",
    "md": "0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1)",
    "lg": "0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1)"
  }
}
```

---

## Category Definitions

### Colors (`colors`)

All color values must be valid CSS color values (hex, rgb, rgba, hsl, hsla).

| Token | Purpose | Required |
|-------|---------|----------|
| `primary` | Primary brand/action color | Yes |
| `primary-hover` | Primary hover state | Yes |
| `secondary` | Secondary accent color | No |
| `background` | Page background | Yes |
| `surface` | Card/section background | Yes |
| `text` | Primary text color | Yes |
| `text-muted` | Secondary/muted text | Yes |
| `border` | Default border color | Yes |
| `success` | Success state color | No |
| `error` | Error state color | No |

Additional colors can be added with descriptive names (e.g., `accent`, `warning`, `info`).

### Typography (`typography`)

| Token | Purpose | Format |
|-------|---------|--------|
| `font-sans` | Primary font stack | CSS font-family string |
| `font-mono` | Monospace font stack | CSS font-family string |
| `scale.*` | Type scale | rem values using Tailwind naming |

### Spacing (`spacing`)

| Token | Purpose | Format |
|-------|---------|--------|
| `unit` | Base spacing unit | px value |
| `scale.*` | Spacing scale | rem values, keys are multipliers |

### Radii (`radii`)

| Token | Purpose | Format |
|-------|---------|--------|
| `sm` | Small radius | rem value |
| `md` | Medium radius | rem value |
| `lg` | Large radius | rem value |
| `xl` | Extra large radius | rem value |
| `full` | Pill/circle | `9999px` |

### Shadows (`shadows`)

| Token | Purpose | Format |
|-------|---------|--------|
| `sm` | Subtle shadow | CSS box-shadow value |
| `md` | Medium shadow | CSS box-shadow value |
| `lg` | Prominent shadow | CSS box-shadow value |

---

## CSS Custom Property → Token Mapping

The extraction process maps CSS custom properties to token categories:

| CSS Property | Token Path |
|-------------|------------|
| `--color-primary` | `colors.primary` |
| `--color-text-muted` | `colors.text-muted` |
| `--text-font-sans` | `typography.font-sans` |
| `--text-xl` | `typography.scale.xl` |
| `--space-4` | `spacing.scale.4` |
| `--space-unit` | `spacing.unit` |
| `--radius-lg` | `radii.lg` |
| `--shadow-md` | `shadows.md` |

**Extraction rules:**
1. Parse the `:root {}` block from the chosen HTML file
2. Split each `--prefix-name: value;` declaration
3. Map to token category by prefix (`--color-` → `colors`, `--text-` → `typography`, etc.)
4. For `--text-font-*`, map to `typography.font-*`
5. For `--text-{size}`, map to `typography.scale.{size}`
6. For `--space-unit`, map to `spacing.unit`
7. For `--space-{n}`, map to `spacing.scale.{n}`
8. Strip whitespace from values but preserve CSS function syntax (e.g., `rgba(...)`)

---

## Lock/Unlock Semantics

### Locked (`"locked": true`)

When tokens are locked:
- Future `/ds:design` runs **must** use these values in the `:root {}` block
- Variants differ in **structure** (layout, interaction, hierarchy) not **visual language**
- If a description conflicts with locked tokens, **flag the conflict** — don't silently override
- New tokens can be **added** (e.g., a new `--color-accent`) but existing ones must not change

### Unlocked (`"locked": false`)

When tokens are unlocked:
- `/ds:design` generates fresh visual language per variant
- Each variant can have completely different colors, fonts, spacing
- Running `/ds:design-pick` re-locks tokens with the chosen variant's values

### Unlocking tokens

Tokens are unlocked conversationally — the user tells Claude to unlock them. The token-extractor agent sets `"locked": false` and clears `locked_at`.

---

## Merge Strategy

When extracting tokens from a new variant into an existing `tokens.json`:

### Full Replace (default)

Replace all token values with the new variant's values. Used when the user picks a new variant.

### Partial Update

When the user says "update just the colors" or "keep spacing, change colors":
1. Read existing `tokens.json`
2. Only overwrite the specified categories
3. Keep all other categories unchanged
4. Update `source_session` and `source_variant`
5. Set `locked_at` to current timestamp

### Conflict Detection

When merging, flag these conflicts to the user:
- **Missing token**: A locked token exists but the new variant doesn't define it
- **Type mismatch**: A token changed type (e.g., color value → gradient value)
- **Significant change**: A color changed by more than 3 hue steps (subjective — flag for review)

---

## Tailwind Config Mapping

When shipping tokens to a Next.js project, map to `tailwind.config.ts`:

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  theme: {
    extend: {
      colors: {
        primary: '#6366f1',
        'primary-hover': '#4f46e5',
        secondary: '#f59e0b',
        background: '#ffffff',
        surface: '#f8fafc',
        'ds-text': '#0f172a',        // prefix to avoid Tailwind conflicts
        'ds-text-muted': '#64748b',
        'ds-border': '#e2e8f0',
        success: '#22c55e',
        error: '#ef4444',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        mono: ['JetBrains Mono', 'ui-monospace', 'monospace'],
      },
      borderRadius: {
        sm: '0.25rem',
        md: '0.375rem',
        lg: '0.5rem',
        xl: '0.75rem',
      },
      boxShadow: {
        sm: '0 1px 2px rgba(0, 0, 0, 0.05)',
        md: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1)',
        lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1)',
      },
    },
  },
}

export default config
```

**Conflict avoidance:** When a token name collides with Tailwind defaults (e.g., `text`, `border`), prefix with `ds-` in the Tailwind config. The converter agent handles this mapping.
