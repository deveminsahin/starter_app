import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/navigation/navigation_event.dart';
import 'package:starter_app/core/navigation/navigation_event_type.dart';
import 'package:starter_app/core/navigation/navigation_tracking_service.dart';

class MockGoRouter extends Mock implements GoRouter {}

class MockGoRouterDelegate extends Mock implements GoRouterDelegate {}

class MockRoute extends Mock implements Route<dynamic> {}

/// Fake implementation of RouteMatchList for testing.
class FakeRouteMatchList extends Fake implements RouteMatchList {
  FakeRouteMatchList({
    required this.lastMatch,
    required this.matchesList,
  });

  final RouteMatch lastMatch;
  final List<RouteMatch> matchesList;

  @override
  RouteMatch get last => lastMatch;

  @override
  List<RouteMatch> get matches => matchesList;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'FakeRouteMatchList';
}

/// Fake implementation of RouteMatch for testing.
class FakeRouteMatch extends Fake implements RouteMatch {
  FakeRouteMatch({required this.goRoute});

  final GoRoute goRoute;

  @override
  GoRoute get route => goRoute;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'FakeRouteMatch';
}

/// Fake implementation of GoRoute for testing.
/// Note: Fields are mutable to allow test manipulation.
// ignore: must_be_immutable
class FakeGoRoute extends Fake implements GoRoute {
  FakeGoRoute({this.routeName, this.routePath = '/'});

  String? routeName;
  String routePath;

  @override
  String? get name => routeName;

  @override
  String get path => routePath;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'FakeGoRoute($routeName)';
}

