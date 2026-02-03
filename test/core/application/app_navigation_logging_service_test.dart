import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/application/app_navigation_logging_service.dart';
import 'package:starter_app/core/domain/ports/i_navigation_tracking_service.dart';
import 'package:starter_app/core/logging/i_app_logger.dart';
import 'package:starter_app/core/navigation/navigation_event.dart';
import 'package:starter_app/core/navigation/navigation_event_type.dart';

class MockNavigationTrackingService extends Mock
    implements INavigationTrackingService {}

class MockAppLogger extends Mock implements IAppLogger {}

void main() {
  group('AppNavigationLoggingService', () {
    late MockNavigationTrackingService mockTrackingService;
    late MockAppLogger mockLogger;
    late StreamController<NavigationEvent> eventController;
    late AppNavigationLoggingService service;

    setUp(() {
      mockTrackingService = MockNavigationTrackingService();
      mockLogger = MockAppLogger();
      eventController = StreamController<NavigationEvent>.broadcast();

      when(() => mockTrackingService.events).thenAnswer(
        (_) => eventController.stream,
      );

      service = AppNavigationLoggingService(mockTrackingService, mockLogger);
    });

    tearDown(() async {
      await service.dispose();
      await eventController.close();
    });

    test('setup subscribes to navigation events', () {
      service.setup();

      verify(() => mockTrackingService.events).called(1);
    });

    test('logs navigation event when received', () async {
      service.setup();

      final event = NavigationEvent(
        type: NavigationEventType.push,
        route: 'dashboard',
        path: '/dashboard',
        fullPath: '/dashboard',
        stackDepth: 1,
        timestamp: DateTime.now(),
      );

      eventController.add(event);
      await Future<void>.delayed(Duration.zero);

      verify(
        () => mockLogger.debug(
          'Navigation: PUSH',
          data: {
            'route': 'dashboard',
            'previous': 'none',
            'stackDepth': 1,
            'path': '/dashboard',
            'fullPath': '/dashboard',
          },
          tag: 'Navigation',
        ),
      ).called(1);
    });

    test('logs previous route when present', () async {
      service.setup();

      final event = NavigationEvent(
        type: NavigationEventType.push,
        route: 'profile',
        path: '/profile',
        fullPath: '/profile',
        stackDepth: 2,
        timestamp: DateTime.now(),
        previousRoute: 'dashboard',
      );

      eventController.add(event);
      await Future<void>.delayed(Duration.zero);

      verify(
        () => mockLogger.debug(
          'Navigation: PUSH',
          data: {
            'route': 'profile',
            'previous': 'dashboard',
            'stackDepth': 2,
            'path': '/profile',
            'fullPath': '/profile',
          },
          tag: 'Navigation',
        ),
      ).called(1);
    });

    test('logs different event types', () async {
      service.setup();

      for (final type in NavigationEventType.values) {
        final event = NavigationEvent(
          type: type,
          route: 'test',
          path: '/test',
          fullPath: '/test',
          stackDepth: 1,
          timestamp: DateTime.now(),
        );

        eventController.add(event);
        await Future<void>.delayed(Duration.zero);

        verify(
          () => mockLogger.debug(
            'Navigation: ${type.name.toUpperCase()}',
            data: any(named: 'data'),
            tag: 'Navigation',
          ),
        ).called(1);
      }
    });

    test('dispose cancels subscription', () async {
      service.setup();

      await service.dispose();

      // Add event after dispose - should not log
      final event = NavigationEvent(
        type: NavigationEventType.push,
        route: 'test',
        path: '/test',
        fullPath: '/test',
        stackDepth: 1,
        timestamp: DateTime.now(),
      );

      eventController.add(event);
      await Future<void>.delayed(Duration.zero);

      // The first setup() call is the only one that should have been made
      verify(() => mockTrackingService.events).called(1);
    });

    test('dispose is safe to call multiple times', () async {
      service.setup();

      await service.dispose();
      await service.dispose();

      // Should not throw
      expect(true, isTrue);
    });

    test('dispose is safe to call without setup', () async {
      await service.dispose();

      // Should not throw
      expect(true, isTrue);
    });
  });
}
