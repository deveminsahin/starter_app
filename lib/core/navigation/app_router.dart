import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/navigation/auth_change_notifier.dart';
import 'package:starter_app/core/navigation/base_route.dart';
import 'package:starter_app/core/navigation/branch_navigator_observer.dart';
import 'package:starter_app/core/navigation/page_builder.dart';
import 'package:starter_app/core/navigation/route_definitions.dart';
import 'package:starter_app/core/presentation/pages/error_page.dart';
import 'package:starter_app/core/presentation/widgets/adaptive_navigation_scaffold.dart';
import 'package:starter_app/features/auth/presentation/pages/auth_page.dart';
import 'package:starter_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:starter_app/features/orders/presentation/orders_page.dart';
import 'package:starter_app/features/profile/presentation/pages/profile_page.dart';
import 'package:starter_app/features/settings/presentation/pages/settings_page.dart';

part '../../features/auth/presentation/routes/auth_routes.dart';
// Feature route declarations (using part files for feature-first architecture)
part '../../features/dashboard/presentation/routes/dashboard_routes.dart';
part '../../features/profile/presentation/routes/profile_routes.dart';
part '../../features/settings/presentation/routes/settings_routes.dart';
part '../../features/orders/presentation/routes/orders_route.dart';
part 'app_router.g.dart';

/// Application router with type-safe routes and custom transitions.
///
/// This class encapsulates the GoRouter configuration with:
/// - Type-safe routing via go_router_builder
/// - Custom page transitions (slide forward, fade back)
/// - Navigation tracking via NavigationTrackingService
/// - Adaptive navigation patterns
/// - Dependency injection integration
/// - **Reactive auth-based redirects via AuthChangeNotifier**
///
/// ## Authentication Redirects
///
/// The router uses refreshListenable with AuthChangeNotifier to
/// automatically re-evaluate redirect logic when authentication state changes.
/// This enables:
/// - Automatic redirect to dashboard on logout
/// - Protection of deep-linked routes
/// - Optional redirect of authenticated users away from auth page
///
/// ## Navigation Tracking
///
/// Navigation events are tracked globally by NavigationTrackingService
/// which listens to GoRouterDelegate.currentConfiguration. This captures
/// ALL route changes including shell route branch switches.
///
/// Usage:
/// ```dart
/// // Get router from DI (after Step 11)
/// final router = getIt<AppRouter>().routerConfig;
///
/// // Or use directly
/// MaterialApp.router(routerConfig: appRouter)
/// ```
@lazySingleton
class AppRouter {
  /// Creates an AppRouter with injected dependencies.
  ///
  // ignore: comment_references
  /// [authChangeNotifier] enables reactive redirects on auth state changes.
  AppRouter(
    this._pageBuilder,
    this._authChangeNotifier,
  );

  final PageBuilder _pageBuilder;
  final AuthChangeNotifier _authChangeNotifier;

  /// Root navigator key for controlling navigation from anywhere
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Get the root navigator state
  static NavigatorState? get rootNavigator => _rootNavigatorKey.currentState;

  /// GoRouter configuration with reactive auth-based redirects.
  ///
  /// The refreshListenable ensures that redirect is re-evaluated
  /// whenever the authentication state changes, not just on navigation.
  late final GoRouter routerConfig = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteDefinitions.initialRoute,
    routes: $appRoutes,
    // Re-evaluate redirect when auth state changes
    refreshListenable: _authChangeNotifier,
    errorPageBuilder: (context, state) => _pageBuilder.build(
      context: context,
      state: state,
      child: ErrorPage(state: state),
    ),
    redirect: _handleRedirect,
  );

  /// Centralized redirect logic for all auth-related navigation.
  ///
  /// This handles:
  /// 1. Protection of deep-linked routes (e.g., /orders)
  /// 2. Optional: Redirect authenticated users away from /auth
  /// 3. Reactive redirects on logout/session expiry (via refreshListenable)
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = _authChangeNotifier.isAuthenticated;
    final currentPath = state.matchedLocation;

    // 1. Protect deep-linked routes - redirect unauthenticated users
    if (RouteDefinitions.isDeepLinkProtectedRoute(currentPath) &&
        !isAuthenticated) {
      return RouteDefinitions.dashboardPath;
    }

    // 2. Optional: Redirect authenticated users away from auth page
    // Uncomment if you want to prevent logged-in users from seeing login page
    // if (isAuthenticated && currentPath == RouteDefinitions.authPath) {
    //   return RouteDefinitions.dashboardPath;
    // }

    // No redirect needed
    return null;
  }
}

