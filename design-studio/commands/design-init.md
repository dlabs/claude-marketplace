---
name: ds:design-init
description: Initialize the design-studio workspace and configure gitignore preferences
---

# /design-studio:ds:design-init

Set up the `.design/` workspace directory and configure how design files interact with git.

## Usage

```
/design-studio:ds:design-init
```

## Workflow

### Step 1: Create Workspace

Run the init script:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-workspace.sh
```

This creates:
```
.design/
├── config.json
├── sessions/
└── DESIGN_NOTES.md
```

### Step 2: Configure Gitignore

Ask the user how they want to handle design files in git:

**Option 1: Ignore everything (default)**
- Add `.design/` to `.gitignore`
- Design exploration stays local — tokens and variants are not committed
- Best for: solo developers, experimental work

**Option 2: Track tokens only**
- Gitignore `.design/sessions/` but track `.design/tokens.json` and `.design/config.json`
- Tokens are shared with the team, but exploration sessions stay local
- Best for: teams that want consistent design language

**Option 3: Track everything**
- Don't add anything to `.gitignore`
- Full design history is committed
- Best for: teams that want design exploration documented in git

### Step 3: Apply Gitignore

Based on the user's choice, update `.gitignore`:

**Option 1 (default):**
```
# design-studio
.design/
```

**Option 2:**
```
# design-studio
.design/sessions/
.design/DESIGN_NOTES.md
```

**Option 3:**
No changes to `.gitignore`.

Update `.design/config.json` with the chosen `gitignore_mode`:
```json
{
  "version": "0.1.0",
  "gitignore_mode": "all|tokens-only|none",
  "created_at": "..."
}
```

### Step 4: Present Results

```
Workspace initialized!

  Directory: .design/
  Gitignore: {mode description}
  Config: .design/config.json

Ready to explore. Run:
  /design-studio:ds:design "description of what to build"
```

## Notes

- Running this command again is safe — it won't overwrite existing sessions or tokens
- You can change the gitignore mode at any time by running this command again
- The `.design/` directory is created in the current working directory (project root)
