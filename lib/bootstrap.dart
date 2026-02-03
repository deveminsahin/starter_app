import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_app/core/application/application_environment.dart';
import 'package:starter_app/core/application/bootstrap_service.dart';
import 'package:starter_app/core/types/types.dart';
import 'package:url_strategy/url_strategy.dart';

/// Shared bootstrap logic for all app flavors.
///
/// Initializes:
/// - Dependency injection (via [onConfigure])
/// - HydratedBloc storage for state persistence
/// - BlocObserver for state change logging
/// - Sentry for error tracking (staging/production only)
/// - Global error handling (Flutter, Platform, and Zone errors)
/// - Navigation event logging
/// - Web-specific configurations (URL strategy)
///
/// Initializes and runs the app with all dependencies.
///
/// Usage:
/// ```dart
/// // Production
/// void main() async {
///   await bootstrap(
///     builder: () => getIt<App>(),
///     environment: AppEnvironment.production,
///     onConfigure: () => configureDependencies(AppEnvironment.production),
///     onResolve: <T extends Object>() => getIt<T>(),
///   );
/// }
/// ```
Future<void> bootstrap<T extends Widget>({
  required AppEnvironment environment,
  required Future<void> Function(AppEnvironment) onConfigure,
  required DependencyResolver onResolve,
}) async {
  // Web-specific configuration
  if (kIsWeb) {
    // Remove '#' from URLs for cleaner web navigation
    setPathUrlStrategy();
    GoRouter.optionURLReflectsImperativeAPIs = true;
  }

  // Wrap everything in a guarded zone to catch async errors
  // that escape Flutter's error handling
  return runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Configure all dependencies (DI)
      await onConfigure(environment);

      // Resolve and initialize bootstrap service
      final bootstrapService = onResolve<BootstrapService>();
      await bootstrapService.initialize(environment);
      bootstrapService..setupErrorHandling()
      ..setupNavigationLogging();

      // Run the app
      runApp(onResolve<T>());
    },
    // Catch async errors that escape Flutter's error handling
    // (e.g., errors in Future callbacks, Timer, Stream)
    (error, stack) {
      try {
        // Attempt to resolve BootstrapService to log the error
        onResolve<BootstrapService>().logZoneError(error, stack);
      } on Exception catch (e) {
        // Fallback if DI is not ready or resolution fails
        debugPrint('Uncaught async error: $error\n$stack');
        debugPrint('Error while logging async error: $e');
      }
    },
  );
}
