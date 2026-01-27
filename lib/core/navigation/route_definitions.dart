/// Centralized route path and name definitions.
///
/// This class provides a single source of truth for all route paths and names
/// used throughout the application. It helps prevent typos and makes route
/// management easier.
///
/// Usage:
/// ```dart
/// @TypedGoRoute<DashboardRoute>(
///   path: RouteDefinitions.DashboardPath,
///   name: RouteDefinitions.DashboardName,
/// )
/// ```
abstract final class RouteDefinitions {
  // ==================== Path Definitions ====================

  /// Dashboard route path: '/dashboard'
  static const String dashboardPath = '/dashboard';

  /// Settings route path: '/settings'
  static const String settingsPath = '/settings';

  /// Profile route path: '/profile'
  static const String profilePath = '/profile';

  /// Orders route path: '/orders'
  static const String ordersPath = '/orders';

  /// Auth route path: '/auth'
  static const String authPath = '/auth';

  // ==================== Name Definitions ====================

  /// Dashboard route name: 'dashboard'
  static const String dashboardName = 'dashboard';

  /// Settings route name: 'settings'
  static const String settingsName = 'settings';

  /// Profile route name: 'profile'
  static const String profileName = 'profile';

  /// Auth route name: 'auth'
  static const String authName = 'auth';

  /// Orders route name: 'orders'
  static const String ordersName = 'orders';

  /// Initial route when app starts
  static const String initialRoute = dashboardPath;

  // ==================== Route Categories ====================

  /// List of all main application routes
  static List<String> get unProtectedRoutes => [
    dashboardPath,
    authPath,
    settingsPath,
    profilePath,
  ];

  /// List of all auth protected routes
  static List<String> get deepLinkProtectedRoutes => [
    ordersPath,
  ];

  /// Check if a path is a main route
  static bool isUnProtectedRoute(String path) =>
      unProtectedRoutes.contains(path);

  /// Check if a path is an auth route
  static bool isDeepLinkProtectedRoute(String path) =>
      deepLinkProtectedRoutes.contains(path);
}
