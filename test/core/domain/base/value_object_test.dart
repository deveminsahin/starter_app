import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/domain/value_objects/name_failure.dart';
import 'package:starter_app/core/domain/value_objects/password_failure.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

/// Test implementation of ValueObject for testing purposes.
class TestValueObject extends ValueObject<String> {
  const TestValueObject._(this.value);

  factory TestValueObject.valid(String value) {
    return TestValueObject._(right(value));
  }

  factory TestValueObject.invalid(List<ValueFailure<String>> failures) {
    return TestValueObject._(left(failures));
  }

  @override
  final Either<List<ValueFailure<String>>, String> value;
}

void main() {
  group('ValueObject', () {
    group('getOrCrash', () {
      test('returns value when valid', () {
        const testValue = 'valid-value';
        final valueObject = TestValueObject.valid(testValue);

        expect(valueObject.getOrCrash(), testValue);
      });

      test('throws UnexpectedValueError when invalid', () {
        final failures = <ValueFailure<String>>[
          const NameFailure.empty(),
          const PasswordFailure.missingUppercase(),
        ];
        final valueObject = TestValueObject.invalid(failures);

        expect(
          valueObject.getOrCrash,
          throwsA(isA<UnexpectedValueError>()),
        );
      });

      test('throws UnexpectedValueError with correct failures', () {
        final failures = <ValueFailure<String>>[
          const NameFailure.empty(),
        ];
        final valueObject = TestValueObject.invalid(failures);

        expect(
          valueObject.getOrCrash,
          throwsA(
            predicate<Error>(
              (error) =>
                  error is UnexpectedValueError &&
                  error.valueFailures.length == failures.length,
            ),
          ),
        );
      });
    });

    group('getOrNull', () {
      test('returns value when valid', () {
        const testValue = 'valid-value';
        final valueObject = TestValueObject.valid(testValue);

        expect(valueObject.getOrNull(), testValue);
      });

      test('returns null when invalid', () {
        final failures = <ValueFailure<String>>[
          const NameFailure.empty(),
        ];
        final valueObject = TestValueObject.invalid(failures);

        expect(valueObject.getOrNull(), null);
      });

      test('returns null for multiple failures', () {
        final failures = <ValueFailure<String>>[
          const NameFailure.empty(),
          const PasswordFailure.missingUppercase(),
        ];
        final valueObject = TestValueObject.invalid(failures);

        expect(valueObject.getOrNull(), null);
      });
    });

    group('getFailuresOrNull', () {
      test('returns null when valid', () {
        const testValue = 'valid-value';
        final valueObject = TestValueObject.valid(testValue);

        expect(valueObject.getFailuresOrNull(), null);
      });

      test('returns failures when invalid', () {
        final failures = <ValueFailure<String>>[
          const NameFailure.empty(),
        ];
        final valueObject = TestValueObject.invalid(failures);

        final result = valueObject.getFailuresOrNull();
        expect(result, isNotNull);
        expect(result!.length, failures.length);
      });

      test('returns all failures when multiple failures exist', () {
        final failures = <ValueFailure<String>>[
          const NameFailure.empty(),
          const PasswordFailure.missingUppercase(),
        ];
        final valueObject = TestValueObject.invalid(failures);

        final result = valueObject.getFailuresOrNull();
        expect(result, isNotNull);
        expect(result!.length, 2);
      });
    });

    group('isValid', () {
      test('returns true when value is valid', () {
        const testValue = 'valid-value';
        final valueObject = TestValueObject.valid(testValue);

        expect(valueObject.isValid, true);
      });

      test('returns false when value is invalid', () {
        final failures = <ValueFailure<String>>[
          const NameFailure.empty(),
        ];
        final valueObject = TestValueObject.invalid(failures);

        expect(valueObject.isValid, false);
      });

      test('returns false when multiple failures exist', () {
        final failures = <ValueFailure<String>>[
          const NameFailure.empty(),
          const PasswordFailure.missingUppercase(),
        ];
        final valueObject = TestValueObject.invalid(failures);

        expect(valueObject.isValid, false);
      });
    });
  });

  group('UnexpectedValueError', () {
    test('creates error with value failures', () {
      final failures = <ValueFailure<dynamic>>[
        const NameFailure.empty(),
        const PasswordFailure.missingUppercase(),
      ];
      final error = UnexpectedValueError(failures);

      expect(error.valueFailures, failures);
    });

    test('toString includes explanation and failures', () {
      final failures = <ValueFailure<dynamic>>[
        const NameFailure.empty(),
      ];
      final error = UnexpectedValueError(failures);

      final errorString = error.toString();
      expect(errorString, contains('Encountered ValueFailure(s)'));
      expect(errorString, contains('Terminating'));
      expect(errorString, contains('Failures:'));
    });

    test('toString includes all failures', () {
      final failures = <ValueFailure<dynamic>>[
        const NameFailure.empty(),
        const PasswordFailure.missingUppercase(),
      ];
      final error = UnexpectedValueError(failures);

      final errorString = error.toString();
      // Freezed classes include the factory name in toString
      expect(errorString, contains('empty'));
      expect(errorString, contains('missingUppercase'));
    });

    test('handles empty failures list', () {
      final failures = <ValueFailure<dynamic>>[];
      final error = UnexpectedValueError(failures);

      expect(error.valueFailures, isEmpty);
      expect(error.toString(), contains('Failures: []'));
    });

    test('is an Error', () {
      final failures = <ValueFailure<dynamic>>[
        const NameFailure.empty(),
      ];
      final error = UnexpectedValueError(failures);

      expect(error, isA<Error>());
    });
  });
}
