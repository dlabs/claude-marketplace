# Brand Guide & Showcase Specification

Complete specification for `brand-guide.html` (the visual brand style guide) and brand showcase pages (real HTML pages demonstrating the brand in action). Used by the **brand-builder** and **brand-showcase-generator** agents.

---

## Part 1: Brand Guide (`brand-guide.html`)

A standalone HTML file styled with the brand's own tokens. Opens in any browser to give a complete visual overview of the brand identity.

### HTML Structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="brand-guide" content="true" data-brand="BRAND_NAME" data-version="1.0">
  <title>BRAND_NAME — Brand Guide</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          /* Map brand tokens to Tailwind utilities — same pattern as variant-spec.md */
        },
      },
    }
  </script>
  <style>
    :root {
      /* Brand tokens from brand.json visual_identity */
    }
    body {
      font-family: var(--text-font-sans);
      background-color: var(--color-background);
      color: var(--color-text);
    }
  </style>
</head>
<body>
  <!-- Sections below -->
</body>
</html>
```

### Sections

The brand guide has 8 sections, rendered in this order:

#### 1. Hero

Displays the brand's core identity — name, tagline, industry, and a brief description.

```html
<header class="...">
  <h1>Brand Name</h1>
  <p class="tagline">Tagline goes here</p>
  <p class="meta">Industry · Archetype</p>
  <p class="description">1-2 sentence business description</p>
</header>
```

**Styling:** Uses the primary color as an accent. Large typography for the brand name. Should immediately communicate the brand's visual personality.

#### 2. Personality

Shows the archetype, personality traits, and tone spectrum as visual sliders.

**Content:**
- Archetype name and brief description
- Trait badges (3-5 traits as styled tags/chips)
- Tone spectrum visualization — 4 horizontal bars showing position on each spectrum:
  - Formal ←→ Casual
  - Serious ←→ Playful
  - Technical ←→ Simple
  - Reserved ←→ Bold

**Tone spectrum rendering:** Each spectrum is a labeled horizontal bar with a marker at the brand's position. The value (0.0-1.0) maps to the marker position. Use CSS for the bars — no external dependencies.

#### 3. Visual Principles

Displays 2-5 principle cards, each with a name, description, and examples.

```html
<section>
  <h2>Visual Principles</h2>
  <div class="grid">
    <div class="card">
      <h3>Principle Name</h3>
      <p>What this principle means for design decisions</p>
      <ul>
        <li>Concrete example 1</li>
        <li>Concrete example 2</li>
      </ul>
    </div>
    <!-- More principle cards -->
  </div>
</section>
```

**Layout:** Card grid — 1 column on mobile, 2-3 on desktop.

#### 4. Color Palette

Shows each color as a swatch with hex value, semantic name, and meaning.

**For each color:**
- Visual swatch (colored rectangle or circle)
- Color name (e.g., "Primary")
- Hex value (e.g., `#6366f1`)
- Semantic meaning (e.g., "Action, trust")
- Contrast ratio against white and black backgrounds (compute at render time or annotate)

**Layout:** Grid of color cards. Group into: Core (primary, secondary), Neutrals (background, surface, text, text-muted, border), States (success, error).

**Contrast annotations:** For each color, show whether it passes WCAG AA for normal text (4.5:1) against the background color.

#### 5. Typography

Font specimens showing each font at various scale sizes.

**Content:**
- Font name and CSS value for each font family (sans, mono)
- Rationale for font choice
- Scale specimens — show each size from `xs` to `4xl` with:
  - Size name (e.g., "xl")
  - Actual size value (e.g., "1.25rem")
  - Sample text rendered at that size

**Sample text:** Use the brand's tagline or a voice example as the sample text (not "The quick brown fox").

#### 6. Spacing & Radii

Visual representations of the spacing scale and border radius options.

**Spacing:** Show each spacing value as a labeled block/bar with the value. Arrange as a visual scale from smallest to largest.

**Radii:** Show each radius applied to a sample card or rectangle. Label with the name and value.

#### 7. Voice & Tone

Examples of correct and incorrect brand voice.

**Layout:** Two-column layout:
- Left: "Do" examples — green-tinted cards with correct voice examples
- Right: "Don't" examples — red-tinted cards with incorrect voice examples

Each example should be a realistic sentence or phrase, not abstract descriptions.

#### 8. References

URLs and images analyzed during discovery, with patterns extracted.

**Content:**
- List of URLs with extracted patterns
- List of images with extracted patterns
- Free-form text descriptions

**Render only if references exist** — skip this section if `references` is empty or absent.

### Quality Requirements

