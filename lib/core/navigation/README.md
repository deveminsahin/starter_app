# Navigation System

Enterprise-grade navigation with type-safe routing, custom transitions, debugging, and adaptive UI patterns.

## Overview

This comprehensive navigation system provides:

- ✅ **Type-Safe Routing** via `go_router_builder` code generation
- ✅ **Custom Page Transitions** (slide forward, fade back)
- ✅ **Navigation Debugging** with AppRouterObserver
- ✅ **Adaptive Navigation** patterns (bottom nav, rail, drawer)
- ✅ **Dependency Injection** integration (ready for Step 11)
- ✅ **Centralized Route Definitions** for maintainability
- ✅ **Deep Linking** support
- ✅ **Route Guards** (ready for authentication)

## Quick Start

```dart
// In app.dart
MaterialApp.router(
  routerConfig: appRouter,  // Auto-detects DI or uses fallback
  // ...
)

// Navigate (type-safe)
const HomeRoute().go(context);
const SettingsRoute().push(context);
context.pop();
```

## Architecture

### Core Components

#### 1. **AppRouter** (`app_router.dart`)

Injectable router class with DI dependencies:

```dart
@injectable
final class AppRouter {
  AppRouter(this._routerObserver, this._pageBuilder);
  
  late final GoRouter routerConfig = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteDefinitions.initialRoute,
    routes: $appRoutes,
    observers: [_routerObserver],
    errorPageBuilder: (context, state) => _pageBuilder.build(...),
  );
}

// Convenience getter (works before and after DI setup)
GoRouter get appRouter => ...
```

#### 2. **RouteDefinitions** (`route_definitions.dart`)

Single source of truth for all route paths and names:

```dart
final class RouteDefinitions {
  // Paths
  static const String homePath = '/';
  static const String settingsPath = '/settings';
  
  // Names
  static const String homeName = 'home';
  static const String settingsName = 'settings';
  
  // Categories
  static List<String> get mainRoutes => [homePath, settingsPath, profilePath];
  static bool isMainRoute(String path) => mainRoutes.contains(path);
}
```

#### 3. **BaseRoute** (`base_route.dart`)

Abstract base class for routes with custom transitions:

```dart
abstract class BaseRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state);
  
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final pageBuilder = _getPageBuilder();
    return pageBuilder.build(
      context: context,
      state: state,
      child: build(context, state),
    );
  }
}
```

#### 4. **PageBuilder** (`page_builder.dart`)

Interface for custom page transitions:

**CustomTransitionPageBuilder** (default):

- **Forward navigation**: Slide from right with easing
- **Back navigation**: Fade out

**NoTransitionPageBuilder**:

- Instant navigation (for tab switches)

```dart
@Singleton(as: PageBuilder)
final class CustomTransitionPageBuilder implements PageBuilder {
  @override
  Page<void> build({required context, required state, required child}) {
    return CustomTransitionPage<void>(
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final isPopping = animation.status == AnimationStatus.reverse;
        if (isPopping) {
          return FadeTransition(opacity: animation, child: child);
        } else {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child,
          );
        }
      },
    );
  }
}
```

#### 5. **AppRouterObserver** (`app_router_observer.dart`)

Navigation debugging and state tracking:

```dart
@LazySingleton(as: NavigatorObserver)
final class AppRouterObserver extends NavigatorObserver {
  // Logs: 🚦 Navigation: PUSH | Route: home | Previous: settings | Stack depth: 2
  
  List<Route<dynamic>> get navigationStack => ...;
  Route<dynamic>? get currentRoute => ...;
  bool get canPop => ...;
  List<String?> get navigationHistory => ...;
}
```

Console output:

``` text
🚦 Navigation: PUSH | Route: product-detail | Previous: home | Stack depth: 2
🚦 Navigation: POP | Route: product-detail | Previous: home | Stack depth: 1
🚦 Navigation: REPLACE | Route: settings | Previous: home | Stack depth: 1
🚦 Navigation: START_GESTURE | Route: settings | Previous: home | Stack depth: 1
🚦 Navigation: STOP_GESTURE
```

