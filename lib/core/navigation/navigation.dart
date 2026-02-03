/// Navigation configuration and routing for the application.
///
/// This package provides GoRouter-based navigation with:
/// - Type-safe routing via go_router_builder
/// - Custom page transitions
/// - Unified navigation tracking
/// - Adaptive navigation patterns
/// - Dependency injection integration
///
/// ## Core Components
///
/// - `AppRouter`: Injectable router with DI dependencies
/// - `appRouter`: Convenience getter for router config
/// - `RouteDefinitions`: Centralized route paths and names
/// - `BaseRoute`: Abstract base for routes with custom transitions
/// - `PageBuilder`: Interface for custom page transitions
/// - `NavigationTrackingService`: Tracks all navigation events
/// - `BranchNavigatorObserver`: Tracks in-branch navigation
///
/// ## Navigation Tracking
///
/// The navigation system uses a unified tracking approach:
/// - `NavigationTrackingService` listens to GoRouterDelegate for
///   branch switches
/// - `BranchNavigatorObserver` forwards in-branch navigation
/// - All events are emitted to a single stream for logging/analytics
///
/// ## Usage Example
///
/// ```dart
/// // In app.dart
/// MaterialApp.router(
///   routerConfig: appRouter,  // Uses DI after Step 11
///   // ...
/// )
///
/// // Type-safe navigation
/// const DashboardRoute().go(context);
/// const SettingsRoute().push(context);
/// ```
///
/// ## Navigation Patterns
///
/// The navigation automatically adapts:
/// - **Compact** (mobile): Bottom NavigationBar
/// - **Medium** (tablet): NavigationRail
/// - **Expanded+** (desktop): NavigationDrawer
///
/// ## Adding Routes
///
/// 1. Add path/name to `RouteDefinitions`
/// 2. Create route class extending `BaseRoute`
/// 3. Add `@TypedGoRoute` annotation
/// 4. Run code generation
///
/// See README.md for detailed examples.
library;

export 'app_router.dart';
export 'base_route.dart';
export 'branch_navigator_observer.dart';
export 'navigation_event.dart';
export 'navigation_event_type.dart';
export 'navigation_tracking_service.dart';
export 'page_builder.dart';
export 'route_definitions.dart';