The brand guide must:
- [ ] Be a single self-contained HTML file under 50KB
- [ ] Open in any browser with zero dependencies beyond Tailwind CDN
- [ ] Use the brand's own tokens for all styling (eat your own dog food)
- [ ] Be responsive (mobile, tablet, desktop)
- [ ] Use semantic HTML and accessible markup
- [ ] Render all sections in the correct order
- [ ] Show real brand data (not placeholder values)

---

## Part 2: Brand Showcase Pages

Showcase pages are real HTML pages that demonstrate the brand applied to actual content. They prove the brand works in practice before the user moves to `/ds:design`.

### Purpose

- Show the brand's visual identity, voice, and principles in context
- Generate realistic pages appropriate to the brand's industry
- Give users something to open in a browser immediately
- NOT variants to choose between — they are complementary pages

### Output Structure

```
.design/brand-showcase/
├── manifest.json
├── landing-page.html
├── pricing-page.html
└── features-page.html
```

### Page Selection Logic

The agent picks 2-3 page types based on the brand's industry and audience:

| Industry/Type | Page 1 | Page 2 | Page 3 |
|--------------|--------|--------|--------|
| SaaS / Developer tools | Landing page | Pricing page | Features page |
| E-commerce / Retail | Product page | Category page | About page |
| Agency / Portfolio | Homepage | Project/case study page | Contact page |
| Education / Course | Landing page | Curriculum page | About/team page |
| Healthcare / Wellness | Landing page | Services page | About/trust page |
| Generic / Unknown | Landing page | About page | Contact page |

The agent should adapt based on the specific brand — a B2B SaaS might get a landing + pricing + integrations page, while a consumer app might get a landing + features + download page.

### Showcase Page Template

Each showcase page follows the same HTML boilerplate as design variants:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="showcase" content="PAGE_TYPE" data-brand="BRAND_NAME" data-industry="INDUSTRY">
  <title>BRAND_NAME — PAGE_TITLE</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          /* Map brand tokens — same convention as variant-spec.md */
        },
      },
    }
  </script>
  <style>
    :root {
      /* Brand tokens from brand.json visual_identity */
      /* MUST use the SAME values as brand-guide.html */
    }
    body {
      font-family: var(--text-font-sans);
      background-color: var(--color-background);
      color: var(--color-text);
    }
  </style>
</head>
<body>
  <!-- Page content -->
  <script>
    // Vanilla JS for interactive elements
  </script>
</body>
</html>
```

### Content Requirements

Each showcase page must:
- Use the brand's **voice and tone** for all copy (headings, CTAs, body text, microcopy)
- Follow the brand's **visual principles** in layout and structure
- Contain **realistic content** appropriate to the industry and audience
- Include a **navigation header** with brand name and plausible nav links
- Include a **footer** with copyright and plausible links
- Have **working interactive elements** (hover states, toggles, accordions where appropriate)

### Copy Guidelines

All text content must match the brand personality:
- **Headings and CTAs** should match `voice_examples.do` patterns
- **Avoid** anything resembling `voice_examples.dont` patterns
- **Tone** should match the `tone_spectrum` values (formal/casual, serious/playful, etc.)
- **Content** should address `audience.primary` pain points and aspirations
- **Language register** should match the technical/simple spectrum

### Manifest Schema

```json
{
  "brand": "Brand Name",
  "generated_at": "ISO 8601 timestamp",
  "source_brand_version": "1.0",
  "pages": [
    {
      "type": "landing-page",
      "file": "landing-page.html",
      "title": "Page title",
      "description": "What this page demonstrates"
    }
  ]
}
```

### Quality Requirements

Every showcase page must:
- [ ] Be a single self-contained HTML file under 50KB
- [ ] Open in any browser with zero dependencies beyond Tailwind CDN
- [ ] Use CSS custom properties for ALL design values (same convention as design variants)
- [ ] Use the EXACT same token values as the brand guide
- [ ] Be responsive (375px mobile, 768px tablet, 1280px desktop)
- [ ] Use semantic HTML elements
- [ ] Have working interactive elements
- [ ] Use realistic content that matches the brand's voice and audience
- [ ] Meet WCAG 2.1 AA contrast requirements
- [ ] Have visible focus states on all interactive elements
- [ ] Include `<meta name="showcase">` tag with page metadata

### Differentiation from Design Variants

| Aspect | Showcase Pages | Design Variants (`/ds:design`) |
|--------|---------------|-------------------------------|
| Purpose | Demonstrate brand works in practice | Explore design directions |
| Count | 2-3 complementary pages | 3-4 competing alternatives |
| Selection | User does NOT choose between them | User picks one |
| Visual language | All share brand tokens | Each may have unique tokens (unless locked) |
| Content | Industry-appropriate realistic content | Matches the user's specific description |
| When generated | After brand discovery | During design exploration |
