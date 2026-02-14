# Brand Schema

Complete schema for `brand.json` — the full brand identity file produced by the brand discovery process. Includes field definitions, validation rules, and derivation mapping to `tokens.json`.

---

## Schema

```json
{
  "version": "1.0",
  "created_at": "ISO 8601 timestamp",
  "updated_at": "ISO 8601 timestamp",

  "identity": {
    "name": "Brand name",
    "tagline": "One-line tagline",
    "industry": "Industry or domain",
    "description": "1-2 sentence business description"
  },

  "audience": {
    "primary": "Primary audience description",
    "secondary": "Secondary audience (optional)",
    "pain_points": ["..."],
    "aspirations": ["..."]
  },

  "personality": {
    "archetype": "The Reliable Craftsperson",
    "traits": ["trustworthy", "clear", "efficient", "approachable"],
    "tone_spectrum": {
      "formal_casual": 0.35,
      "serious_playful": 0.25,
      "technical_simple": 0.6,
      "reserved_bold": 0.4
    },
    "voice_examples": {
      "do": ["Deploy with confidence. Every time."],
      "dont": ["Leverage synergies to optimize your deployment paradigm!"]
    }
  },

  "visual_principles": [
    {
      "name": "Principle name",
      "description": "What it means for design decisions",
      "examples": ["Concrete example of this principle in action"]
    }
  ],

  "visual_identity": {
    "color_intent": {
      "primary": { "value": "#6366f1", "meaning": "Action, trust" },
      "primary-hover": { "value": "#4f46e5", "meaning": "Active state for primary" },
      "secondary": { "value": "#f59e0b", "meaning": "Accent, highlights" },
      "background": { "value": "#ffffff", "meaning": "Page background" },
      "surface": { "value": "#f8fafc", "meaning": "Card and section backgrounds" },
      "text": { "value": "#0f172a", "meaning": "Primary text" },
      "text-muted": { "value": "#64748b", "meaning": "Secondary text, captions" },
      "border": { "value": "#e2e8f0", "meaning": "Separators, outlines" },
      "success": { "value": "#22c55e", "meaning": "Positive states" },
      "error": { "value": "#ef4444", "meaning": "Error states" }
    },
    "typography_intent": {
      "font_sans": {
        "value": "Inter, system-ui, -apple-system, sans-serif",
        "rationale": "Why this font fits the brand"
      },
      "font_mono": {
        "value": "JetBrains Mono, ui-monospace, monospace",
        "rationale": "Why this font fits the brand"
      },
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
  },

  "references": {
    "urls_analyzed": [
      { "url": "https://example.com", "patterns_extracted": ["dark palette", "geometric shapes"] }
    ],
    "images_analyzed": [
      { "path": "path/to/image.png", "patterns_extracted": ["warm tones", "organic curves"] }
    ],
    "text_descriptions": ["User-provided free-form descriptions"]
  },

  "discovery_log": [
    { "phase": "questionnaire", "completed_at": "ISO 8601", "questions_answered": 8 },
    { "phase": "references", "completed_at": "ISO 8601", "urls_analyzed": 2, "images_analyzed": 1 },
    { "phase": "synthesis", "completed_at": "ISO 8601" }
  ]
}
```

---

## Field Definitions

### `identity` (required)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | The brand or product name |
| `tagline` | string | Yes | One-line tagline or value proposition |
| `industry` | string | Yes | Industry, domain, or category (e.g., "SaaS", "E-commerce", "Education") |
| `description` | string | Yes | 1-2 sentence business description |

### `audience` (required)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `primary` | string | Yes | Primary audience description (who they are, what they do) |
| `secondary` | string | No | Secondary audience if applicable |
| `pain_points` | string[] | Yes | What frustrates or challenges the audience (min 2) |
| `aspirations` | string[] | Yes | What the audience wants to achieve (min 2) |

### `personality` (required)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `archetype` | string | Yes | Brand archetype (e.g., "The Reliable Craftsperson", "The Bold Pioneer") |
| `traits` | string[] | Yes | 3-5 personality trait adjectives |
| `tone_spectrum` | object | Yes | Four spectrum values (see below) |
| `voice_examples.do` | string[] | Yes | 2-4 examples of how the brand SHOULD sound |
| `voice_examples.dont` | string[] | Yes | 2-4 examples of how the brand should NOT sound |

**Tone spectrum values** are floats from 0.0 to 1.0:

| Spectrum | 0.0 end | 1.0 end |
|----------|---------|---------|
| `formal_casual` | Very formal | Very casual |
| `serious_playful` | Very serious | Very playful |
| `technical_simple` | Very technical | Very simple |
| `reserved_bold` | Very reserved | Very bold |