#### 6. **AdaptiveNavigationScaffold** (`core/presentation/widgets/adaptive_navigation_scaffold.dart`)

Adaptive navigation shell based on screen size (located in presentation layer):

| Screen Size | Navigation Pattern | Behavior |
|-------------|-------------------|----------|
| **Compact** (0-599dp) | Bottom NavigationBar | Fixed bottom navigation |
| **Medium** (600-839dp) | NavigationRail | Side rail with labels |
| **Expanded** (840-1199dp) | NavigationDrawer (Dismissible) | Hamburger menu with drawer |
| **Large/Extra Large** (1200dp+) | NavigationDrawer (Permanent) | Always visible drawer |

## Adding New Routes

### Step 1: Add to RouteDefinitions

```dart
// lib/core/navigation/route_definitions.dart
final class RouteDefinitions {
  static const String productDetailPath = '/product/:id';
  static const String productDetailName = 'product-detail';
}
```

### Step 2: Define the Route Class

**Standard route with custom transitions:**

```dart
// lib/core/navigation/app_router.dart
@TypedGoRoute<ProductDetailRoute>(
  path: RouteDefinitions.productDetailPath,
  name: RouteDefinitions.productDetailName,
)
final class ProductDetailRoute extends BaseRoute with $ProductDetailRoute {
  const ProductDetailRoute(this.id);
  
  final String id;
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProductDetailPage(productId: id);
  }
}
```

**Shell/tab route (no transition):**

```dart
final class HomeRoute extends BaseRoute with $HomeRoute {
  const HomeRoute();
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
  
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    // Override for instant tab switching
    return NoTransitionPage(
      key: state.pageKey,
      name: state.name,
      child: build(context, state),
    );
  }
}
```

### Step 3: Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 4: Navigate

```dart
// Type-safe navigation
const ProductDetailRoute('product-123').go(context);
const ProductDetailRoute('product-123').push(context);
const ProductDetailRoute('product-123').replace(context);

// Pop with result
context.pop(result);
```

## Custom Transitions

### Create Custom Transition

```dart
@Injectable(as: PageBuilder)
final class ScaleTransitionPageBuilder implements PageBuilder {
  @override
  Page<void> build({required context, required state, required child}) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      },
    );
  }
}
```

### Use Custom Transition

```dart
// After Step 11 (DI), register your custom PageBuilder
// It will automatically be used by all routes extending BaseRoute
```

## Navigation Patterns

### Basic Navigation

```dart
// Navigate (replace current route in stack)
const HomeRoute().go(context);

// Push (add to stack)
const SettingsRoute().push(context);

// Replace (swap current route)
const ProfileRoute().replace(context);

// Pop (go back)
context.pop();
context.pop(result);  // With result
```

### Nested Routes

```dart
@TypedGoRoute<ProductsRoute>(
  path: '/products',
  routes: [
    TypedGoRoute<ProductDetailRoute>(path: ':id'),
  ],
)
class ProductsRoute extends BaseRoute with $ProductsRoute {
  // Results in /products and /products/:id
}

// Navigate
ProductDetailRoute('123').go(context);  // → /products/123
```

### Route Parameters

```dart
// Path parameters
class UserRoute extends BaseRoute with $UserRoute {
  const UserRoute(this.userId);
  final String userId;
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return UserPage(userId: userId);
  }
}

// Query parameters
class SearchRoute extends BaseRoute with $SearchRoute {
  const SearchRoute({this.q, this.category});
  final String? q;
  final String? category;
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SearchPage(query: q, category: category);
  }
}

// Navigate
UserRoute('user-123').go(context);
SearchRoute(q: 'flutter', category: 'mobile').go(context);
```

### Route Guards

```dart
// In AppRouter.routerConfig
redirect: (context, state) {
  final isAuthenticated = getIt<AuthService>().isAuthenticated;
  final isAuthRoute = RouteDefinitions.isAuthRoute(state.uri.path);
  
  if (!isAuthenticated && !isAuthRoute) {
    return RouteDefinitions.signInPath;
  }
  if (isAuthenticated && isAuthRoute) {
    return RouteDefinitions.homePath;
  }
  
  return null;  // No redirect
},
```

