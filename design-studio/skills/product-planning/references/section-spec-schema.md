# Section Spec Schema

Exact format specification for `.design/product/sections/{id}/spec.md`. The design-studio-app viewer parses this file with `parseSectionSpec()`.

---

## Format

```markdown
# {Section Title}

## Overview
{What this section does and why it exists.}

## User Flows
- {Flow step or user action one}
- {Flow step or user action two}
- {Flow step or user action three}

## UI Requirements
- {Requirement one}
- {Requirement two}
- {Requirement three}
```

---

## Field Rules

### Section Title (H1 heading, required)

- Must be a single `# ` heading
- Should match the title used in the roadmap (for consistent linking)
- Example: `# User Authentication` — matches roadmap entry `**User Authentication**`
- The parser returns `null` if no H1 is found

### Overview (optional but recommended)

- Appears under `## Overview`
- 1-2 paragraphs explaining the section's purpose and scope
- If missing, the viewer displays an empty overview

### User Flows (optional but recommended)

- Appears under `## User Flows`
- Bullet list using `-` or `*` prefix
- Each bullet describes one user action, flow step, or use case
- Write from the user's perspective: "Sign up with email and password"
- Include the complete set of user-facing actions this section supports
- 3-8 flows is typical

### UI Requirements (optional but recommended)

- Appears under `## UI Requirements`
- Bullet list using `-` or `*` prefix
- Each bullet describes one UI/UX requirement
- Focus on interactive elements, validation, feedback, and behavior
- 3-8 requirements is typical

---

## Section ID and Directory

The section lives in `.design/product/sections/{id}/` where `{id}` is the slugified version of the title:

```
slugify("User Authentication") → "user-authentication"
```

**Slugification rules** (must match the viewer's `parseProductRoadmap()` logic):
1. Convert to lowercase
2. Replace any non-alphanumeric character (including spaces) with a hyphen
3. Trim leading and trailing hyphens

The section directory contains:
- `spec.md` — this file (required for the section to be considered "has spec")
- `data.json` — optional sample data (valid JSON object)
- `screen-designs/` — optional directory with HTML screen designs

---

## Parser Behavior

The parser (`parseSectionSpec`) works as follows:

1. Extracts the H1 heading as `title` — returns `null` if no H1 found
2. Extracts `## Overview` as plain text (empty string if missing)
3. Extracts `## User Flows` and parses bullet items into array
4. Extracts `## UI Requirements` and parses bullet items into array

---

## Example Output

```markdown
# User Authentication

## Overview
Complete authentication flow including sign up, login, password reset, and social OAuth. Supports email/password and Google OAuth as primary methods. Session management uses JWT tokens with refresh rotation.

## User Flows
- Sign up with email and password
- Login with existing credentials
- Login with Google OAuth
- Login with GitHub OAuth
- Reset forgotten password via email link
- Update profile information (name, avatar)
- Change password from settings
- Sign out from current device
- Sign out from all devices

## UI Requirements
- Email field with real-time format validation
- Password strength indicator with color feedback (weak/fair/strong)
- Social auth buttons (Google, GitHub) with provider branding
- Remember me checkbox that extends session duration
- Loading states on all form submissions
- Error messages inline below the relevant field
- Success toast on password reset email sent
- Redirect to intended page after login
```

---

## Return Type

```typescript
interface SectionSpec {
  title: string;          // From H1 heading
  overview: string;       // From ## Overview (empty string if missing)
  userFlows: string[];    // Bullet items from ## User Flows
  uiRequirements: string[];// Bullet items from ## UI Requirements
}
```

---

## Guidelines

### Matching Roadmap Entries

When creating a section for a roadmap entry, use the **exact same title**:
- Roadmap: `3. **Task Board** - Kanban-style task management`
- Section spec: `# Task Board`

This ensures the slugified IDs match (`task-board`) and the viewer correctly links them.

### User Flows

- Write from the user's perspective, not the developer's
- Each flow should be a discrete, completable action
- Cover the happy path first, then edge cases
- Include CRUD operations where relevant (create, read, update, delete)

### UI Requirements

- Focus on interactive behavior, not visual styling
- Include validation rules, feedback mechanisms, and state transitions
- Mention accessibility requirements specific to this section
- Cover loading states, error states, and empty states
