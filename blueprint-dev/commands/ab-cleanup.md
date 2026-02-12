---
name: ab-cleanup
description: Remove losing A/B variant, promote winner, clean up feature flags and tracking code
argument-hint: A/B test name
---

# /blueprint-dev:ab-cleanup

Execute the cleanup plan from an A/B test decision. Removes the losing variant, promotes the winner, and cleans up feature flags and tracking code.

## Usage

```
/blueprint-dev:ab-cleanup "login-page"
/blueprint-dev:ab-cleanup   # (will list decided tests needing cleanup)
```

## Prerequisites

- Must have a `docs/ab-tests/{test-name}/DECISION.md` (run `/blueprint-dev:ab-decide` first)

## Workflow

### Step 1: Read Decision
Read `docs/ab-tests/{test-name}/DECISION.md` for the cleanup plan.

### Step 2: Confirm Plan
Show the user exactly what will happen:
- Which variant is being promoted
- Which files will be renamed/modified
- Which files will be deleted
- What imports will change

**Get explicit user confirmation before proceeding.**

### Step 3: Execute Cleanup

Follow the cleanup plan from the DECISION.md:

1. **Promote winner**: Rename the winning variant to the standard component name
2. **Update imports**: Change all imports from the wrapper to the promoted component
3. **Remove wrapper**: Delete the A/B test wrapper component
4. **Remove loser(s)**: Delete the losing variant file(s)
5. **Remove tracking**: Delete A/B-specific tracking events (keep any general tracking)
6. **Remove flag**: Delete or deactivate the feature flag definition
7. **Update registry**: Set the test status to "completed" in the A/B test registry
8. **Clean directories**: Remove empty A/B test directories

### Step 4: Verify
After cleanup:
- Check that imports resolve correctly
- Verify no broken references to deleted files
- Confirm the promoted component renders correctly

### Step 5: Summary
Show what was done:
```
A/B Test Cleanup: login-page
==============================
✅ Promoted: variant-b → LoginPage.tsx
🗑️ Removed: variant-a.tsx, ab-test-wrapper.tsx, tracking.ts
🗑️ Removed: feature flag ab_login_page
📝 Updated: 3 import references
📝 Updated: ab-tests registry (status → completed)
```

## Notes

- This command modifies source files — always confirm with the user first
- The DECISION.md is kept as permanent documentation (not deleted)
- If the decision was "keep control", this command removes all variant code and the wrapper
- Run tests after cleanup to verify nothing broke
