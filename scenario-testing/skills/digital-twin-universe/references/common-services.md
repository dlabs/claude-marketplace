# Common Service Twin Patterns

Reference patterns and state machines for frequently-twinned third-party services. These serve as starting points — the twin-builder agent customizes them based on which endpoints your codebase actually calls.

## Okta (Identity Provider)

### Key Endpoints
```yaml
routes:
  - POST /api/v1/authn              # Primary authentication
  - POST /api/v1/authn/factors/{id}/verify  # MFA verification
  - GET  /api/v1/users/{id}         # Get user profile
  - POST /api/v1/users              # Create user
  - GET  /api/v1/apps/{id}/users    # List app users
  - POST /oauth2/v1/token           # OAuth token exchange
  - POST /oauth2/v1/revoke          # Revoke token
  - GET  /oauth2/v1/userinfo        # Get user info from token
```

### State Machine
```yaml
entities:
  auth_session:
    initial_state: unauthenticated
    transitions:
      - from: unauthenticated → mfa_required (when primary auth succeeds + MFA enrolled)
      - from: unauthenticated → authenticated (when primary auth succeeds + no MFA)
      - from: mfa_required → authenticated (when MFA verification succeeds)
      - from: mfa_required → locked_out (after 5 failed MFA attempts)
      - from: authenticated → unauthenticated (on session expiry or revoke)

  oauth_token:
    initial_state: none
    transitions:
      - none → active (on token exchange)
      - active → expired (after TTL)
      - active → revoked (on explicit revoke)

  user:
    initial_state: staged
    transitions:
      - staged → active (on activation)
      - active → suspended (on admin action)
      - suspended → active (on admin action)
      - active → deprovisioned (on deprovision)
```

### Chaos Patterns
- Token exchange returns expired token (forces refresh flow)
- MFA service temporarily unavailable (tests fallback)
- Rate limiting on `/authn` (tests login retry UX)
- SAML assertion clock skew (tests time validation)

---

## Jira (Project Management)

### Key Endpoints
```yaml
routes:
  - POST /rest/api/3/issue           # Create issue
  - GET  /rest/api/3/issue/{key}     # Get issue
  - PUT  /rest/api/3/issue/{key}     # Update issue
  - POST /rest/api/3/issue/{key}/transitions  # Transition issue status
  - GET  /rest/api/3/issue/{key}/transitions  # Get available transitions
  - POST /rest/api/3/issue/{key}/comment      # Add comment
  - GET  /rest/api/3/search          # JQL search
  - GET  /rest/api/3/project         # List projects
  - GET  /rest/api/3/priority        # List priorities
```

### State Machine
```yaml
entities:
  issue:
    initial_state: open
    states: [open, in_progress, in_review, done, closed, reopened]
    transitions:
      - open → in_progress (Start Progress, id: 21)
      - in_progress → in_review (Submit for Review, id: 31)
      - in_review → done (Approve, id: 41)
      - in_review → in_progress (Request Changes, id: 51)
      - done → closed (Close, id: 61)
      - done → reopened (Reopen, id: 71)
      - reopened → in_progress (Start Progress, id: 21)
    constraints:
      - "Transition IDs must be valid for current status"
      - "Required fields must be set before transitioning to done"
      - "Cannot transition from closed without admin permission"

  project:
    constraints:
      - "Key: 2-10 uppercase ASCII letters"
      - "Key is immutable after creation"
      - "Name is unique within the instance"
```

### Chaos Patterns
- JQL search returns empty during indexing (tests empty state handling)
- Create issue returns 400 with missing required field (tests validation UI)
- Bulk operations hit rate limit at 429 (tests batch retry)
- Webhook delivery fails (tests eventual consistency)

---

## Slack (Messaging)

### Key Endpoints
```yaml
routes:
  - POST /api/chat.postMessage       # Send message
  - POST /api/chat.update            # Update message
  - POST /api/conversations.list     # List channels
  - POST /api/conversations.history  # Get channel messages
  - POST /api/users.info             # Get user info
  - POST /api/reactions.add          # Add reaction
  - POST /api/files.upload           # Upload file
  - POST /api/views.open             # Open modal
  - POST /api/views.update           # Update modal
```

### State Machine
```yaml
entities:
  message:
    constraints:
      - "ts (timestamp) is unique identifier"
      - "Cannot update messages older than 48 hours (workspace setting)"
      - "Bot messages require bot token scope"

  channel:
    states: [active, archived]
    transitions:
      - active → archived (on archive)
      - archived → active (on unarchive)
    constraints:
      - "Cannot post to archived channels"
      - "Private channels require membership"
```

