import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:starter_app/core/domain/ports/i_navigation_tracking_service.dart';
import 'package:starter_app/core/navigation/navigation_event_type.dart';

/// Forwards in-branch navigation events to the tracking service.
///
/// Each shell branch (Dashboard, Profile, Settings) has its own navigator.
/// This observer captures navigation within that branch and forwards events
/// to the centralized tracking service.
///
/// ## Usage
///
/// ```dart
/// final class DashboardBranch extends StatefulShellBranchData {
///   static final List<NavigatorObserver> $observers = [
///     BranchNavigatorObserver(name: 'dashboard'),
///   ];
/// }
/// ```
///
/// ## Service Location
///
/// Uses GetIt because `go_router_builder` requires static `$observers` fields.
/// This is the **only** place Service Locator is used in navigation tracking.
/// The observer is a thin forwarding layer - all logic lives in the service.
final class BranchNavigatorObserver extends NavigatorObserver {
  /// Creates an observer for the given branch [name].
  BranchNavigatorObserver({this.name = 'branch'});

  /// Branch name for identification (e.g., 'dashboard', 'profile').
  final String name;

  INavigationTrackingService? _cachedService;

  /// Lazily retrieves the tracking service from DI.
  INavigationTrackingService? get _service {
    if (_cachedService != null) return _cachedService;

    try {
      if (GetIt.I.isRegistered<INavigationTrackingService>()) {
        _cachedService = GetIt.I<INavigationTrackingService>();
      }
      // GetIt throws various exception types during registration lookup.
      // Catch all to prevent crashes before DI is fully initialized.
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      // Service not ready - will be available on subsequent navigations
    }
    return _cachedService;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _service?.onBranchNavigation(
      eventType: NavigationEventType.push,
      branchName: name,
      route: route,
      previousRoute: previousRoute,
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _service?.onBranchNavigation(
      eventType: NavigationEventType.pop,
      branchName: name,
      route: route,
      previousRoute: previousRoute,
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _service?.onBranchNavigation(
        eventType: NavigationEventType.replace,
        branchName: name,
        route: newRoute,
        previousRoute: oldRoute,
      );
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _service?.onBranchNavigation(
      eventType: NavigationEventType.remove,
      branchName: name,
      route: route,
      previousRoute: previousRoute,
    );
  }
}