// ============================================================================
// TYPED ROUTES
// ============================================================================

/// Shell route for main app navigation with adaptive navigation patterns.
///
/// This stateful shell route provides persistent bottom navigation
/// and maintains state across tab switches.
/// Each tab has its own navigation stack.
///
/// ## Navigator Observer Architecture
///
/// This app uses a **multi-level observer pattern**
/// for comprehensive navigation
/// tracking:
///
/// ``` text
/// ┌─────────────────────────────────────────┐
/// │  Root Navigator (GoRouter)              │
/// │  Observer: AppRouterObserver [root]     │
/// │  Sees: All routes (shell + branches)    │
/// │                                         │
/// │  ┌─────────────────────────────────┐    │
/// │  │  Dashboard Branch Navigator          │    │
/// │  │  Observer: [Dashboard]               │    │
/// │  │  Sees: Dashboard branch routes only  │    │
/// │  └─────────────────────────────────┘    │
/// │                                         │
/// │  ┌─────────────────────────────────┐    │
/// │  │  Profile/Settings Branches...   │    │
/// │  └─────────────────────────────────┘    │
/// └─────────────────────────────────────────┘
/// ```
///
/// **Why multiple observers?**
/// - Root observer tracks global navigation flow
/// - Branch observers track tab-specific navigation
/// - Each observer has its own stack (stackDepth differs between observers)
///
/// **Expected log behavior:**
/// When navigating to `/dashboard`, you'll see TWO push logs:
/// - `[root] PUSH Dashboard` - Root navigator sees the route
/// - `[Dashboard] PUSH Dashboard` - Dashboard branch navigator sees the route
///
/// This is **expected behavior**, not a bug. Each navigator independently
/// tracks its own routes for proper back-stack management per tab.
///
/// Branch observers are defined in feature route files:
/// - `features/dashboard/presentation/routes/dashboard_routes.dart`
/// - `features/profile/presentation/routes/profile_routes.dart`
/// - `features/settings/presentation/routes/settings_routes.dart`
@TypedStatefulShellRoute<AppShellRoute>(
  branches: [
    TypedStatefulShellBranch<DashboardBranch>(
      routes: [
        TypedGoRoute<DashboardRoute>(
          path: RouteDefinitions.dashboardPath,
          name: RouteDefinitions.dashboardName,
        ),
      ],
    ),
    TypedStatefulShellBranch<ProfileBranch>(
      routes: [
        TypedGoRoute<ProfileRoute>(
          path: RouteDefinitions.profilePath,
          name: RouteDefinitions.profileName,
        ),
      ],
    ),
    TypedStatefulShellBranch<SettingsBranch>(
      routes: [
        TypedGoRoute<SettingsRoute>(
          path: RouteDefinitions.settingsPath,
          name: RouteDefinitions.settingsName,
        ),
      ],
    ),
  ],
)
final class AppShellRoute extends StatefulShellRouteData {
  const AppShellRoute();
  static final $navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    // Navigation events are tracked globally by INavigationEventService
    return AdaptiveNavigationScaffold(
      navigationShell: navigationShell,
    );
  }
}

// ============================================================================
// ROUTE DECLARATIONS
// ============================================================================
// Route classes are defined in feature-specific files using 'part of':
// - features/settings/presentation/routes/settings_routes.dart
// - features/profile/presentation/routes/profile_routes.dart
//
// This follows feature-first architecture where each feature owns its routes.
