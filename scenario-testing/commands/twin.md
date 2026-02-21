---
name: st:twin
description: Build a digital twin (behavioral clone) for a third-party service by analyzing codebase API usage
argument-hint: Service name to build a twin for (e.g., okta, jira, slack)
---

# /scenario-testing:st:twin

Build a digital twin for a third-party service.

## Usage

```
/scenario-testing:st:twin "jira"
/scenario-testing:st:twin "okta"
/scenario-testing:st:twin "google-sheets"
/scenario-testing:st:twin   # (will ask which service)
```

## Workflow

### Step 1: Gather Input
If no argument provided:
- Scan the codebase for common third-party service patterns (SDK imports, API URLs, env vars)
- Present discovered services: "I found calls to Jira, Slack, and Okta. Which would you like to twin?"

### Step 2: Check for Existing Twin
- Check `.scenarios/twins/{service}/` for an existing twin
- If found: "A twin for {service} already exists (v{version}). Rebuild from scratch, or update?"

### Step 3: Build the Twin
The **twin-builder** agent:
1. Searches the codebase for all API calls to the target service
2. Maps discovered endpoints into route definitions
3. Models the state machine (entities, transitions, constraints)
4. Configures chaos modes based on the service's known failure patterns
5. Writes all 4 files to `.scenarios/twins/{service}/`

### Step 4: Validate the Twin
The **twin-validator** agent reviews:
1. Route coverage — are all discovered endpoints mapped?
2. State machine validity — are transitions reachable and correct?
3. Schema accuracy — do request/response shapes match the code's expectations?
4. Chaos realism — are failure modes realistic for this service?

### Step 5: Present Results
Show the user:
1. **Twin summary** — service name, endpoints covered, entities modeled
2. **Discovery sources** — which files in the codebase informed the twin
3. **Validation report** — any gaps or warnings
4. **Chaos modes** — available failure injection options
5. **Next steps** — create scenarios that use this twin, or configure chaos

### Step 6: Save and Index
- Write twin files to `.scenarios/twins/{service}/`
- Update `.scenarios/catalog.json` with the new twin entry
- Assign a port (starting from 9001, checking for conflicts)

## Notes

- The twin-builder and twin-validator run sequentially (validator needs builder's output)
- Reference `skills/digital-twin-universe/references/common-services.md` for known patterns
- If the codebase doesn't call the specified service, warn the user and offer to build a generic twin from API docs
- Twins are not running servers — they are configuration files that describe how a twin server would behave. The trajectory-runner uses these definitions during scenario execution.
