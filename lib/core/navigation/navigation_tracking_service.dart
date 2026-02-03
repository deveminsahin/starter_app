import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/domain/ports/i_navigation_tracking_service.dart';
import 'package:starter_app/core/navigation/navigation_event.dart';
import 'package:starter_app/core/navigation/navigation_event_type.dart';

/// Tracks ALL navigation changes across the application.
///
/// This is the **single source of truth** for navigation events:
/// - **Branch switches** via GoRouterDelegate (Dashboard ↔ Profile ↔ Settings)
/// - **In-branch pushes** via [onBranchNavigation] (Profile → Auth)
///
/// ## How it works
///
/// ```text
/// GoRouterDelegate.addListener()     BranchNavigatorObserver
///           ↓                                  ↓
///      _onRouteChange()              onBranchNavigation()
///           ↓                                  ↓
///           └──────────→ _emitEvent() ←────────┘
///                              ↓
///                    Stream<NavigationEvent>
///                              ↓
///                    AppNavigationLoggingService
/// ```
///
/// The delegate listener captures route configuration changes (branch
/// switches), while branch observers forward in-branch navigation (pushes
/// within a branch). Both flow through `_emitEvent` for consistency.
@LazySingleton(as: INavigationTrackingService)
class NavigationTrackingService implements INavigationTrackingService {
  /// Creates the tracking service and starts listening to route changes.
  NavigationTrackingService(this._router) {
    _routerDelegate = _router.routerDelegate;
    _routerDelegate.addListener(_onRouteChange);
  }

  final GoRouter _router;
  late final GoRouterDelegate _routerDelegate;

  final _eventController = StreamController<NavigationEvent>.broadcast();
  final List<String> _history = [];

  String? _lastRoute;
  String? _previousRoute;
  NavigationEvent? _lastEvent;

  // ─────────────────────────────────────────────────────────────────────────
  // Public API (INavigationTrackingService)
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Stream<NavigationEvent> get events => _eventController.stream;

  @override
  NavigationEvent? get lastEvent => _lastEvent;

  @override
  String? get currentRoute => _lastEvent?.route;

  @override
  bool get canPop => _history.length > 1;

  @override
  List<String> get navigationHistory => List.unmodifiable(_history);

  @override
  void onBranchNavigation({
    required NavigationEventType eventType,
    required String branchName,
    required Route<dynamic> route,
    Route<dynamic>? previousRoute,
  }) {
    final routeName = route.settings.name ?? 'unnamed';
    final path = _normalizePath(routeName);

    // Handle POP: update history but don't emit (avoids duplicate events)
    if (eventType == NavigationEventType.pop) {
      _handlePop();
      return;
    }

    // Skip duplicates - this also handles branch roots since delegate
    // already emitted for them (setting _lastRoute)
    if (routeName == _lastRoute) return;

    _emitEvent(
      type: eventType,
      route: routeName,
      path: path,
      stackDepth: _history.length + 1,
    );
  }

  @override
  @disposeMethod
  Future<void> dispose() async {
    _routerDelegate.removeListener(_onRouteChange);
    await _eventController.close();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private: Event Handling
  // ─────────────────────────────────────────────────────────────────────────

  /// Handles delegate route configuration changes.
  void _onRouteChange() {
    final config = _routerDelegate.currentConfiguration;
    final routeName = config.last.route.name ?? 'unnamed';

    // Skip duplicates (use route NAME, not path - path stays same for modals)
    if (routeName == _lastRoute) return;

    final path = _normalizePath(config.last.route.path);

    _emitEvent(
      type: NavigationEventType.push,
      route: routeName,
      path: path,
      stackDepth: config.matches.length,
    );
  }

  /// Emits a navigation event and updates internal state.
  void _emitEvent({
    required NavigationEventType type,
    required String route,
    required String path,
    required int stackDepth,
  }) {
    final event = NavigationEvent(
      type: type,
      route: route,
      previousRoute: _previousRoute,
      stackDepth: stackDepth,
      path: path,
      fullPath: path,
      timestamp: DateTime.now(),
    );

    _lastEvent = event;
    _history.add(route);
    _eventController.add(event);

    _previousRoute = route;
    _lastRoute = route;
  }

  /// Handles POP events by updating history without emitting.
  void _handlePop() {
    if (_history.isEmpty) return;

    _history.removeLast();
    _previousRoute = _history.isNotEmpty ? _history.last : null;
    _lastRoute = _previousRoute;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private: Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Normalizes path to always have leading slash.
  String _normalizePath(String path) {
    if (path.isEmpty) return '/';
    return path.startsWith('/') ? path : '/$path';
  }
}
