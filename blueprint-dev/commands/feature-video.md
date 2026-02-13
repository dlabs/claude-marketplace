---
name: bp:feature-video
description: Record a video walkthrough of a feature and add it to the PR description
argument-hint: "[PR number or 'current'] [optional: base URL, default localhost:3000]"
---

# /blueprint-dev:bp:feature-video

Record a video walkthrough demonstrating a feature, optionally upload it, and add it to the PR description.

## Usage

```
/blueprint-dev:bp:feature-video
/blueprint-dev:bp:feature-video 847
/blueprint-dev:bp:feature-video 847 http://localhost:5000
/blueprint-dev:bp:feature-video current https://staging.example.com
```

## Prerequisites

- Local development server running (e.g., `bin/dev`, `rails server`, `npm run dev`)
- `agent-browser` CLI installed
- Git repository with a PR to document
- `ffmpeg` installed (for video conversion)
- `rclone` configured (optional, for cloud upload)

## Setup

**Check required tools:**
```bash
command -v agent-browser >/dev/null 2>&1 && echo "agent-browser: OK" || echo "agent-browser: MISSING - run: npm install -g agent-browser && agent-browser install"
command -v ffmpeg >/dev/null 2>&1 && echo "ffmpeg: OK" || echo "ffmpeg: MISSING - install via your package manager (brew install ffmpeg / apt install ffmpeg)"
command -v rclone >/dev/null 2>&1 && echo "rclone: OK (upload available)" || echo "rclone: MISSING (upload will be skipped, local files only)"
```

See the `agent-browser` skill for detailed CLI reference.

## Workflow

### Step 1: Parse Arguments

**Arguments:** $ARGUMENTS

