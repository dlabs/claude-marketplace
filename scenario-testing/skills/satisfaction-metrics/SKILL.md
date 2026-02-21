---
name: satisfaction-metrics
description: Framework for measuring, aggregating, and trending satisfaction scores across scenarios. Covers LLM-as-judge methodology, trajectory evaluation, threshold configuration, comparison analysis, and reporting.
---

# Satisfaction Metrics

This skill provides the measurement framework for scenario validation. Satisfaction is a probabilistic metric — the fraction of observed trajectories through scenarios that an LLM judge deems "satisfactory" for the described user.

## When to Use

- `/scenario-testing:st:satisfy` — judging trajectories
- `/scenario-testing:st:report` — generating satisfaction reports
- `/scenario-testing:st:validate` — full pipeline validation
- When any agent needs to understand how satisfaction is computed

## Why Satisfaction, Not Correctness

Traditional tests measure **correctness**: does the output match the expected output?

Satisfaction measures something different: **would the user described in the scenario consider this outcome acceptable?**

This distinction matters because:
- Agentic software has many valid execution paths — there is no single "correct" output
- LLM-powered features produce non-deterministic outputs — running the same scenario twice yields different (but potentially equally good) results
- User satisfaction is context-dependent — the persona's expertise, goals, and expectations shape what counts as "good enough"

## The Satisfaction Computation

### Per-Trajectory

Each trajectory is judged independently:

```
judge(trajectory, scenario) → {
  verdict: "satisfactory" | "unsatisfactory",
  reasoning: string,
  criteria_matched: string[],
  anti_patterns_matched: string[],
  confidence: float  // 0.0 to 1.0
}
```

A trajectory is "satisfactory" when ALL of:
1. At least ONE satisfaction criterion is matched
2. ZERO anti-patterns are matched
3. The judge believes the described persona would accept this outcome

### Per-Scenario

```
satisfaction(scenario) = count(satisfactory) / count(total_trajectories)
```

The number of trajectories per scenario is configurable (default: 50). More trajectories give a tighter confidence interval on the satisfaction estimate.

### Per-Domain

```
satisfaction(domain) = mean(satisfaction(scenario) for scenario in domain)
```

Equal weighting across scenarios in the domain. Override with explicit weights in config if some scenarios are more important.

### Overall

```
satisfaction(overall) = weighted_mean(satisfaction(domain) for domain in all_domains)
weight(domain) = total_trajectory_count(domain)
```

Weighted by trajectory count to avoid small domains disproportionately affecting the overall score.

## LLM-as-Judge Methodology

### Default Judge Configuration

```yaml
model: opus
temperature: 0.0  # deterministic judgment
max_tokens: 2000

system_prompt: |
  You are a satisfaction judge evaluating whether a software interaction trajectory
  would satisfy the user described in the scenario.

  You will receive:
  1. The scenario (persona, intent, satisfaction criteria, anti-patterns)
  2. The trajectory (actions taken, state transitions, final outcome)

  Evaluate:
  - Does the outcome match ANY of the satisfaction criteria?
  - Does the trajectory match ANY anti-patterns?
  - Would the described persona consider this outcome acceptable?

  Respond with a JSON object:
  {
    "verdict": "satisfactory" or "unsatisfactory",
    "reasoning": "2-3 sentence explanation",
    "criteria_matched": ["list of matched criteria"],
    "anti_patterns_matched": ["list of matched anti-patterns"],
    "confidence": 0.0 to 1.0
  }
```

### Why Temperature 0?

The judge should be deterministic — the same trajectory judged twice should get the same verdict. Temperature 0 ensures consistent evaluation. If you want to measure judge variance, run multiple judgment passes and compare.

### Custom Judges

Override the default judge per-scenario or per-domain:

```yaml
# Per-scenario (in the scenario YAML)
judge_config:
  system_prompt: |
    You are a security-focused judge. Weight data protection
    and access control heavily in your evaluation.
  strict_mode: true  # any anti-pattern = unsatisfactory regardless
```

