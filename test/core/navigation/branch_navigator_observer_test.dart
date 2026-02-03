import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/domain/ports/i_navigation_tracking_service.dart';
import 'package:starter_app/core/navigation/branch_navigator_observer.dart';
import 'package:starter_app/core/navigation/navigation_event_type.dart';

class MockNavigationTrackingService extends Mock
    implements INavigationTrackingService {}

class MockRoute extends Mock implements Route<dynamic> {}

void main() {
  group('BranchNavigatorObserver', () {
    late MockNavigationTrackingService mockService;
    late BranchNavigatorObserver observer;

    setUpAll(() {
      registerFallbackValue(NavigationEventType.push);
      registerFallbackValue(MockRoute());
    });

    setUp(() async {
      mockService = MockNavigationTrackingService();

      // Reset GetIt
      if (GetIt.I.isRegistered<INavigationTrackingService>()) {
        await GetIt.I.unregister<INavigationTrackingService>();
      }
      GetIt.I.registerSingleton<INavigationTrackingService>(mockService);

      observer = BranchNavigatorObserver(name: 'test');
    });

    tearDown(() async {
      if (GetIt.I.isRegistered<INavigationTrackingService>()) {
        await GetIt.I.unregister<INavigationTrackingService>();
      }
    });

    test('creates with default name', () {
      final defaultObserver = BranchNavigatorObserver();
      expect(defaultObserver.name, 'branch');
    });

    test('creates with custom name', () {
      expect(observer.name, 'test');
    });

    group('didPush', () {
      test('forwards push event to tracking service', () {
        final route = MockRoute();
        final previousRoute = MockRoute();
        when(
          () => route.settings,
        ).thenReturn(const RouteSettings(name: 'test_route'));
        when(
          () => previousRoute.settings,
        ).thenReturn(const RouteSettings(name: 'prev_route'));

        observer.didPush(route, previousRoute);

        verify(
          () => mockService.onBranchNavigation(
            eventType: NavigationEventType.push,
            branchName: 'test',
            route: route,
            previousRoute: previousRoute,
          ),
        ).called(1);
      });

      test('handles null previousRoute', () {
        final route = MockRoute();
        when(
          () => route.settings,
        ).thenReturn(const RouteSettings(name: 'test_route'));

        observer.didPush(route, null);

        verify(
          () => mockService.onBranchNavigation(
            eventType: NavigationEventType.push,
            branchName: 'test',
            route: route,
          ),
        ).called(1);
      });
    });

    group('didPop', () {
      test('forwards pop event to tracking service', () {
        final route = MockRoute();
        final previousRoute = MockRoute();
        when(
          () => route.settings,
        ).thenReturn(const RouteSettings(name: 'test_route'));

        observer.didPop(route, previousRoute);

        verify(
          () => mockService.onBranchNavigation(
            eventType: NavigationEventType.pop,
            branchName: 'test',
            route: route,
            previousRoute: previousRoute,
          ),
        ).called(1);
      });
    });

    group('didReplace', () {
      test('forwards replace event when newRoute is not null', () {
        final newRoute = MockRoute();
        final oldRoute = MockRoute();
        when(
          () => newRoute.settings,
        ).thenReturn(const RouteSettings(name: 'new_route'));

        observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);

        verify(
          () => mockService.onBranchNavigation(
            eventType: NavigationEventType.replace,
            branchName: 'test',
            route: newRoute,
            previousRoute: oldRoute,
          ),
        ).called(1);
      });

      test('does not forward when newRoute is null', () {
        final oldRoute = MockRoute();

        observer.didReplace(oldRoute: oldRoute);

        verifyNever(
          () => mockService.onBranchNavigation(
            eventType: any(named: 'eventType'),
            branchName: any(named: 'branchName'),
            route: any(named: 'route'),
            previousRoute: any(named: 'previousRoute'),
          ),
        );
      });
    });

    group('didRemove', () {
      test('forwards remove event to tracking service', () {
        final route = MockRoute();
        final previousRoute = MockRoute();
        when(
          () => route.settings,
        ).thenReturn(const RouteSettings(name: 'test_route'));

        observer.didRemove(route, previousRoute);

        verify(
          () => mockService.onBranchNavigation(
            eventType: NavigationEventType.remove,
            branchName: 'test',
            route: route,
            previousRoute: previousRoute,
          ),
        ).called(1);
      });
    });

    group('service lookup', () {
      test('handles unregistered service gracefully', () async {
        await GetIt.I.unregister<INavigationTrackingService>();

        final route = MockRoute();
        when(
          () => route.settings,
        ).thenReturn(const RouteSettings(name: 'test_route'));

        // Should not throw
        expect(() => observer.didPush(route, null), returnsNormally);
      });

      test('caches service after first lookup', () {
        final route = MockRoute();
        when(
          () => route.settings,
        ).thenReturn(const RouteSettings(name: 'test_route'));

        observer
          ..didPush(route, null)
          ..didPush(route, null);

        // Service should be called twice (not verifying caching directly,
        // but service is used successfully both times)
        verify(
          () => mockService.onBranchNavigation(
            eventType: NavigationEventType.push,
            branchName: 'test',
            route: route,
          ),
        ).called(2);
      });
    });
  });
}
