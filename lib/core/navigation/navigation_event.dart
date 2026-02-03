import 'package:starter_app/core/navigation/navigation_event_type.dart';

/// Represents a navigation event in the application.
///
/// Emitted by NavigationTrackingService whenever a route change occurs,
/// including shell route branch switches.
///
/// Consumers can subscribe to navigation events for:
/// - Logging
/// - Analytics tracking
/// - Performance monitoring
/// - Screen view tracking
final class NavigationEvent {
  const NavigationEvent({
    required this.type,
    required this.route,
    required this.path,
    required this.fullPath,
    required this.stackDepth,
    required this.timestamp,
    this.previousRoute,
  });

  /// The type of navigation event (push, pop, replace, remove).
  final NavigationEventType type;

  /// The name of the current route (screen).
  final String route;

  /// The name of the previous route, if any.
  final String? previousRoute;

  /// The number of route matches in the current configuration.
  final int stackDepth;

  /// The URI path of the current route.
  final String path;

  /// The full path from the route configuration.
  final String fullPath;

  /// When the navigation event occurred.
  final DateTime timestamp;

  @override
  String toString() {
    return 'NavigationEvent(type: ${type.name}, route: $route, '
        'previous: $previousRoute, stackDepth: $stackDepth, path: $path)';
  }
}
