---
name: stack-detection
description: Detects project technology stacks by analyzing package manifests, config files, directory structures, and code patterns. Produces a structured stack profile for agent adaptation.
---

# Stack Detection

This skill provides comprehensive technology stack detection for any project. It goes beyond simple file-existence checks to analyze actual configurations, versions, and usage patterns.

## When to Use

- At the start of any blueprint-dev workflow (`/blueprint-dev:bp:discover`)
- When agents need to adapt their output to the project's specific stack
- When generating CLAUDE.md suggestions based on detected technologies

## How It Works

### Detection Layers

1. **Manifest Analysis**: Read package managers (package.json, composer.json, Gemfile, etc.) for declared dependencies
2. **Config File Analysis**: Read framework configs for specific settings (e.g., Next.js app router vs pages router)
3. **Code Pattern Analysis**: Grep source files for usage patterns that confirm or refine detections
4. **Infrastructure Analysis**: Check for Docker, CI/CD, deployment configs

### Fingerprint Matching

Use the fingerprints in `references/fingerprints.md` to match specific technologies. Each fingerprint has:
- **Primary signal**: File or pattern that strongly indicates the technology
- **Confirming signals**: Additional evidence that increases confidence
- **Version detection**: How to determine the specific version in use
- **Variant detection**: Sub-variants (e.g., Next.js App Router vs Pages Router)

### Output

Results go to `.blueprint/stack-profile.json` using the template in `references/profile-template.md`.

## Key Principles

- **Verify, don't guess**: Only report technologies you can confirm through multiple signals
- **Version matters**: `react@18` and `react@19` may need different agent behavior
- **Conventions matter more than dependencies**: How the project *uses* a technology is more valuable than knowing it's installed
- **Fast by default**: The SessionStart hook does a quick scan; deep analysis happens only when `/discover` is explicitly run
