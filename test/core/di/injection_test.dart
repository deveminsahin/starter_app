import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:starter_app/core/application/application_environment.dart';
import 'package:starter_app/core/di/injection.dart';

void main() {
  setUpAll(() {
    // Initialize Flutter bindings required for dependency injection
    // (e.g., SharedPreferences, HydratedStorage)
    TestWidgetsFlutterBinding.ensureInitialized();

    // Set up method channels for platform plugins
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (methodCall) async {
            if (methodCall.method == 'getTemporaryDirectory') {
              return '/tmp';
            }
            return null;
          },
        );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/shared_preferences'),
          (methodCall) async {
            return <String, dynamic>{};
          },
        );
  });

  tearDownAll(() {
    // Clean up method channel handlers
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/shared_preferences'),
          null,
        );
  });

  group('configureDependencies', () {
    tearDown(() async {
      // Reset GetIt after each test to avoid conflicts
      await GetIt.instance.reset();
    });

    test('completes successfully with development environment', () async {
      // Act & Assert
      await expectLater(
        configureDependencies(AppEnvironment.development),
        completes,
      );
    });

    test('completes successfully with staging environment', () async {
      // Act & Assert
      await expectLater(
        configureDependencies(AppEnvironment.staging),
        completes,
      );
    });

    test('completes successfully with production environment', () async {
      // Act & Assert
      await expectLater(
        configureDependencies(AppEnvironment.production),
        completes,
      );
    });

    test('can be called multiple times with different environments', () async {
      // Act & Assert - should complete without error
      await configureDependencies(AppEnvironment.development);
      await GetIt.instance.reset();

      await configureDependencies(AppEnvironment.staging);
      await GetIt.instance.reset();

      await configureDependencies(AppEnvironment.production);
    });
  });
}
