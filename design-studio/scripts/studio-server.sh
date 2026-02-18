#!/usr/bin/env bash
# studio-server.sh — Start/stop the Design Studio viewer app
# Usage:
#   bash studio-server.sh start [workspace-path]
#   bash studio-server.sh stop
#   bash studio-server.sh status

set -euo pipefail

PROJECT_ROOT="${PWD}"
PID_FILE="/tmp/design-studio-server.pid"
LOG_FILE="/tmp/design-studio-server.log"

# Where is the design-studio-app installed?
# Priority: DESIGN_STUDIO_APP_PATH env > sibling of plugin > sibling of plugin marketplace
find_app_path() {
  if [[ -n "${DESIGN_STUDIO_APP_PATH:-}" ]]; then
    echo "$DESIGN_STUDIO_APP_PATH"
    return
  fi

  # Resolve relative to CLAUDE_PLUGIN_ROOT (set by Claude Code)
  local plugin_root="${CLAUDE_PLUGIN_ROOT:-}"
  if [[ -n "$plugin_root" ]]; then
    # Plugin is at: .../claude-marketplace/design-studio
    # App could be at: .../design-studio-app
    local marketplace_parent
    marketplace_parent="$(dirname "$(dirname "$plugin_root")")"
    if [[ -f "${marketplace_parent}/design-studio-app/package.json" ]]; then
      echo "${marketplace_parent}/design-studio-app"
      return
    fi
  fi

  echo ""
}

cmd_start() {
  local workspace_path="${1:-${PROJECT_ROOT}/.design}"

  # Resolve to absolute path
  if [[ ! "$workspace_path" = /* ]]; then
    workspace_path="${PROJECT_ROOT}/${workspace_path}"
  fi

  if [[ ! -d "$workspace_path" ]]; then
    echo "ERROR: Workspace not found at ${workspace_path}"
    echo "Run /design-studio:ds:design-init first."
    exit 1
  fi

  # Check if already running
  if [[ -f "$PID_FILE" ]]; then
    local old_pid
    old_pid=$(cat "$PID_FILE")
    if kill -0 "$old_pid" 2>/dev/null; then
      echo "ALREADY_RUNNING"
      echo "PID: ${old_pid}"
      echo "URL: http://localhost:5173"
      exit 0
    else
      rm -f "$PID_FILE"
    fi
  fi

  local app_path
  app_path="$(find_app_path)"

  if [[ -z "$app_path" || ! -f "${app_path}/package.json" ]]; then
    echo "ERROR: design-studio-app not found."
    echo "Set DESIGN_STUDIO_APP_PATH to the app directory."
    exit 1
  fi

  # Check dependencies are installed
  if [[ ! -d "${app_path}/node_modules" ]]; then
    echo "INSTALLING_DEPS"
    cd "$app_path"
    COREPACK_ENABLE_STRICT=0 pnpm install --frozen-lockfile 2>&1 || COREPACK_ENABLE_STRICT=0 pnpm install 2>&1
  fi

  # Build shared package (required before dev)
  echo "BUILDING_SHARED"
  cd "$app_path"
  COREPACK_ENABLE_STRICT=0 pnpm --filter @design-studio/shared build 2>&1

  # Start dev servers
  echo "STARTING"
  cd "$app_path"
  COREPACK_ENABLE_STRICT=0 WORKSPACE_PATH="$workspace_path" pnpm dev > "$LOG_FILE" 2>&1 &
  local dev_pid=$!
  echo "$dev_pid" > "$PID_FILE"

  # Wait for servers to be ready
  local attempts=0
  local max_attempts=30
  while [[ $attempts -lt $max_attempts ]]; do
    if curl -sf http://localhost:4200/api/health > /dev/null 2>&1; then
      echo "READY"
      echo "PID: ${dev_pid}"
      echo "URL: http://localhost:5173"
      echo "API: http://localhost:4200"
      echo "WORKSPACE: ${workspace_path}"
      exit 0
    fi
    sleep 1
    attempts=$((attempts + 1))

    # Check if process died
    if ! kill -0 "$dev_pid" 2>/dev/null; then
      echo "ERROR: Server process died. Check ${LOG_FILE}"
      rm -f "$PID_FILE"
      exit 1
    fi
  done

  echo "ERROR: Server did not become ready within ${max_attempts}s"
  echo "Check ${LOG_FILE} for details"
  kill "$dev_pid" 2>/dev/null || true
  rm -f "$PID_FILE"
  exit 1
}

cmd_stop() {
  if [[ ! -f "$PID_FILE" ]]; then
    echo "NOT_RUNNING"
    exit 0
  fi

  local pid
  pid=$(cat "$PID_FILE")

  # Kill the process tree (concurrently spawns children)
  if kill -0 "$pid" 2>/dev/null; then
    # Kill the process group, fall back to single PID
    kill -- -"$pid" 2>/dev/null || kill "$pid" 2>/dev/null || true
    echo "STOPPED"
  else
    echo "ALREADY_STOPPED"
  fi

  rm -f "$PID_FILE"
}

cmd_status() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      echo "RUNNING"
      echo "PID: ${pid}"

      if curl -sf http://localhost:4200/api/health > /dev/null 2>&1; then
        echo "HEALTH: ok"
        echo "URL: http://localhost:5173"
      else
        echo "HEALTH: unhealthy"
      fi
      exit 0
    fi
  fi

  echo "NOT_RUNNING"
}

case "${1:-status}" in
  start)
    shift
    cmd_start "${1:-}"
    ;;
  stop)
    cmd_stop
    ;;
  status)
    cmd_status
    ;;
  *)
    echo "Usage: studio-server.sh {start|stop|status} [workspace-path]"
    exit 1
    ;;
esac
