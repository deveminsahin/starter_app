import 'package:starter_app/core/feature_flags/feature_flag.dart';

/// Port for feature flag evaluation.
///
/// Defines the contract for checking feature flag states.
/// Implementations can use local defaults, remote config, or both.
///
/// Example:
/// ```dart
/// if (featureFlagService.isEnabled(FeatureFlag.darkModeToggle)) {
///   // Show dark mode toggle
/// }
/// ```
abstract interface class IFeatureFlagService {
  /// Checks if a feature flag is enabled.
  ///
  /// Returns `true` if the feature is enabled, `false` otherwise.
  /// Priority: Override > Remote Config > Default Value
  bool isEnabled(FeatureFlag flag);

  /// Gets all enabled features.
  ///
  /// Useful for debugging and analytics.
  Set<FeatureFlag> get enabledFlags;

  /// Gets all feature flag states as a map.
  ///
  /// Useful for debugging and analytics reporting.
  Map<FeatureFlag, bool> get allFlags;

  /// Sets a local override for a feature flag.
  ///
  /// Overrides take precedence over remote config and defaults.
  /// Useful for development and testing.
  void setOverride(FeatureFlag flag, {required bool value});

  /// Removes a local override for a feature flag.
  ///
  /// The flag will revert to remote config or default value.
  void removeOverride(FeatureFlag flag);

  /// Clears all local overrides.
  ///
  /// All flags will revert to remote config or default values.
  void clearOverrides();

  /// Checks if a flag has a local override.
  bool hasOverride(FeatureFlag flag);

  /// Refreshes feature flags from remote config.
  ///
  /// Returns `true` if refresh was successful, `false` otherwise.
  Future<bool> refresh();
}
