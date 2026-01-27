/// Available feature flags in the application.
///
/// Each flag represents a capability that can be toggled on/off.
/// Flags default to disabled and can be enabled via:
/// - Remote config
/// - Local development overrides
/// - Environment-specific defaults
///
/// ## Naming Convention
/// - Use camelCase for flag names
/// - Name should describe the feature, not the state
/// - Be descriptive but concise
///
/// ## Adding a New Flag
/// 1. Add the enum value here
/// 2. Add default value in [FeatureFlagX.defaultValue]
/// 3. Document the flag's purpose
/// 4. Add remote config key if applicable
enum FeatureFlag {
  /// Enables the new dashboard design with enhanced widgets.
  newDashboard,

  /// Enables dark mode toggle in settings.
  darkModeToggle,

  /// Enables push notification support.
  pushNotifications,

  /// Enables biometric authentication (fingerprint/face).
  biometricAuth,

  /// Enables offline mode with local data caching.
  offlineMode,

  /// Enables analytics event tracking.
  analytics,

  /// Enables crash reporting to external services.
  crashReporting,

  /// Enables experimental features for beta testers.
  experimentalFeatures,

  /// Enables profile picture upload functionality.
  profilePictureUpload,

  /// Enables social login (Google, Apple, etc.).
  socialLogin,
}

/// Extension providing utilities for [FeatureFlag].
extension FeatureFlagX on FeatureFlag {
  /// The remote config key for this flag.
  ///
  /// Used when fetching flag values from remote config services.
  String get remoteConfigKey => 'feature_$name';

  /// Default value for this flag when no override is set.
  ///
  /// These values are used when remote config is unavailable
  /// or the flag hasn't been defined remotely.
  bool get defaultValue {
    switch (this) {
      case FeatureFlag.newDashboard:
        return false; // Gradual rollout
      case FeatureFlag.darkModeToggle:
        return true; // Enabled by default
      case FeatureFlag.pushNotifications:
        return false; // Requires setup
      case FeatureFlag.biometricAuth:
        return false; // Security feature, opt-in
      case FeatureFlag.offlineMode:
        return false; // Requires infrastructure
      case FeatureFlag.analytics:
        return true; // Enabled by default
      case FeatureFlag.crashReporting:
        return true; // Enabled by default
      case FeatureFlag.experimentalFeatures:
        return false; // Beta only
      case FeatureFlag.profilePictureUpload:
        return true; // Standard feature
      case FeatureFlag.socialLogin:
        return false; // Requires setup
    }
  }

  /// Description of the feature for debugging and documentation.
  String get description {
    switch (this) {
      case FeatureFlag.newDashboard:
        return 'New dashboard design with enhanced widgets';
      case FeatureFlag.darkModeToggle:
        return 'Dark mode toggle in settings';
      case FeatureFlag.pushNotifications:
        return 'Push notification support';
      case FeatureFlag.biometricAuth:
        return 'Biometric authentication (fingerprint/face)';
      case FeatureFlag.offlineMode:
        return 'Offline mode with local data caching';
      case FeatureFlag.analytics:
        return 'Analytics event tracking';
      case FeatureFlag.crashReporting:
        return 'Crash reporting to external services';
      case FeatureFlag.experimentalFeatures:
        return 'Experimental features for beta testers';
      case FeatureFlag.profilePictureUpload:
        return 'Profile picture upload functionality';
      case FeatureFlag.socialLogin:
        return 'Social login (Google, Apple, etc.)';
    }
  }
}
