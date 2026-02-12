# Tracking Plan Template

Use this template when creating the PLAN.md for an A/B test.

---

## Tracking Events

### Core Events (required for every A/B test)

| Event Name | Trigger | Properties |
|------------|---------|------------|
| `ab_{test}_viewed` | Component mounts / page loads | `variant`, `userId`, `sessionId`, `timestamp` |
| `ab_{test}_interacted` | User's first meaningful interaction | `variant`, `interactionType`, `targetElement` |
| `ab_{test}_completed` | User completes primary task | `variant`, `completionTime`, `stepsCount` |
| `ab_{test}_abandoned` | User leaves without completing | `variant`, `lastStep`, `timeSpent` |
| `ab_{test}_error` | Error occurs during flow | `variant`, `errorType`, `errorMessage` |

### Custom Events (test-specific)

Add events specific to what the test measures:

| Event Name | Trigger | Properties |
|------------|---------|------------|
| `ab_{test}_{action}` | {specific interaction} | `variant`, {custom props} |

---

## Hypothesis Documentation

### Template

```
We believe that [VARIANT DESCRIPTION]
will result in [EXPECTED OUTCOME]
for [USER SEGMENT]
because [REASONING]

We will know this is true when we see
[PRIMARY METRIC] [increase/decrease] by [MINIMUM DETECTABLE EFFECT]
with statistical significance (p < 0.05).

We will stop the test if
[GUARDRAIL METRIC] degrades by more than [THRESHOLD].
```

### Example

```
We believe that a card-based layout (Variant B)
will result in higher task completion rate
for all authenticated users
because cards provide better scannability and visual grouping of related actions.

We will know this is true when we see
task completion rate increase by 10%
with statistical significance (p < 0.05).

We will stop the test if
page load time increases by more than 500ms.
```

---

## Sample Size Calculation

### Formula (simplified)

For a two-sided test:
```
n = (Z_α/2 + Z_β)² × 2 × p(1-p) / δ²

Where:
  Z_α/2 = 1.96 (for 95% confidence)
  Z_β = 0.84 (for 80% power)
  p = baseline conversion rate
  δ = minimum detectable effect (absolute)
```

### Quick Reference Table

| Baseline Rate | MDE (relative) | MDE (absolute) | Sample per Variant |
|---------------|----------------|-----------------|-------------------|
| 5% | +20% | 1% | ~4,800 |
| 10% | +15% | 1.5% | ~3,000 |
| 20% | +10% | 2% | ~2,000 |
| 50% | +5% | 2.5% | ~2,500 |

### Duration Estimation

```
Duration (days) = Sample per Variant × Number of Variants / Daily Traffic to Feature
```

---

## Rollout Configuration

### Standard Rollout (2 variants)

```
Day 1-2:   10% traffic → smoke test (check for errors, tracking fires correctly)
Day 3+:    50/50 split → full test
```

### Three-Variant Rollout

```
Day 1-2:   10% traffic → smoke test
Day 3+:    33/33/33 split → full test
```

### Segment-Targeted Rollout

```
Segment: {description}
Within segment: 50/50 split
Outside segment: 100% control
```

---

## Decision Criteria

### Auto-Stop Conditions
1. **Guardrail violation**: Any guardrail metric degrades > threshold → stop test, revert to control
2. **Error rate spike**: Error rate > 2x baseline → stop test, investigate

### Decision Timeline
1. **Minimum duration**: {X days} (must run at least this long for statistical validity)
2. **Maximum duration**: {Y weeks} (stop and decide even if not significant)
3. **Check frequency**: Weekly review of metrics

### Decision Matrix

| Primary Metric | Guardrails | Sample Size | Decision |
|---------------|------------|-------------|----------|
| Significant + positive | All healthy | Sufficient | Promote challenger |
| Significant + negative | All healthy | Sufficient | Keep control |
| Not significant | All healthy | Sufficient | Keep control (simpler) |
| Any | Violated | Any | Stop, keep control |
| Any | Healthy | Insufficient | Continue testing |
