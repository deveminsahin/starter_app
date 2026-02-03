import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/application/application_environment.dart';
import 'package:starter_app/core/infrastructure/error/sentry_monitoring_initializer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SentryMonitoringInitializer', () {
    late SentryMonitoringInitializer initializer;

    setUp(() {
      initializer = const SentryMonitoringInitializer();
    });

    test('can be instantiated as const', () {
      const instance1 = SentryMonitoringInitializer();
      const instance2 = SentryMonitoringInitializer();

      expect(identical(instance1, instance2), isTrue);
    });

    group('initialize', () {
      test('returns false for development environment', () async {
        final result = await initializer.initialize(AppEnvironment.development);

        expect(result, isFalse);
      });

      test('returns false when monitoring is enabled but no DSN', () async {
        // Staging has monitoring enabled, but no DSN is set in test environment
        final result = await initializer.initialize(AppEnvironment.staging);

        expect(result, isFalse);
      });

      test(
        'initializes Sentry when DSN is provided',
        () async {
          final log = <MethodCall>[];
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                const MethodChannel('sentry_flutter'),
                (methodCall) async {
                  log.add(methodCall);
                  return null;
                },
              );

          try {
            final result = await initializer.initialize(
              AppEnvironment.staging,
              dsnOverride: 'https://example@sentry.io/123',
            );

            expect(result, isTrue);
            expect(log, isNotEmpty);
          } finally {
            // Clean up
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
                .setMockMethodCallHandler(
                  const MethodChannel('sentry_flutter'),
                  null,
                );
          }
        },
        // Skip in CI if Sentry native bindings unavailable
        skip: Platform.environment['CI'] == 'true',
      );

      test('returns true when Sentry is successfully initialized', () async {
        // Mock the Sentry method channel
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('sentry_flutter'),
              (methodCall) async => null,
            );

        final result = await initializer.initialize(
          AppEnvironment.production,
          dsnOverride: 'https://example@sentry.io/456',
        );

        expect(result, isTrue);

        // Clean up
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('sentry_flutter'),
              null,
            );
      });
    });
  });
}