Parse the input:
- First argument: PR number or "current" (defaults to current branch's PR)
- Second argument: Base URL (defaults to `http://localhost:3000`)

```bash
# Get PR number for current branch if needed
gh pr view --json number -q '.number'
```

### Step 2: Gather Feature Context

**Get PR details:**
```bash
gh pr view [number] --json title,body,files,headRefName -q '.'
```

**Get changed files:**
```bash
gh pr view [number] --json files -q '.files[].path'
```

**Map files to testable routes:**

| File Pattern | Route(s) |
|-------------|----------|
| `app/views/users/*` | `/users`, `/users/:id`, `/users/new` |
| `app/controllers/*_controller.rb` | Corresponding resource routes |
| `app/javascript/controllers/*_controller.js` | Pages using that Stimulus controller |
| `app/components/*_component.rb` | Pages rendering that component |
| `src/app/*` (Next.js) | Corresponding routes |
| `src/pages/*` (Next.js pages dir) | Corresponding routes |
| `src/components/*` | Pages using those components |

### Step 3: Plan the Video Flow

Before recording, create a shot list:

1. **Opening shot**: Homepage or starting point (2-3 seconds)
2. **Navigation**: How user gets to the feature
3. **Feature demonstration**: Core functionality (main focus)
4. **Edge cases**: Error states, validation, etc. (if applicable)
5. **Success state**: Completed action/result

Ask user to confirm or adjust the flow using AskUserQuestion:
- Present the proposed shot list
- Options: "Yes, start recording" / "Modify the flow" / "Add specific interactions"

### Step 4: Setup Recording

```bash
mkdir -p tmp/videos tmp/screenshots
```

### Step 5: Record the Walkthrough

Execute the planned flow, capturing each step:

**Navigate to starting point:**
```bash
agent-browser open "[base-url]/[start-route]"
agent-browser wait 2000
agent-browser screenshot tmp/screenshots/01-start.png
```

**Perform navigation/interactions:**
```bash
agent-browser snapshot -i  # Get refs
agent-browser click @e1    # Click navigation element
agent-browser wait 1000
agent-browser screenshot tmp/screenshots/02-navigate.png
```

**Demonstrate feature:**
```bash
agent-browser snapshot -i  # Get refs for feature elements
agent-browser click @e2    # Click feature element
agent-browser wait 1000
agent-browser screenshot tmp/screenshots/03-feature.png
```

**Capture result:**
```bash
agent-browser wait 2000
agent-browser screenshot tmp/screenshots/04-result.png
```

### Step 6: Create Video from Screenshots

```bash
# Create MP4 video (primary format, good quality, small size)
# -framerate 0.5 = 2 seconds per frame (slower playback for readability)
ffmpeg -y -framerate 0.5 -pattern_type glob -i 'tmp/screenshots/*.png' \
  -c:v libx264 -pix_fmt yuv420p -vf "scale=1280:-2" \
  tmp/videos/feature-demo.mp4

# Create preview GIF (small file for GitHub embed)
ffmpeg -y -framerate 0.5 -pattern_type glob -i 'tmp/screenshots/*.png' \
  -vf "scale=640:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse" \
  -loop 0 tmp/videos/feature-demo-preview.gif
```

**Notes:**
- The `-2` in MP4 scale ensures height is divisible by 2 (required for H.264)
- Preview GIF uses 640px width and 128 colors to keep file size small (~100-200KB)
- Adjust `-framerate` for speed: 0.5 = 2s per frame, 1 = 1s per frame

### Step 7: Upload (Optional)

**Check if rclone is configured:**
```bash
command -v rclone >/dev/null 2>&1 && rclone listremotes
```

**If rclone is available and configured, ask user if they want to upload:**

Use AskUserQuestion:
- "Upload video to cloud storage?"
- Options: "Yes, upload" / "No, keep local only"

**If uploading:**
```bash
# Upload video and preview to user's configured remote
# Replace {REMOTE} and {BUCKET} with user's rclone config
rclone copy tmp/videos/ {REMOTE}:{BUCKET}/pr-videos/pr-[number]/ --progress
rclone copy tmp/screenshots/ {REMOTE}:{BUCKET}/pr-videos/pr-[number]/screenshots/ --progress
```

Ask the user for their rclone remote name and bucket/path if not previously configured.

**If rclone is not available:** Skip upload, note that videos are available locally at `tmp/videos/`.

### Step 8: Update PR Description

**Get current PR body:**
```bash
gh pr view [number] --json body -q '.body'
```

**Add video section to PR description.**

GitHub cannot embed external MP4s directly. Use a clickable GIF that links to the video:

**If uploaded to cloud storage:**
```markdown
## Demo

[![Feature Demo]({preview-gif-url})]({video-mp4-url})

*Click to view full video*
```

**If local only (no upload):**
Add a comment noting the video was recorded locally:
```bash
gh pr comment [number] --body "## Feature Demo

Video walkthrough recorded locally at \`tmp/videos/feature-demo.mp4\`.

_Automated walkthrough of the changes in this PR_"
```

**Update the PR:**
```bash
gh pr edit [number] --body "[updated body with video section]"
```

### Step 9: Cleanup

```bash
# Optional: Clean up screenshots (keep videos)
rm -rf tmp/screenshots
echo "Video retained at: tmp/videos/feature-demo.mp4"
echo "Preview GIF at: tmp/videos/feature-demo-preview.gif"
```

### Step 10: Summary

Present completion summary:

```markdown
## Feature Video Complete

**PR:** #[number] - [title]
**Video:** [url or local path]
**Duration:** ~[X] seconds
**Format:** MP4 + Preview GIF

### Shots Captured
1. [Starting point] - [description]
2. [Navigation] - [description]
3. [Feature demo] - [description]
4. [Result] - [description]

### PR Updated
- [x] Video section added to PR description
- [ ] Ready for review
```

## Tips

- **Keep it short**: 10-30 seconds is ideal for PR demos
- **Focus on the change**: Don't include unrelated UI
- **Show before/after**: If fixing a bug, show the broken state first (if possible)
- **Framerate tuning**: Use `-framerate 0.5` for slow walkthroughs, `-framerate 1` for faster demos
