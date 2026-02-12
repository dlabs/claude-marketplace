---
name: bp:compound
description: Document a solved problem for compound knowledge — 5 parallel agents extract context, solution, cross-references, prevention, and classification
---

# /blueprint-dev:bp:compound

Document a recently solved problem so it compounds into team knowledge. Uses 5 parallel agents to extract different facets of the problem and solution.

## Usage

```
/blueprint-dev:bp:compound
/blueprint-dev:bp:compound "token refresh race condition"
```

## Trigger

- Run manually after solving a problem
- Auto-suggested by the Stop hook when it detects confirmation phrases ("it works", "fixed", "that solved it")

## Workflow

### Step 1: Confirm Problem Was Solved
Ask the user to confirm:
- What was the problem?
- Is it fully resolved?
- Brief description (used for filename and title)

### Step 2: Parallel Agent Swarm
Launch 5 agents **in parallel** using the Task tool:

1. **context-analyzer** — Extract problem metadata (module, symptom, environment, timeline)
2. **solution-extractor** — Capture root cause and what fixed it (code changes)
3. **related-docs-finder** — Search `docs/solutions/` for similar past problems
4. **prevention-strategist** — Document how to prevent recurrence
5. **category-classifier** — Generate validated YAML frontmatter (category, severity, tags)

### Step 3: Assemble Document
Combine all agent outputs into a single document:

```markdown
---
{YAML frontmatter from category-classifier}
---

{Problem Context from context-analyzer}

{Root Cause from solution-extractor}

{Solution from solution-extractor}

{Prevention Strategy from prevention-strategist}

{Related Solutions from related-docs-finder}
```

### Step 4: Save
Create the file structure:
```
docs/solutions/{category}/{symptom}-{module}-{date}.md
```

Create directories if they don't exist.

### Step 5: Present and Offer Options
Show the user the document summary and offer:

1. **Continue working** — document is saved, done
2. **Promote to CLAUDE.md** — add the prevention strategy as a Required Reading section
3. **Link to issue/PR** — add references to related GitHub issues or PRs
4. **Create linting rule** — if the prevention strategist suggested one, help implement it
5. **Create regression test** — if the prevention strategist suggested one, help write it

## Notes

- The 5 agents run in parallel for speed
- All agents can read the conversation context to extract information
- The knowledge loop: `research-scout` in `/plan` reads these docs before planning
- Documents use validated YAML frontmatter for consistent searchability
- Category enum and tags are validated against the schema
