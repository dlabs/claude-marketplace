# Screen Design Specification

Complete specification for standalone HTML screen design variants generated during the Section Design phase. Screen designs represent **app screens within a shell** — not standalone pages.

---

## Key Difference from Variant Spec

Screen designs include **app shell chrome** (sidebar, top bar) to show how the screen looks in context. The variant-spec.md covers standalone pages; this spec covers screens within the application.

| Aspect | Variant Spec | Screen Design Spec |
|--------|-------------|-------------------|
| Chrome | None | Sidebar + top bar |
| Content source | User description | Section spec requirements |
| Layout | Full viewport | Content area within shell |
| Location | `.design/sessions/` | `.design/product/sections/{id}/screen-designs/.drafts/` |
| Manifest | Session manifest | Extended with `section_id`, `screen_name` |

---

## HTML Boilerplate Template

Every screen design variant MUST use this boilerplate structure. It includes the app shell chrome with sidebar and top bar placeholders:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="variant" content="VARIANT_ID" data-section="SECTION_ID" data-screen="SCREEN_NAME" data-approach="APPROACH_NAME">
  <title>SECTION_TITLE — SCREEN_NAME | PRODUCT_NAME</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            primary: 'var(--color-primary)',
            'primary-hover': 'var(--color-primary-hover)',
            secondary: 'var(--color-secondary)',
            background: 'var(--color-background)',
            surface: 'var(--color-surface)',
            'surface-elevated': 'var(--color-surface-elevated)',
            'text-primary': 'var(--color-text)',
            'text-muted': 'var(--color-text-muted)',
            border: 'var(--color-border)',
            success: 'var(--color-success)',
            error: 'var(--color-error)',
            'shell-bg': 'var(--color-shell-bg)',
            'shell-text': 'var(--color-shell-text)',
            'shell-active': 'var(--color-shell-active)',
          },
          fontFamily: {
            sans: 'var(--text-font-sans)',
            mono: 'var(--text-font-mono)',
          },
          borderRadius: {
            sm: 'var(--radius-sm)',
            md: 'var(--radius-md)',
            lg: 'var(--radius-lg)',
            xl: 'var(--radius-xl)',
          },
          boxShadow: {
            sm: 'var(--shadow-sm)',
            md: 'var(--shadow-md)',
            lg: 'var(--shadow-lg)',
          },
          width: {
            'sidebar': 'var(--shell-sidebar-width)',
          },
          height: {
            'topbar': 'var(--shell-topbar-height)',
          },
        },
      },
    }
  </script>
  <style>
    :root {
      /* ── Shell Layout ── */
      --shell-sidebar-width: 240px;
      --shell-topbar-height: 56px;

      /* ── Shell Colors ── */
      --color-shell-bg: #1e293b;
      --color-shell-text: #94a3b8;
      --color-shell-active: #ffffff;

      /* ── Colors ── */
      --color-primary: #6366f1;
      --color-primary-hover: #4f46e5;
      --color-secondary: #f59e0b;
      --color-background: #ffffff;
      --color-surface: #f8fafc;
      --color-surface-elevated: #ffffff;
      --color-text: #0f172a;
      --color-text-muted: #64748b;
      --color-border: #e2e8f0;
      --color-success: #22c55e;
      --color-error: #ef4444;

      /* ── Typography ── */
      --text-font-sans: 'Inter', system-ui, -apple-system, sans-serif;
      --text-font-mono: 'JetBrains Mono', ui-monospace, monospace;
      --text-xs: 0.75rem;
      --text-sm: 0.875rem;
      --text-base: 1rem;
      --text-lg: 1.125rem;
      --text-xl: 1.25rem;
      --text-2xl: 1.5rem;
      --text-3xl: 1.875rem;

      /* ── Spacing ── */
      --space-1: 0.25rem;
      --space-2: 0.5rem;
      --space-3: 0.75rem;
      --space-4: 1rem;
      --space-5: 1.25rem;
      --space-6: 1.5rem;
      --space-8: 2rem;
      --space-10: 2.5rem;
      --space-12: 3rem;
      --space-16: 4rem;

      /* ── Radii ── */
      --radius-sm: 0.25rem;
      --radius-md: 0.375rem;
      --radius-lg: 0.5rem;
      --radius-xl: 0.75rem;

      /* ── Shadows ── */
      --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
      --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
      --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
    }

    body {
      font-family: var(--text-font-sans);
      background-color: var(--color-background);
      color: var(--color-text);
      margin: 0;
      overflow: hidden;
      height: 100vh;
    }

    /* ── Shell Layout ── */
    .app-shell {
      display: flex;
      height: 100vh;
    }

    .shell-sidebar {
      width: var(--shell-sidebar-width);
      background: var(--color-shell-bg);
      color: var(--color-shell-text);
      flex-shrink: 0;
      display: flex;
      flex-direction: column;
      overflow-y: auto;
    }

    .shell-main {
      flex: 1;
      display: flex;
      flex-direction: column;
      overflow: hidden;
    }

    .shell-topbar {
      height: var(--shell-topbar-height);
      background: var(--color-surface-elevated);
      border-bottom: 1px solid var(--color-border);
      display: flex;
      align-items: center;
      padding: 0 var(--space-6);
      flex-shrink: 0;
    }

    .shell-content {
      flex: 1;
      overflow-y: auto;
      background: var(--color-background);
    }

    /* ── Sidebar Navigation ── */
    .nav-item {
      display: flex;
      align-items: center;
      gap: var(--space-3);
      padding: var(--space-2) var(--space-4);
      color: var(--color-shell-text);
      text-decoration: none;
      font-size: var(--text-sm);
      border-radius: var(--radius-md);
      margin: 0 var(--space-2);
      transition: background 0.15s, color 0.15s;
    }

    .nav-item:hover {
      background: rgba(255, 255, 255, 0.08);
      color: var(--color-shell-active);
    }

    .nav-item.active {
      background: rgba(255, 255, 255, 0.12);
      color: var(--color-shell-active);
      font-weight: 500;
    }

    /* ── Responsive: collapse sidebar on mobile ── */
    @media (max-width: 768px) {
      .shell-sidebar {
        display: none;
      }
    }
  </style>