```json
// Per-domain (in config.json)
{
  "judge_overrides": {
    "auth": {
      "system_prompt": "...",
      "strict_mode": true
    }
  }
}
```

## Thresholds

### Configuration

```json
{
  "thresholds": {
    "global_minimum": 0.80,
    "domains": {
      "auth": 0.95,
      "payments": 0.98,
      "onboarding": 0.75,
      "integrations": 0.85
    },
    "scenarios": {
      "sso-login": 0.98,
      "password-reset": 0.90
    }
  }
}
```

### Threshold Hierarchy

Scenario-specific > domain-specific > global minimum. If a scenario has its own threshold, that takes precedence.

### Threshold Semantics

- **Above threshold** — the feature is working well enough for users
- **Below threshold** — investigation needed, satisfaction has degraded
- **Below global minimum** — critical alert, feature may be broken

## Comparison Analysis

### Run-over-Run Comparison

```
/scenario-testing:st:report --compare-to 2026-02-15
```

Computes delta per-scenario and highlights:
- **Improvements** (positive delta > 0.02)
- **Regressions** (negative delta > 0.02)
- **Stable** (delta within ±0.02)

### Trend Analysis

```
/scenario-testing:st:report --trend --days 30
```

Shows satisfaction over time, helping identify:
- Gradual degradation (satisfaction slowly declining)
- Step-function changes (satisfaction dropped after a specific date/deploy)
- Recovery patterns (satisfaction dropped and came back)

## Statistical Considerations

### Sample Size

The number of trajectories affects confidence in the satisfaction estimate:

| Trajectories | 95% Confidence Interval Width |
|--------------|-------------------------------|
| 10           | ±0.31                         |
| 25           | ±0.20                         |
| 50           | ±0.14                         |
| 100          | ±0.10                         |
| 200          | ±0.07                         |
| 500          | ±0.04                         |

For critical scenarios (auth, payments), use 100+ trajectories. For exploratory features, 25-50 is sufficient.

### Judge Reliability

The LLM judge is itself non-deterministic (even at temperature 0, model updates can change behavior). Periodically:
- Re-judge a sample of past trajectories and compare verdicts
- Compute inter-judge agreement if using multiple judge configurations
- Review the judge's reasoning for edge cases

## Report Format

### Terminal Report

```
═══════════════════════════════════════════════
  SATISFACTION REPORT — 2026-02-20
═══════════════════════════════════════════════

  Overall: 0.91 (1365/1500 trajectories)

  Domain          Satisfaction  Threshold  Status
  ─────────────   ────────────  ─────────  ──────
  auth            0.96          0.95       PASS
  onboarding      0.87          0.75       PASS
  integrations    0.88          0.85       PASS
  payments        0.93          0.98       FAIL ▼

  Scenarios Below Threshold:
    payments/checkout-flow  0.93 (target: 0.98)
      → 7/100 unsatisfactory: timeout during payment confirmation
        not communicated to user (no retry UI)

═══════════════════════════════════════════════
```

### JSON Report (for CI)

```json
{
  "date": "2026-02-20",
  "overall_satisfaction": 0.91,
  "total_trajectories": 1500,
  "satisfactory_trajectories": 1365,
  "pass": false,
  "domains": {
    "auth": { "satisfaction": 0.96, "threshold": 0.95, "pass": true },
    "payments": { "satisfaction": 0.93, "threshold": 0.98, "pass": false }
  },
  "failing_scenarios": [
    {
      "id": "checkout-flow",
      "domain": "payments",
      "satisfaction": 0.93,
      "threshold": 0.98,
      "failure_summary": "timeout handling not communicated to user"
    }
  ]
}
```

## References

- `references/judge-prompt-template.md` — Default and domain-specific judge system prompts
- `references/report-schemas.md` — JSON schemas for reports, judgments, and run manifests