### Chaos Patterns
- `chat.postMessage` rate limited (1 per second per channel)
- Token revoked mid-conversation (tests re-auth flow)
- File upload exceeds size limit (tests error handling)
- Slash command timeout (3 second response window)

---

## Google Sheets (Spreadsheets)

### Key Endpoints
```yaml
routes:
  - POST /v4/spreadsheets                    # Create spreadsheet
  - GET  /v4/spreadsheets/{id}               # Get spreadsheet metadata
  - GET  /v4/spreadsheets/{id}/values/{range}        # Read cells
  - PUT  /v4/spreadsheets/{id}/values/{range}        # Write cells
  - POST /v4/spreadsheets/{id}/values:append         # Append rows
  - POST /v4/spreadsheets/{id}:batchUpdate           # Batch update
  - POST /v4/spreadsheets/{id}/sheets:copyTo         # Copy sheet
```

### State Machine
```yaml
entities:
  spreadsheet:
    constraints:
      - "Cells: max 10 million per spreadsheet"
      - "Sheets: max 200 per spreadsheet"
      - "Cell content: max 50,000 characters"

  cell:
    constraints:
      - "Formulas start with ="
      - "Circular references are detected and error"
      - "Date values stored as serial numbers"
```

### Chaos Patterns
- Quota exceeded: 60 read requests per minute per user
- Quota exceeded: 60 write requests per minute per user
- Concurrent edit conflict (tests merge behavior)
- Spreadsheet not found (sharing permission revoked)

---

## Google Drive (File Storage)

### Key Endpoints
```yaml
routes:
  - POST /drive/v3/files                    # Create/upload file
  - GET  /drive/v3/files/{id}               # Get file metadata
  - GET  /drive/v3/files/{id}?alt=media     # Download file
  - PATCH /drive/v3/files/{id}              # Update metadata
  - DELETE /drive/v3/files/{id}             # Delete file
  - GET  /drive/v3/files                    # List files
  - POST /drive/v3/files/{id}/permissions   # Share file
```

### State Machine
```yaml
entities:
  file:
    states: [active, trashed, deleted]
    transitions:
      - active → trashed (on trash)
      - trashed → active (on untrash)
      - trashed → deleted (after 30 days or explicit delete)
    constraints:
      - "File names are not unique (same name allowed in same folder)"
      - "Max file size: 5 TB"
      - "Folder depth: recommended max 20 levels"

  permission:
    roles: [owner, organizer, fileOrganizer, writer, commenter, reader]
    constraints:
      - "Exactly one owner per file"
      - "Owner cannot be removed (must transfer ownership first)"
      - "Permissions are inherited from parent folders by default"
```

---

## Stripe (Payments)

### Key Endpoints
```yaml
routes:
  - POST /v1/customers                      # Create customer
  - POST /v1/payment_intents                 # Create payment intent
  - POST /v1/payment_intents/{id}/confirm    # Confirm payment
  - POST /v1/subscriptions                   # Create subscription
  - DELETE /v1/subscriptions/{id}            # Cancel subscription
  - POST /v1/refunds                         # Create refund
  - GET  /v1/charges/{id}                    # Get charge
  - POST /v1/webhooks                        # (incoming webhooks)
```

### State Machine
```yaml
entities:
  payment_intent:
    initial_state: requires_payment_method
    states:
      - requires_payment_method
      - requires_confirmation
      - requires_action
      - processing
      - succeeded
      - canceled
    transitions:
      - requires_payment_method → requires_confirmation (attach method)
      - requires_confirmation → processing (confirm)
      - requires_confirmation → requires_action (3D Secure needed)
      - requires_action → processing (3D Secure completed)
      - processing → succeeded (payment processed)
      - processing → requires_payment_method (payment failed)
      - any → canceled (explicit cancel)

  subscription:
    initial_state: incomplete
    states: [incomplete, active, past_due, canceled, unpaid, trialing]
    transitions:
      - incomplete → active (first payment succeeds)
      - active → past_due (renewal payment fails)
      - past_due → active (retry payment succeeds)
      - past_due → canceled (max retries exceeded)
      - active → canceled (explicit cancel)
      - trialing → active (trial ends, payment succeeds)
```

### Chaos Patterns
- Payment declined (insufficient funds, card_declined)
- 3D Secure required (tests redirect flow)
- Webhook delivery failure (tests idempotent handling)
- Idempotency key conflict (tests retry safety)
