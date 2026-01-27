import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';
import 'package:starter_app/features/auth/domain/value_objects/token_failure.dart';

void main() {
  group('TokenFailure', () {
    group('TokenEmpty', () {
      test('creates correctly via factory constructor', () {
        const failure = TokenFailure.empty();

        expect(failure, isA<TokenEmpty>());
        expect(failure, isA<TokenFailure>());
        expect(failure, isA<ValueFailure<dynamic>>());
      });

      test('equality works correctly', () {
        const failure1 = TokenFailure.empty();
        const failure2 = TokenFailure.empty();

        expect(failure1, equals(failure2));
        expect(failure1.hashCode, equals(failure2.hashCode));
      });

      test('when method returns correct callback result', () {
        const failure = TokenFailure.empty();

        final result = failure.when(
          empty: () => 'Token is empty',
          tooShort: (_, _) => 'Too short',
          invalidFormat: (_) => 'Invalid format',
          expired: () => 'Expired',
        );

        expect(result, 'Token is empty');
      });
    });

    group('TokenTooShort', () {
      test('creates correctly with required parameters', () {
        const failure = TokenFailure.tooShort(
          minLength: 10,
          actualLength: 5,
        );

        expect(failure, isA<TokenTooShort>());
        expect(failure, isA<TokenFailure>());
      });

      test('stores minLength and actualLength correctly', () {
        const failure = TokenFailure.tooShort(
          minLength: 10,
          actualLength: 5,
        );
        const tooShort = failure as TokenTooShort;

        expect(tooShort.minLength, 10);
        expect(tooShort.actualLength, 5);
      });

      test('equality works correctly with same values', () {
        const failure1 = TokenFailure.tooShort(
          minLength: 10,
          actualLength: 5,
        );
        const failure2 = TokenFailure.tooShort(
          minLength: 10,
          actualLength: 5,
        );

        expect(failure1, equals(failure2));
      });

      test('inequality works correctly with different values', () {
        const failure1 = TokenFailure.tooShort(
          minLength: 10,
          actualLength: 5,
        );
        const failure2 = TokenFailure.tooShort(
          minLength: 8,
          actualLength: 3,
        );

        expect(failure1, isNot(equals(failure2)));
      });

      test('when method returns correct callback result', () {
        const failure = TokenFailure.tooShort(
          minLength: 10,
          actualLength: 5,
        );

        final result = failure.when(
          empty: () => 'Empty',
          tooShort: (min, actual) => 'Min: $min, Actual: $actual',
          invalidFormat: (_) => 'Invalid format',
          expired: () => 'Expired',
        );

        expect(result, 'Min: 10, Actual: 5');
      });
    });

    group('TokenInvalidFormat', () {
      test('creates correctly with required parameters', () {
        const failure = TokenFailure.invalidFormat(
          expectedFormat: 'JWT',
        );

        expect(failure, isA<TokenInvalidFormat>());
        expect(failure, isA<TokenFailure>());
      });

      test('stores expectedFormat correctly', () {
        const failure = TokenFailure.invalidFormat(
          expectedFormat: 'JWT',
        );
        const invalidFormat = failure as TokenInvalidFormat;

        expect(invalidFormat.expectedFormat, 'JWT');
      });

      test('equality works correctly', () {
        const failure1 = TokenFailure.invalidFormat(
          expectedFormat: 'JWT',
        );
        const failure2 = TokenFailure.invalidFormat(
          expectedFormat: 'JWT',
        );

        expect(failure1, equals(failure2));
      });

      test('when method returns correct callback result', () {
        const failure = TokenFailure.invalidFormat(
          expectedFormat: 'Bearer',
        );

        final result = failure.when(
          empty: () => 'Empty',
          tooShort: (_, _) => 'Too short',
          invalidFormat: (format) => 'Expected: $format',
          expired: () => 'Expired',
        );

        expect(result, 'Expected: Bearer');
      });
    });

    group('TokenExpired', () {
      test('creates correctly via factory constructor', () {
        const failure = TokenFailure.expired();

        expect(failure, isA<TokenExpired>());
        expect(failure, isA<TokenFailure>());
      });

      test('equality works correctly', () {
        const failure1 = TokenFailure.expired();
        const failure2 = TokenFailure.expired();

        expect(failure1, equals(failure2));
        expect(failure1.hashCode, equals(failure2.hashCode));
      });

      test('when method returns correct callback result', () {
        const failure = TokenFailure.expired();

        final result = failure.when(
          empty: () => 'Empty',
          tooShort: (_, _) => 'Too short',
          invalidFormat: (_) => 'Invalid format',
          expired: () => 'Token has expired',
        );

        expect(result, 'Token has expired');
      });
    });

    group('pattern matching', () {
      test('maybeWhen returns correct callback for each variant', () {
        const empty = TokenFailure.empty();
        const tooShort = TokenFailure.tooShort(
          minLength: 10,
          actualLength: 5,
        );
        const invalidFormat = TokenFailure.invalidFormat(
          expectedFormat: 'JWT',
        );
        const expired = TokenFailure.expired();

        expect(
          empty.maybeWhen(
            empty: () => 'E',
            orElse: () => 'X',
          ),
          'E',
        );
        expect(
          tooShort.maybeWhen(
            tooShort: (_, _) => 'T',
            orElse: () => 'X',
          ),
          'T',
        );
        expect(
          invalidFormat.maybeWhen(
            invalidFormat: (_) => 'I',
            orElse: () => 'X',
          ),
          'I',
        );
        expect(
          expired.maybeWhen(
            expired: () => 'EX',
            orElse: () => 'X',
          ),
          'EX',
        );
      });

      test('map method works for all variants', () {
        const empty = TokenFailure.empty();
        const expired = TokenFailure.expired();

        expect(
          empty.map(
            empty: (_) => 'empty',
            tooShort: (_) => 'tooShort',
            invalidFormat: (_) => 'invalidFormat',
            expired: (_) => 'expired',
          ),
          'empty',
        );
        expect(
          expired.map(
            empty: (_) => 'empty',
            tooShort: (_) => 'tooShort',
            invalidFormat: (_) => 'invalidFormat',
            expired: (_) => 'expired',
          ),
          'expired',
        );
      });
    });
  });
}
