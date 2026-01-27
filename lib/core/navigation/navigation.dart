/// Navigation configuration and routing for the application.
///
/// This package provides GoRouter-based navigation with:
/// - Type-safe routing via go_router_builder
/// - Custom page transitions
/// - Navigation debugging and logging
/// - Adaptive UI patterns
/// - Dependency injection integration
///
/// ## Core Components
///
/// - `AppRouter`: Injectable router with DI dependencies
/// - `appRouter`: Convenience getter for router config
/// - `RouteDefinitions`: Centralized route paths and names
/// - `BaseRoute`: Abstract base for routes with custom transitions
/// - `PageBuilder`: Interface for custom page transitions
/// - `AppRouterObserver`: Navigation debugging and logging
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
export 'app_router_observer.dart';
export 'base_route.dart';
export 'page_builder.dart';
export 'route_definitions.dart';
