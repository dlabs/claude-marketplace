# Stack Fingerprints

100+ technology fingerprints for stack detection. Each entry has: primary signal, confirming signals, version detection, and variant detection.

---

## JavaScript/TypeScript Runtimes

### Node.js
- **Primary**: `package.json` exists
- **Confirming**: `.nvmrc`, `.node-version`, `engines.node` in package.json
- **Version**: Read `.nvmrc` or `engines.node`
- **Variants**: CommonJS (no `"type": "module"`), ESM (`"type": "module"`)

### Bun
- **Primary**: `bun.lockb` or `bunfig.toml`
- **Confirming**: `bun` in scripts, `.bun` directory
- **Version**: `bun --version` or `engines.bun`

### Deno
- **Primary**: `deno.json` or `deno.jsonc`
- **Confirming**: `import_map.json`, URLs in imports

---

## Frontend Frameworks

### React
- **Primary**: `react` in dependencies
- **Confirming**: `.jsx`/`.tsx` files, `ReactDOM.render` or `createRoot`
- **Version**: `dependencies.react` in package.json
- **Variants**: CRA, Vite-React, custom

### Next.js
- **Primary**: `next` in dependencies + `next.config.*`
- **Confirming**: `pages/` or `app/` directory, `_app.tsx`, `layout.tsx`
- **Version**: `dependencies.next`
- **Variants**:
  - App Router: `app/` dir with `layout.tsx`
  - Pages Router: `pages/` dir with `_app.tsx`
  - Hybrid: both `app/` and `pages/`

### Vue
- **Primary**: `vue` in dependencies
- **Confirming**: `.vue` files, `createApp`
- **Version**: `dependencies.vue` (2.x vs 3.x)
- **Variants**: Options API, Composition API, `<script setup>`

### Nuxt
- **Primary**: `nuxt` in dependencies + `nuxt.config.*`
- **Confirming**: `pages/`, `composables/`, `server/`
- **Version**: `dependencies.nuxt`
- **Variants**: Nuxt 3 (default), Nuxt 2 (legacy)

### Svelte / SvelteKit
- **Primary**: `svelte` in dependencies
- **Confirming**: `.svelte` files, `svelte.config.js`
- **Variants**: SvelteKit (`@sveltejs/kit`), standalone Svelte

### Angular
- **Primary**: `@angular/core` in dependencies + `angular.json`
- **Confirming**: `.component.ts` files, `NgModule` or `@Component`
- **Version**: `dependencies.@angular/core`
- **Variants**: Standalone components (v15+), NgModule-based

### Astro
- **Primary**: `astro` in dependencies + `astro.config.*`
- **Confirming**: `.astro` files, `src/pages/`

### Remix
- **Primary**: `@remix-run/react` in dependencies
- **Confirming**: `root.tsx`, `routes/` directory

### SolidJS
- **Primary**: `solid-js` in dependencies
- **Confirming**: `.tsx` with `createSignal`, `createEffect`

---

## Backend Frameworks

### Laravel
- **Primary**: `artisan` file + `laravel/framework` in composer.json
- **Confirming**: `app/Http/Controllers/`, `routes/web.php`, `config/app.php`
- **Version**: `require.laravel/framework` in composer.json
- **Variants**:
  - Monolith: `resources/views/` with Blade
  - API-only: `routes/api.php` dominant
  - Inertia: `inertiajs/inertia-laravel` in composer.json
  - Livewire: `livewire/livewire` in composer.json
  - Filament: `filament/filament` in composer.json

### Rails
- **Primary**: `Gemfile` with `rails` + `config/routes.rb`
- **Confirming**: `app/controllers/`, `app/models/`, `db/schema.rb`
- **Version**: `Gemfile` rails version
- **Variants**:
  - API-only: `config/application.rb` with `api_only`
  - Hotwire/Turbo: `turbo-rails` in Gemfile
  - Importmap: `importmap-rails` in Gemfile

### Django
- **Primary**: `manage.py` + `django` in requirements
- **Confirming**: `settings.py`, `urls.py`, `wsgi.py`
- **Version**: `django==X.Y` in requirements
- **Variants**: DRF (`djangorestframework`), Channels, standard