</head>
<body>
  <div class="app-shell">
    <!-- Sidebar -->
    <aside class="shell-sidebar">
      <div style="padding: var(--space-4) var(--space-4) var(--space-6);">
        <div style="font-size: var(--text-lg); font-weight: 700; color: var(--color-shell-active);">
          PRODUCT_NAME
        </div>
      </div>
      <nav style="flex: 1;">
        <!-- Navigation items from shell spec -->
        <!-- Mark the current section's nav item with class="nav-item active" -->
        <a href="#" class="nav-item active">
          <span>ACTIVE_SECTION</span>
        </a>
        <a href="#" class="nav-item">
          <span>Other Section</span>
        </a>
      </nav>
    </aside>

    <!-- Main content area -->
    <div class="shell-main">
      <!-- Top bar -->
      <header class="shell-topbar">
        <div style="flex: 1; display: flex; align-items: center; gap: var(--space-3);">
          <span style="font-size: var(--text-sm); color: var(--color-text-muted);">BREADCRUMB</span>
          <span style="color: var(--color-text-muted);">/</span>
          <span style="font-size: var(--text-sm); font-weight: 500;">SCREEN_NAME</span>
        </div>
      </header>

      <!-- Screen content -->
      <main class="shell-content">
        <!-- SCREEN DESIGN GOES HERE -->
      </main>
    </div>
  </div>

  <script>
    // Vanilla JS for interactive elements
  </script>
