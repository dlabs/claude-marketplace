# Stack Profile Template

The stack profile is saved to `.blueprint/stack-profile.json`. Use this template as the reference schema.

```json
{
  "detected_at": "2026-02-10T12:00:00Z",
  "project_root": "/absolute/path/to/project",
  "project_name": "my-project",
  "primary_language": "typescript",
  "secondary_languages": ["css", "sql"],
  "framework": {
    "name": "next.js",
    "version": "14.2.0",
    "variant": "app-router",
    "config_file": "next.config.ts"
  },
  "package_manager": "pnpm",
  "runtime": {
    "name": "node",
    "version": "20.11.0"
  },
  "build": {
    "bundler": "turbopack",
    "task_runner": "npm-scripts",
    "config_files": ["next.config.ts", "tsconfig.json", "postcss.config.js"]
  },
  "testing": {
    "unit": {
      "framework": "vitest",
      "config": "vitest.config.ts",
      "command": "pnpm test"
    },
    "integration": {
      "framework": "playwright",
      "config": "playwright.config.ts",
      "command": "pnpm test:e2e"
    },
    "coverage": {
      "tool": "v8",
      "threshold": 80,
      "command": "pnpm test:coverage"
    }
  },
  "linting": {
    "code": {
      "tool": "eslint",
      "config": "eslint.config.mjs",
      "command": "pnpm lint"
    },
    "formatting": {
      "tool": "prettier",
      "config": ".prettierrc",
      "command": "pnpm format"
    },
    "types": {
      "tool": "typescript",
      "strictness": "strict",
      "command": "pnpm type-check"
    }
  },
  "infrastructure": {
    "containerization": "docker-compose",
    "ci_cd": "github-actions",
    "deployment": "vercel",
    "database": {
      "primary": "postgresql",
      "orm": "prisma",
      "migration_command": "pnpm prisma migrate dev"
    }
  },
  "feature_flags": {
    "provider": "posthog",
    "integration_pattern": "sdk",
    "sdk_package": "posthog-js"
  },
  "monorepo": {
    "is_monorepo": false,
    "tool": "none",
    "packages": []
  },
  "conventions": {
    "file_naming": "kebab-case",
    "component_pattern": "function",
    "directory_structure": "feature-based",
    "api_style": "rest",
    "import_style": "absolute"
  },
  "architecture": {
    "state_management": "zustand",
    "auth_approach": "clerk",
    "realtime": "none",
    "api_layer": "fetch"
  },
  "detected_tools": [
    "node", "pnpm", "typescript", "nextjs", "react", "tailwindcss",
    "prisma", "postgresql", "vitest", "playwright", "eslint", "prettier",
    "docker", "github-actions", "vercel", "posthog"
  ]
}
```

## Field Rules

- Use `null` for fields that cannot be confidently detected
- Use `"none"` for fields where the absence is confirmed (e.g., no feature flags)
- `detected_tools` is a flat list used for quick lookups by other agents
- Version strings should be semver when available, `"X.x"` for major-only detection
- Commands should be the actual CLI commands from scripts/Makefile (e.g., `pnpm test`, not `vitest`)
