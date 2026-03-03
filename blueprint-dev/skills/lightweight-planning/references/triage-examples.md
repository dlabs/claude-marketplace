# Triage Examples

Concrete examples to calibrate the scope triage in `/bp:go`.

---

## Small Tweaks

These go straight to inline planning (3-5 bullet points, no plan doc).

### "Fix the date format on the invoice PDF"
- **Files**: 1-2 (date formatter, possibly a test)
- **LOC**: ~20
- **Why small**: Single formatting change, no new behavior
- **Plan**: Change date format in invoice template, update test assertion

### "Add aria-label to the search input"
- **Files**: 1 (component file)
- **LOC**: ~5
- **Why small**: Accessibility attribute addition, no logic change
- **Plan**: Add `aria-label` prop to search input element

### "Fix N+1 query on the users index page"
- **Files**: 1-2 (controller/query, possibly test)
- **LOC**: ~15
- **Why small**: Add eager loading, no new behavior
- **Plan**: Add `.includes(:posts)` to the query, verify with test

### "Update error message when file upload exceeds size limit"
- **Files**: 1-2 (validation, locale/translation file)
- **LOC**: ~10
- **Why small**: Copy change in a known location
- **Plan**: Update validation message string, check translations

### "Add loading spinner to the submit button"
- **Files**: 2-3 (component, possibly CSS, test)
- **LOC**: ~30
- **Why small**: UI polish, uses existing spinner component
- **Plan**: Add loading state to button, show spinner during submission

---

## Medium Features

These get a lightweight plan doc (`.blueprint/plans/{date}-{slug}-lite.md`).

### "Add CSV export to the reports API"
- **Files**: 6-8 (new endpoint, CSV builder, tests, possibly UI button)
- **LOC**: ~300
- **Why medium**: New endpoint with data transformation, but straightforward pattern
- **Feature flag**: No (backend utility, not user-facing behavior change)
- **Key decisions**: CSV library choice (use existing if available), column selection

### "Add pagination to the activity feed"
- **Files**: 5-7 (API endpoint, query changes, frontend component, tests)
- **LOC**: ~250
- **Why medium**: Touches backend and frontend, but pagination is a well-known pattern
- **Feature flag**: No (UX improvement, not new behavior)
- **Key decisions**: Cursor vs offset pagination, page size

### "Add email notification when a user is mentioned in a comment"
- **Files**: 6-10 (notification service, email template, event listener, tests)
- **LOC**: ~400
- **Why medium**: New behavior but clear scope — follows existing notification patterns
- **Feature flag**: Yes (new user-facing notification type)
- **Key decisions**: Sync vs async sending, batching for multiple mentions

### "Add dark mode toggle to user settings"
- **Files**: 8-12 (settings UI, theme context/provider, CSS variables, storage, tests)
- **LOC**: ~500
- **Why medium**: Touches many files but each change is small and mechanical
- **Feature flag**: Yes (new user-facing preference)
- **Key decisions**: CSS variables vs Tailwind dark:, persist in localStorage vs user profile

---

## Escalate to /bp:plan

These should use the full planning pipeline — too complex for `/bp:go`.

### "Add real-time notifications via WebSocket"
- **Files**: 15+ (WebSocket server, client, auth, channels, UI components, tests)
- **LOC**: 800+
- **Why escalate**: Architecture decision needed (WebSocket vs SSE vs polling), new infrastructure
- **Needs**: `/bp:architect` for technology choice, `/bp:plan` for phased rollout

### "Implement multi-tenant data isolation"
- **Files**: 20+ (middleware, queries, migrations, tests across all modules)
- **LOC**: 1000+
- **Why escalate**: Fundamental architecture change, security implications, data migration
- **Needs**: `/bp:architect` for isolation strategy, `/bp:plan` for migration plan, security review

### "Add Stripe payment integration for subscriptions"
- **Files**: 15+ (webhook handlers, models, API endpoints, UI, tests)
- **LOC**: 800+
- **Why escalate**: Security-critical (PCI), external service integration, subscription lifecycle
- **Needs**: `/bp:architect` for webhook design, `/bp:plan` for subscription states

### "Redesign the onboarding flow with A/B variants"
- **Files**: 10+ per variant
- **LOC**: 600+ per variant
- **Why escalate**: Needs `/bp:design` for variant creation and A/B test setup
- **Needs**: `/bp:design` for variants, `/bp:plan` for metrics and success criteria
