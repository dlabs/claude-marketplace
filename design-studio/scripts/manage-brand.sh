#!/usr/bin/env bash
# manage-brand.sh — Brand lifecycle management
# Usage:
#   bash manage-brand.sh status          # Report brand state
#   bash manage-brand.sh derive-tokens   # Derive tokens.json from brand.json
#   bash manage-brand.sh validate        # Validate brand.json has required fields

set -euo pipefail

PROJECT_ROOT="${PWD}"
DESIGN_DIR="${PROJECT_ROOT}/.design"
BRAND_FILE="${DESIGN_DIR}/brand.json"
TOKENS_FILE="${DESIGN_DIR}/tokens.json"

# ── Helpers ──
get_timestamp() {
  if command -v python3 &>/dev/null; then
    python3 -c "from datetime import datetime, timezone; print(datetime.now(timezone.utc).isoformat())"
  else
    date -u +"%Y-%m-%dT%H:%M:%SZ"
  fi
}

require_python() {
  if ! command -v python3 &>/dev/null; then
    echo "Error: python3 is required for brand management" >&2
    exit 1
  fi
}

require_brand() {
  if [[ ! -f "$BRAND_FILE" ]]; then
    echo "Error: No brand.json found at ${BRAND_FILE}" >&2
    echo "Run /design-studio:ds:brand to create one." >&2
    exit 1
  fi
}

# ── Status subcommand ──
cmd_status() {
  if [[ ! -f "$BRAND_FILE" ]]; then
    echo "Brand: not defined"
    echo "Run /design-studio:ds:brand to build a brand identity."
    exit 0
  fi

  require_python

  python3 << 'PYEOF'
import json, sys, os

brand_file = os.environ.get("BRAND_FILE", ".design/brand.json")
tokens_file = os.environ.get("TOKENS_FILE", ".design/tokens.json")

try:
    with open(brand_file, "r") as f:
        brand = json.load(f)
except (json.JSONDecodeError, FileNotFoundError) as e:
    print(f"Brand: error reading brand.json ({e})")
    sys.exit(1)

name = brand.get("identity", {}).get("name", "unnamed")
archetype = brand.get("personality", {}).get("archetype", "none")
industry = brand.get("identity", {}).get("industry", "unknown")
version = brand.get("version", "unknown")
color_count = len(brand.get("visual_identity", {}).get("color_intent", {}))
principle_count = len(brand.get("visual_principles", []))

# Check token derivation
tokens_from_brand = False
if os.path.exists(tokens_file):
    try:
        with open(tokens_file, "r") as f:
            tokens = json.load(f)
        tokens_from_brand = tokens.get("source_brand", False)
    except (json.JSONDecodeError, FileNotFoundError):
        pass

# Check brand guide
guide_exists = os.path.exists(os.path.join(os.path.dirname(brand_file), "brand-guide.html"))

# Check showcase pages
showcase_dir = os.path.join(os.path.dirname(brand_file), "brand-showcase")
showcase_count = 0
if os.path.isdir(showcase_dir):
    showcase_count = len([f for f in os.listdir(showcase_dir) if f.endswith(".html")])

print(f"Brand: defined")
print(f"  Name: {name}")
print(f"  Archetype: {archetype}")
print(f"  Industry: {industry}")
print(f"  Version: {version}")
print(f"  Colors: {color_count}  Principles: {principle_count}")
print(f"  Brand guide: {'exists' if guide_exists else 'not generated'}")
print(f"  Showcase pages: {showcase_count}")
print(f"  Tokens derived from brand: {'yes' if tokens_from_brand else 'no'}")
PYEOF
}

