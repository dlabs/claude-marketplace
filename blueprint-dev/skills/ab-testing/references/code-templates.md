# A/B Test Code Templates

Stack-specific templates for wrappers, feature flags, and tracking.

---

## React + TypeScript (PostHog)

### Wrapper Component
```tsx
'use client'; // if Next.js App Router

import { useFeatureFlagVariantKey } from 'posthog-js/react';
import { useEffect } from 'react';
import { VariantA } from './variant-a';
import { VariantB } from './variant-b';
import { trackAbEvent } from './tracking';
import type { SharedProps } from './types';

const VARIANTS = {
  control: VariantA,
  'variant-b': VariantB,
} as const;

export function AbTestWrapper(props: SharedProps) {
  const variant = useFeatureFlagVariantKey('ab_{test_name}') ?? 'control';
  const Component = VARIANTS[variant as keyof typeof VARIANTS] ?? VariantA;

  useEffect(() => {
    trackAbEvent('viewed', { variant });
  }, [variant]);

  return <Component {...props} />;
}
```

### Tracking Module
```tsx
import posthog from 'posthog-js';

const TEST_NAME = 'ab_{test_name}';

export const EVENTS = {
  viewed: `${TEST_NAME}_viewed`,
  interacted: `${TEST_NAME}_interacted`,
  completed: `${TEST_NAME}_completed`,
  abandoned: `${TEST_NAME}_abandoned`,
  error: `${TEST_NAME}_error`,
} as const;

export function trackAbEvent(
  event: keyof typeof EVENTS,
  properties?: Record<string, unknown>
) {
  posthog.capture(EVENTS[event], {
    test_name: TEST_NAME,
    ...properties,
  });
}
```

### Types
```tsx
export interface SharedProps {
  // Common props shared across all variants
}
```

---

## React + TypeScript (LaunchDarkly)

### Wrapper Component
```tsx
import { useFlags } from 'launchdarkly-react-client-sdk';
import { useEffect } from 'react';
import { VariantA } from './variant-a';
import { VariantB } from './variant-b';
import { trackAbEvent } from './tracking';
import type { SharedProps } from './types';

export function AbTestWrapper(props: SharedProps) {
  const flags = useFlags();
  const variant = flags['ab_{test_name}'] ?? 'control';
  const Component = variant === 'variant-b' ? VariantB : VariantA;

  useEffect(() => {
    trackAbEvent('viewed', { variant });
  }, [variant]);

  return <Component {...props} />;
}
```

---

## Vue 3 + Composition API (PostHog)

### Wrapper Component
```vue
<script setup lang="ts">
import { computed, onMounted } from 'vue';
import { usePostHog } from '@/composables/posthog';
import VariantA from './variant-a.vue';
import VariantB from './variant-b.vue';
import { trackAbEvent } from './tracking';
import type { SharedProps } from './types';

defineProps<SharedProps>();

const posthog = usePostHog();
const variant = computed(() => posthog.getFeatureFlag('ab_{test_name}') ?? 'control');
const ActiveComponent = computed(() => variant.value === 'variant-b' ? VariantB : VariantA);

onMounted(() => {
  trackAbEvent('viewed', { variant: variant.value });
});
</script>

<template>
  <component :is="ActiveComponent" v-bind="$props" />
</template>
```

---

## Laravel + Pennant (PHP)

### Feature Flag
```php
<?php

namespace App\Features;

use Illuminate\Support\Lottery;
use Laravel\Pennant\Feature;

class Ab{TestName}Feature
{
    public function resolve(mixed $scope): string
    {
        return Lottery::odds(1, 2)->winner(fn () => 'variant-b')->loser(fn () => 'control')->choose();
    }
}
```

### Tracking Events
```php
<?php

namespace App\AbTests\{TestName};

class {TestName}TrackingEvents
{
    public const VIEWED = 'ab_{test_name}_viewed';
    public const INTERACTED = 'ab_{test_name}_interacted';
    public const COMPLETED = 'ab_{test_name}_completed';
    public const ERROR = 'ab_{test_name}_error';

    public static function track(string $event, array $properties = []): void
    {
        // Uses PostHog, Segment, or your analytics provider
        analytics()->capture($event, array_merge([
            'test_name' => 'ab_{test_name}',
            'variant' => Feature::value(Ab{TestName}Feature::class),
        ], $properties));
    }
}
```

### Controller Usage
```php
use Laravel\Pennant\Feature;
use App\Features\Ab{TestName}Feature;

public function show()
{
    $variant = Feature::value(Ab{TestName}Feature::class);

    return match ($variant) {
        'variant-b' => $this->renderVariantB(),
        default => $this->renderVariantA(),
    };
}
```

---

## Rails + Flipper (Ruby)

### Feature Flag
```ruby
# config/initializers/flipper.rb (add to existing)
Flipper.register(:ab_{test_name}_variant_b) do |actor|
  actor.respond_to?(:id) && actor.id.hash.abs % 2 == 1
end
```

### Controller Usage
```ruby
class {Feature}Controller < ApplicationController
  def show
    @variant = if Flipper.enabled?(:ab_{test_name}_variant_b, current_user)
      'variant-b'
    else
      'control'
    end

    track_ab_event('viewed')
    render "#{@variant.underscore}_template"
  end

  private

  def track_ab_event(event_name)
    Analytics.track(
      event: "ab_{test_name}_#{event_name}",
      properties: { variant: @variant, user_id: current_user.id }
    )
  end
end
```

---

## Environment Variable Fallback (Any Stack)

When no feature flag provider is detected:

```typescript
// Simple env-based flag
const AB_TEST_VARIANT = process.env.AB_{TEST_NAME} || 'control';

function getVariant(): string {
  return AB_TEST_VARIANT;
}
```

```php
// PHP env-based
$variant = env('AB_{TEST_NAME}', 'control');
```

```ruby
# Ruby env-based
variant = ENV.fetch('AB_{TEST_NAME}', 'control')
```

---

## A/B Test Registry

### TypeScript
```typescript
// src/config/ab-tests.ts
export interface AbTest {
  name: string;
  flagKey: string;
  variants: string[];
  status: 'active' | 'completed' | 'stopped';
  createdAt: string;
  owner: string;
  planDoc: string;
}

export const AB_TESTS: AbTest[] = [
  {
    name: '{test-name}',
    flagKey: 'ab_{test_name}',
    variants: ['control', 'variant-b'],
    status: 'active',
    createdAt: '{date}',
    owner: '{owner}',
    planDoc: 'docs/ab-tests/{test-name}/PLAN.md',
  },
];
```

### PHP
```php
// config/ab-tests.php
return [
    '{test-name}' => [
        'flag_key' => 'ab_{test_name}',
        'variants' => ['control', 'variant-b'],
        'status' => 'active',
        'created_at' => '{date}',
        'owner' => '{owner}',
        'plan_doc' => 'docs/ab-tests/{test-name}/PLAN.md',
    ],
];
```
