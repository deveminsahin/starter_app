import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:starter_app/core/domain/ports/i_navigation_tracking_service.dart';
import 'package:starter_app/core/logging/i_app_logger.dart';
import 'package:starter_app/core/navigation/navigation_event.dart';

/// Logs all navigation events to the application logger.
///
/// This service subscribes to the navigation tracking service and logs
/// each navigation change. It follows the same pattern as other application
/// services like AppErrorHandlingService.
///
/// ## Lifecycle
///
/// - Created during DI initialization
/// - Activated via `setup()` during bootstrap
/// - Lives for entire application lifetime
/// - Disposed on app shutdown
///
/// ## Log Output
///
/// ```text
/// [Navigation] Navigation: ROUTE_CHANGE | Data: {route: profile, ...}
/// ```
@singleton
class AppNavigationLoggingService {
  /// Creates the service with required dependencies.
  AppNavigationLoggingService(
    this._trackingService,
    this._logger,
  );

  final INavigationTrackingService _trackingService;
  final IAppLogger _logger;

  StreamSubscription<void>? _subscription;

  /// Starts listening to navigation events and logging them.
  ///
  /// Call this once during application bootstrap via BootstrapService.
  void setup() {
    _subscription = _trackingService.events.listen(_logNavigationEvent);
  }

  void _logNavigationEvent(NavigationEvent event) {
    _logger.debug(
      'Navigation: ${event.type.name.toUpperCase()}',
      data: {
        'route': event.route,
        'previous': event.previousRoute ?? 'none',
        'stackDepth': event.stackDepth,
        'path': event.path,
        'fullPath': event.fullPath,
      },
      tag: 'Navigation',
    );
  }

  /// Disposes the subscription.
  @disposeMethod
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
