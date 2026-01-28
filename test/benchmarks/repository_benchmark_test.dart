import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/features/auth/infrastructure/models/auth_tokens_model.dart';
import 'package:starter_app/features/auth/infrastructure/models/user_model.dart';

import '../helpers/test_data.dart';

/// Repository and data layer performance benchmarks.
///
/// These tests measure JSON parsing, model creation, and data transformations.
/// Run with: `flutter test test/benchmarks/repository_benchmark_test.dart`
void main() {
  group('Repository Benchmarks', () {
    group('JSON Parsing', () {
      test('benchmark: UserModel fromJson', () {
        const json = TestData.userJson;

        final stopwatch = Stopwatch()..start();

        // Parse 100 times
        for (var i = 0; i < 100; i++) {
          UserModel.fromJson(json);
        }

        stopwatch.stop();

        // Benchmark output for CI tracking
        // ignore: avoid_print
        print(
          'BENCHMARK: user_model_from_json_x100 = '
          '${stopwatch.elapsedMicroseconds}μs',
        );

        // 100 parses should be fast (< 50ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });

      test('benchmark: UserModel toJson', () {
        final model = UserModel.fromJson(TestData.userJson);

        final stopwatch = Stopwatch()..start();

        // Serialize 100 times
        for (var i = 0; i < 100; i++) {
          model.toJson();
        }

        stopwatch.stop();

        // Benchmark output for CI tracking
        // ignore: avoid_print
        print(
          'BENCHMARK: user_model_to_json_x100 = '
          '${stopwatch.elapsedMicroseconds}μs',
        );

        // 100 serializations should be fast (< 50ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });

      test('benchmark: AuthTokensModel fromJson', () {
        const json = TestData.authTokensJson;

        final stopwatch = Stopwatch()..start();

        // Parse 100 times
        for (var i = 0; i < 100; i++) {
          AuthTokensModel.fromJson(json);
        }

        stopwatch.stop();

        // Benchmark output for CI tracking
        // ignore: avoid_print
        print(
          'BENCHMARK: auth_tokens_from_json_x100 = '
          '${stopwatch.elapsedMicroseconds}μs',
        );

        // 100 parses should be fast (< 50ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });

      test('benchmark: large JSON parsing', () {
        // Create a large JSON response (simulating paginated list)
        final users = List.generate(50, (i) => TestData.userJson);
        final largeJson = jsonEncode({'users': users, 'total': 50});

        final stopwatch = Stopwatch()..start();

        // Parse 10 times
        for (var i = 0; i < 10; i++) {
          final decoded = jsonDecode(largeJson) as Map<String, dynamic>;
          final userList = decoded['users'] as List;
          for (final user in userList) {
            UserModel.fromJson(user as Map<String, dynamic>);
          }
        }

        stopwatch.stop();

        // Benchmark output for CI tracking
        // ignore: avoid_print
        print(
          'BENCHMARK: large_json_parse_x10 = '
          '${stopwatch.elapsedMilliseconds}ms',
        );

        // 10 large parses should be reasonable (< 200ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
      });
    });

    group('Domain Transformations', () {
      test('benchmark: UserModel toDomain', () {
        final model = UserModel.fromJson(TestData.userJson);

        final stopwatch = Stopwatch()..start();

        // Transform 100 times
        for (var i = 0; i < 100; i++) {
          model.toDomain();
        }

        stopwatch.stop();

        // Benchmark output for CI tracking
        // ignore: avoid_print
        print(
          'BENCHMARK: user_model_to_domain_x100 = '
          '${stopwatch.elapsedMicroseconds}μs',
        );

        // 100 transformations should be fast (< 100ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('benchmark: Value object creation', () {
        final stopwatch = Stopwatch()..start();

        // Create 100 value objects
        for (var i = 0; i < 100; i++) {
          TestData.emailAddress();
          TestData.passwordVO();
          TestData.nameVO();
        }

        stopwatch.stop();

        // Benchmark output for CI tracking
        // ignore: avoid_print
        print(
          'BENCHMARK: value_object_creation_x300 = '
          '${stopwatch.elapsedMicroseconds}μs',
        );

        // 300 value object creations should be fast (< 50ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });

      test('benchmark: credentials factory', () {
        final stopwatch = Stopwatch()..start();

        // Create 100 credentials
        for (var i = 0; i < 100; i++) {
          TestData.loginCredentials();
          TestData.registerCredentials();
        }

        stopwatch.stop();

        // Benchmark output for CI tracking
        // ignore: avoid_print
        print(
          'BENCHMARK: credentials_creation_x200 = '
          '${stopwatch.elapsedMicroseconds}μs',
        );

        // 200 credential creations should be fast (< 100ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('Memory Pressure', () {
      test('benchmark: repeated object creation and disposal', () {
        final stopwatch = Stopwatch()..start();

        // Create and discard many objects
        for (var i = 0; i < 1000; i++) {
          final model = UserModel.fromJson(TestData.userJson);
          final user = model.toDomain();
          // Objects go out of scope and are eligible for GC
          expect(user, isNotNull);
        }

        stopwatch.stop();

        // Benchmark output for CI tracking
        // ignore: avoid_print
        print(
          'BENCHMARK: object_churn_x1000 = ${stopwatch.elapsedMilliseconds}ms',
        );

        // 1000 object creations should be reasonable (< 500ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });
  });
}