### Express
- **Primary**: `express` in dependencies
- **Confirming**: `app.use`, `app.get`, `app.listen` in source
- **Variants**: Plain Express, with TypeScript, with Passport

### Fastify
- **Primary**: `fastify` in dependencies
- **Confirming**: `fastify.register`, route schemas

### NestJS
- **Primary**: `@nestjs/core` in dependencies
- **Confirming**: `.module.ts`, `.controller.ts`, `.service.ts` files

### Spring Boot
- **Primary**: `spring-boot-starter` in build.gradle or pom.xml
- **Confirming**: `@SpringBootApplication`, `application.properties`

### Phoenix (Elixir)
- **Primary**: `mix.exs` with `phoenix`
- **Confirming**: `lib/{app}_web/`, `router.ex`

### FastAPI
- **Primary**: `fastapi` in requirements/pyproject
- **Confirming**: `@app.get`, `@app.post` decorators

### Gin (Go)
- **Primary**: `github.com/gin-gonic/gin` in go.mod
- **Confirming**: `gin.Default()`, `r.GET` in source

---

## CSS & Styling

### Tailwind CSS
- **Primary**: `tailwindcss` in devDependencies + `tailwind.config.*`
- **Confirming**: `@tailwind` directives, utility classes in templates
- **Version**: v3 (`content:[]` in config) vs v4 (`@import "tailwindcss"`)

### Sass/SCSS
- **Primary**: `sass` or `node-sass` in dependencies
- **Confirming**: `.scss` or `.sass` files

### CSS Modules
- **Primary**: `.module.css` or `.module.scss` files
- **Confirming**: `import styles from` patterns

