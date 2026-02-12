# CLAUDE.md Section Catalog

Reference catalog of high-value CLAUDE.md sections, organized by priority and category. Use this to identify gaps and generate targeted suggestions.

---

## Priority 1: Essential (Every Project)

### Project Overview
```markdown
## Project Overview
{Project name} is a {type} that {purpose}. Built with {primary stack}.
```

### Development Setup
```markdown
## Development

### Setup
{install command}

### Running
{dev server command}

### Testing
{test command}

### Linting
{lint command}

### Type Checking
{type check command}
```

### Directory Structure
```markdown
## Project Structure
- `src/` — Application source code
- `tests/` — Test files
- `docs/` — Documentation
{stack-specific directories}
```

---

## Priority 2: Conventions (Stack-Specific)

### Naming Conventions
```markdown
## Conventions

### File Naming
- Components: PascalCase (`UserProfile.tsx`)
- Utilities: camelCase (`formatDate.ts`)
- Tests: `{name}.test.ts` or `{name}.spec.ts`
```

### Code Patterns
```markdown
### Code Patterns
- Use {pattern} for {purpose}
- Prefer {approach A} over {approach B} because {reason}
```

### API Conventions
```markdown
### API Routes
- RESTful resource naming: `/api/v1/{resource}`
- Always return JSON with `{ data, error, meta }` shape
```

---

## Priority 3: Architecture (Complex Projects)

### State Management
```markdown
## State Management
- Client state: {tool} (for UI state, form state)
- Server state: {tool} (for API data, caching)
- Global state: {tool} (for auth, theme, app-wide state)
```

### Database
```markdown
## Database
- ORM: {orm}
- Migrations: `{migration command}`
- Always include rollback in migrations
- Never drop columns without a deprecation migration first
```

### Authentication
```markdown
## Authentication
- Provider: {provider}
- Protected routes: {pattern}
- Token handling: {approach}
```

---

## Priority 4: Quality Gates

### Pre-Commit
```markdown
## Before Committing
1. Run `{lint command}` — fix all errors
2. Run `{type check command}` — no type errors
3. Run `{test command}` — all tests pass
4. Run `{format command}` — consistent formatting
```

### PR Requirements
```markdown
## Pull Requests
- All CI checks must pass
- Tests required for new features
- {coverage threshold}% coverage minimum
- Max {LOC limit} lines changed per PR
```

---

## Priority 5: Stack-Specific Gotchas

### Next.js App Router
```markdown
## Next.js Notes
- Use App Router (`app/`), not Pages Router
- Default to Server Components; add 'use client' only when needed
- Use `loading.tsx` for streaming, not manual loading states
- Data fetching in Server Components, not useEffect
```

### Laravel
```markdown
## Laravel Notes
- Use Eloquent query scopes for reusable query logic
- Use Form Requests for validation, not inline validation
- Use Resources for API responses
- Feature flags via Pennant: `Feature::active('name')`
- Queue long-running tasks, never in request lifecycle
```

### Rails
```markdown
## Rails Notes
- Use concerns for shared model behavior
- Use service objects for complex business logic
- Use Hotwire/Turbo for real-time features, not custom JS
- Database: always use `change` method in migrations for reversibility
```

### React + TypeScript
```markdown
## React Notes
- Functional components only (no class components)
- Use TypeScript strict mode
- Props interfaces: `interface {Component}Props {}`
- Prefer named exports over default exports
```

---

## Suggestion Template

When generating suggestions, use this template:

```markdown
## Suggestion {N}: {Section Name}

**Rationale**: {Why this helps Claude work more effectively with this project}
**Priority**: {1-5}
**Detected from**: {What in the stack profile triggered this suggestion}

**Add to CLAUDE.md:**

\```markdown
{Exact content to add}
\```
```
