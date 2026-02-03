import 'package:flutter/widgets.dart';
import 'package:starter_app/core/navigation/navigation_event.dart';
import 'package:starter_app/core/navigation/navigation_event_type.dart';

/// Contract for navigation tracking across the application.
///
/// This is the **single source of truth** for navigation events.
/// It captures both branch switches and in-branch navigation.
///
/// ## Architecture
///
/// ```text
/// ┌─────────────────────────────────────────────────────────────┐
/// │  GoRouterDelegate  ──→  NavigationTrackingService           │
/// │  (branch switches)                                          │
/// │                              ↓                              │
/// │  BranchNavigatorObserver ──→ events stream                  │
/// │  (in-branch pushes)          ↓                              │
/// │                     AppNavigationLoggingService             │
/// └─────────────────────────────────────────────────────────────┘
/// ```
///
/// ## Why this exists
///
/// Standard `NavigatorObserver` doesn't fire for shell route branch
/// switches via `goBranch()`. This service combines:
/// - GoRouterDelegate listener for branch switches
/// - BranchNavigatorObserver callbacks for in-branch navigation
///
/// ## Usage
///
/// ```dart
/// final service = getIt<INavigationTrackingService>();
///
/// // Subscribe to all navigation events
/// service.events.listen((event) {
///   analytics.trackScreen(event.route);
/// });
///
/// // Query navigation state
/// if (service.canPop) navigator.pop();
/// print('Current: ${service.currentRoute}');
/// print('History: ${service.navigationHistory}');
/// ```
abstract interface class INavigationTrackingService {
  /// Stream of all navigation events.
  Stream<NavigationEvent> get events;

  /// The most recent navigation event, if any.
  NavigationEvent? get lastEvent;

  /// Name of the current route (e.g., 'dashboard', 'profile').
  String? get currentRoute;

  /// Whether there's navigation history to pop back to.
  bool get canPop;

  /// Complete navigation history as route names.
  List<String> get navigationHistory;

  /// Called by branch navigator observers for in-branch navigation.
  ///
  /// [eventType] identifies the navigation action (push, pop, etc.).
  /// [branchName] identifies the shell branch (e.g., 'dashboard').
  /// [route] is the Flutter route being navigated to.
  /// [previousRoute] is the route being navigated from (if any).
  void onBranchNavigation({
    required NavigationEventType eventType,
    required String branchName,
    required Route<dynamic> route,
    Route<dynamic>? previousRoute,
  });

  /// Cleans up resources (removes listeners, closes streams).
  void dispose();
}
