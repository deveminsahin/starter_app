import 'package:starter_app/app/app.dart';
import 'package:starter_app/bootstrap.dart';
import 'package:starter_app/core/application/application_environment.dart';
import 'package:starter_app/core/di/injection.dart';

/// Entry point for development environment.
///
/// Run with:
/// ```bash
/// flutter run --dart-define-from-file=config/development.json
/// ```
///
/// Configuration:
/// - Environment: development
/// - Sentry: Disabled
/// - API URL: localhost:3000
/// - Console Logging: Enabled
void main() async {
  await bootstrap<App>(
    environment: AppEnvironment.development,
    onConfigure: configureDependencies,
    onResolve: getIt.get,
  );
}
