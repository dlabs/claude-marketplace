#!/usr/bin/env bash
# detect-stack.sh — Quick stack detection for SessionStart hook
# Outputs a brief systemMessage with detected stack info
# Full deep analysis is done by the stack-detective agent via /blueprint-dev:bp:discover

set -euo pipefail

PROJECT_ROOT="${PWD}"
DETECTED=()

# ── Package Managers & Runtimes ──
[ -f "$PROJECT_ROOT/package.json" ] && DETECTED+=("node")
[ -f "$PROJECT_ROOT/bun.lockb" ] && DETECTED+=("bun")
[ -f "$PROJECT_ROOT/pnpm-lock.yaml" ] && DETECTED+=("pnpm")
[ -f "$PROJECT_ROOT/yarn.lock" ] && DETECTED+=("yarn")
[ -f "$PROJECT_ROOT/composer.json" ] && DETECTED+=("php/composer")
[ -f "$PROJECT_ROOT/Gemfile" ] && DETECTED+=("ruby/bundler")
[ -f "$PROJECT_ROOT/requirements.txt" ] || [ -f "$PROJECT_ROOT/pyproject.toml" ] && DETECTED+=("python")
[ -f "$PROJECT_ROOT/go.mod" ] && DETECTED+=("go")
[ -f "$PROJECT_ROOT/Cargo.toml" ] && DETECTED+=("rust")
[ -f "$PROJECT_ROOT/build.gradle" ] || [ -f "$PROJECT_ROOT/build.gradle.kts" ] && DETECTED+=("gradle")
[ -f "$PROJECT_ROOT/pom.xml" ] && DETECTED+=("maven")

# ── Frameworks ──
[ -f "$PROJECT_ROOT/next.config.js" ] || [ -f "$PROJECT_ROOT/next.config.mjs" ] || [ -f "$PROJECT_ROOT/next.config.ts" ] && DETECTED+=("nextjs")
[ -f "$PROJECT_ROOT/nuxt.config.ts" ] || [ -f "$PROJECT_ROOT/nuxt.config.js" ] && DETECTED+=("nuxt")
[ -f "$PROJECT_ROOT/svelte.config.js" ] && DETECTED+=("svelte")
[ -f "$PROJECT_ROOT/angular.json" ] && DETECTED+=("angular")
[ -f "$PROJECT_ROOT/artisan" ] && DETECTED+=("laravel")
[ -f "$PROJECT_ROOT/config/routes.rb" ] && DETECTED+=("rails")
[ -f "$PROJECT_ROOT/manage.py" ] && DETECTED+=("django")
[ -f "$PROJECT_ROOT/mix.exs" ] && DETECTED+=("elixir")

# ── Infrastructure ──
[ -f "$PROJECT_ROOT/Dockerfile" ] || [ -f "$PROJECT_ROOT/docker-compose.yml" ] || [ -f "$PROJECT_ROOT/docker-compose.yaml" ] && DETECTED+=("docker")
[ -f "$PROJECT_ROOT/.github/workflows/"*.yml ] 2>/dev/null && DETECTED+=("github-actions")
[ -f "$PROJECT_ROOT/.gitlab-ci.yml" ] && DETECTED+=("gitlab-ci")
[ -f "$PROJECT_ROOT/terraform/"*.tf ] 2>/dev/null && DETECTED+=("terraform")
[ -d "$PROJECT_ROOT/.kubernetes" ] || [ -d "$PROJECT_ROOT/k8s" ] && DETECTED+=("kubernetes")
[ -f "$PROJECT_ROOT/vercel.json" ] && DETECTED+=("vercel")

# ── Testing ──
[ -f "$PROJECT_ROOT/jest.config.js" ] || [ -f "$PROJECT_ROOT/jest.config.ts" ] && DETECTED+=("jest")
[ -f "$PROJECT_ROOT/vitest.config.ts" ] || [ -f "$PROJECT_ROOT/vitest.config.js" ] && DETECTED+=("vitest")
[ -f "$PROJECT_ROOT/phpunit.xml" ] && DETECTED+=("phpunit")
[ -f "$PROJECT_ROOT/cypress.config.js" ] || [ -f "$PROJECT_ROOT/cypress.config.ts" ] && DETECTED+=("cypress")
[ -f "$PROJECT_ROOT/playwright.config.ts" ] && DETECTED+=("playwright")

# ── Feature Flags ──
grep -rql "posthog" "$PROJECT_ROOT/package.json" "$PROJECT_ROOT/composer.json" 2>/dev/null && DETECTED+=("posthog")
grep -rql "launchdarkly" "$PROJECT_ROOT/package.json" "$PROJECT_ROOT/composer.json" 2>/dev/null && DETECTED+=("launchdarkly")
grep -rql "unleash" "$PROJECT_ROOT/package.json" "$PROJECT_ROOT/composer.json" 2>/dev/null && DETECTED+=("unleash")
[ -d "$PROJECT_ROOT/app/Features" ] || grep -rql "Laravel\\\\Pennant" "$PROJECT_ROOT/composer.json" 2>/dev/null && DETECTED+=("pennant")

# ── Database ──
grep -rql "mysql\|mariadb" "$PROJECT_ROOT/.env" 2>/dev/null && DETECTED+=("mysql")
grep -rql "pgsql\|postgresql\|postgres" "$PROJECT_ROOT/.env" 2>/dev/null && DETECTED+=("postgresql")
grep -rql "sqlite" "$PROJECT_ROOT/.env" 2>/dev/null && DETECTED+=("sqlite")
[ -f "$PROJECT_ROOT/prisma/schema.prisma" ] && DETECTED+=("prisma")

# ── Monorepo ──
[ -f "$PROJECT_ROOT/lerna.json" ] && DETECTED+=("lerna")
[ -f "$PROJECT_ROOT/nx.json" ] && DETECTED+=("nx")
[ -f "$PROJECT_ROOT/turbo.json" ] && DETECTED+=("turborepo")
[ -d "$PROJECT_ROOT/packages" ] && DETECTED+=("monorepo-packages")

# ── Output ──
if [ ${#DETECTED[@]} -eq 0 ]; then
  echo "[blueprint-dev] No recognized stack detected. Run /blueprint-dev:bp:discover for deep analysis."
else
  STACK_LIST=$(IFS=', '; echo "${DETECTED[*]}")
  echo "[blueprint-dev] Detected stack: ${STACK_LIST}. Run /blueprint-dev:bp:discover for full profile + CLAUDE.md suggestions."
fi