</body>
</html>
```

---

## Shell Chrome Rules

The app shell chrome must be included in every variant to show the screen in context:

### Sidebar

- Use the exact width from shell spec (`--shell-sidebar-width`)
- List all navigation items from the shell spec
- Mark the current section as **active** with visual distinction
- Include the product name/logo at the top
- Sidebar is for context only — the design focus is the **content area**
- Collapse sidebar on mobile (below 768px)

### Top Bar

- Use the exact height from shell spec (`--shell-topbar-height`)
- Include breadcrumbs showing: Product > Section > Screen
- May include: search bar, user avatar, notification bell (if mentioned in shell spec)
- Keep top bar simple — it provides context, not core functionality

### Content Area

- This is where the actual screen design lives
- Uses `overflow-y: auto` for scrollable content
- Background matches `--color-background`
- Padding/margins are part of the design exploration (variants may differ)

### Shell vs. Screen Priority

The shell chrome is **functional context**, not the design focus. Spend 90% of design effort on the screen content area. The shell should be clean and consistent across all 3 variants — only the content area differs meaningfully between variants.

---

## CSS Custom Property Naming

Follows the same convention as `variant-spec.md` with these additions for shell:

| Prefix | Category | Examples |
|--------|----------|----------|
| `--shell-*` | Shell layout | `--shell-sidebar-width`, `--shell-topbar-height` |
| `--color-shell-*` | Shell colors | `--color-shell-bg`, `--color-shell-text`, `--color-shell-active` |
| `--color-surface-elevated` | Elevated surfaces | Top bar, cards, modals |

---

## Manifest Schema

Each screen design draft set must have a `manifest.json` in the drafts directory:

```json
{
  "section_id": "user-auth",
  "screen_name": "login",
  "prompt": "The user description or auto-generated context",
  "created_at": "2026-02-19T10:30:00Z",
  "tokens_locked": false,
  "locked_token_source": null,
  "shell_spec_used": true,
  "variants": [
    {
      "id": "a",
      "file": "variant-a.html",
      "description": "Centered login card with email/password fields and social login options",
      "approach": "centered-card",
      "differentiators": ["layout", "density"]
    },
    {
      "id": "b",
      "file": "variant-b.html",
      "description": "Split-panel with branding on left, login form on right",
      "approach": "split-panel",
      "differentiators": ["layout", "weight"]
    },
    {
      "id": "c",
      "file": "variant-c.html",
      "description": "Progressive login with email-first step, then password",
      "approach": "stepper-flow",
      "differentiators": ["interaction", "hierarchy"]
    }
  ]
}
```

**Additional fields (vs. session manifest):**
- `section_id`: The section this screen belongs to (matches directory name)
- `screen_name`: The screen name slug (matches drafts subdirectory name)
- `shell_spec_used`: Whether shell spec was available and used for chrome

**After pick**, the manifest is updated with:
```json
{
  "picked_variant": "b",
  "picked_at": "2026-02-19T11:00:00Z"
}
```

---

## Quality Requirements

All requirements from `variant-spec.md` apply, plus:

- [ ] Includes app shell chrome (sidebar + top bar)
- [ ] Sidebar navigation items match shell spec
- [ ] Active section is highlighted in sidebar
- [ ] Breadcrumbs show correct path
- [ ] Content area scrolls independently of shell
- [ ] Shell chrome is consistent across all 3 variants
- [ ] Screen content addresses the section spec's UI requirements
- [ ] Realistic data matches the section's domain

---

## Directory Structure

```
sections/{section-id}/
  spec.md                              # Section functional spec
  data.json                            # Optional sample data
  screen-designs/
    login.html                         # ← picked screen design
    signup.html                        # ← picked screen design
    .drafts/
      login/
        manifest.json                  # Draft manifest
        variant-a.html                 # Variant files
        variant-b.html
        variant-c.html
        chosen.html                    # Copy of picked variant (after pick)
        rejected/                      # Non-chosen variants (after pick)
          variant-a.html
          variant-c.html
      signup/
        manifest.json
        variant-a.html
        variant-b.html
        variant-c.html
```
