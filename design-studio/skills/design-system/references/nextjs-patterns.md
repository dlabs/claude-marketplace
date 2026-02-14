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

## shadcn/ui Integration

When shadcn/ui is detected in the project, use its components instead of raw HTML elements. This produces output that matches the project's existing patterns and requires less custom styling.

### Detection

Check these indicators in order:

1. **`components.json`** in the project root — this is the definitive signal. Read it for:
   - `style`: `"default"` or `"new-york"` (affects component styling)
   - `aliases.components`: the import path for UI components (usually `@/components/ui`)
   - `aliases.utils`: the import path for `cn()` utility (usually `@/lib/utils`)
   - `tailwind.cssVariables`: whether the project uses CSS variables for theming
2. **UI component directory**: Glob `{src/,}components/ui/*.tsx` to build the list of installed components. Each file name (minus `.tsx`) is an available component.
3. **`cn()` utility**: Read `{src/,}lib/utils.{ts,js}` — if it exports a `cn` function (typically `clsx` + `twMerge`), use it for all conditional class logic.
4. **`class-variance-authority`** in `package.json`: If present, component variants should use the `cva()` pattern.

### Component Mapping Table

When a shadcn component is installed, replace the raw HTML pattern with the shadcn equivalent:

| HTML Variant Pattern | shadcn Component | Import Path | Notes |
|---------------------|-----------------|-------------|-------|
| `<button class="bg-... text-... rounded-... px-... py-...">` | `<Button variant="default" size="default">` | `@/components/ui/button` | Map visual style to `variant`: filled → `"default"`, outline → `"outline"`, ghost/text-only → `"ghost"`, destructive/red → `"destructive"`, link-style → `"link"`, subtle → `"secondary"`. Map size by padding: extra-small → `"xs"`, small → `"sm"`, default → `"default"`, large → `"lg"`, icon-only → `"icon"`. |
| `<div>` with card-like structure (border, shadow, rounded, header + content) | `<Card>` wrapping `<CardHeader>`, `<CardTitle>`, `<CardDescription>`, `<CardAction>`, `<CardContent>`, `<CardFooter>` | `@/components/ui/card` | Decompose the div structure: heading → `CardTitle`, subtext → `CardDescription`, header action (badge, button in top-right) → `CardAction`, body → `CardContent`, footer actions → `CardFooter`. |
| Tab navigation with buttons + panels | `<Tabs defaultValue="...">` wrapping `<TabsList>`, `<TabsTrigger value="...">`, `<TabsContent value="...">` | `@/components/ui/tabs` | Each tab button → `TabsTrigger`, each panel → `TabsContent`. Connect via matching `value` props. Use `<TabsList variant="line">` for underline-style tabs. |
| `<input type="text" class="...">` | `<Input placeholder="..." />` | `@/components/ui/input` | shadcn Input handles its own styling. Pass `type`, `placeholder`, `disabled`, `className` for overrides. |
| Toggle switch (checkbox styled as switch) | `<Switch checked={...} onCheckedChange={...} />` | `@/components/ui/switch` | Replace `useState` + checkbox with `Switch`. The `onCheckedChange` callback replaces `onChange`. |
| `<select>` or custom dropdown | `<Select>` wrapping `<SelectTrigger>`, `<SelectValue>`, `<SelectContent>`, `<SelectItem>` | `@/components/ui/select` | Each `<option>` → `<SelectItem value="...">`. The trigger displays the `<SelectValue placeholder="...">`. |
| Modal / dialog overlay | `<Dialog>` wrapping `<DialogTrigger>`, `<DialogContent>`, `<DialogHeader>`, `<DialogTitle>`, `<DialogDescription>` | `@/components/ui/dialog` | The trigger button opens the dialog. Content goes inside `DialogContent`. Always include `DialogTitle` for accessibility. |
| Badge / tag / pill | `<Badge variant="...">` | `@/components/ui/badge` | Map style: default filled → `"default"`, outline → `"outline"`, muted → `"secondary"`, destructive → `"destructive"`. Badge only has these 4 variants (no `"ghost"` or `"link"` like Button). |
| Accordion / collapsible sections | `<Accordion type="single" collapsible>` wrapping `<AccordionItem>`, `<AccordionTrigger>`, `<AccordionContent>` | `@/components/ui/accordion` | Each section → `AccordionItem` with unique `value`. Header → `AccordionTrigger`, body → `AccordionContent`. Use `type="multiple"` if multiple can open simultaneously. |
| Alert / notice / callout | `<Alert>` wrapping `<AlertTitle>`, `<AlertDescription>` | `@/components/ui/alert` | Map style: info → default, destructive → `variant="destructive"`. |
| `<label>` for form fields | `<Label htmlFor="...">` | `@/components/ui/label` | Replace raw `<label>` elements with shadcn Label for consistent styling. |
| Separator / divider (`<hr>` or border div) | `<Separator />` | `@/components/ui/separator` | Use `orientation="horizontal"` (default) or `"vertical"`. |

