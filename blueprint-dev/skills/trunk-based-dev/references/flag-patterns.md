# Feature Flag Patterns Per Stack

---

## React / Next.js + PostHog

### Hook-based Pattern
```tsx
import { useFeatureFlagEnabled } from 'posthog-js/react';

function Dashboard() {
  const showNewLayout = useFeatureFlagEnabled('feature_new_dashboard');

  if (showNewLayout) {
    return <NewDashboard />;
  }
  return <CurrentDashboard />;
}
```

### Server Component Pattern (Next.js App Router)
```tsx
import PostHogClient from '@/lib/posthog-server';

export default async function Page() {
  const posthog = PostHogClient();
  const flags = await posthog.getAllFlags('user-id');

  return flags['feature_new_dashboard']
    ? <NewDashboard />
    : <CurrentDashboard />;
}
```

---

## React + LaunchDarkly

### Hook-based Pattern
```tsx
import { useFlags } from 'launchdarkly-react-client-sdk';

function Dashboard() {
  const { featureNewDashboard } = useFlags();

  return featureNewDashboard
    ? <NewDashboard />
    : <CurrentDashboard />;
}
```

---

## Vue 3 + Unleash

### Composable Pattern
```vue
<script setup lang="ts">
import { useUnleash } from '@/composables/unleash';

const { isEnabled } = useUnleash();
const showNewLayout = isEnabled('feature_new_dashboard');
</script>

<template>
  <NewDashboard v-if="showNewLayout" />
  <CurrentDashboard v-else />
</template>
```

---

## Laravel + Pennant

### Blade Template
```php
@feature('feature_new_dashboard')
    <x-new-dashboard />
@else
    <x-current-dashboard />
@endfeature
```

### Controller
```php
use Laravel\Pennant\Feature;

public function index()
{
    if (Feature::active('feature_new_dashboard')) {
        return $this->newDashboard();
    }
    return $this->currentDashboard();
}
```

### Feature Definition
```php
// app/Features/NewDashboard.php
namespace App\Features;

class NewDashboard
{
    public function resolve(mixed $scope): bool
    {
        // Gradual rollout: percentage-based
        return match(true) {
            app()->environment('local', 'staging') => true, // Always on in dev/staging
            default => $scope?->id % 100 < 10, // 10% of users
        };
    }
}
```

---

## Rails + Flipper

### Controller
```ruby
class DashboardController < ApplicationController
  def index
    if Flipper.enabled?(:feature_new_dashboard, current_user)
      render :new_dashboard
    else
      render :current_dashboard
    end
  end
end
```

### Percentage Rollout
```ruby
# Enable for 10% of actors
Flipper.enable_percentage_of_actors(:feature_new_dashboard, 10)
```

---

## Django + django-waffle

### View
```python
import waffle

def dashboard(request):
    if waffle.flag_is_active(request, 'feature_new_dashboard'):
        return render(request, 'new_dashboard.html')
    return render(request, 'current_dashboard.html')
```

### Template
```django
{% load waffle_tags %}
{% flag "feature_new_dashboard" %}
  {% include "new_dashboard.html" %}
{% else %}
  {% include "current_dashboard.html" %}
{% endflag %}
```

---

## Environment Variable Fallback (Any Stack)

### Node.js
```typescript
const FEATURE_NEW_DASHBOARD = process.env.FEATURE_NEW_DASHBOARD === 'true';

function getDashboard() {
  return FEATURE_NEW_DASHBOARD ? NewDashboard : CurrentDashboard;
}
```

### PHP
```php
$featureNewDashboard = env('FEATURE_NEW_DASHBOARD', false);
```

### Ruby
```ruby
feature_new_dashboard = ENV.fetch('FEATURE_NEW_DASHBOARD', 'false') == 'true'
```

### Python
```python
import os
FEATURE_NEW_DASHBOARD = os.getenv('FEATURE_NEW_DASHBOARD', 'false').lower() == 'true'
```

---

## Flag Cleanup Pattern

When promoting a flag to permanent "on":

### Before (flagged)
```tsx
function Dashboard() {
  const showNew = useFeatureFlag('feature_new_dashboard');
  return showNew ? <NewDashboard /> : <CurrentDashboard />;
}
```

### After (cleaned up)
```tsx
function Dashboard() {
  return <NewDashboard />;
}
// Delete CurrentDashboard component if unused elsewhere
// Remove flag from provider dashboard
// Remove from flag registry
```