void main() {
  group('NavigationTrackingService', () {
    late MockGoRouter mockRouter;
    late MockGoRouterDelegate mockDelegate;
    late FakeGoRoute fakeGoRoute;
    late FakeRouteMatch fakeRouteMatch;
    late FakeRouteMatchList fakeMatchList;
    late NavigationTrackingService service;
    late VoidCallback? capturedListener;

    setUp(() {
      mockRouter = MockGoRouter();
      mockDelegate = MockGoRouterDelegate();
      fakeGoRoute = FakeGoRoute(
        routeName: 'dashboard',
        routePath: '/dashboard',
      );
      fakeRouteMatch = FakeRouteMatch(goRoute: fakeGoRoute);
      fakeMatchList = FakeRouteMatchList(
        lastMatch: fakeRouteMatch,
        matchesList: [fakeRouteMatch],
      );

      when(() => mockRouter.routerDelegate).thenReturn(mockDelegate);
      when(() => mockDelegate.addListener(any())).thenAnswer((invocation) {
        capturedListener =
            invocation.positionalArguments[0] as VoidCallback? ?? () {};
      });
      when(() => mockDelegate.removeListener(any())).thenReturn(null);
      when(() => mockDelegate.currentConfiguration).thenReturn(fakeMatchList);

      service = NavigationTrackingService(mockRouter);
    });

    tearDown(() async {
      await service.dispose();
    });

    test('adds listener on construction', () {
      verify(() => mockDelegate.addListener(any())).called(1);
    });

    test('removes listener on dispose', () async {
      await service.dispose();
      verify(() => mockDelegate.removeListener(any())).called(1);
    });

    test('events stream emits navigation events', () async {
      final events = <NavigationEvent>[];
      final subscription = service.events.listen(events.add);

      // Trigger route change
      capturedListener?.call();

      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.route, 'dashboard');
      expect(events.first.type, NavigationEventType.push);

      await subscription.cancel();
    });

    test('skips duplicate routes', () async {
      final events = <NavigationEvent>[];
      final subscription = service.events.listen(events.add);

      // First route change
      capturedListener?.call();
      await Future<void>.delayed(Duration.zero);

      // Same route again
      capturedListener?.call();
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));

      await subscription.cancel();
    });

    test('lastEvent returns most recent event', () async {
      expect(service.lastEvent, isNull);

      capturedListener?.call();
      await Future<void>.delayed(Duration.zero);

      expect(service.lastEvent, isNotNull);
      expect(service.lastEvent!.route, 'dashboard');
    });

    test('currentRoute returns current route name', () async {
      expect(service.currentRoute, isNull);

      capturedListener?.call();
      await Future<void>.delayed(Duration.zero);

      expect(service.currentRoute, 'dashboard');
    });

    test('canPop returns false with only one route', () async {
      capturedListener?.call();
      await Future<void>.delayed(Duration.zero);

      expect(service.canPop, isFalse);
    });

    test('canPop returns true with multiple routes', () async {
      // First route
      capturedListener?.call();
      await Future<void>.delayed(Duration.zero);

      // Second route
      fakeGoRoute
        ..routeName = 'profile'
        ..routePath = '/profile';
      capturedListener?.call();
      await Future<void>.delayed(Duration.zero);

      expect(service.canPop, isTrue);
    });

    test('navigationHistory tracks route history', () async {
      expect(service.navigationHistory, isEmpty);

      capturedListener?.call();
      await Future<void>.delayed(Duration.zero);

      expect(service.navigationHistory, ['dashboard']);

      fakeGoRoute
        ..routeName = 'profile'
        ..routePath = '/profile';
      capturedListener?.call();
      await Future<void>.delayed(Duration.zero);

      expect(service.navigationHistory, ['dashboard', 'profile']);
    });

    group('onBranchNavigation', () {
      late MockRoute mockRoute;

      setUp(() {
        mockRoute = MockRoute();
        when(
          () => mockRoute.settings,
        ).thenReturn(const RouteSettings(name: 'auth'));
      });

      test('emits event for push', () async {
        // Initialize with first route
        capturedListener?.call();
        await Future<void>.delayed(Duration.zero);

        final events = <NavigationEvent>[];
        final subscription = service.events.listen(events.add);

        service.onBranchNavigation(
          eventType: NavigationEventType.push,
          branchName: 'profile',
          route: mockRoute,
        );

        await Future<void>.delayed(Duration.zero);

        expect(events.last.route, 'auth');
        expect(events.last.type, NavigationEventType.push);
        expect(events.last.previousRoute, 'dashboard');

        await subscription.cancel();
      });

      test('handles pop without emitting', () async {
        // Initialize with routes
        capturedListener?.call();
        await Future<void>.delayed(Duration.zero);

        fakeGoRoute
          ..routeName = 'profile'
          ..routePath = '/profile';
        capturedListener?.call();
        await Future<void>.delayed(Duration.zero);

        final initialHistory = List<String>.from(service.navigationHistory);

        final events = <NavigationEvent>[];
        final subscription = service.events.listen(events.add);

        service.onBranchNavigation(
          eventType: NavigationEventType.pop,
          branchName: 'profile',
          route: mockRoute,
        );

        await Future<void>.delayed(Duration.zero);

        // Pop doesn't emit event
        expect(events, isEmpty);
        // But updates history
        expect(service.navigationHistory.length, initialHistory.length - 1);

        await subscription.cancel();
      });

      test('skips duplicate routes', () async {
        capturedListener?.call();
        await Future<void>.delayed(Duration.zero);

        final events = <NavigationEvent>[];
        final subscription = service.events.listen(events.add);

        // Push same route as last
        when(
          () => mockRoute.settings,
        ).thenReturn(const RouteSettings(name: 'dashboard'));

        service.onBranchNavigation(
          eventType: NavigationEventType.push,
          branchName: 'dashboard',
          route: mockRoute,
        );

        await Future<void>.delayed(Duration.zero);

        expect(events, isEmpty);

        await subscription.cancel();
      });

      test('emits event for replace', () async {
        capturedListener?.call();
        await Future<void>.delayed(Duration.zero);

        final events = <NavigationEvent>[];
        final subscription = service.events.listen(events.add);

        service.onBranchNavigation(
          eventType: NavigationEventType.replace,
          branchName: 'profile',
          route: mockRoute,
        );

        await Future<void>.delayed(Duration.zero);

        expect(events.last.type, NavigationEventType.replace);

        await subscription.cancel();
      });

      test('emits event for remove', () async {
        capturedListener?.call();
        await Future<void>.delayed(Duration.zero);

        final events = <NavigationEvent>[];
        final subscription = service.events.listen(events.add);

        service.onBranchNavigation(
          eventType: NavigationEventType.remove,
          branchName: 'profile',
          route: mockRoute,
        );

        await Future<void>.delayed(Duration.zero);

        expect(events.last.type, NavigationEventType.remove);

        await subscription.cancel();
      });

      test('handles unnamed routes', () async {
        capturedListener?.call();
        await Future<void>.delayed(Duration.zero);

        when(
          () => mockRoute.settings,
        ).thenReturn(const RouteSettings());

        final events = <NavigationEvent>[];
        final subscription = service.events.listen(events.add);

        service.onBranchNavigation(
          eventType: NavigationEventType.push,
          branchName: 'profile',
          route: mockRoute,
        );

        await Future<void>.delayed(Duration.zero);

        expect(events.last.route, 'unnamed');

        await subscription.cancel();
      });
    });

    test('normalizes paths with leading slash', () async {
      fakeGoRoute.routePath = 'dashboard';
      capturedListener?.call();
      await Future<void>.delayed(Duration.zero);

      expect(service.lastEvent!.path, '/dashboard');
    });

    test('handles empty history on pop gracefully', () {
      final mockRoute = MockRoute();
      when(
        () => mockRoute.settings,
      ).thenReturn(const RouteSettings(name: 'test'));

      // Pop on empty history should not crash
      service.onBranchNavigation(
        eventType: NavigationEventType.pop,
        branchName: 'profile',
        route: mockRoute,
      );

      expect(service.navigationHistory, isEmpty);
    });
  });
}
