import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_state.dart';

import '../helpers/fake_helpers.dart' show FakeSecureStorage;
import '../helpers/mock_helpers.dart';

/// Startup performance benchmarks.
///
/// These tests measure the time taken for critical startup operations.
/// Run with: `flutter test test/benchmarks/startup_benchmark_test.dart`
void main() {
  group('Startup Benchmarks', () {
    late GetIt getIt;

    setUp(() {
      getIt = GetIt.asNewInstance();
      HydratedBloc.storage = MockStorage();
    });

    tearDown(() async {
      await getIt.reset();
    });

    test('benchmark: GetIt registration time', () async {
      final stopwatch = Stopwatch()..start();

      // Simulate registering common dependencies using cascade
      getIt
        ..registerSingleton<MockAppLogger>(MockAppLogger())
        ..registerSingleton<MockTokenStorage>(MockTokenStorage())
        ..registerSingleton<MockSecureStorage>(MockSecureStorage())
        ..registerSingleton<MockAuthRepository>(MockAuthRepository())
        ..registerFactory<MockAuthBloc>(MockAuthBloc.new)
        ..registerFactory<MockThemeCubit>(MockThemeCubit.new)
        ..registerFactory<MockLocaleCubit>(MockLocaleCubit.new);

      stopwatch.stop();

      // Benchmark output for CI tracking
      // ignore: avoid_print
      print(
        'BENCHMARK: getit_registration = ${stopwatch.elapsedMicroseconds}μs',
      );

      // Registration should be very fast (< 10ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });

    test('benchmark: mock BLoC instantiation overhead', () async {
      final stopwatch = Stopwatch()..start();

      // Measures the overhead of creating mock BLoC instances.
      // This tests mocktail/bloc_test mock creation cost, not real BLoC startup.
      // Real BLoC performance depends on injected dependencies.
      final blocs = <dynamic>[
        MockAuthBloc(),
        MockThemeCubit(),
        MockLocaleCubit(),
        MockProfileBloc(),
      ];

      for (var i = 1; i < 10; i++) {
        blocs
          ..add(MockAuthBloc())
          ..add(MockThemeCubit())
          ..add(MockLocaleCubit())
          ..add(MockProfileBloc());
      }

      stopwatch.stop();

      // Benchmark output for CI tracking
      // ignore: avoid_print
      print(
        'BENCHMARK: mock_bloc_overhead_x40 = '
        '${stopwatch.elapsedMicroseconds}μs',
      );

      // 40 mock instantiations should be very fast (< 20ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(20));
      expect(blocs.length, equals(40));
    });

    test('benchmark: FakeSecureStorage operations under load', () async {
      // Tests in-memory storage performance for large test suites.
      // Uses FakeSecureStorage which is the actual test helper used in tests.
      final storage = FakeSecureStorage();

      final stopwatch = Stopwatch()..start();

      // Simulate realistic test suite storage usage
      for (var i = 0; i < 100; i++) {
        await storage.write(key: 'token_$i', value: 'access_token_value_$i');
        await storage.read(key: 'token_$i');
      }

      // Bulk operations
      for (var i = 0; i < 50; i++) {
        await storage.delete(key: 'token_$i');
      }

      stopwatch.stop();

      // Benchmark output for CI tracking
      // ignore: avoid_print
      print(
        'BENCHMARK: fake_storage_ops_x250 = '
        '${stopwatch.elapsedMicroseconds}μs',
      );

      // 250 storage operations should be very fast (< 50ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(50));

      // Verify remaining keys
      expect(storage.contents.length, equals(50));
    });

    test('benchmark: AuthState creation', () async {
      final stopwatch = Stopwatch()..start();

      // Create many state objects
      final states = <AuthState>[
        AuthState.empty(),
        const AuthState.unauthenticated(),
      ];

      for (var i = 1; i < 100; i++) {
        states
          ..add(AuthState.empty())
          ..add(const AuthState.unauthenticated());
      }

      stopwatch.stop();

      // Benchmark output for CI tracking
      // ignore: avoid_print
      print(
        'BENCHMARK: auth_state_creation_x200 = '
        '${stopwatch.elapsedMicroseconds}μs',
      );

      // 200 state creations should be fast (< 10ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
      expect(states.length, equals(200));
    });
  });
}