### Styled Components
- **Primary**: `styled-components` in dependencies
- **Confirming**: `` styled.div` `` template literals

### CSS-in-JS (Emotion)
- **Primary**: `@emotion/react` in dependencies
- **Confirming**: `css` prop, `styled()` calls

---

## State Management

### Redux / RTK
- **Primary**: `@reduxjs/toolkit` or `redux` in dependencies
- **Confirming**: `createSlice`, `configureStore`, `useSelector`

### Zustand
- **Primary**: `zustand` in dependencies
- **Confirming**: `create()` stores

### Jotai
- **Primary**: `jotai` in dependencies
- **Confirming**: `atom()`, `useAtom()`

### TanStack Query
- **Primary**: `@tanstack/react-query` in dependencies
- **Confirming**: `useQuery`, `useMutation`, `QueryClient`

### Pinia (Vue)
- **Primary**: `pinia` in dependencies
- **Confirming**: `defineStore()`

---

## Database & ORM

### Prisma
- **Primary**: `prisma/schema.prisma` + `@prisma/client`
- **Confirming**: `npx prisma` in scripts

### Drizzle
- **Primary**: `drizzle-orm` in dependencies + `drizzle.config.*`
- **Confirming**: `drizzle/` directory with schema files

### Eloquent (Laravel)
- **Primary**: Laravel detected + `database/migrations/`
- **Confirming**: `extends Model` in PHP files

### Active Record (Rails)
- **Primary**: Rails detected + `db/migrate/`
- **Confirming**: `< ApplicationRecord` in models

### TypeORM
- **Primary**: `typeorm` in dependencies
- **Confirming**: `@Entity()`, `@Column()` decorators

### Sequelize
- **Primary**: `sequelize` in dependencies
- **Confirming**: `sequelize.define`, migration files

### SQLAlchemy
- **Primary**: `sqlalchemy` in requirements
- **Confirming**: `Base = declarative_base()`, `session.query`

---

## Testing

### Jest
- **Primary**: `jest` in devDependencies + `jest.config.*`
- **Confirming**: `describe`, `it`, `expect` in test files

### Vitest
- **Primary**: `vitest` in devDependencies + `vitest.config.*`
- **Confirming**: `import { describe, it, expect } from 'vitest'`

### PHPUnit
- **Primary**: `phpunit.xml` + `phpunit/phpunit` in composer
- **Confirming**: `extends TestCase` in PHP test files

### RSpec
- **Primary**: `rspec-rails` in Gemfile + `spec/` directory
- **Confirming**: `describe`, `it`, `expect()` in spec files

### Pytest
- **Primary**: `pytest` in requirements + `tests/` or `test_*.py`
- **Confirming**: `def test_`, `@pytest.fixture`

### Cypress
- **Primary**: `cypress` in devDependencies + `cypress.config.*`
- **Confirming**: `cypress/` directory

### Playwright
- **Primary**: `@playwright/test` in devDependencies + `playwright.config.*`
- **Confirming**: `tests/` with `.spec.ts`

### Testing Library
- **Primary**: `@testing-library/react` (or /vue, /angular) in devDependencies
- **Confirming**: `render`, `screen`, `userEvent` in tests

---

## CI/CD & Deployment

### GitHub Actions
- **Primary**: `.github/workflows/*.yml`
- **Confirming**: `on: push`, `jobs:`, `runs-on:`

### GitLab CI
- **Primary**: `.gitlab-ci.yml`
- **Confirming**: `stages:`, `script:`

### Vercel
- **Primary**: `vercel.json` or `.vercel/`
- **Confirming**: `VERCEL` env vars

### Docker
- **Primary**: `Dockerfile`
- **Confirming**: `docker-compose.yml`, `.dockerignore`

### Kubernetes
- **Primary**: `k8s/` or `.kubernetes/` directory
- **Confirming**: `deployment.yaml`, `service.yaml`

---

## Feature Flags

### PostHog
- **Primary**: `posthog-js` or `posthog-node` in dependencies
- **Confirming**: `posthog.capture`, `posthog.isFeatureEnabled`

### LaunchDarkly
- **Primary**: `launchdarkly-js-client-sdk` or server SDK
- **Confirming**: `ldClient.variation`

### Unleash
- **Primary**: `unleash-client` or `unleash-proxy-client`
- **Confirming**: `unleash.isEnabled`

### Laravel Pennant
- **Primary**: `laravel/pennant` in composer.json
- **Confirming**: `Feature::active()`, `Feature::define()`, `app/Features/`

### Flipper (Rails)
- **Primary**: `flipper` in Gemfile
- **Confirming**: `Flipper.enabled?`

### Environment Variable Flags
- **Primary**: `FEATURE_*` or `FF_*` patterns in `.env` or code
- **Confirming**: `process.env.FEATURE_*` or `env('FEATURE_*')` in source

---

## Monorepo Tools

### Turborepo
- **Primary**: `turbo.json`
- **Confirming**: `turbo` in devDependencies

### Nx
- **Primary**: `nx.json`
- **Confirming**: `@nx/` packages

### Lerna
- **Primary**: `lerna.json`
- **Confirming**: `lerna` in devDependencies

### pnpm Workspaces
- **Primary**: `pnpm-workspace.yaml`
- **Confirming**: `packages:` entries

### Yarn Workspaces
- **Primary**: `"workspaces"` in package.json
- **Confirming**: Multiple `package.json` in subdirectories

---

## Code Quality

### ESLint
- **Primary**: `.eslintrc.*` or `eslint.config.*` (flat config)
- **Version**: v8 (`.eslintrc.*`) vs v9 (`eslint.config.*`)

### Prettier
- **Primary**: `.prettierrc*` or `prettier` in package.json
- **Confirming**: `.prettierignore`

### PHP-CS-Fixer / Pint
- **Primary**: `.php-cs-fixer.php` or `pint.json`
- **Confirming**: `laravel/pint` in composer

### PHPStan
- **Primary**: `phpstan.neon` or `phpstan.neon.dist`
- **Level**: Read `level:` from config (0-9 or max)

### Biome
- **Primary**: `biome.json`
- **Confirming**: `@biomejs/biome` in devDependencies

### Husky (Git Hooks)
- **Primary**: `.husky/` directory
- **Confirming**: `husky` in devDependencies, `prepare` script
