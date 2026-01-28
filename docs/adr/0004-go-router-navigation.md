# ADR-0004: go_router for Navigation

## Status

Accepted

## Context

Flutter's Navigator 2.0 provides declarative routing but is complex to implement directly. I evaluated:

| Solution | Pros | Cons |
|----------|------|------|
| **go_router** | Declarative, type-safe, deep linking | Requires code generation for type safety |
| **auto_route** | Full type-safety, guards built-in | Heavier, more complex |
| **Navigator 1.0** | Simple for basic apps | Imperative, no deep linking |
| **Navigator 2.0 raw** | Full control | Very complex, lots of boilerplate |

I needed:
1. Deep linking support (web, mobile)
2. Type-safe route parameters
3. Navigation guards for authentication
4. Nested navigation for shell routes
5. Active maintenance and Flutter team backing

## Decision

I adopt **go_router** with **go_router_builder** for type-safe navigation.

### Implementation Pattern

```dart
// Route definitions with type safety
@TypedGoRoute<DashboardRoute>(path: '/dashboard')
@immutable
class DashboardRoute extends GoRouteData {
  const DashboardRoute();
}

@TypedGoRoute<ProfileRoute>(path: '/profile/:userId')
@immutable
class ProfileRoute extends GoRouteData {
  const ProfileRoute({required this.userId});
  final String userId;
}

// Navigation with compile-time checking
const DashboardRoute().go(context);
ProfileRoute(userId: '123').go(context);
```

### Router Configuration

```dart
GoRouter(
  routes: $appRoutes,
  // Re-evaluate redirect when auth state changes
  refreshListenable: authChangeNotifier,
  redirect: (context, state) {
    final isAuth = authChangeNotifier.isAuthenticated;
    final isProtected = RouteDefinitions.isDeepLinkProtectedRoute(state.matchedLocation);
    
    if (!isAuth && isProtected) {
      return '/dashboard';
    }
    return null;
  },
  observers: [NavigationObserver()],
);
```

### Route Protection Strategy

Single-layer protection with `refreshListenable`:
1. **`AuthChangeNotifier`**: Listens to `AuthBloc` and calls `notifyListeners()` on state changes
2. **GoRouter `refreshListenable`**: Re-evaluates `redirect` whenever `AuthChangeNotifier` notifies
3. **Result**: Unified protection for both navigation attempts AND reactive auth state changes

## Consequences

### Positive

- **Type Safety**: Compile-time route parameter validation
- **Deep Linking**: Works on web and mobile
- **Flutter Team**: Maintained by the Flutter team
- **Shell Routes**: Clean nested navigation patterns
- **Declarative**: Routes defined in one place

### Negative

- **Code Generation**: Required for type-safe routes
- **Redirect Complexity**: Auth guards require careful setup

### Neutral

- Route parameters accessible via generated classes
- Navigation logging via observers

## References

- [go_router Documentation](https://pub.dev/packages/go_router)
- [go_router_builder](https://pub.dev/packages/go_router_builder)
