import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:starter_app/core/domain/base/usecase.dart';
import 'package:starter_app/core/error/failures/infrastructure_failures.dart';
import 'package:starter_app/core/types/types.dart';

/// Test implementation of UseCase for testing purposes.
class TestUseCase extends UseCase<String, int> {
  TestUseCase(this._result);

  final FutureResult<int> Function(String) _result;

  @override
  FutureResult<int> call(String params) => _result(params);
}

/// Test implementation of UseCaseNoParams for testing purposes.
class TestUseCaseNoParams extends UseCaseNoParams<String> {
  TestUseCaseNoParams(this._result);

  final FutureResult<String> Function() _result;

  @override
  FutureResult<String> call() => _result();
}

/// Test implementation of StreamUseCase for testing purposes.
class TestStreamUseCase extends StreamUseCase<String, int> {
  TestStreamUseCase(this._result);

  final StreamResult<int> Function(String) _result;

  @override
  StreamResult<int> call(String params) => _result(params);
}

/// Test implementation of StreamUseCaseNoParams for testing purposes.
class TestStreamUseCaseNoParams extends StreamUseCaseNoParams<String> {
  TestStreamUseCaseNoParams(this._result);

  final StreamResult<String> Function() _result;

  @override
  StreamResult<String> call() => _result();
}

void main() {
  group('UseCase', () {
    test('can be instantiated', () {
      final useCase = TestUseCase((params) async => right(42));

      expect(useCase, isNotNull);
    });

    test('executes call with params and returns result', () async {
      final useCase = TestUseCase((params) async => right(42));
      final result = await useCase.call('test');

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (value) => expect(value, 42),
      );
    });

    test('handles failure result', () async {
      const failure = InfrastructureFailure.server(message: 'Test error');
      final useCase = TestUseCase((params) async => left(failure));
      final result = await useCase.call('test');

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('Should not return value'),
      );
    });

    test('is instance of UseCase', () {
      final useCase = TestUseCase((params) async => right(42));

      expect(useCase, isA<UseCase<String, int>>());
    });
  });

  group('UseCaseNoParams', () {
    test('can be instantiated', () {
      final useCase = TestUseCaseNoParams(() async => right('result'));

      expect(useCase, isNotNull);
    });

    test('executes call without params and returns result', () async {
      final useCase = TestUseCaseNoParams(() async => right('result'));
      final result = await useCase.call();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (value) => expect(value, 'result'),
      );
    });

    test('handles failure result', () async {
      const failure = InfrastructureFailure.server(message: 'Test error');
      final useCase = TestUseCaseNoParams(() async => left(failure));
      final result = await useCase.call();

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('Should not return value'),
      );
    });

    test('is instance of UseCaseNoParams', () {
      final useCase = TestUseCaseNoParams(() async => right('result'));

      expect(useCase, isA<UseCaseNoParams<String>>());
    });
  });

  group('StreamUseCase', () {
    test('can be instantiated', () {
      final useCase = TestStreamUseCase(
        (params) => Stream.value(right(42)),
      );

      expect(useCase, isNotNull);
    });

    test('executes call with params and returns stream result', () async {
      final useCase = TestStreamUseCase(
        (params) => Stream.value(right(42)),
      );
      final stream = useCase.call('test');
      final result = await stream.first;

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (value) => expect(value, 42),
      );
    });

    test('handles failure result in stream', () async {
      const failure = InfrastructureFailure.server(message: 'Test error');
      final useCase = TestStreamUseCase(
        (params) => Stream.value(left(failure)),
      );
      final stream = useCase.call('test');
      final result = await stream.first;

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('Should not return value'),
      );
    });

    test('can emit multiple values', () async {
      final useCase = TestStreamUseCase(
        (params) => Stream.fromIterable([
          right(1),
          right(2),
          right(3),
        ]),
      );
      final stream = useCase.call('test');
      final results = await stream.toList();

      expect(results.length, 3);
      expect(results[0].fold((l) => null, (r) => r), 1);
      expect(results[1].fold((l) => null, (r) => r), 2);
      expect(results[2].fold((l) => null, (r) => r), 3);
    });

    test('is instance of StreamUseCase', () {
      final useCase = TestStreamUseCase(
        (params) => Stream.value(right(42)),
      );

      expect(useCase, isA<StreamUseCase<String, int>>());
    });
  });

  group('StreamUseCaseNoParams', () {
    test('can be instantiated', () {
      final useCase = TestStreamUseCaseNoParams(
        () => Stream.value(right('result')),
      );

      expect(useCase, isNotNull);
    });

    test('executes call without params and returns stream result', () async {
      final useCase = TestStreamUseCaseNoParams(
        () => Stream.value(right('result')),
      );
      final stream = useCase.call();
      final result = await stream.first;

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (value) => expect(value, 'result'),
      );
    });

    test('handles failure result in stream', () async {
      const failure = InfrastructureFailure.server(message: 'Test error');
      final useCase = TestStreamUseCaseNoParams(
        () => Stream.value(left(failure)),
      );
      final stream = useCase.call();
      final result = await stream.first;

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('Should not return value'),
      );
    });

    test('can emit multiple values', () async {
      final useCase = TestStreamUseCaseNoParams(
        () => Stream.fromIterable([
          right('value1'),
          right('value2'),
          right('value3'),
        ]),
      );
      final stream = useCase.call();
      final results = await stream.toList();

      expect(results.length, 3);
      expect(results[0].fold((l) => null, (r) => r), 'value1');
      expect(results[1].fold((l) => null, (r) => r), 'value2');
      expect(results[2].fold((l) => null, (r) => r), 'value3');
    });

    test('is instance of StreamUseCaseNoParams', () {
      final useCase = TestStreamUseCaseNoParams(
        () => Stream.value(right('result')),
      );

      expect(useCase, isA<StreamUseCaseNoParams<String>>());
    });
  });
}
