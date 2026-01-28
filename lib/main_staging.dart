import 'package:starter_app/app/app.dart';
import 'package:starter_app/bootstrap.dart';
import 'package:starter_app/core/application/application_environment.dart';
import 'package:starter_app/core/di/injection.dart';

/// Entry point for staging environment.
///
/// Run with:
/// ```bash
/// flutter run --dart-define-from-file=config/staging.json
/// ```
///
/// Configuration:
/// - Environment: staging
/// - Sentry: Enabled (staging project)
/// - API URL: From config file
/// - Console Logging: Enabled (in debug mode)
/// - Sentry Sample Rate: 100% (capture everything)
void main() async {
  await bootstrap<App>(
    environment: AppEnvironment.staging,
    onConfigure: configureDependencies,
    onResolve: getIt.get,
  );
}
