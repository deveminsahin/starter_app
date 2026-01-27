import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:starter_app/core/application/application_environment.dart';
import 'package:starter_app/core/domain/ports/i_error_reporter.dart';
import 'package:starter_app/core/domain/ports/i_monitoring_initializer.dart';
import 'package:starter_app/core/domain/ports/i_platform_info.dart';
import 'package:starter_app/core/logging/i_app_logger.dart';

/// Service responsible for application monitoring and diagnostics.
///
/// Handles:
/// - Sentry SDK initialization (via [IMonitoringInitializer])
/// - Startup configuration logging
/// - Integration of [IAppLogger] (console) and [IErrorReporter] (Sentry)
///
/// **Architecture:**
/// - [IAppLogger]: Console logging for development debugging
/// - [IErrorReporter]: Error tracking and breadcrumbs for staging/production
/// - [IMonitoringInitializer]: SDK initialization
///   (keeps infrastructure decoupled)
///
/// Sentry must be initialized before [IErrorReporter] methods work.
@lazySingleton
class AppMonitoringService {
  AppMonitoringService(
    this._logger,
    this._errorReporter,
    this._platformInfo,
    this._monitoringInitializer,
  );

  final IAppLogger _logger;
  final IErrorReporter _errorReporter;
  final IPlatformInfo _platformInfo;
  final IMonitoringInitializer _monitoringInitializer;

  /// Initializes the monitoring system.
  ///
  /// Must be called early in app bootstrap before using [IErrorReporter].
  Future<void> initialize(
    AppEnvironment environment, {
    String? sentryDsnOverride,
    @visibleForTesting String? configurationWarningOverride,
  }) async {
    // Log startup configuration to console
    _logStartupConfiguration(
      environment,
      warningOverride: configurationWarningOverride,
    );

    // Initialize monitoring SDK (required for IErrorReporter to work)
    final initialized = await _monitoringInitializer.initialize(
      environment,
      dsnOverride: sentryDsnOverride,
    );

    // Add startup breadcrumb to Sentry if initialized
    if (initialized) {
      _errorReporter.addBreadcrumb(
        'Application initialized',
        category: 'lifecycle',
        data: {
          'environment': environment.name,
          'platform': _platformInfo.targetPlatform,
        },
        level: SeverityLevel.info,
      );
    }
  }

  void _logStartupConfiguration(
    AppEnvironment environment, {
    String? warningOverride,
  }) {
    final warning = warningOverride ?? AppEnvironment.configurationWarning;
    if (warning != null) {
      _logger.warning(warning, tag: 'Configuration');
    }

    _logger.info(
      'Application starting',
      data: {
        'environment': environment.name,
        'explicitlyConfigured': AppEnvironment.isExplicitlyConfigured,
        'apiBaseUrl': environment.apiBaseUrl,
        'webSocketUrl': environment.webSocketUrl,
        'sentryEnabled': environment.sentryEnabled,
        'operatingSystem': _platformInfo.targetPlatform,
        'operatingSystemVersion': _platformInfo.operatingSystemVersion,
      },
      tag: 'Bootstrap',
    );
  }
}
