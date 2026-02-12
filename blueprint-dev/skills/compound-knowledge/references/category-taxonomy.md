# Category Taxonomy

Definitions and examples for each problem category. Use this to classify problems consistently.

---

## build-errors
**Definition**: Problems that prevent code from compiling, bundling, or producing a build artifact.

**Examples**:
- TypeScript compilation error due to incompatible types
- Webpack/Vite build failure from circular dependency
- Composer/npm dependency resolution conflict
- Docker build failure from missing system dependency

**Common tags**: `webpack`, `vite`, `typescript`, `composer`, `docker`, `dependency`, `compilation`

---

## test-failures
**Definition**: Test suite failures, flaky tests, or test infrastructure problems.

**Examples**:
- Flaky test due to timing/race condition
- Test failure after dependency update
- Test infrastructure issue (database not available)
- Snapshot test mismatch after intentional change

**Common tags**: `flaky`, `jest`, `vitest`, `phpunit`, `playwright`, `snapshot`, `timing`

---

## runtime-errors
**Definition**: Exceptions, crashes, or unhandled errors in running code.

**Examples**:
- Null pointer / undefined is not a function
- Unhandled promise rejection
- Memory leak causing OOM
- Race condition between async operations

**Common tags**: `null-reference`, `promise`, `memory-leak`, `race-condition`, `exception`, `crash`

---

## performance-issues
**Definition**: Slow queries, memory leaks, high latency, or resource exhaustion.

**Examples**:
- N+1 database query causing slow page load
- Memory leak from event listener not cleaned up
- Slow API response from unindexed query
- Frontend re-render storm from state management

**Common tags**: `n-plus-one`, `slow-query`, `memory-leak`, `latency`, `index`, `caching`, `re-render`

---

## database-issues
**Definition**: Migration failures, schema problems, data corruption, or query issues.

**Examples**:
- Migration timeout on large table
- Foreign key constraint violation from bad data
- Schema drift between environments
- Deadlock from concurrent writes

**Common tags**: `migration`, `schema`, `constraint`, `deadlock`, `corruption`, `index`, `foreign-key`

---

## security-issues
**Definition**: Vulnerabilities, authentication bugs, authorization bypass, or data exposure.

**Examples**:
- SQL injection via unparameterized query
- IDOR allowing access to other users' data
- JWT validation bypass
- Sensitive data in logs

**Common tags**: `injection`, `xss`, `csrf`, `idor`, `jwt`, `auth`, `exposure`, `owasp`

---

## ui-bugs
**Definition**: Visual glitches, layout breaks, interaction problems, or rendering issues.

**Examples**:
- Layout shift on page load (CLS)
- Modal not closing on backdrop click
- Form validation message not showing
- Responsive breakpoint not working

**Common tags**: `layout`, `responsive`, `modal`, `form`, `animation`, `css`, `z-index`, `overflow`

---

## integration-issues
**Definition**: API failures, service communication problems, webhook issues.

**Examples**:
- Third-party API response format changed
- Webhook signature verification failing
- CORS error from misconfigured headers
- Timeout from slow upstream service

**Common tags**: `api`, `webhook`, `cors`, `timeout`, `http`, `serialization`, `upstream`

---

## logic-errors
**Definition**: Incorrect business logic, wrong calculations, invalid state transitions.

**Examples**:
- Discount calculated on wrong subtotal
- State machine allowing invalid transition
- Off-by-one error in pagination
- Timezone handling producing wrong date

**Common tags**: `calculation`, `state-machine`, `off-by-one`, `timezone`, `rounding`, `pagination`

---

## Choosing Between Categories

If a problem fits multiple categories, choose based on the **root cause**, not the symptom:

| Symptom | Root Cause | Category |
|---------|-----------|----------|
| Page loads slow | Missing database index | database-issues |
| Page loads slow | Bundle too large | performance-issues |
| 500 error | Null reference in logic | runtime-errors |
| 500 error | Migration not run | database-issues |
| Wrong data displayed | Bad calculation | logic-errors |
| Wrong data displayed | Stale cache | performance-issues |
