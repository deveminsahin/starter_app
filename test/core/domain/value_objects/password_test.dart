import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/domain/value_objects/password.dart';
import 'package:starter_app/core/domain/value_objects/password_failure.dart';

void main() {
  group('Password', () {
    group('constructor', () {
      test('creates valid password with all requirements met', () {
        const validPassword = 'Test123!@#';
        final password = Password(validPassword);

        expect(password.isValid, true);
        expect(password.getOrCrash(), validPassword);
        expect(password.getOrNull(), validPassword);
        expect(password.getFailuresOrNull(), null);
      });

      test('accepts valid password with minimum requirements', () {
        final password = Password('Abc123!@');

        expect(password.isValid, true);
        expect(password.getOrCrash(), 'Abc123!@');
      });

      test('rejects empty password', () {
        final password = Password('');

        expect(password.isValid, false);

        final failures = password.getFailuresOrNull();
        expect(failures, isNotNull);
        expect(failures!.length, 1);
        expect(failures.first, isA<PasswordEmpty>());
      });

      test('rejects password without uppercase letter', () {
        final password = Password('test123!@#');

        expect(password.isValid, false);

        final failures = password.getFailuresOrNull();
        expect(failures, isNotNull);
        expect(
          failures!.any((f) => f is PasswordMissingUppercase),
          true,
        );
      });

      test('rejects password without lowercase letter', () {
        final password = Password('TEST123!@#');

        expect(password.isValid, false);

        final failures = password.getFailuresOrNull();
        expect(failures, isNotNull);
        expect(
          failures!.any((f) => f is PasswordMissingLowercase),
          true,
        );
      });

      test('rejects password without digit', () {
        final password = Password('TestTest!@#');

        expect(password.isValid, false);

        final failures = password.getFailuresOrNull();
        expect(failures, isNotNull);
        expect(
          failures!.any((f) => f is PasswordMissingDigit),
          true,
        );
      });

      test('rejects password without special character', () {
        final password = Password('Test1234');

        expect(password.isValid, false);

        final failures = password.getFailuresOrNull();
        expect(failures, isNotNull);
        expect(
          failures!.any((f) => f is PasswordMissingSpecialCharacter),
          true,
        );
      });

      test('rejects password shorter than minimum length', () {
        final password = Password('T1!a');

        expect(password.isValid, false);

        final failures = password.getFailuresOrNull();
        expect(failures, isNotNull);
        expect(
          failures!.any((f) => f is PasswordTooShort),
          true,
        );
      });

      test('rejects password longer than maximum length', () {
        final longPassword = 'A1!${'a' * 130}'; // > 128 chars
        final password = Password(longPassword);

        expect(password.isValid, false);

        final failures = password.getFailuresOrNull();
        expect(failures, isNotNull);
        expect(
          failures!.any((f) => f is PasswordTooLong),
          true,
        );
      });

      test('accumulates multiple validation failures', () {
        final password = Password('short'); // Too short, missing requirements

        expect(password.isValid, false);

        final failures = password.getFailuresOrNull();
        expect(failures, isNotNull);
        expect(failures!.length, greaterThan(1));

        // Should have multiple specific failures
        expect(failures.any((f) => f is PasswordTooShort), true);
        expect(failures.any((f) => f is PasswordMissingUppercase), true);
        expect(failures.any((f) => f is PasswordMissingDigit), true);
        expect(failures.any((f) => f is PasswordMissingSpecialCharacter), true);
      });

      test('accepts password with exactly minimum length', () {
        final password = Password('Test123!');

        expect(password.isValid, true);
      });

      test('accepts password with maximum length', () {
        final maxPassword = 'A1!${'a' * (Password.maxLength - 4)}';
        final password = Password(maxPassword);

        expect(password.isValid, true);
      });

      test('accepts various special characters', () {
        const specialChars = ['!', '@', '#', r'$', '%', '^', '&', '*'];

        for (final char in specialChars) {
          final password = Password('Test123$char');
          expect(password.isValid, true, reason: 'Should accept $char');
        }
      });
    });

    group('fromTrustedSource', () {
      test('creates password without validation', () {
        final password = Password.fromTrustedSource('hashed_password_123');

        expect(password.isValid, true);
        expect(password.getOrCrash(), 'hashed_password_123');
      });

      test('bypasses validation for weak passwords', () {
        final password = Password.fromTrustedSource('weak');

        expect(password.isValid, true);
      });
    });

    group('strengthLevel', () {
      test('returns invalid for invalid password', () {
        final password = Password('weak');

        expect(password.strengthLevel, PasswordStrength.invalid);
      });

      test('returns weak for minimum valid password', () {
        final password = Password('Test123!');

        expect(password.strengthLevel, PasswordStrength.weak);
      });

      test('returns good for good password (12+ chars)', () {
        final password = Password('Test12345678!');

        expect(password.strengthLevel, PasswordStrength.good);
      });

      test('returns strong for strong password (16+ chars)', () {
        final password = Password('Test123456789012!@');

        expect(password.strengthLevel, PasswordStrength.strong);
      });

      test('increases strength with multiple special chars and digits', () {
        final weakValid = Password('Test123!');
        final stronger = Password('Test123!!99');

        expect(stronger.strengthLevel, greaterThan(weakValid.strengthLevel));
      });
    });

    group('strengthLabel', () {
      test('returns "Invalid" for invalid password', () {
        final password = Password('weak');

        expect(password.strengthLabel, 'Invalid');
      });

      test('returns "Weak" for minimum valid password', () {
        final password = Password('Test123!');

        expect(password.strengthLabel, 'Weak');
      });

      test('returns "Good" for good password', () {
        final password = Password('Test12345678!');

        expect(password.strengthLabel, 'Good');
      });

      test('returns "Strong" for strong password', () {
        final password = Password('Test123456789012!@');

        expect(password.strengthLabel, 'Strong');
      });
    });

    group('getOrCrash', () {
      test('returns value when valid', () {
        final password = Password('Test123!@#');

        expect(password.getOrCrash(), 'Test123!@#');
      });

      test('throws UnexpectedValueError when invalid', () {
        final password = Password('invalid');

        expect(
          password.getOrCrash,
          throwsA(isA<UnexpectedValueError>()),
        );
      });
    });

    group('getOrNull', () {
      test('returns value when valid', () {
        final password = Password('Test123!@#');

        expect(password.getOrNull(), 'Test123!@#');
      });

      test('returns null when invalid', () {
        final password = Password('invalid');

        expect(password.getOrNull(), null);
      });
    });

    group('equality', () {
      test('equals another password with same value', () {
        final password1 = Password('Test123!@#');
        final password2 = Password('Test123!@#');

        expect(password1, password2);
        expect(password1.hashCode, password2.hashCode);
      });

      test('not equals password with different value', () {
        final password1 = Password('Test123!@#');
        final password2 = Password('Test456!@#');

        expect(password1, isNot(password2));
      });
    });

    group('toString', () {
      test('shows **** when valid (for security)', () {
        final password = Password('Test123!@#');

        expect(password.toString(), 'Password(****)');
      });

      test('shows "invalid" when invalid', () {
        final password = Password('weak');

        expect(password.toString(), 'Password(invalid)');
      });
    });

    group('edge cases', () {
      test('handles unicode characters', () {
        final password = Password('Test123!αβγ');

        expect(password.isValid, true);
      });

      test('handles all required special characters', () {
        final password = Password(r'Test123!@#$%^&*()');

        expect(password.isValid, true);
      });

      test('rejects password with only spaces', () {
        final password = Password('        ');

        expect(password.isValid, false);
      });

      test('handles password with exactly 12 characters', () {
        final password = Password('Test1234567!'); // 12 characters

        expect(password.isValid, true);
        // 12 chars gives +1 bonus, making it "good" (strength 2)
        expect(password.strengthLevel, PasswordStrength.good);
      });

      test('handles password with exactly 16 characters', () {
        final password = Password('Test1234567890!@');

        expect(password.isValid, true);
        expect(password.strengthLevel, PasswordStrength.strong);
      });

      test('handles password with multiple special characters', () {
        final password = Password('Test123!!@@##');

        expect(password.isValid, true);
      });

      test('handles password with multiple digits', () {
        final password = Password('Test123456!@');

        expect(password.isValid, true);
      });

      test('handles null input', () {
        // Note: Password constructor doesn't accept null, but testing edge case
        final password = Password('');

        expect(password.isValid, false);
      });
    });

    // Note: 'message property' tests removed since PasswordFailure no longer
    // has message getter. For localized messages, use FailureMessageService.
    group('type-based validation', () {
      test('empty password creates PasswordEmpty failure', () {
        final password = Password('');
        final failures = password.getFailuresOrNull();

        expect(failures!.first, isA<PasswordEmpty>());
      });

      test('short password creates PasswordTooShort failure', () {
        final password = Password('T1!a');
        final failures = password.getFailuresOrNull();
        final tooShort = failures!.whereType<PasswordTooShort>().first;

        expect(tooShort.minLength, Password.minLength);
        expect(tooShort.actualLength, 4);
      });

      test('missingUppercase failure is correct type', () {
        const failure = PasswordFailure.missingUppercase();

        expect(failure, isA<PasswordMissingUppercase>());
      });

      test('missingDigit failure is correct type', () {
        const failure = PasswordFailure.missingDigit();

        expect(failure, isA<PasswordMissingDigit>());
      });
    });
  });

  group('PasswordStrength', () {
    group('comparison operators', () {
      test('invalid < weak', () {
        expect(PasswordStrength.invalid < PasswordStrength.weak, true);
        expect(PasswordStrength.invalid <= PasswordStrength.weak, true);
      });

      test('weak < good', () {
        expect(PasswordStrength.weak < PasswordStrength.good, true);
        expect(PasswordStrength.weak <= PasswordStrength.good, true);
      });

      test('good < strong', () {
        expect(PasswordStrength.good < PasswordStrength.strong, true);
        expect(PasswordStrength.good <= PasswordStrength.strong, true);
      });

      test('strong > good', () {
        expect(PasswordStrength.strong > PasswordStrength.good, true);
        expect(PasswordStrength.strong >= PasswordStrength.good, true);
      });

      test('weak >= weak (equality)', () {
        expect(PasswordStrength.weak >= PasswordStrength.weak, true);
        expect(PasswordStrength.weak <= PasswordStrength.weak, true);
      });

      test('invalid <= invalid (equality)', () {
        expect(PasswordStrength.invalid <= PasswordStrength.invalid, true);
        expect(PasswordStrength.invalid >= PasswordStrength.invalid, true);
      });

      test('strong > invalid', () {
        expect(PasswordStrength.strong > PasswordStrength.invalid, true);
        expect(PasswordStrength.strong >= PasswordStrength.invalid, true);
      });

      test('invalid is not > weak', () {
        expect(PasswordStrength.invalid > PasswordStrength.weak, false);
      });

      test('weak is not < invalid', () {
        expect(PasswordStrength.weak < PasswordStrength.invalid, false);
      });
    });

    group('compareTo', () {
      test('returns negative when comparing invalid to weak', () {
        expect(
          PasswordStrength.invalid.compareTo(PasswordStrength.weak),
          lessThan(0),
        );
      });

      test('returns positive when comparing strong to good', () {
        expect(
          PasswordStrength.strong.compareTo(PasswordStrength.good),
          greaterThan(0),
        );
      });

      test('returns zero when comparing same strength', () {
        expect(
          PasswordStrength.weak.compareTo(PasswordStrength.weak),
          0,
        );
      });

      test('sorts strengths correctly', () {
        final strengths = [
          PasswordStrength.strong,
          PasswordStrength.invalid,
          PasswordStrength.good,
          PasswordStrength.weak,
        ]..sort();

        expect(strengths, [
          PasswordStrength.invalid,
          PasswordStrength.weak,
          PasswordStrength.good,
          PasswordStrength.strong,
        ]);
      });
    });

    group('value and label', () {
      test('invalid has correct value and label', () {
        expect(PasswordStrength.invalid.value, 0);
        expect(PasswordStrength.invalid.label, 'Invalid');
      });

      test('weak has correct value and label', () {
        expect(PasswordStrength.weak.value, 1);
        expect(PasswordStrength.weak.label, 'Weak');
      });

      test('good has correct value and label', () {
        expect(PasswordStrength.good.value, 2);
        expect(PasswordStrength.good.label, 'Good');
      });

      test('strong has correct value and label', () {
        expect(PasswordStrength.strong.value, 3);
        expect(PasswordStrength.strong.label, 'Strong');
      });
    });
  });
}
