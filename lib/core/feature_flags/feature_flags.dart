/// Feature flag configuration and evaluation for the application.
///
/// This module provides a comprehensive feature flag system supporting:
/// - Local feature flag definitions
/// - Remote config integration (future)
/// - Development overrides
/// - Typed flag access
///
/// ## Architecture
///
/// - `FeatureFlag` - Enum defining all available feature flags
/// - `IFeatureFlagService` - Port for feature flag evaluation
/// - `FeatureFlagService` - Implementation with local overrides
///
/// ## Usage
///
/// ```dart
/// // Check if a feature is enabled
/// final isEnabled = featureFlagService.isEnabled(FeatureFlag.darkMode);
///
/// // Get a feature with development override
/// if (kDebugMode) {
///   featureFlagService.setOverride(FeatureFlag.newDashboard, true);
/// }
/// ```
library;

export 'feature_flag.dart';
export 'feature_flag_service.dart';
export 'i_feature_flag_service.dart';
