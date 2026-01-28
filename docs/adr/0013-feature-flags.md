# ADR-0013: Feature Flags with Priority System

## Status

Accepted

## Context

Feature flags enable:
1. Gradual rollouts
2. A/B testing
3. Kill switches for problematic features
4. Development toggles

I needed a system that:
- Works offline (local defaults)
- Supports remote configuration
- Allows developer overrides for testing
- Has clear priority when values conflict

## Decision

I adopt a **priority-based feature flag system**:

### Priority Order

```
1. Local Override (highest) → Development/testing
2. Remote Config           → Firebase Remote Config, LaunchDarkly, etc.
3. Default Value (lowest)  → Hardcoded in FeatureFlag enum
```

### Implementation

```dart
// Feature flag definition with extension for properties
enum FeatureFlag {
  darkModeToggle,
  experimentalChat,
  newOnboarding,
}

/// Extension providing utilities for [FeatureFlag].
extension FeatureFlagX on FeatureFlag {
  /// Remote config key for this flag.
  String get remoteConfigKey => 'feature_$name';

  /// Default value when no override or remote value is set.
  bool get defaultValue {
    switch (this) {
      case FeatureFlag.darkModeToggle: return true;
      case FeatureFlag.experimentalChat: return false;
      case FeatureFlag.newOnboarding: return false;
    }
  }

  /// Description for debugging and documentation.
  String get description {
    switch (this) {
      case FeatureFlag.darkModeToggle: return 'Dark mode toggle';
      case FeatureFlag.experimentalChat: return 'Experimental chat';
      case FeatureFlag.newOnboarding: return 'New onboarding flow';
    }
  }
}

// Service with priority logic
@LazySingleton(as: IFeatureFlagService)
class FeatureFlagService implements IFeatureFlagService {
  final Map<FeatureFlag, bool> _overrides = {};
  final Map<FeatureFlag, bool> _remoteValues = {};

  @override
  bool isEnabled(FeatureFlag flag) {
    // Priority 1: Local override
    if (_overrides.containsKey(flag)) return _overrides[flag]!;
    
    // Priority 2: Remote config
    if (_remoteValues.containsKey(flag)) return _remoteValues[flag]!;
    
    // Priority 3: Default
    return flag.defaultValue;
  }

  @override
  void setOverride(FeatureFlag flag, {required bool value}) {
    assert(() {
      _overrides[flag] = value;
      return true;
    }(), 'setOverride only works in debug mode');
  }
}
```

See: `lib/core/feature_flags/`

### Usage

```dart
// Check a flag
if (featureFlagService.isEnabled(FeatureFlag.newOnboarding)) {
  showNewOnboarding();
} else {
  showLegacyOnboarding();
}

// Developer override for testing
featureFlagService.setOverride(FeatureFlag.experimentalChat, value: true);
```

## Consequences

### Positive
- **Offline-first**: Works without remote config
- **Testable**: Override any flag in tests
- **Explicit defaults**: Enum extension defines fallback behavior
- **Debugging**: Logs show which source provided value
- **Extensible**: Extension pattern allows adding `remoteConfigKey`, `description` without changing enum
- **Secure**: Override methods wrapped in `assert()` - no-ops in release builds

### Negative
- **Remote config integration**: Requires additional setup

### Neutral
- Flags are boolean (use multiple flags for variants)
- Debug mode logs every flag access
- Exhaustive switch ensures all flags have defaults
