import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:starter_app/core/domain/base/query.dart';
import 'package:starter_app/core/error/failures/infrastructure_failures.dart';
import 'package:starter_app/core/types/types.dart';

/// Test implementation of Query for testing purposes.
class TestQuery extends Query<String, int> {
  TestQuery(this._result);

  final FutureResult<int> Function(String) _result;

  @override
  FutureResult<int> call(String params) => _result(params);
}

/// Test implementation of QueryNoParams for testing purposes.
class TestQueryNoParams extends QueryNoParams<String> {
  TestQueryNoParams(this._result);

  final FutureResult<String> Function() _result;

  @override
  FutureResult<String> call() => _result();
}

/// Test implementation of StreamQuery for testing purposes.
class TestStreamQuery extends StreamQuery<String, int> {
  TestStreamQuery(this._result);

  final StreamResult<int> Function(String) _result;

  @override
  StreamResult<int> call(String params) => _result(params);
}

/// Test implementation of StreamQueryNoParams for testing purposes.
class TestStreamQueryNoParams extends StreamQueryNoParams<String> {
  TestStreamQueryNoParams(this._result);

  final StreamResult<String> Function() _result;

  @override
  StreamResult<String> call() => _result();
}

void main() {
  group('Query', () {
    test('can be instantiated', () {
      final query = TestQuery((params) async => right(42));

      expect(query, isNotNull);
    });

    test('executes call with params and returns result', () async {
      final query = TestQuery((params) async => right(42));
      final result = await query.call('test');

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (value) => expect(value, 42),
      );
    });

    test('handles failure result', () async {
      const failure = InfrastructureFailure.server(message: 'Test error');
      final query = TestQuery((params) async => left(failure));
      final result = await query.call('test');

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('Should not return value'),
      );
    });

    test('is instance of Query', () {
      final query = TestQuery((params) async => right(42));

      expect(query, isA<Query<String, int>>());
    });

    test('passes params correctly to implementation', () async {
      String? receivedParam;
      final query = TestQuery((params) async {
        receivedParam = params;
        return right(params.length);
      });

      await query.call('hello');

      expect(receivedParam, 'hello');
    });

    test('returns same result for same input (idempotent behavior)', () async {
      final query = TestQuery((params) async => right(params.length));

      final result1 = await query.call('test');
      final result2 = await query.call('test');

      expect(result1, result2);
    });
  });

  group('QueryNoParams', () {
    test('can be instantiated', () {
      final query = TestQueryNoParams(() async => right('result'));

      expect(query, isNotNull);
    });

    test('executes call without params and returns result', () async {
      final query = TestQueryNoParams(() async => right('result'));
      final result = await query.call();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (value) => expect(value, 'result'),
      );
    });

    test('handles failure result', () async {
      const failure = InfrastructureFailure.server(message: 'Test error');
      final query = TestQueryNoParams(() async => left(failure));
      final result = await query.call();

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('Should not return value'),
      );
    });

    test('is instance of QueryNoParams', () {
      final query = TestQueryNoParams(() async => right('result'));

      expect(query, isA<QueryNoParams<String>>());
    });
  });

  group('StreamQuery', () {
    test('can be instantiated', () {
      final query = TestStreamQuery(
        (params) => Stream.value(right(42)),
      );

      expect(query, isNotNull);
    });

    test('executes call with params and returns stream result', () async {
      final query = TestStreamQuery(
        (params) => Stream.value(right(42)),
      );
      final stream = query.call('test');
      final result = await stream.first;

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (value) => expect(value, 42),
      );
    });

    test('handles failure result in stream', () async {
      const failure = InfrastructureFailure.server(message: 'Test error');
      final query = TestStreamQuery(
        (params) => Stream.value(left(failure)),
      );
      final stream = query.call('test');
      final result = await stream.first;

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('Should not return value'),
      );
    });

    test('can emit multiple values', () async {
      final query = TestStreamQuery(
        (params) => Stream.fromIterable([
          right(1),
          right(2),
          right(3),
        ]),
      );
      final stream = query.call('test');
      final results = await stream.toList();

      expect(results.length, 3);
      expect(results[0].fold((l) => null, (r) => r), 1);
      expect(results[1].fold((l) => null, (r) => r), 2);
      expect(results[2].fold((l) => null, (r) => r), 3);
    });

    test('is instance of StreamQuery', () {
      final query = TestStreamQuery(
        (params) => Stream.value(right(42)),
      );

      expect(query, isA<StreamQuery<String, int>>());
    });
  });

  group('StreamQueryNoParams', () {
    test('can be instantiated', () {
      final query = TestStreamQueryNoParams(
        () => Stream.value(right('result')),
      );

      expect(query, isNotNull);
    });

    test('executes call without params and returns stream result', () async {
      final query = TestStreamQueryNoParams(
        () => Stream.value(right('result')),
      );
      final stream = query.call();
      final result = await stream.first;

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (value) => expect(value, 'result'),
      );
    });

    test('handles failure result in stream', () async {
      const failure = InfrastructureFailure.server(message: 'Test error');
      final query = TestStreamQueryNoParams(
        () => Stream.value(left(failure)),
      );
      final stream = query.call();
      final result = await stream.first;

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('Should not return value'),
      );
    });

    test('can emit multiple values', () async {
      final query = TestStreamQueryNoParams(
        () => Stream.fromIterable([
          right('value1'),
          right('value2'),
          right('value3'),
        ]),
      );
      final stream = query.call();
      final results = await stream.toList();

      expect(results.length, 3);
      expect(results[0].fold((l) => null, (r) => r), 'value1');
      expect(results[1].fold((l) => null, (r) => r), 'value2');
      expect(results[2].fold((l) => null, (r) => r), 'value3');
    });

    test('is instance of StreamQueryNoParams', () {
      final query = TestStreamQueryNoParams(
        () => Stream.value(right('result')),
      );

      expect(query, isA<StreamQueryNoParams<String>>());
    });
  });
}
