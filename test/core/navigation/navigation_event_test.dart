import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/navigation/navigation_event.dart';
import 'package:starter_app/core/navigation/navigation_event_type.dart';

void main() {
  group('NavigationEvent', () {
    test('creates with all required fields', () {
      final timestamp = DateTime.now();
      final event = NavigationEvent(
        type: NavigationEventType.push,
        route: 'dashboard',
        path: '/dashboard',
        fullPath: '/dashboard',
        stackDepth: 1,
        timestamp: timestamp,
      );

      expect(event.type, NavigationEventType.push);
      expect(event.route, 'dashboard');
      expect(event.path, '/dashboard');
      expect(event.fullPath, '/dashboard');
      expect(event.stackDepth, 1);
      expect(event.timestamp, timestamp);
      expect(event.previousRoute, isNull);
    });

    test('creates with optional previousRoute', () {
      final event = NavigationEvent(
        type: NavigationEventType.push,
        route: 'profile',
        path: '/profile',
        fullPath: '/profile',
        stackDepth: 2,
        timestamp: DateTime.now(),
        previousRoute: 'dashboard',
      );

      expect(event.previousRoute, 'dashboard');
    });

    test('toString includes all relevant fields', () {
      final event = NavigationEvent(
        type: NavigationEventType.push,
        route: 'profile',
        path: '/profile',
        fullPath: '/profile',
        stackDepth: 2,
        timestamp: DateTime.now(),
        previousRoute: 'dashboard',
      );

      final str = event.toString();

      expect(str, contains('push'));
      expect(str, contains('profile'));
      expect(str, contains('dashboard'));
      expect(str, contains('2'));
      expect(str, contains('/profile'));
    });

    test('toString handles null previousRoute', () {
      final event = NavigationEvent(
        type: NavigationEventType.pop,
        route: 'dashboard',
        path: '/dashboard',
        fullPath: '/dashboard',
        stackDepth: 1,
        timestamp: DateTime.now(),
      );

      final str = event.toString();

      expect(str, contains('null'));
      expect(str, contains('pop'));
    });

    group('NavigationEventType', () {
      test('has all expected values', () {
        expect(NavigationEventType.values, hasLength(4));
        expect(NavigationEventType.values, contains(NavigationEventType.push));
        expect(NavigationEventType.values, contains(NavigationEventType.pop));
        expect(
          NavigationEventType.values,
          contains(NavigationEventType.replace),
        );
        expect(
          NavigationEventType.values,
          contains(NavigationEventType.remove),
        );
      });

      test('name returns correct string', () {
        expect(NavigationEventType.push.name, 'push');
        expect(NavigationEventType.pop.name, 'pop');
        expect(NavigationEventType.replace.name, 'replace');
        expect(NavigationEventType.remove.name, 'remove');
      });
    });
  });
}
