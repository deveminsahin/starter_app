import 'package:injectable/injectable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:starter_app/core/application/application_environment.dart';
import 'package:starter_app/core/domain/ports/i_error_reporter.dart';
import 'package:starter_app/core/domain/ports/i_monitoring_initializer.dart';

/// Sentry-based monitoring initializer implementation.
///
/// Handles the Sentry SDK initialization which must happen before
/// any [IErrorReporter] methods can work.
///
/// This is in infrastructure layer because it directly uses `sentry_flutter`.
@LazySingleton(as: IMonitoringInitializer)
class SentryMonitoringInitializer implements IMonitoringInitializer {
  const SentryMonitoringInitializer();

  @override
  Future<bool> initialize(
    AppEnvironment environment, {
    String? dsnOverride,
  }) async {
    final dsn = dsnOverride ?? environment.sentryDsn;

    // Skip if Sentry is disabled or no DSN
    if (!environment.sentryEnabled || dsn == null) {
      return false;
    }

    await SentryFlutter.init(
      (options) {
        options
          ..dsn = dsn
          ..environment = environment.name
          ..tracesSampleRate = environment.sentrySampleRate;
      },
    );

    return true;
  }
}
