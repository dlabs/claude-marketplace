# Product Overview Schema

Exact format specification for `.design/product/product-overview.md`. The design-studio-app viewer parses this file with `parseProductOverview()`.

---

## Format

```markdown
# {Product Name}

## Description
{1-3 paragraphs describing what the product does and who it's for.}

## Problems & Solutions
### Problem 1: {Problem Title}
{Solution description paragraph.}

### Problem 2: {Problem Title}
{Solution description paragraph.}

## Key Features
- {Feature one}
- {Feature two}
- {Feature three}
```

---

## Field Rules

### Product Name (H1 heading, required)

- Must be a single `# ` heading at the start of the file
- This is the product/project name, not a generic title like "Product Overview"
- Example: `# TaskFlow` or `# Acme Dashboard`

### Description (required)

- Appears under `## Description`
- 1-3 paragraphs of plain text
- Should cover: what the product does, who it's for, and the core value proposition
- Everything between `## Description` and the next `## ` heading is captured

### Problems & Solutions (optional but recommended)

- Appears under `## Problems & Solutions`
- Each problem is a `### ` subsection
- The heading format is `### Problem N: {Title}` where N is the number and Title is the problem name
  - The parser also accepts `### {Title}` without the "Problem N:" prefix
- The body text after the heading is the solution description
- Both the title AND the solution body must be non-empty for the problem to be captured
- Minimum 2 problems recommended, maximum 6

### Key Features (optional but recommended)

- Appears under `## Key Features`
- Simple bullet list using `-` or `*` prefix
- Each bullet is one feature (single line)
- Minimum 3 features recommended, maximum 10

---

## Parser Behavior

The parser (`parseProductOverview`) works as follows:

1. Extracts the H1 heading as `name` — returns `null` if no H1 found
2. Extracts `## Description` section — returns `null` if not found
3. Splits `## Problems & Solutions` on `### ` boundaries, then for each block:
   - Line 1: matched against `/^(?:Problem\s+\d+:\s*)?(.+)$/` to get the title
   - Lines 2+: joined as the solution text
   - Both title and solution must be non-empty to be included
4. Extracts `## Key Features` bullet items by splitting lines and stripping `-`/`*` prefixes

**Critical**: The parser uses `## ` (with space) as section delimiters. Do not use `##` without a trailing space.

---

## Example Output

```markdown
# TaskFlow

## Description
TaskFlow is a collaborative task management platform for remote engineering teams. It helps distributed teams stay aligned by combining real-time task boards, async standups, and smart notifications into a single workspace.

## Problems & Solutions
### Problem 1: Context Switching
Engineers lose 20+ minutes per context switch when juggling Slack, Jira, and email. TaskFlow consolidates all task-related communication into a single timeline per task, eliminating the need to check multiple tools.

### Problem 2: Async Coordination
Remote teams across time zones struggle with synchronous standup meetings. TaskFlow provides async standup templates that auto-aggregate into a daily digest, keeping everyone informed without scheduling conflicts.

### Problem 3: Priority Drift
Without clear visibility, teams work on low-impact tasks while critical items stall. TaskFlow uses a weighted scoring system based on deadlines, dependencies, and business impact to surface the highest-priority work.

## Key Features
- Real-time collaborative task boards with drag-and-drop
- Async standup templates with daily digest
- Smart priority scoring based on deadlines and dependencies
- Time zone-aware notifications and focus modes
- Project timeline with dependency visualization
- Integration with GitHub, GitLab, and Slack
```

---

## Return Type

```typescript
interface ProductOverview {
  name: string;           // From H1 heading
  description: string;    // From ## Description
  problems: Array<{
    title: string;        // From ### heading (without "Problem N:" prefix)
    solution: string;     // Body text after heading
  }>;
  features: string[];     // From ## Key Features bullet items
}
```