### `visual_principles` (required, min 2, max 5)

Each principle describes a design philosophy that guides visual decisions:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Short principle name (e.g., "Purposeful whitespace") |
| `description` | string | Yes | What this principle means for design decisions |
| `examples` | string[] | Yes | 1-3 concrete examples of applying this principle |

### `visual_identity` (required)

Contains the visual system that gets derived into `tokens.json`.

#### `color_intent`

Each color has a value and a semantic meaning:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `value` | string | Yes | Valid CSS color (hex, rgb, hsl) |
| `meaning` | string | Yes | Why this color was chosen, what it communicates |

**Required colors:** `primary`, `primary-hover`, `background`, `surface`, `text`, `text-muted`, `border`
**Optional colors:** `secondary`, `success`, `error`, `accent`, `warning`, `info`, and any custom names

#### `typography_intent`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `font_sans.value` | string | Yes | CSS font-family string for sans-serif |
| `font_sans.rationale` | string | Yes | Why this font fits the brand |
| `font_mono.value` | string | No | CSS font-family string for monospace |
| `font_mono.rationale` | string | No | Why this font fits the brand |
| `scale.*` | string | Yes | Type scale in rem values (Tailwind naming) |

#### `spacing`, `radii`, `shadows`

Follow the same structure as `tokens.json` (see `token-schema.md`). These are purely visual values with no semantic annotation.

### `references` (optional)

Captures the reference material analyzed during brand discovery:

| Field | Type | Description |
|-------|------|-------------|
| `urls_analyzed` | array | URLs fetched and analyzed for patterns |
| `images_analyzed` | array | Images analyzed for visual patterns |
| `text_descriptions` | string[] | Free-form text descriptions from the user |

### `discovery_log` (auto-generated)

Tracks the phases of brand discovery for auditing. The brand-builder agent appends entries as it progresses.

---

## Validation Rules

A valid `brand.json` must have:

1. `identity.name` is a non-empty string
2. `personality` section exists with `archetype` and at least 3 `traits`
3. `visual_identity.color_intent` has at least 3 colors including `primary`, `background`, and `text`
4. `visual_identity.typography_intent` has at least `font_sans` with a non-empty value
5. `visual_principles` has at least 2 entries
6. All `tone_spectrum` values are between 0.0 and 1.0

The `manage-brand.sh validate` command checks these rules and returns exit code 0 (valid) or 1 (invalid with details).

---

## Token Derivation Mapping

`brand.json` is the source of truth. `tokens.json` is a derived visual subset. The derivation mapping extracts only the visual values, discarding semantic annotations (meaning, rationale).

### Mapping Rules

| brand.json path | tokens.json path | Transform |
|----------------|-----------------|-----------|
| `visual_identity.color_intent.{name}.value` | `colors.{name}` | Extract value only, convert underscore → hyphen in name |
| `visual_identity.typography_intent.font_sans.value` | `typography.font-sans` | Extract value only |
| `visual_identity.typography_intent.font_mono.value` | `typography.font-mono` | Extract value only |
| `visual_identity.typography_intent.scale.*` | `typography.scale.*` | Direct copy |
| `visual_identity.spacing.unit` | `spacing.unit` | Direct copy |
| `visual_identity.spacing.scale.*` | `spacing.scale.*` | Direct copy |
| `visual_identity.radii.*` | `radii.*` | Direct copy |
| `visual_identity.shadows.*` | `shadows.*` | Direct copy |

### Name Transforms

- Color names with underscores become hyphens: `primary_hover` → `primary-hover`
- Font key names use hyphens: `font_sans` → `font-sans`, `font_mono` → `font-mono`
- All other keys are copied as-is

### Derived tokens.json Metadata

When tokens are derived from brand, the tokens file gets an additional flag:

```json
{
  "locked": true,
  "locked_at": "ISO 8601",
  "source_brand": true,
  "source_session": null,
  "source_variant": null,
  "colors": { ... },
  "typography": { ... },
  "spacing": { ... },
  "radii": { ... },
  "shadows": { ... }
}
```

Key differences from variant-derived tokens:
- `source_brand: true` — indicates these tokens came from brand discovery, not variant picking
- `source_session: null` — no session involved
- `source_variant: null` — no variant involved
- Tokens are automatically locked since they represent a deliberate brand decision

### Re-derivation

Running `manage-brand.sh derive-tokens` re-derives tokens from the current `brand.json`. This is useful when:
- `brand.json` has been manually edited
- The brand was refined via `/ds:brand` and tokens need updating
- Tokens were unlocked/modified and need resetting to brand values

Re-derivation always overwrites the current `tokens.json` with brand-derived values.