## Testing

### Basic Navigation Test

```dart
testWidgets('Navigation works correctly', (tester) async {
  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();
  
  // Verify we're on home page
  expect(find.byType(CounterPage), findsOneWidget);
  
  // Navigate
  const SettingsRoute().go(tester.element(find.byType(MaterialApp)));
  await tester.pumpAndSettle();
  
  // Verify navigation
  expect(find.text('Settings Page'), findsOneWidget);
});
```

### Mock Navigation Observer

```dart
final mockObserver = MockAppRouterObserver();
when(() => mockObserver.canPop).thenReturn(true);
when(() => mockObserver.currentRoute).thenReturn(mockRoute);
```

## Best Practices

### DO ✅

- Use `RouteDefinitions` for all paths and names
- Extend `BaseRoute` for standard routes with custom transitions
- Override `buildPage` for shell/tab routes to use `NoTransitionPage`
- Use type-safe navigation (e.g., `const HomeRoute().go(context)`)
- Run code generation after route changes
- Check `AppRouterObserver` logs for debugging
- Use route guards for authentication
- Add route names for analytics

### DON'T ❌

- Don't use `Navigator.push` directly
- Don't hardcode route strings
- Don't bypass route guards
- Don't forget mixin clause (`with $RouteClassName`)
- Don't use transitions for shell/tab routes
- Don't create circular route dependencies

## Adaptive UI Integration

```dart
// Navigate based on screen size
if (context.isMobile) {
  const DetailRoute().push(context);  // Full-screen
} else {
  showDialog(...);  // Modal on large screens
}
```

## Dependency Injection (After Step 11)

Once DI is configured, the router will automatically use:

- Injected `AppRouterObserver` for all navigation logging
- Injected `PageBuilder` for all route transitions
- Injected `AppRouter` via the `appRouter` getter

Until then, it uses fallback implementations that work identically.

## Migration from String-Based Routes

```dart
// ❌ Before (string-based)
context.go('/settings');
context.push('/product/123');

// ✅ After (type-safe)
const SettingsRoute().go(context);
ProductDetailRoute('123').push(context);
```

## Performance

- Routes are generated at compile-time (zero runtime overhead)
- Custom transitions use hardware-accelerated animations
- Navigation observer logging only in debug mode
- Shell routes maintain state across tab switches

## File Organization

### Core Navigation Files

- `lib/core/navigation/app_router.dart` - Main router hub (imports feature routes)
- `lib/core/navigation/route_definitions.dart` - Centralized paths/names
- `lib/core/navigation/base_route.dart` - Base route class
- `lib/core/navigation/page_builder.dart` - Transition builders
- `lib/core/navigation/app_router_observer.dart` - Navigation debugging
- `lib/core/presentation/widgets/adaptive_navigation_scaffold.dart` - Adaptive shell

### Feature Route Files (part of app_router.dart)

- `lib/counter/view/counter_routes.dart` - Counter feature routes
- `lib/features/settings/presentation/routes/settings_routes.dart` - Settings routes
- `lib/features/profile/presentation/routes/profile_routes.dart` - Profile routes

### Architecture Rules

- `docs/architecture-rules/13_navigation.md` - Navigation architecture rules
- `docs/architecture-rules/01_project_structure.md` - Feature-first organization

## References

- [GoRouter Documentation](https://pub.dev/documentation/go_router/latest/)
- [go_router_builder](https://pub.dev/packages/go_router_builder)
- [Material Design 3 Navigation](https://m3.material.io/components/navigation-bar/overview)
- [Flutter Navigation and Routing](https://docs.flutter.dev/ui/navigation)

## Feature Checklist

- [x] Type-safe routes with `go_router_builder` ✅
- [x] Custom page transitions (slide/fade) ✅
- [x] Navigation debugging with observer ✅
- [x] Adaptive navigation patterns ✅
- [x] Centralized route definitions ✅
- [x] DI integration ✅
- [x] Shell routes for persistent navigation ✅
- [x] Authentication guards (via AuthChangeNotifier + redirect) ✅
- [ ] Route-level data preloading
- [ ] Analytics integration
