import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/base/unique_id_failure.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

void main() {
  group('UniqueIdFailure', () {
    group('UniqueIdEmpty', () {
      test('creates correctly via factory constructor', () {
        const failure = UniqueIdFailure.empty();

        expect(failure, isA<UniqueIdEmpty>());
        expect(failure, isA<UniqueIdFailure>());
        expect(failure, isA<ValueFailure<dynamic>>());
      });

      test('equality works correctly', () {
        const failure1 = UniqueIdFailure.empty();
        const failure2 = UniqueIdFailure.empty();

        expect(failure1, equals(failure2));
        expect(failure1.hashCode, equals(failure2.hashCode));
      });

      test('when method returns correct callback result', () {
        const failure = UniqueIdFailure.empty();

        final result = failure.when(
          empty: () => 'ID is empty',
          invalidFormat: () => 'Invalid format',
        );

        expect(result, 'ID is empty');
      });

      test('map method returns correct callback result', () {
        const failure = UniqueIdFailure.empty();

        final result = failure.map(
          empty: (value) => 'Mapped: empty',
          invalidFormat: (value) => 'Mapped: invalid',
        );

        expect(result, 'Mapped: empty');
      });

      test('maybeWhen calls correct callback', () {
        const failure = UniqueIdFailure.empty();

        final result = failure.maybeWhen(
          empty: () => 'Empty',
          orElse: () => 'Other',
        );

        expect(result, 'Empty');
      });

      test('maybeWhen calls orElse when callback not provided', () {
        const failure = UniqueIdFailure.empty();

        final result = failure.maybeWhen(
          invalidFormat: () => 'Invalid',
          orElse: () => 'Fallback',
        );

        expect(result, 'Fallback');
      });
    });

    group('UniqueIdInvalidFormat', () {
      test('creates correctly via factory constructor', () {
        const failure = UniqueIdFailure.invalidFormat();

        expect(failure, isA<UniqueIdInvalidFormat>());
        expect(failure, isA<UniqueIdFailure>());
        expect(failure, isA<ValueFailure<dynamic>>());
      });

      test('equality works correctly', () {
        const failure1 = UniqueIdFailure.invalidFormat();
        const failure2 = UniqueIdFailure.invalidFormat();

        expect(failure1, equals(failure2));
        expect(failure1.hashCode, equals(failure2.hashCode));
      });

      test('when method returns correct callback result', () {
        const failure = UniqueIdFailure.invalidFormat();

        final result = failure.when(
          empty: () => 'ID is empty',
          invalidFormat: () => 'Invalid format',
        );

        expect(result, 'Invalid format');
      });

      test('map method returns correct callback result', () {
        const failure = UniqueIdFailure.invalidFormat();

        final result = failure.map(
          empty: (value) => 'Mapped: empty',
          invalidFormat: (value) => 'Mapped: invalid',
        );

        expect(result, 'Mapped: invalid');
      });

      test('maybeWhen calls correct callback', () {
        const failure = UniqueIdFailure.invalidFormat();

        final result = failure.maybeWhen(
          invalidFormat: () => 'Invalid',
          orElse: () => 'Other',
        );

        expect(result, 'Invalid');
      });
    });

    group('inequality between variants', () {
      test('empty is not equal to invalidFormat', () {
        const empty = UniqueIdFailure.empty();
        const invalidFormat = UniqueIdFailure.invalidFormat();

        expect(empty, isNot(equals(invalidFormat)));
      });
    });

    group('toString', () {
      test('empty returns meaningful representation', () {
        const failure = UniqueIdFailure.empty();

        expect(failure.toString(), contains('UniqueIdFailure'));
      });

      test('invalidFormat returns meaningful representation', () {
        const failure = UniqueIdFailure.invalidFormat();

        expect(failure.toString(), contains('UniqueIdFailure'));
      });
    });
  });
}
