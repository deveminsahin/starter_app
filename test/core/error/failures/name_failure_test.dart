import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/value_objects/name_failure.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

void main() {
  group('NameFailure', () {
    group('NameEmpty', () {
      test('creates correctly via factory constructor', () {
        const failure = NameFailure.empty();

        expect(failure, isA<NameEmpty>());
        expect(failure, isA<NameFailure>());
        expect(failure, isA<ValueFailure<dynamic>>());
      });

      test('equality works correctly', () {
        const failure1 = NameFailure.empty();
        const failure2 = NameFailure.empty();

        expect(failure1, equals(failure2));
        expect(failure1.hashCode, equals(failure2.hashCode));
      });

      test('when method returns correct callback result', () {
        const failure = NameFailure.empty();

        final result = failure.when(
          empty: () => 'Name is empty',
          tooLong: (_, _) => 'Name is too long',
        );

        expect(result, 'Name is empty');
      });

      test('map method returns correct callback result', () {
        const failure = NameFailure.empty();

        final result = failure.map(
          empty: (value) => 'Mapped: empty',
          tooLong: (value) => 'Mapped: tooLong',
        );

        expect(result, 'Mapped: empty');
      });

      test('maybeWhen calls correct callback', () {
        const failure = NameFailure.empty();

        final result = failure.maybeWhen(
          empty: () => 'Empty',
          orElse: () => 'Other',
        );

        expect(result, 'Empty');
      });

      test('maybeWhen calls orElse when callback not provided', () {
        const failure = NameFailure.empty();

        final result = failure.maybeWhen(
          orElse: () => 'Fallback',
        );

        expect(result, 'Fallback');
      });

      test('toString returns meaningful representation', () {
        const failure = NameFailure.empty();

        expect(failure.toString(), contains('NameFailure'));
      });
    });

    group('NameTooLong', () {
      test('creates correctly via factory constructor', () {
        const failure = NameFailure.tooLong(
          maxLength: 100,
          actualLength: 150,
        );

        expect(failure, isA<NameTooLong>());
        expect(failure, isA<NameFailure>());
        expect(failure, isA<ValueFailure<dynamic>>());
      });

      test('equality works correctly', () {
        const failure1 = NameFailure.tooLong(
          maxLength: 100,
          actualLength: 150,
        );
        const failure2 = NameFailure.tooLong(
          maxLength: 100,
          actualLength: 150,
        );

        expect(failure1, equals(failure2));
        expect(failure1.hashCode, equals(failure2.hashCode));
      });

      test('different values are not equal', () {
        const failure1 = NameFailure.tooLong(
          maxLength: 100,
          actualLength: 150,
        );
        const failure2 = NameFailure.tooLong(
          maxLength: 100,
          actualLength: 200,
        );

        expect(failure1, isNot(equals(failure2)));
      });

      test('when method returns correct callback result', () {
        const failure = NameFailure.tooLong(
          maxLength: 100,
          actualLength: 150,
        );

        final result = failure.when(
          empty: () => 'Name is empty',
          tooLong: (max, actual) => 'Name is too long: $actual > $max',
        );

        expect(result, 'Name is too long: 150 > 100');
      });

      test('map method returns correct callback result', () {
        const failure = NameFailure.tooLong(
          maxLength: 100,
          actualLength: 150,
        );

        final result = failure.map(
          empty: (value) => 'Mapped: empty',
          tooLong: (value) => 'Mapped: tooLong ${value.actualLength}',
        );

        expect(result, 'Mapped: tooLong 150');
      });

      test('maybeWhen calls correct callback', () {
        const failure = NameFailure.tooLong(
          maxLength: 100,
          actualLength: 150,
        );

        final result = failure.maybeWhen(
          tooLong: (max, actual) => 'Too long: $actual',
          orElse: () => 'Other',
        );

        expect(result, 'Too long: 150');
      });
    });
  });
}
