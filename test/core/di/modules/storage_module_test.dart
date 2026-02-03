import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_app/core/di/modules/storage_module.dart';

class TestStorageModule extends StorageModule {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Mock Path Provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (methodCall) async {
            if (methodCall.method == 'getTemporaryDirectory') {
              return '.';
            }
            return null;
          },
        );

    // Mock SharedPreferences
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/shared_preferences'),
          (methodCall) async {
            if (methodCall.method == 'getAll') {
              return <String, dynamic>{};
            }
            return null;
          },
        );
  });

  group('StorageModule', () {
    late TestStorageModule module;

    setUp(() {
      module = TestStorageModule();
    });

    group('provideHydratedStorage', () {
      test('should return HydratedStorage', () async {
        final storage = await module.provideHydratedStorage();
        expect(storage, isA<HydratedStorage>());
      });
    });

    group('provideSharedPreferences', () {
      test('should return SharedPreferences', () async {
        final prefs = await module.provideSharedPreferences();
        expect(prefs, isA<SharedPreferences>());
      });
    });

    group('provideFlutterSecureStorage', () {
      test('should return FlutterSecureStorage', () {
        final storage = module.provideFlutterSecureStorage();
        expect(storage, isA<FlutterSecureStorage>());
      });
    });
  });
}
