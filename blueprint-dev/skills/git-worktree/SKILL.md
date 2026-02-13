---
name: git-worktree
description: Git worktree management for isolated parallel development. Handles creating, listing, switching, and cleaning up worktrees with interactive confirmations, automatic .env copying, and .gitignore management. Follows KISS principles.
---

# Git Worktree Manager

Unified interface for managing Git worktrees across your development workflow. Whether reviewing PRs in isolation or working on features in parallel, this skill handles all the complexity.

## What This Skill Does

- **Create worktrees** from a base branch with clear branch names
- **List worktrees** with current status
- **Switch between worktrees** for parallel work
- **Clean up completed worktrees** automatically
- **Automatic .gitignore management** for `.worktrees/` directory
- **Automatic .env file copying** from main repo to new worktrees

## CRITICAL: Always Use the Manager Script

**NEVER call `git worktree add` directly.** Always use the `worktree-manager.sh` script.

The script handles critical setup that raw git commands don't:
1. Copies `.env`, `.env.local`, `.env.test`, etc. from main repo
2. Ensures `.worktrees` is in `.gitignore`
3. Creates consistent directory structure

```bash
# CORRECT - Always use the script
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh create feature-name

# WRONG - Never do this directly
git worktree add .worktrees/feature-name -b feature-name main
```

## When to Use This Skill

1. **Code Review (`/blueprint-dev:bp:review`)**: If NOT already on the target branch, offer worktree for isolated review
2. **Feature Work (`/blueprint-dev:bp:build`)**: Ask if user wants parallel worktree or live branch work
3. **Parallel Development**: When working on multiple features simultaneously
4. **Cleanup**: After completing work in a worktree

## Commands

### `create <branch-name> [from-branch]`

Creates a new worktree with the given branch name.

- `branch-name` (required): Name for the new branch and worktree
- `from-branch` (optional): Base branch to create from (defaults to `main`)

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh create feature-login
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh create feature-auth develop
```

**What happens:**
1. Checks if worktree already exists
2. Updates the base branch from remote
3. Creates new worktree and branch
4. Copies all .env files from main repo (.env, .env.local, .env.test, etc.)
5. Shows path for cd-ing to the worktree

### `list` or `ls`

Lists all available worktrees with their branches and current status.

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh list
```

### `switch <name>` or `go <name>`

Switches to an existing worktree.

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh switch feature-login
```

If name not provided, lists available worktrees and prompts for selection.

### `copy-env [name]` or `env [name]`

Copies .env files from main repo to an existing worktree. If name is omitted and you're inside a worktree, copies to the current worktree.

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh copy-env feature-login
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh copy-env  # copies to current worktree
```

### `cleanup` or `clean`

Interactively cleans up inactive worktrees with confirmation.

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh cleanup
```

**What happens:**
1. Lists all inactive worktrees
2. Asks for confirmation
3. Removes selected worktrees
4. Cleans up empty directories

## Workflow Integration

### With `/blueprint-dev:bp:review`

```
1. Check current branch
2. If ALREADY on target branch → stay there, no worktree needed
3. If DIFFERENT branch → offer worktree:
   "Use worktree for isolated review? (y/n)"
   - yes → call git-worktree skill to create worktree
   - no → proceed with PR diff on current branch
```

### With `/blueprint-dev:bp:build`

```
1. Ask: "How do you want to work?"
   1. New branch on current worktree (live work)
   2. Worktree (parallel work)

2. If choice 1 → create new branch normally
3. If choice 2 → call git-worktree skill to create from main
```

## Workflow Examples

### Code Review with Worktree

```bash
# Create isolated worktree for review (copies .env files)
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh create pr-123-feature-name
cd .worktrees/pr-123-feature-name

# After review, return to main and clean up
cd ../..
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh cleanup
```

### Parallel Feature Development

```bash
# Start first feature
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh create feature-login

# Start second feature
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh create feature-notifications

# List and switch between them
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh list
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh switch feature-login
```

## Key Design Principles

### KISS (Keep It Simple)
- **One manager script** handles all worktree operations
- **Simple commands** with sensible defaults
- **Interactive prompts** prevent accidental operations

### Opinionated Defaults
- Worktrees always created from **main** (unless specified)
- Worktrees stored in **.worktrees/** directory
- Branch name becomes worktree name
- **.gitignore** automatically managed

### Safety First
- Confirms before creating worktrees
- Confirms before cleanup to prevent accidental removal
- Won't remove current worktree
- Clear error messages

## Troubleshooting

### "Worktree already exists"
The script will ask if you want to switch to it instead.

### "Cannot remove worktree: it is the current worktree"
Switch out of the worktree first:
```bash
cd $(git rev-parse --show-toplevel)
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh cleanup
```

### .env files missing in worktree?
Copy them manually:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/git-worktree/scripts/worktree-manager.sh copy-env feature-name
```

## Technical Details

### Directory Structure

```
.worktrees/
├── feature-login/          # Worktree 1
│   ├── .git
│   ├── app/
│   └── ...
├── feature-notifications/  # Worktree 2
│   ├── .git
│   ├── app/
│   └── ...

.gitignore (updated to include .worktrees)
```

### How It Works
- Uses `git worktree add` for isolated environments
- Each worktree has its own branch
- Changes in one worktree don't affect others
- Shared git history with main repo
- Can push from any worktree

### Performance
- Worktrees are lightweight (file system links)
- No repository duplication
- Shared git objects for efficiency
- Much faster than cloning or stashing/switching
