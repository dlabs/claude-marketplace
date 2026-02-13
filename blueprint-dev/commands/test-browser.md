---
name: bp:test-browser
description: Run browser tests on pages affected by current PR or branch
argument-hint: "[PR number, branch name, or 'current' for current branch]"
---

# /blueprint-dev:bp:test-browser

Run end-to-end browser tests on pages affected by a PR or branch changes using `agent-browser` CLI.

## Usage

```
/blueprint-dev:bp:test-browser
/blueprint-dev:bp:test-browser 847
/blueprint-dev:bp:test-browser feature/new-dashboard
```

## CRITICAL: Use agent-browser CLI Only

**DO NOT use Chrome MCP tools (mcp__claude-in-chrome__*) or Playwright MCP tools (mcp__plugin_playwright_playwright__*).**

This command uses the `agent-browser` CLI exclusively. It is a Bash-based tool from Vercel that runs headless Chromium. If you find yourself calling MCP browser tools, STOP. Use `agent-browser` Bash commands instead.

## Prerequisites

- Local development server running (e.g., `bin/dev`, `rails server`, `npm run dev`)
- `agent-browser` CLI installed (see Setup below)
- Git repository with changes to test

## Setup

```bash
command -v agent-browser >/dev/null 2>&1 && echo "Ready" || (echo "Installing..." && npm install -g agent-browser && agent-browser install)
```

See the `agent-browser` skill for detailed CLI reference.

## Workflow

### Step 1: Verify agent-browser Installation

Before starting ANY browser testing, verify agent-browser is installed:

```bash
command -v agent-browser >/dev/null 2>&1 && echo "Ready" || (echo "Installing..." && npm install -g agent-browser && agent-browser install)
```

If installation fails, inform the user and stop.

### Step 2: Ask Browser Mode

Before starting tests, ask user their preference:

Use AskUserQuestion with:
- Question: "Do you want to watch the browser tests run?"
- Options:
  1. **Headed (watch)** — Opens visible browser window so you can see tests run
  2. **Headless (faster)** — Runs in background, faster but invisible

Store the choice and use `--headed` flag when user selects "Headed".

### Step 3: Determine Test Scope

**Arguments:** $ARGUMENTS

**If PR number provided:**
```bash
gh pr view [number] --json files -q '.files[].path'
```

**If 'current' or empty:**
```bash
git diff --name-only main...HEAD
```

**If branch name provided:**
```bash
git diff --name-only main...[branch]
```

### Step 4: Map Files to Routes

Map changed files to testable routes:

| File Pattern | Route(s) |
|-------------|----------|
| `app/views/users/*` | `/users`, `/users/:id`, `/users/new` |
| `app/controllers/*_controller.rb` | Corresponding resource routes |
| `app/javascript/controllers/*_controller.js` | Pages using that Stimulus controller |
| `app/components/*_component.rb` | Pages rendering that component |
| `app/views/layouts/*` | All pages (test homepage at minimum) |
| `app/assets/stylesheets/*` | Visual regression on key pages |
| `app/helpers/*_helper.rb` | Pages using that helper |
| `src/app/*` (Next.js) | Corresponding routes |
| `src/pages/*` (Next.js pages dir) | Corresponding routes |
| `src/components/*` | Pages using those components |
| `templates/**` (Django) | Corresponding view URLs |

Build a list of URLs to test based on the mapping.

### Step 5: Verify Server is Running

Before testing, verify the local server is accessible:

```bash
agent-browser open http://localhost:3000
agent-browser snapshot -i
```

If server is not running, inform user:
```
Server not running. Please start your development server:
- Rails: `bin/dev` or `rails server`
- Node/Next.js: `npm run dev`
- Django: `python manage.py runserver`

Then run `/blueprint-dev:bp:test-browser` again.
```

### Step 6: Test Each Affected Page

For each affected route, use agent-browser CLI commands:

**Navigate and capture snapshot:**
```bash
agent-browser open "http://localhost:3000/[route]"
agent-browser snapshot -i
```

**For headed mode:**
```bash
agent-browser --headed open "http://localhost:3000/[route]"
agent-browser --headed snapshot -i
```

**Verify key elements:**
- Use `agent-browser snapshot -i` to get interactive elements with refs
- Page title/heading present
- Primary content rendered
- No error messages visible
- Forms have expected fields

**Test critical interactions:**
```bash
agent-browser click @e1  # Use ref from snapshot
agent-browser snapshot -i
```

**Take screenshots:**
```bash
agent-browser screenshot page-name.png
agent-browser screenshot --full page-name-full.png
```

### Step 7: Human Verification (When Required)

Pause for human input when testing touches:

| Flow Type | What to Ask |
|-----------|-------------|
| OAuth | "Please sign in with [provider] and confirm it works" |
| Email | "Check your inbox for the test email and confirm receipt" |
| Payments | "Complete a test purchase in sandbox mode" |
| SMS | "Verify you received the SMS code" |
| External APIs | "Confirm the [service] integration is working" |

Use AskUserQuestion for these verification steps.

### Step 8: Handle Failures

When a test fails:

1. **Document the failure:**
   - Screenshot the error state: `agent-browser screenshot error.png`
   - Note exact reproduction steps

2. **Ask user how to proceed:**
   - **Fix now** — investigate and fix the issue, then re-run the failing test
   - **Create todo** — log for later, continue testing
   - **Skip** — continue testing other pages

### Step 9: Test Summary

After all tests complete, present summary:

```markdown
## Browser Test Results

**Test Scope:** PR #[number] / [branch name]
**Server:** http://localhost:3000

### Pages Tested: [count]

| Route | Status | Notes |
|-------|--------|-------|
| `/users` | Pass | |
| `/settings` | Pass | |
| `/dashboard` | Fail | Console error: [msg] |

### Console Errors: [count]
### Human Verifications: [count]
### Failures: [count]
### Result: [PASS / FAIL / PARTIAL]
```

## agent-browser CLI Quick Reference

```bash
# Navigation
agent-browser open <url>
agent-browser back
agent-browser close

# Snapshots (get element refs)
agent-browser snapshot -i
agent-browser snapshot -i --json

# Interactions (use refs from snapshot)
agent-browser click @e1
agent-browser fill @e1 "text"
agent-browser type @e1 "text"
agent-browser press Enter

# Screenshots
agent-browser screenshot out.png
agent-browser screenshot --full out.png

# Headed mode (visible browser)
agent-browser --headed open <url>

# Wait
agent-browser wait @e1
agent-browser wait 2000
```
