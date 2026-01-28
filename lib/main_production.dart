import 'package:starter_app/app/app.dart';
import 'package:starter_app/bootstrap.dart';
import 'package:starter_app/core/application/application_environment.dart';
import 'package:starter_app/core/di/injection.dart';

/// Entry point for production environment.
///
/// Configuration:
/// - Environment: production
/// - Sentry: Enabled (production project)
/// - API URL: From config file
/// - Console Logging: Disabled (in release mode)
/// - Sentry Sample Rate: 10% (sampled for performance)
void main() async {
  await bootstrap<App>(
    environment: AppEnvironment.production,
    onConfigure: configureDependencies,
    onResolve: getIt.get,
  );
}
