# Product Roadmap Schema

Exact format specification for `.design/product/product-roadmap.md`. The design-studio-app viewer parses this file with `parseProductRoadmap()`.

---

## Format

Use the **numbered list format** (preferred):

```markdown
1. **Section Title** - Brief description of this section
2. **Another Section** - Brief description of this section
3. **Third Section** - Brief description of this section
```

---

## Field Rules

### Numbered List Format (preferred)

Each line follows this exact pattern:

```
{N}. **{Title}** - {Description}
```

- `{N}` — Integer starting from 1, defines the display order
- `**{Title}**` — Bold section title, wrapped in double asterisks
- `-` — Separator between title and description (also accepts `–`, `—`, or `:`)
- `{Description}` — One-line description of the section's scope

### Heading Format (fallback)

If the parser finds no numbered list items, it falls back to `### ` headings:

```markdown
### 1. Section Title
Description paragraph.

### 2. Another Section
Description paragraph.
```

**Always use the numbered list format.** The heading fallback exists for compatibility but the numbered list format is cleaner and more reliable.

### Section ID (slugification)

Each section title is automatically slugified to create a directory name:

```
slugify("User Authentication") → "user-authentication"
slugify("API & Integrations")  → "api-integrations"
slugify("Real-Time Updates")   → "real-time-updates"
```

**Slugification rules:**
1. Convert to lowercase
2. Replace any non-alphanumeric character with a hyphen
3. Trim leading and trailing hyphens

The slugified ID is used as the directory name under `.design/product/sections/{id}/`. It **must** match between the roadmap and the section directories for the viewer to link them correctly.

**Important**: When creating sections with `ds:section`, use the same title as in the roadmap so the IDs match.

---

## Parser Behavior

The parser (`parseProductRoadmap`) works as follows:

1. Tries numbered list pattern: `/^(\d+)\.\s+\*\*(.+?)\*\*\s*[-–—:]\s*(.+)$/gm`
   - Group 1: order number
   - Group 2: title (text inside `**`)
   - Group 3: description (text after separator)
2. If no matches, falls back to `### ` heading pattern
3. Returns `null` if no sections found at all

**Critical**: The title is extracted from inside `**...**` — do not nest other markdown formatting inside the title.

---

## Example Output

```markdown
1. **User Authentication** - Sign up, login, password reset, and OAuth integration
2. **Dashboard** - Overview metrics, activity feed, and quick actions
3. **Project Management** - Create, organize, and track projects with milestones
4. **Task Board** - Kanban-style task management with drag-and-drop
5. **Team Collaboration** - Comments, mentions, file sharing, and async standups
6. **Notifications** - Smart alerts with time zone awareness and focus modes
7. **Settings & Admin** - User preferences, team management, billing
```

---

## Return Type

```typescript
interface ProductRoadmap {
  sections: Array<{
    id: string;          // Slugified from title (e.g., "user-authentication")
    title: string;       // From **...** (e.g., "User Authentication")
    description: string; // Text after separator
    order: number;       // From the leading number
  }>;
}
```

---

## Roadmap Size Guidelines

- **Minimum**: 3 sections (any fewer and the product may not be well-defined)
- **Recommended**: 5-8 sections (enough to cover a real product without overwhelming)
- **Maximum**: 12 sections (beyond this, suggest grouping related sections)

Each roadmap section typically maps to one section directory. The order defines the recommended build sequence.
