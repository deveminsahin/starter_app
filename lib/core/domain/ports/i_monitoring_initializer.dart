import 'package:starter_app/core/application/application_environment.dart';

/// Port interface for monitoring SDK initialization.
///
/// This abstracts the monitoring SDK initialization to keep the application
/// layer decoupled from specific
/// monitoring implementations (Sentry, Firebase, etc.).
///
/// **Implementations:**
/// - `SentryMonitoringInitializer` in `infrastructure/error/` - Sentry SDK
abstract interface class IMonitoringInitializer {
  /// Initializes the monitoring SDK with the given configuration.
  ///
  /// [environment] The current app environment for monitoring configuration.
  /// [dsnOverride] Optional DSN override for testing.
  ///
  /// Returns `true` if monitoring was initialized, `false` if skipped
  /// (e.g., development mode or no DSN configured).
  Future<bool> initialize(
    AppEnvironment environment, {
    String? dsnOverride,
  });
}
