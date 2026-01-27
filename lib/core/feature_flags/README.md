# Feature Flags

Local feature flag system with remote config support.

## Architecture

```
feature_flags/
├── feature_flag.dart           # Enum of all flags + extensions
├── i_feature_flag_service.dart # Port interface
├── feature_flag_service.dart   # Implementation (LazySingleton)
└── feature_flags.dart          # Barrel export
```

**Pattern**: Port/Adapter (Hexagonal Architecture)

## Usage

```dart
// Check flag
if (featureFlagService.isEnabled(FeatureFlag.darkModeToggle)) {
  // Show dark mode toggle
}

// Development override (DEBUG MODE ONLY)
featureFlagService.setOverride(FeatureFlag.newDashboard, value: true);
```

## Adding a New Flag

1. Add enum value in `feature_flag.dart`
2. Add default value in `FeatureFlagX.defaultValue`
3. Add description in `FeatureFlagX.description`

## Priority Order

1. **Local override** (debug only)
2. **Remote config** (via `setRemoteValues`)
3. **Default value** (from enum extension)

## Remote Config Integration

Implement `refresh()` to fetch from Firebase Remote Config, LaunchDarkly, etc:

```dart
@override
Future<bool> refresh() async {
  await remoteConfig.fetchAndActivate();
  
  final values = <FeatureFlag, bool>{};
  for (final flag in FeatureFlag.values) {
    values[flag] = remoteConfig.getBool(flag.remoteConfigKey);
  }
  setRemoteValues(values);
  return true;
}
```

## Security

Override methods (`setOverride`, `removeOverride`, `clearOverrides`) are wrapped in `assert()` blocks and **only work in debug mode**. In release builds, they are no-ops.
