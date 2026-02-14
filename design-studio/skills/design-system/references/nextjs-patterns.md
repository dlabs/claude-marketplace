# Next.js Conversion Patterns

Patterns and heuristics for converting standalone HTML variants into production Next.js components during the Ship phase.

---

## App Router Patterns

### `"use client"` Decision Tree

A component needs `"use client"` if it uses ANY of:
- `useState`, `useEffect`, `useRef`, `useCallback`, `useMemo`
- Event handlers (`onClick`, `onChange`, `onSubmit`)
- Browser-only APIs (`window`, `document`, `localStorage`)
- Third-party client libraries (`framer-motion`, etc.)

A component should be a **Server Component** (no directive) if it:
- Only renders static or async-fetched content
- Has no interactivity
- Contains no hooks or event handlers

**Strategy:** Default to Server Component. Only add `"use client"` when the component genuinely needs client-side features. Split interactive parts into the smallest possible client components.

### File Structure

Follow the project's existing conventions. Common patterns:

**Co-located components (preferred for pages):**
```
src/app/pricing/
├── page.tsx              # Server Component (page entry)
├── pricing-cards.tsx     # Client Component (interactive cards)
├── pricing-toggle.tsx    # Client Component (billing toggle)
└── pricing-header.tsx    # Server Component (static header)
```

**Shared components:**
```
src/components/
├── ui/
│   ├── button.tsx
│   └── card.tsx
└── pricing/
    ├── pricing-cards.tsx
    └── pricing-toggle.tsx
```

---

## Component Splitting Heuristics

When converting a monolithic HTML variant into components:

### Split When:
1. **A section has its own interactivity** — toggle, tab, form, accordion → separate client component
2. **A pattern repeats 3+ times** — card, row, list item → extract component with props
3. **A section is independently scrollable or loaded** — sidebar, modal → separate component
4. **Content is fetched from different sources** — static header vs. dynamic pricing → separate server/client

### Don't Split When:
1. **The section is small** (< 30 lines) and only used once
2. **Splitting would require complex prop drilling** — keep together unless readability demands it
3. **All content is static** — a single Server Component is fine

### Naming Convention Detection

Before creating components, scan the project for:
- **File naming**: `kebab-case.tsx` vs `PascalCase.tsx` vs `camelCase.tsx`
- **Component naming**: `export function PricingCard` vs `export const PricingCard`
- **Export style**: named exports vs default exports
- **Directory structure**: flat vs nested vs grouped by domain

Match whatever the project uses. If no convention is detectable, default to:
- `kebab-case.tsx` files
- `PascalCase` function components
- Named exports
- Co-located with the page

---

## Vanilla JS → React Hooks Conversion

Common conversions from the HTML variant's `<script>` tag:

### Toggle State
```javascript
// HTML variant (vanilla JS)
let isAnnual = false;
document.getElementById('toggle').addEventListener('click', () => {
  isAnnual = !isAnnual;
  updatePrices(isAnnual);
});
```
```tsx
// React conversion
'use client';
import { useState } from 'react';

export function PricingToggle() {
  const [isAnnual, setIsAnnual] = useState(false);
  return (
    <button onClick={() => setIsAnnual(!isAnnual)}>
      {isAnnual ? 'Annual' : 'Monthly'}
    </button>
  );
}
```

### Tab Selection
```javascript
// HTML variant
const tabs = document.querySelectorAll('[data-tab]');
tabs.forEach(tab => {
  tab.addEventListener('click', () => {
    tabs.forEach(t => t.classList.remove('active'));
    tab.classList.add('active');
    showPanel(tab.dataset.tab);
  });
});
```
```tsx
// React conversion
'use client';
import { useState } from 'react';

export function Tabs({ items }: { items: { id: string; label: string; content: React.ReactNode }[] }) {
  const [active, setActive] = useState(items[0].id);
  return (
    <div>
      <div role="tablist">
        {items.map(item => (
          <button
            key={item.id}
            role="tab"
            aria-selected={active === item.id}
            onClick={() => setActive(item.id)}
          >
            {item.label}
          </button>
        ))}
      </div>
      <div role="tabpanel">
        {items.find(item => item.id === active)?.content}
      </div>
    </div>
  );
}
```

### Accordion / Disclosure
```javascript
// HTML variant
document.querySelectorAll('.accordion-header').forEach(header => {
  header.addEventListener('click', () => {
    header.parentElement.classList.toggle('open');
  });
});
```
```tsx
// React conversion
'use client';
import { useState } from 'react';

export function Accordion({ items }: { items: { title: string; content: React.ReactNode }[] }) {
  const [openIndex, setOpenIndex] = useState<number | null>(null);
  return (
    <div>
      {items.map((item, i) => (
        <div key={i}>
          <button
            aria-expanded={openIndex === i}
            onClick={() => setOpenIndex(openIndex === i ? null : i)}
          >
            {item.title}
          </button>
          {openIndex === i && <div>{item.content}</div>}
        </div>
      ))}
    </div>
  );
}
```

---

## Tailwind Config Extension

When the project already has a `tailwind.config.ts`, extend it — don't replace it.

### Safe Extension Pattern
```typescript
// Read existing config, add tokens under a namespace to avoid collisions
theme: {
  extend: {
    colors: {
      // Existing project colors remain untouched
      // Add design-studio tokens:
      ds: {
        primary: tokens.colors.primary,
        'primary-hover': tokens.colors['primary-hover'],
        // ...
      },
    },
  },
}
```

### When to Namespace
- **Always namespace** if the project already has custom colors defined
- **Skip namespace** if the project uses only Tailwind defaults
- **Use the project's existing pattern** if it already has a namespace or design token system

### Config File Detection
Check for config in this order:
1. `tailwind.config.ts`
2. `tailwind.config.js`
3. `tailwind.config.mjs`
4. `tailwind.config.cjs`

---

## CSS Custom Properties to Tailwind Classes

When converting HTML that uses `var(--color-primary)` to Tailwind classes:

| HTML Variant | Next.js Component |
|-------------|-------------------|
| `style="color: var(--color-primary)"` | `className="text-ds-primary"` |
| `style="background: var(--color-surface)"` | `className="bg-ds-surface"` |
| `style="border-radius: var(--radius-lg)"` | `className="rounded-lg"` |
| `style="box-shadow: var(--shadow-md)"` | `className="shadow-md"` |
| `style="font-family: var(--text-font-mono)"` | `className="font-mono"` |
| `style="padding: var(--space-4)"` | `className="p-4"` |

For values that directly map to Tailwind defaults (spacing, radii), use Tailwind's built-in classes. Only use `ds-` prefixed tokens for colors and custom values.

---

## Conversion Rules

1. **Never overwrite existing files** — if `page.tsx` exists, propose a different name or ask the user
2. **Never install new dependencies** — use only what's in the project's `package.json`
3. **Never modify existing components** — create new ones alongside them
4. **Never modify layout files** — `layout.tsx`, `template.tsx`, `loading.tsx` are off limits
5. **Always do a dry-run first** — show the user what files will be created before writing
6. **Match existing TypeScript strictness** — if the project uses strict mode, follow it
7. **Preserve accessibility** — every accessibility feature from the HTML variant must survive conversion
8. **Update DESIGN_NOTES.md** — append a section documenting what was converted and from which session
