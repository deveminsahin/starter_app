import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/feature_flags/feature_flag.dart';
import 'package:starter_app/core/feature_flags/i_feature_flag_service.dart';
import 'package:starter_app/core/logging/i_app_logger.dart';

/// Implementation of [IFeatureFlagService] with local overrides.
///
/// This service manages feature flags with the following priority:
/// 1. Local overrides (development/testing)
/// 2. Remote config values (future implementation)
/// 3. Default values from [FeatureFlagX.defaultValue]
///
/// In debug mode, additional logging is provided for flag access.
///
/// Usage:
/// ```dart
/// final service = FeatureFlagService(logger);
///
/// // Check a flag
/// if (service.isEnabled(FeatureFlag.darkModeToggle)) {
///   // Enable dark mode toggle
/// }
///
/// // Set override for development
/// service.setOverride(FeatureFlag.experimentalFeatures, value: true);
/// ```
@LazySingleton(as: IFeatureFlagService)
final class FeatureFlagService implements IFeatureFlagService {
  /// Creates a [FeatureFlagService] with the given logger.
  FeatureFlagService(this._logger);

  final IAppLogger _logger;

  /// Local overrides for feature flags.
  final Map<FeatureFlag, bool> _overrides = {};

  /// Remote config values (populated by refresh).
  final Map<FeatureFlag, bool> _remoteValues = {};

  @override
  bool isEnabled(FeatureFlag flag) {
    // Priority 1: Local override
    if (_overrides.containsKey(flag)) {
      final value = _overrides[flag]!;
      if (kDebugMode) {
        _logger.debug(
          'FeatureFlag.${flag.name}: $value (override)',
          tag: 'FeatureFlagService',
        );
      }
      return value;
    }

    // Priority 2: Remote config value
    if (_remoteValues.containsKey(flag)) {
      final value = _remoteValues[flag]!;
      if (kDebugMode) {
        _logger.debug(
          'FeatureFlag.${flag.name}: $value (remote)',
          tag: 'FeatureFlagService',
        );
      }
      return value;
    }

    // Priority 3: Default value
    final value = flag.defaultValue;
    if (kDebugMode) {
      _logger.debug(
        'FeatureFlag.${flag.name}: $value (default)',
        tag: 'FeatureFlagService',
      );
    }
    return value;
  }

  @override
  Set<FeatureFlag> get enabledFlags =>
      FeatureFlag.values.where(isEnabled).toSet();

  @override
  Map<FeatureFlag, bool> get allFlags => {
    for (final flag in FeatureFlag.values) flag: isEnabled(flag),
  };

  @override
  void setOverride(FeatureFlag flag, {required bool value}) {
    assert(
      () {
        _overrides[flag] = value;
        _logger.info(
          'Override set: FeatureFlag.${flag.name} = $value',
          tag: 'FeatureFlagService',
        );
        return true;
      }(),
      'setOverride should only be called in debug mode',
    );
  }

  @override
  void removeOverride(FeatureFlag flag) {
    assert(
      () {
        _overrides.remove(flag);
        _logger.info(
          'Override removed: FeatureFlag.${flag.name}',
          tag: 'FeatureFlagService',
        );
        return true;
      }(),
      'removeOverride should only be called in debug mode',
    );
  }

  @override
  void clearOverrides() {
    assert(
      () {
        _overrides.clear();
        _logger.info(
          'All overrides cleared',
          tag: 'FeatureFlagService',
        );
        return true;
      }(),
      'clearOverrides should only be called in debug mode',
    );
  }

  @override
  bool hasOverride(FeatureFlag flag) => _overrides.containsKey(flag);

  @override
  Future<bool> refresh() async {
    //
    // This method should fetch feature flag values from your remote config
    // service and call setRemoteValues() to update the flags.
    //
    // Example integrations:
    // - Firebase Remote Config
    // - LaunchDarkly
    // - Unleash
    // - Split.io
    // - Custom backend endpoint
    //
    // Example implementation with Firebase Remote Config:
    // ```dart
    // await remoteConfig.fetchAndActivate();
    //
    // final values = <FeatureFlag, bool>{};
    // for (final flag in FeatureFlag.values) {
    //   final key = flag.remoteConfigKey;
    //   if (key != null) {
    //     values[flag] = remoteConfig.getBool(key);
    //   }
    // }
    // setRemoteValues(values);
    // ```
    //
    // The setRemoteValues() method is already implemented and ready to use.

    _logger.info(
      'Remote config not configured - using default values. '
      'Implement refresh() to enable remote feature flags.',
      tag: 'FeatureFlagService',
    );
    return true;
  }

  /// Sets remote config values (used by remote config adapter).
  ///
  /// This should be called by the remote config integration after
  /// fetching values from the remote service.
  @visibleForTesting
  void setRemoteValues(Map<FeatureFlag, bool> values) {
    _remoteValues
      ..clear()
      ..addAll(values);
    _logger.info(
      'Remote values updated: ${values.length} flags',
      tag: 'FeatureFlagService',
    );
  }
}
