# Navigation Rules (GoRouter)

## Setup

### Router Configuration

**Actual implementation from this starter app:**

```dart
// lib/core/navigation/app_router.dart
@injectable
final class AppRouter {
  AppRouter(this._routerObserver, this._pageBuilder);

  final NavigatorObserver _routerObserver;
  final PageBuilder _pageBuilder;

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter routerConfig = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteDefinitions.initialRoute,
    routes: $appRoutes,
    observers: [_routerObserver],
    errorPageBuilder: (context, state) => _pageBuilder.build(
      context: context,
      state: state,
      child: ErrorPage(state: state),
    ),
    redirect: (context, state) {
      // Default: No authentication redirect
      // See network_module.dart for authentication strategies
      return null;
    },
  );
}

/// Convenience getter for AppRouter
GoRouter get appRouter => getIt<AppRouter>().routerConfig;
```

**Note**: For authentication redirects, see the comprehensive documentation in `lib/core/di/modules/network_module.dart` which explains 3 different authentication navigation strategies.

## Type-Safe Routes

### Using go_router_builder

**Example from auth feature:**

```dart
// features/auth/presentation/routes/auth_routes.dart
part of '../../../../core/navigation/app_router.dart';

/// Authentication route branch (not in tab navigation).
@TypedGoRoute<AuthRoute>(
  path: RouteDefinitions.authPath,
  name: RouteDefinitions.authName,
)
final class AuthRoute extends BaseRoute {
  const AuthRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state) {
    return const AuthPage();
  }
}

// Usage - type-safe navigation
context.go(const AuthRoute().location);
context.push(const AuthRoute().location);
```

**Key points:**
- Routes are defined in feature-specific files using `part of`
- Uses `BaseRoute` extension for custom page transitions
- Constants defined in `RouteDefinitions` for type-safe path/name references
- Generated code handles routing logic

## Navigation Patterns

### Push (Stack Navigation)

```dart
// Navigate to new page
context.push('/products/123');

// Type-safe
context.push(ProductDetailRoute('123').location);

// With result
final result = await context.push<bool>('/confirm');
if (result == true) {
  // Handle confirmation
}
```

### Replace (No Back)

```dart
context.replace('/success');
```

### Go (Clear Stack)

```dart
context.go('/home');
```

### Pop (Go Back)

```dart
context.pop();
context.pop(result); // With result
```

## Route Guards

### Authentication

```dart
redirect: (context, state) {
  final authService = getIt<AuthService>();
  final isAuthenticated = authService.isAuthenticated;
  final isAuthRoute = state.matchedLocation.startsWith('/auth');
  
  if (!isAuthenticated && !isAuthRoute) {
    return '/auth/sign-in?redirect=${state.uri}';
  }
  return null;
}
```

### Permissions

```dart
redirect: (context, state) {
  if (state.matchedLocation.startsWith('/admin')) {
    final user = getIt<AuthService>().currentUser;
    if (user?.role != UserRole.admin) {
      return '/forbidden';
    }
  }
  return null;
}
```

## Deep Linking

### Handle Initial Route

```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [...],
  errorBuilder: (context, state) => ErrorPage(error: state.error),
);
```

### Query Parameters

```dart
// Pass query params
context.push('/search?q=flutter&category=mobile');

// Access in route
class SearchRoute extends GoRouteData {
  const SearchRoute({this.q, this.category});
  
  final String? q;
  final String? category;
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SearchPage(query: q, category: category);
  }
}
```

## Bottom Navigation

### StatefulShellRoute

**Actual implementation from this starter app:**

```dart
// lib/core/navigation/app_router.dart
@TypedStatefulShellRoute<AppShellRoute>(
  branches: [
    TypedStatefulShellBranch<HomeBranch>(
      routes: [
        TypedGoRoute<HomeRoute>(
          path: RouteDefinitions.homePath,
          name: RouteDefinitions.homeName,
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
    return AdaptiveNavigationScaffold(
      navigationShell: navigationShell,
    );
  }
}
```

**Note**: This app uses `AdaptiveNavigationScaffold` which automatically switches between bottom navigation (mobile) and navigation rail (desktop/tablet) based on screen size.

## Error Handling

### Error Page

```dart
final router = GoRouter(
  routes: [...],
  errorBuilder: (context, state) => ErrorPage(
    error: state.error?.toString() ?? 'Unknown error',
    onRetry: () => context.go('/home'),
  ),
);
```

## Rules

- ✅ Use type-safe routes with go_router_builder
- ✅ Centralize navigation in app_router.dart
- ✅ Use route guards for auth/permissions
- ✅ Handle deep links and query parameters
- ❌ Don't use Navigator.push directly
- ❌ Don't bypass route guards
