# Data Shape Schema

Exact format specification for `.design/product/data-shape/data-shape.md`. The design-studio-app viewer parses this file with `parseDataShape()`.

---

## Format

```markdown
# Data Shape

## Entities
### EntityName
Description of what this entity represents, its purpose, and key attributes.

### AnotherEntity
Description of this entity.

## Relationships
- A User belongs to many Organizations
- An Organization has many Projects
- A Project has many Tasks
- A Task belongs to one User (assignee)
```

---

## Field Rules

### Entities (required)

- Must appear under `## Entities`
- Each entity is a `### EntityName` subsection
- The entity name must be **PascalCase** (e.g., `User`, `Project`, `TaskComment`)
- The body text after the heading is the entity description
- The description should mention key attributes and the entity's role in the system
- **Always use `### ` heading format** — the parser also supports a bullet fallback (`- **Name**: Description`) but the heading format is more reliable

### Relationships (optional but recommended)

- Appears under `## Relationships`
- Simple bullet list using `-` prefix
- Each bullet describes one relationship using natural language
- Use clear cardinality language:
  - "A {Entity} has many {Entity}" (one-to-many)
  - "A {Entity} belongs to one {Entity}" (many-to-one)
  - "A {Entity} has one {Entity}" (one-to-one)
  - "A {Entity} has many {Entity} through {Entity}" (many-to-many)

---

## Parser Behavior

The parser (`parseDataShape`) works as follows:

1. Extracts the `## Entities` section
2. Splits on `### ` boundaries — each block becomes an entity
   - Line 1 (after `### `): entity name
   - Lines 2+: entity description
3. If no `### ` headings found in the entities section, falls back to bullet format: `- **Name** - Description`
4. Extracts `## Relationships` as bullet items
5. Returns `null` if no entities found

**Critical**: Always use the `### EntityName` heading format. The bullet fallback only triggers when there are zero `### ` headings in the entities section.

---

## Example Output

```markdown
# Data Shape

## Entities
### User
Registered account with email, name, avatar, and role. Can belong to multiple organizations. Serves as the identity for authentication and authorization across the platform.

### Organization
A team or company workspace. Contains projects and manages member access through roles (owner, admin, member). Has billing information and subscription tier.

### Project
A collection of tasks organized under an organization. Has a name, description, status (active, archived, completed), deadline, and assigned team members.

### Task
The core work unit. Has title, description, status (todo, in-progress, review, done), priority (low, medium, high, urgent), assignee, due date, estimated hours, and supports subtasks for breaking down complex work.

### Comment
A message attached to a task. Contains text content, author reference, timestamp, and optional file attachments. Supports @mentions for notifications.

## Relationships
- A User belongs to many Organizations (through membership with role)
- An Organization has many Projects
- A Project has many Tasks
- A Task belongs to one Project
- A Task belongs to one User (assignee)
- A Task can have many child Tasks (subtasks)
- A Task has many Comments
- A Comment belongs to one User (author)
- A Comment belongs to one Task
```

---

## Return Type

```typescript
interface DataShape {
  entities: Array<{
    name: string;        // From ### heading (e.g., "User")
    description: string; // Body text after heading
  }>;
  relationships: string[]; // Bullet items from ## Relationships
}
```

---

## Guidelines

### Entity Design

- **Name every significant noun** in the product — if users interact with it, it's probably an entity
- **Include 4-8 entities** for a typical product (fewer suggests missing domain objects, more suggests over-modeling)
- **Describe key attributes** in the description — the viewer displays descriptions as-is
- **Consider lifecycle** — mention statuses and state transitions where relevant

### Relationship Design

- **Cover all entity connections** — every entity should appear in at least one relationship
- **Specify cardinality** — always indicate one-to-one, one-to-many, or many-to-many
- **Note junction entities** — for many-to-many relationships, mention the intermediate entity if it has its own attributes (e.g., "membership with role")
- **Keep it natural** — relationships should read like English sentences
