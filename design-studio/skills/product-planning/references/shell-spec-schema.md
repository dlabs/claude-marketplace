# Shell Spec Schema

Exact format specification for `.design/product/shell/spec.md`. The design-studio-app viewer parses this file with `parseShellSpec()`.

---

## Format

```markdown
# Shell Specification

## Overview
{Description of the overall app shell layout and design approach.}

## Navigation
- {Navigation item one}
- {Navigation item two}
- {Navigation item three}

## Layout
{Description of the layout pattern — sidebar width, content area behavior, responsive breakpoints, top bar configuration.}
```

---

## Field Rules

### Overview (required)

- Must appear under `## Overview`
- 1-3 paragraphs describing the overall app shell approach
- Should cover: layout type (sidebar, top-nav, etc.), visual style, responsive strategy
- The parser returns `null` if this section is missing — it is the only required section

### Navigation (optional but recommended)

- Appears under `## Navigation`
- Simple bullet list using `-` or `*` prefix
- Each bullet is one navigation item
- Use `**→**` or similar notation for special behavior (e.g., `Help **→** opens docs in new tab`)
- Items should map to the roadmap sections where possible
- Include both primary navigation and any secondary/utility navigation

### Layout (optional but recommended)

- Appears under `## Layout`
- Free-form text describing the layout pattern
- Include specific measurements where relevant (sidebar width, top bar height, breakpoints)
- Cover responsive behavior (how the layout adapts on mobile)

### Raw Markdown

The parser also returns the complete original markdown as `raw`. This allows the viewer to display the full spec even if some sections are non-standard.

---

## Parser Behavior

The parser (`parseShellSpec`) works as follows:

1. Extracts `## Overview` — returns `null` if missing
2. Extracts `## Navigation` and parses bullet items
3. Extracts `## Layout` as plain text
4. Returns the complete markdown as `raw`

**Critical**: The `## Overview` section is required. Without it, the entire shell spec is treated as invalid.

---

## Example Output

```markdown
# Shell Specification

## Overview
A responsive sidebar-based layout with a collapsible navigation panel on the left and a scrollable main content area on the right. The design uses a neutral background with card-based content sections. The top bar is fixed and contains the app logo, global search, and user avatar with dropdown.

## Navigation
- Dashboard
- My Tasks
- Projects
- Team Members
- Reports
- Settings
- Help **→** opens docs in new tab

## Layout
Fixed sidebar (240px collapsed to 64px icon-only mode) with a scrollable main content area. Top bar is 56px tall with the app logo on the left, centered search bar (max 480px), and user avatar + notification bell on the right. On screens below 768px, the sidebar becomes a hamburger menu overlay. Content area has a max-width of 1280px with 24px horizontal padding. Cards use 16px internal padding with 12px gap between them.
```

---

## Return Type

```typescript
interface ShellSpec {
  raw: string;              // Complete original markdown
  overview: string;         // From ## Overview
  navigationItems: string[];// Bullet items from ## Navigation
  layoutPattern: string;    // From ## Layout (empty string if missing)
}
```

---

## Guidelines

### Navigation Design

- **Map to roadmap sections** — each major roadmap section should have a corresponding nav item
- **Add utility items** — Settings, Help, Profile are common additions
- **Group logically** — primary features first, utility items last
- **5-8 items** is typical for primary navigation
- **Note special behaviors** — external links, popups, badges

### Layout Patterns

Common patterns to consider:
- **Sidebar + content**: Fixed or collapsible sidebar, scrollable main area
- **Top nav + content**: Horizontal navigation bar, full-width content below
- **Top nav + sidebar + content**: Top bar for global actions, sidebar for section navigation
- **Responsive strategy**: How the layout adapts below common breakpoints (768px, 1024px)
