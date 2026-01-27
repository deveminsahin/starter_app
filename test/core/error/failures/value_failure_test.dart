import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/base/unique_id_failure.dart';
import 'package:starter_app/core/domain/value_objects/email_failure.dart';
import 'package:starter_app/core/domain/value_objects/name_failure.dart';
import 'package:starter_app/core/domain/value_objects/password_failure.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';
import 'package:starter_app/features/auth/domain/value_objects/token_failure.dart';

void main() {
  group('ValueFailure hierarchy', () {
    test('all domain-specific failures extend ValueFailure', () {
      const passwordFailure = PasswordFailure.empty();
      const emailFailure = EmailFailure.empty();
      const nameFailure = NameFailure.empty();
      const tokenFailure = TokenFailure.empty();
      const uniqueIdFailure = UniqueIdFailure.empty();

      expect(passwordFailure, isA<ValueFailure<String>>());
      expect(emailFailure, isA<ValueFailure<String>>());
      expect(nameFailure, isA<ValueFailure<String>>());
      expect(tokenFailure, isA<ValueFailure<String>>());
      expect(uniqueIdFailure, isA<ValueFailure<String>>());
    });
  });

  group('PasswordFailure', () {
    group('empty', () {
      test('creates empty password failure', () {
        const failure = PasswordFailure.empty();

        expect(failure, isA<PasswordEmpty>());
      });

      test('equals another empty failure', () {
        const failure1 = PasswordFailure.empty();
        const failure2 = PasswordFailure.empty();

        expect(failure1, failure2);
      });
    });

    group('tooShort', () {
      test('creates too short failure with lengths', () {
        const failure = PasswordFailure.tooShort(
          minLength: 8,
          actualLength: 5,
        );

        expect(failure, isA<PasswordTooShort>());
        failure.when(
          empty: () => fail('Wrong type'),
          tooShort: (minLength, actualLength) {
            expect(minLength, 8);
            expect(actualLength, 5);
          },
          tooLong: (_, _) => fail('Wrong type'),
          missingUppercase: () => fail('Wrong type'),
          missingLowercase: () => fail('Wrong type'),
          missingDigit: () => fail('Wrong type'),
          missingSpecialCharacter: () => fail('Wrong type'),
        );
      });

      test('equals another tooShort failure with same values', () {
        const failure1 = PasswordFailure.tooShort(
          minLength: 8,
          actualLength: 5,
        );
        const failure2 = PasswordFailure.tooShort(
          minLength: 8,
          actualLength: 5,
        );

        expect(failure1, failure2);
      });

      test('not equals tooShort failure with different values', () {
        const failure1 = PasswordFailure.tooShort(
          minLength: 8,
          actualLength: 5,
        );
        const failure2 = PasswordFailure.tooShort(
          minLength: 10,
          actualLength: 5,
        );

        expect(failure1, isNot(failure2));
      });
    });

    group('tooLong', () {
      test('creates too long failure with lengths', () {
        const failure = PasswordFailure.tooLong(
          maxLength: 128,
          actualLength: 150,
        );

        expect(failure, isA<PasswordTooLong>());
        failure.when(
          empty: () => fail('Wrong type'),
          tooShort: (_, _) => fail('Wrong type'),
          tooLong: (maxLength, actualLength) {
            expect(maxLength, 128);
            expect(actualLength, 150);
          },
          missingUppercase: () => fail('Wrong type'),
          missingLowercase: () => fail('Wrong type'),
          missingDigit: () => fail('Wrong type'),
          missingSpecialCharacter: () => fail('Wrong type'),
        );
      });
    });

    group('character requirements', () {
      test('creates missingUppercase failure', () {
        const failure = PasswordFailure.missingUppercase();

        expect(failure, isA<PasswordMissingUppercase>());
      });

      test('creates missingLowercase failure', () {
        const failure = PasswordFailure.missingLowercase();

        expect(failure, isA<PasswordMissingLowercase>());
      });

      test('creates missingDigit failure', () {
        const failure = PasswordFailure.missingDigit();

        expect(failure, isA<PasswordMissingDigit>());
      });

      test('creates missingSpecialCharacter failure', () {
        const failure = PasswordFailure.missingSpecialCharacter();

        expect(failure, isA<PasswordMissingSpecialCharacter>());
      });

    });

    group('pattern matching', () {
      test('when handles all cases', () {
        const failures = <PasswordFailure>[
          PasswordFailure.empty(),
          PasswordFailure.tooShort(minLength: 8, actualLength: 5),
          PasswordFailure.tooLong(maxLength: 128, actualLength: 150),
          PasswordFailure.missingUppercase(),
          PasswordFailure.missingLowercase(),
          PasswordFailure.missingDigit(),
          PasswordFailure.missingSpecialCharacter(),
        ];

        for (final failure in failures) {
          final message = failure.when(
            empty: () => 'empty',
            tooShort: (min, actual) => 'tooShort:$min:$actual',
            tooLong: (max, actual) => 'tooLong:$max:$actual',
            missingUppercase: () => 'uppercase',
            missingLowercase: () => 'lowercase',
            missingDigit: () => 'digit',
            missingSpecialCharacter: () => 'special',
          );
          expect(message, isNotEmpty);
        }
      });
    });
  });

  group('EmailFailure', () {
    test('creates empty failure', () {
      const failure = EmailFailure.empty();

      expect(failure, isA<EmailEmpty>());
    });

    test('creates tooLong failure with lengths', () {
      const failure = EmailFailure.tooLong(
        maxLength: 254,
        actualLength: 300,
      );

      expect(failure, isA<EmailTooLong>());
      failure.when(
        empty: () => fail('Wrong type'),
        tooLong: (maxLength, actualLength) {
          expect(maxLength, 254);
          expect(actualLength, 300);
        },
        invalidFormat: (_) => fail('Wrong type'),
      );
    });

    test('creates invalidFormat failure with failed value', () {
      const failure = EmailFailure.invalidFormat(failedValue: 'not-an-email');

      expect(failure, isA<EmailInvalidFormat>());
      failure.when(
        empty: () => fail('Wrong type'),
        tooLong: (_, _) => fail('Wrong type'),
        invalidFormat: (failedValue) {
          expect(failedValue, 'not-an-email');
        },
      );
    });
  });

  group('NameFailure', () {
    test('creates empty failure', () {
      const failure = NameFailure.empty();

      expect(failure, isA<NameEmpty>());
    });

    test('equals another empty failure', () {
      const failure1 = NameFailure.empty();
      const failure2 = NameFailure.empty();

      expect(failure1, failure2);
    });
  });

  group('TokenFailure', () {
    test('creates empty failure', () {
      const failure = TokenFailure.empty();

      expect(failure, isA<TokenEmpty>());
    });
  });

  group('UniqueIdFailure', () {
    test('creates empty failure', () {
      const failure = UniqueIdFailure.empty();

      expect(failure, isA<UniqueIdEmpty>());
    });
  });
}
