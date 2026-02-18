---
name: ds:studio-open
description: Launch the Design Studio viewer app in your browser
---

# /design-studio:ds:studio-open

Launch the Design Studio web viewer to visually browse sessions, compare variants, and inspect tokens in the browser.

## Usage

```
/design-studio:ds:studio-open        # Start the viewer
/design-studio:ds:studio-open stop   # Stop the viewer
/design-studio:ds:studio-open status # Check if running
```

## Workflow

### Step 1: Check Workspace

Verify `.design/` exists:
```bash
if [ ! -d ".design" ]; then
  echo "No workspace found."
fi
```

If not found, tell the user:
```
No design-studio workspace found.
Run /design-studio:ds:design-init to set up.
```

### Step 2: Launch Server

Run the studio server script:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/studio-server.sh start .design
```

Parse the output:
- `ALREADY_RUNNING` — The studio is already running, skip to Step 3
- `STARTING` / `READY` — Server started successfully
- `ERROR: *` — Show the error message to the user

### Step 3: Open Browser

Once the server reports `READY` or `ALREADY_RUNNING`, open the browser:
```bash
open http://localhost:5173
```

On Linux, use `xdg-open` instead of `open`.

### Step 4: Report

Tell the user:
```
Design Studio is running:
  Viewer: http://localhost:5173
  API:    http://localhost:4200

The viewer will live-refresh when .design/ files change.
Run /design-studio:ds:studio-open stop to shut it down.
```

## Stop Command

If the user runs `/design-studio:ds:studio-open stop`:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/studio-server.sh stop
```

## Status Command

If the user runs `/design-studio:ds:studio-open status`:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/studio-server.sh status
```

## Notes

- The viewer is **read-only** — it does not modify `.design/` files
- File changes made by Claude Code agents trigger automatic refresh via WebSocket
- The server runs on port 4200, the viewer on port 5173
- PID is stored at `/tmp/design-studio-server.pid`
- Logs are at `/tmp/design-studio-server.log`
- Set `DESIGN_STUDIO_APP_PATH` if the app is not in the default location