# ── Derive-tokens subcommand ──
cmd_derive_tokens() {
  require_brand
  require_python

  TIMESTAMP=$(get_timestamp)

  python3 -c "
import json, sys, os

brand_file = '$BRAND_FILE'
tokens_file = '$TOKENS_FILE'
timestamp = '$TIMESTAMP'

with open(brand_file, 'r') as f:
    brand = json.load(f)

vi = brand.get('visual_identity', {})
tokens = {
    'locked': True,
    'locked_at': timestamp,
    'source_brand': True,
    'source_session': None,
    'source_variant': None,
}

# Derive colors: extract .value from each color_intent entry
colors = {}
for name, info in vi.get('color_intent', {}).items():
    # Convert underscores to hyphens in color names
    token_name = name.replace('_', '-')
    if isinstance(info, dict):
        colors[token_name] = info.get('value', '')
    else:
        colors[token_name] = str(info)
tokens['colors'] = colors

# Derive typography
typography = {}
ti = vi.get('typography_intent', {})
if 'font_sans' in ti:
    val = ti['font_sans']
    typography['font-sans'] = val.get('value', val) if isinstance(val, dict) else val
if 'font_mono' in ti:
    val = ti['font_mono']
    typography['font-mono'] = val.get('value', val) if isinstance(val, dict) else val
if 'scale' in ti:
    typography['scale'] = dict(ti['scale'])
tokens['typography'] = typography

# Derive spacing (direct copy)
if 'spacing' in vi:
    tokens['spacing'] = dict(vi['spacing'])
    if 'scale' in vi['spacing']:
        tokens['spacing']['scale'] = dict(vi['spacing']['scale'])

# Derive radii (direct copy)
if 'radii' in vi:
    tokens['radii'] = dict(vi['radii'])

# Derive shadows (direct copy)
if 'shadows' in vi:
    tokens['shadows'] = dict(vi['shadows'])

with open(tokens_file, 'w') as f:
    json.dump(tokens, f, indent=2)

color_count = len(colors)
font_count = sum(1 for k in typography if k.startswith('font-'))
scale_count = len(typography.get('scale', {}))
spacing_count = len(tokens.get('spacing', {}).get('scale', {}))
radii_count = len(tokens.get('radii', {}))
shadow_count = len(tokens.get('shadows', {}))

print(f'Tokens derived from brand.json:')
print(f'  {color_count} colors, {font_count} fonts, {scale_count} type sizes')
print(f'  {spacing_count} spacing values, {radii_count} radii, {shadow_count} shadows')
print(f'  Written to: {tokens_file}')
print(f'  Locked: yes (source_brand: true)')
"
}

# ── Validate subcommand ──
cmd_validate() {
  require_brand
  require_python

  python3 << 'PYEOF'
import json, sys, os

brand_file = os.environ.get("BRAND_FILE", ".design/brand.json")
errors = []

try:
    with open(brand_file, "r") as f:
        brand = json.load(f)
except json.JSONDecodeError as e:
    print(f"INVALID: brand.json is not valid JSON: {e}")
    sys.exit(1)

# 1. identity.name must be non-empty
name = brand.get("identity", {}).get("name", "")
if not name or not name.strip():
    errors.append("identity.name is missing or empty")

# 2. personality section with archetype and >=3 traits
personality = brand.get("personality", {})
if not personality:
    errors.append("personality section is missing")
else:
    if not personality.get("archetype"):
        errors.append("personality.archetype is missing")
    traits = personality.get("traits", [])
    if len(traits) < 3:
        errors.append(f"personality.traits has {len(traits)} items (minimum 3)")
    # tone_spectrum values between 0.0 and 1.0
    spectrum = personality.get("tone_spectrum", {})
    for key, val in spectrum.items():
        if not isinstance(val, (int, float)) or val < 0.0 or val > 1.0:
            errors.append(f"personality.tone_spectrum.{key} must be 0.0-1.0 (got {val})")

# 3. >=3 colors including primary, background, text
colors = brand.get("visual_identity", {}).get("color_intent", {})
if len(colors) < 3:
    errors.append(f"visual_identity.color_intent has {len(colors)} colors (minimum 3)")
for required in ["primary", "background", "text"]:
    if required not in colors:
        errors.append(f"visual_identity.color_intent.{required} is missing")

# 4. typography with font_sans
typo = brand.get("visual_identity", {}).get("typography_intent", {})
font_sans = typo.get("font_sans", {})
if isinstance(font_sans, dict):
    if not font_sans.get("value"):
        errors.append("visual_identity.typography_intent.font_sans.value is missing")
elif not font_sans:
    errors.append("visual_identity.typography_intent.font_sans is missing")

# 5. >=2 visual_principles
principles = brand.get("visual_principles", [])
if len(principles) < 2:
    errors.append(f"visual_principles has {len(principles)} entries (minimum 2)")

if errors:
    print(f"INVALID: brand.json has {len(errors)} issue(s):")
    for err in errors:
        print(f"  - {err}")
    sys.exit(1)
else:
    print("VALID: brand.json passes all checks")
    sys.exit(0)
PYEOF
}

# ── Main dispatch ──
case "${1:-}" in
  status)
    cmd_status
    ;;
  derive-tokens)
    cmd_derive_tokens
    ;;
  validate)
    cmd_validate
    ;;
  *)
    echo "Usage: manage-brand.sh {status|derive-tokens|validate}" >&2
    echo "  status         — Report brand state" >&2
    echo "  derive-tokens  — Derive tokens.json from brand.json" >&2
    echo "  validate       — Check brand.json has required fields" >&2
    exit 1
    ;;
esac
