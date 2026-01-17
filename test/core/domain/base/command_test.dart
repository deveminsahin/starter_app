import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:starter_app/core/domain/base/command.dart';
import 'package:starter_app/core/error/failures/infrastructure_failures.dart';
import 'package:starter_app/core/types/types.dart';

/// Test implementation of Command for testing purposes.
class TestCommand extends Command<String, int> {
  TestCommand(this._result);

  final FutureResult<int> Function(String) _result;

  @override
  FutureResult<int> call(String params) => _result(params);
}

/// Test implementation of CommandNoParams for testing purposes.
class TestCommandNoParams extends CommandNoParams<String> {
  TestCommandNoParams(this._result);

  final FutureResult<String> Function() _result;

  @override
  FutureResult<String> call() => _result();
}

/// Test implementation of StreamCommand for testing purposes.
class TestStreamCommand extends StreamCommand<String, int> {
  TestStreamCommand(this._result);

  final StreamResult<int> Function(String) _result;

  @override
  StreamResult<int> call(String params) => _result(params);
}

/// Test implementation of StreamCommandNoParams for testing purposes.
class TestStreamCommandNoParams extends StreamCommandNoParams<String> {
  TestStreamCommandNoParams(this._result);

  final StreamResult<String> Function() _result;

  @override
  StreamResult<String> call() => _result();
}

void main() {
  group('Command', () {
    test('can be instantiated', () {
      final command = TestCommand((params) async => right(42));

      expect(command, isNotNull);
    });

    test('executes call with params and returns result', () async {
      final command = TestCommand((params) async => right(42));
      final result = await command.call('test');

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (value) => expect(value, 42),
      );
    });

    test('handles failure result', () async {
      const failure = InfrastructureFailure.server(message: 'Test error');
      final command = TestCommand((params) async => left(failure));
      final result = await command.call('test');

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('Should not return value'),
      );
    });

    test('is instance of Command', () {
      final command = TestCommand((params) async => right(42));

      expect(command, isA<Command<String, int>>());
    });

    test('passes params correctly to implementation', () async {
      String? receivedParam;
      final command = TestCommand((params) async {
        receivedParam = params;
        return right(params.length);
      });

      await command.call('hello');

      expect(receivedParam, 'hello');
    });
  });

  group('CommandNoParams', () {
    test('can be instantiated', () {
      final command = TestCommandNoParams(() async => right('result'));

      expect(command, isNotNull);
    });

    test('executes call without params and returns result', () async {
      final command = TestCommandNoParams(() async => right('result'));
      final result = await command.call();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (value) => expect(value, 'result'),
      );
    });

    test('handles failure result', () async {
      const failure = InfrastructureFailure.server(message: 'Test error');
      final command = TestCommandNoParams(() async => left(failure));
      final result = await command.call();

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('Should not return value'),
      );
    });

    test('is instance of CommandNoParams', () {
      final command = TestCommandNoParams(() async => right('result'));

      expect(command, isA<CommandNoParams<String>>());
    });
  });

  group('StreamCommand', () {
    test('can be instantiated', () {
      final command = TestStreamCommand(
        (params) => Stream.value(right(42)),
      );

      expect(command, isNotNull);
    });

    test('executes call with params and returns stream result', () async {
      final command = TestStreamCommand(
        (params) => Stream.value(right(42)),
      );
      final stream = command.call('test');
      final result = await stream.first;

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (value) => expect(value, 42),
      );
    });

    test('handles failure result in stream', () async {
      const failure = InfrastructureFailure.server(message: 'Test error');
      final command = TestStreamCommand(
        (params) => Stream.value(left(failure)),
      );
      final stream = command.call('test');
      final result = await stream.first;

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('Should not return value'),
      );
    });

    test('can emit multiple values', () async {
      final command = TestStreamCommand(
        (params) => Stream.fromIterable([
          right(1),
          right(2),
          right(3),
        ]),
      );
      final stream = command.call('test');
      final results = await stream.toList();

      expect(results.length, 3);
      expect(results[0].fold((l) => null, (r) => r), 1);
      expect(results[1].fold((l) => null, (r) => r), 2);
      expect(results[2].fold((l) => null, (r) => r), 3);
    });

    test('is instance of StreamCommand', () {
      final command = TestStreamCommand(
        (params) => Stream.value(right(42)),
      );

      expect(command, isA<StreamCommand<String, int>>());
    });
  });

  group('StreamCommandNoParams', () {
    test('can be instantiated', () {
      final command = TestStreamCommandNoParams(
        () => Stream.value(right('result')),
      );

      expect(command, isNotNull);
    });

    test('executes call without params and returns stream result', () async {
      final command = TestStreamCommandNoParams(
        () => Stream.value(right('result')),
      );
      final stream = command.call();
      final result = await stream.first;

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (value) => expect(value, 'result'),
      );
    });

    test('handles failure result in stream', () async {
      const failure = InfrastructureFailure.server(message: 'Test error');
      final command = TestStreamCommandNoParams(
        () => Stream.value(left(failure)),
      );
      final stream = command.call();
      final result = await stream.first;

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('Should not return value'),
      );
    });

    test('can emit multiple values', () async {
      final command = TestStreamCommandNoParams(
        () => Stream.fromIterable([
          right('value1'),
          right('value2'),
          right('value3'),
        ]),
      );
      final stream = command.call();
      final results = await stream.toList();

      expect(results.length, 3);
      expect(results[0].fold((l) => null, (r) => r), 'value1');
      expect(results[1].fold((l) => null, (r) => r), 'value2');
      expect(results[2].fold((l) => null, (r) => r), 'value3');
    });

    test('is instance of StreamCommandNoParams', () {
      final command = TestStreamCommandNoParams(
        () => Stream.value(right('result')),
      );

      expect(command, isA<StreamCommandNoParams<String>>());
    });
  });
}