### Conversion Examples

**Button (without shadcn):**
```tsx
<button className="bg-primary text-white rounded-md px-4 py-2 hover:bg-primary/90">
  Get Started
</button>
```

**Button (with shadcn):**
```tsx
import { Button } from "@/components/ui/button"

<Button>Get Started</Button>
```

**Card (without shadcn):**
```tsx
<div className="rounded-lg border bg-card p-6 shadow-sm">
  <h3 className="text-lg font-semibold">Pro Plan</h3>
  <p className="text-sm text-muted-foreground">For growing teams</p>
  <div className="mt-4">
    <span className="text-3xl font-bold">$29</span>/mo
  </div>
</div>
```

**Card (with shadcn):**
```tsx
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card"

<Card>
  <CardHeader>
    <CardTitle>Pro Plan</CardTitle>
    <CardDescription>For growing teams</CardDescription>
  </CardHeader>
  <CardContent>
    <span className="text-3xl font-bold">$29</span>/mo
  </CardContent>
</Card>
```

**Tabs (without shadcn):**
```tsx
'use client';
import { useState } from 'react';

export function PricingToggle() {
  const [period, setPeriod] = useState('monthly');
  return (
    <div>
      <div role="tablist" className="flex gap-1 rounded-lg bg-muted p-1">
        <button role="tab" aria-selected={period === 'monthly'} onClick={() => setPeriod('monthly')}
          className={cn("rounded-md px-3 py-1.5 text-sm", period === 'monthly' && "bg-background shadow-sm")}>
          Monthly
        </button>
        <button role="tab" aria-selected={period === 'annual'} onClick={() => setPeriod('annual')}
          className={cn("rounded-md px-3 py-1.5 text-sm", period === 'annual' && "bg-background shadow-sm")}>
          Annual
        </button>
      </div>
      {period === 'monthly' ? <MonthlyPrices /> : <AnnualPrices />}
    </div>
  );
}
```

**Tabs (with shadcn):**
```tsx
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs"

export function PricingToggle() {
  return (
    <Tabs defaultValue="monthly">
      <TabsList>
        <TabsTrigger value="monthly">Monthly</TabsTrigger>
        <TabsTrigger value="annual">Annual</TabsTrigger>
      </TabsList>
      <TabsContent value="monthly"><MonthlyPrices /></TabsContent>
      <TabsContent value="annual"><AnnualPrices /></TabsContent>
    </Tabs>
  );
}
```

### cn() Utility Usage

When `cn()` is detected, always use it for conditional class names:

```tsx
import { cn } from "@/lib/utils"

// Instead of template literals:
className={`px-4 py-2 ${isActive ? 'bg-primary' : 'bg-muted'}`}

// Use cn():
className={cn("px-4 py-2", isActive ? "bg-primary" : "bg-muted")}
```

### Fallback Behavior

When a UI pattern exists in the variant but the corresponding shadcn component is NOT installed:

1. Use raw HTML + Tailwind classes (standard conversion)
2. Add a comment noting the opportunity:
   ```tsx
   {/* Consider: npx shadcn@latest add accordion */}
   <div className="border rounded-lg">
     {/* raw accordion implementation */}
   </div>
   ```
3. List all suggested installations in the dry-run plan under "Consider installing"

### shadcn Theming Awareness

shadcn/ui projects typically use CSS variables for theming (set via `tailwind.config.ts` and `globals.css`). When extending the Tailwind config with design tokens:

- Check if the project uses `cssVariables: true` in `components.json`
- If so, add design tokens as CSS variables in the appropriate layer rather than hardcoded hex values in `tailwind.config.ts`
- Respect the existing variable naming pattern (e.g., `--primary`, `--secondary`, `--muted`, etc.)
- Namespace design-studio tokens to avoid collisions: `--ds-primary`, `--ds-surface`, etc.

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
