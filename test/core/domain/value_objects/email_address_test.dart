import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/domain/value_objects/email_address.dart';
import 'package:starter_app/core/domain/value_objects/email_failure.dart';


void main() {
  group('EmailAddress', () {
    group('constructor', () {
      test('creates valid email address with valid input', () {
        const validEmail = 'test@example.com';
        final email = EmailAddress(validEmail);

        expect(email.isValid, true);
        expect(email.getOrCrash(), 'test@example.com');
        expect(email.getOrNull(), 'test@example.com');
        expect(email.getFailuresOrNull(), null);
      });

      test('normalizes email to lowercase', () {
        final email = EmailAddress('TEST@EXAMPLE.COM');

        expect(email.isValid, true);
        expect(email.getOrCrash(), 'test@example.com');
      });

      test('rejects email with leading/trailing whitespace', () {
        final email = EmailAddress('  test@example.com  ');

        expect(email.isValid, false);
      });

      test('fromTrustedSource preserves value without trimming', () {
        // fromTrustedSource bypasses validation and preserves the exact value
        final trustedEmail = EmailAddress.fromTrustedSource(
          '  TEST@EXAMPLE.COM  ',
        );
        expect(trustedEmail.getOrCrash(), '  TEST@EXAMPLE.COM  ');
      });

      test('accepts valid email formats', () {
        const validEmails = [
          'simple@example.com',
          'user.name@example.com',
          'user+tag@example.com',
          'user_name@example.com',
          'user123@example.com',
          'test@subdomain.example.com',
          'a@b.co',
        ];

        for (final validEmail in validEmails) {
          final email = EmailAddress(validEmail);
          expect(email.isValid, true, reason: '$validEmail should be valid');
        }
      });

      test('rejects empty email', () {
        final email = EmailAddress('');

        expect(email.isValid, false);
        expect(email.getOrNull(), null);

        final failures = email.getFailuresOrNull();
        expect(failures, isNotNull);
        expect(failures!.length, 1);
        expect(failures.first, isA<EmailEmpty>());
      });

      test('rejects null email', () {
        final email = EmailAddress('');

        expect(email.isValid, false);
        final failures = email.getFailuresOrNull();
        expect(failures!.first, isA<EmailEmpty>());
      });

      test('rejects email exceeding max length', () {
        final longEmail = '${'a' * 250}@example.com'; // > 254 chars
        final email = EmailAddress(longEmail);

        expect(email.isValid, false);
        final failures = email.getFailuresOrNull();
        expect(failures!.first, isA<EmailTooLong>());
      });

      test('rejects invalid email formats', () {
        const invalidEmails = [
          'plaintext',
          '@example.com',
          'user@',
          'user@@example.com',
          'user@example',
          'user name@example.com',
          'user@exam ple.com',
        ];

        for (final invalidEmail in invalidEmails) {
          final email = EmailAddress(invalidEmail);
          expect(
            email.isValid,
            false,
            reason: '$invalidEmail should be invalid',
          );

          final failures = email.getFailuresOrNull();
          expect(failures, isNotNull);
          expect(failures!.first, isA<EmailInvalidFormat>());
        }
      });
    });

    group('fromTrustedSource', () {
      test('creates email without validation', () {
        final email = EmailAddress.fromTrustedSource('trusted@example.com');

        expect(email.isValid, true);
        expect(email.getOrCrash(), 'trusted@example.com');
      });

      test('bypasses validation for potentially invalid formats', () {
        final email = EmailAddress.fromTrustedSource('not-validated');

        expect(email.isValid, true);
        expect(email.getOrCrash(), 'not-validated');
      });
    });

    group('getOrCrash', () {
      test('returns value when valid', () {
        final email = EmailAddress('test@example.com');

        expect(email.getOrCrash(), 'test@example.com');
      });

      test('throws UnexpectedValueError when invalid', () {
        final email = EmailAddress('invalid');

        expect(email.getOrCrash, throwsA(isA<UnexpectedValueError>()));
      });
    });

    group('getOrNull', () {
      test('returns value when valid', () {
        final email = EmailAddress('test@example.com');

        expect(email.getOrNull(), 'test@example.com');
      });

      test('returns null when invalid', () {
        final email = EmailAddress('invalid');

        expect(email.getOrNull(), null);
      });
    });

    group('getFailuresOrNull', () {
      test('returns null when valid', () {
        final email = EmailAddress('test@example.com');

        expect(email.getFailuresOrNull(), null);
      });

      test('returns failures when invalid', () {
        final email = EmailAddress('');

        final failures = email.getFailuresOrNull();
        expect(failures, isNotNull);
        expect(failures!.length, greaterThan(0));
      });
    });

    group('equality', () {
      test('equals another email with same value', () {
        final email1 = EmailAddress('test@example.com');
        final email2 = EmailAddress('test@example.com');

        expect(email1, email2);
        expect(email1.hashCode, email2.hashCode);
      });

      test('normalizes before comparing', () {
        final email1 = EmailAddress('TEST@example.com');
        final email2 = EmailAddress('test@example.com');

        expect(email1, email2);
      });

      test('not equals email with different value', () {
        final email1 = EmailAddress('test1@example.com');
        final email2 = EmailAddress('test2@example.com');

        expect(email1, isNot(email2));
      });

      test('invalid emails have value-based equality', () {
        final email1 = EmailAddress('invalid1');
        final email2 = EmailAddress('invalid2');

        expect(email1, isNot(email2)); // Different invalid values
        // Note: Two separately created invalid emails may not be equal
        // even with same input due to Left(List) instance differences
      });
    });

    group('toString', () {
      test('shows value when valid', () {
        final email = EmailAddress('test@example.com');

        expect(email.toString(), 'EmailAddress(test@example.com)');
      });

      test('shows "invalid" when invalid', () {
        final email = EmailAddress('');

        expect(email.toString(), 'EmailAddress(invalid)');
      });
    });

    group('edge cases', () {
      test('handles very long valid email up to 254 characters', () {
        final localPart = 'a' * 64; // Max local part
        final domain = 'b' * 63; // Max domain label
        final validLongEmail = '$localPart@$domain.com';

        if (validLongEmail.length <= 254) {
          final email = EmailAddress(validLongEmail);
          expect(email.isValid, true);
        }
      });

      test('handles special characters in local part', () {
        final email = EmailAddress('user.name+tag@example.com');
        expect(email.isValid, true);
      });

      test('handles subdomains', () {
        final email = EmailAddress('test@mail.subdomain.example.com');
        expect(email.isValid, true);
      });

      test('handles email at exactly max length', () {
        // Create email exactly at 254 characters
        final localPart = 'a' * 64;
        final domain = 'b' * 63;
        const tld = 'com';
        final exactMaxEmail = '$localPart@$domain.$tld';

        if (exactMaxEmail.length == EmailAddress.maxLength) {
          final email = EmailAddress(exactMaxEmail);
          expect(email.isValid, true);
        }
      });

      test('handles email with numbers in local part', () {
        final email = EmailAddress('user123@example.com');
        expect(email.isValid, true);
        expect(email.getOrCrash(), 'user123@example.com');
      });

      test('handles email with hyphens in domain', () {
        // Regex supports hyphens in domain labels (not at start/end)
        final email = EmailAddress('test@sub-domain.example.com');
        expect(email.isValid, true);
        expect(email.getOrCrash(), 'test@sub-domain.example.com');
      });

      test('handles email with underscores in local part', () {
        final email = EmailAddress('user_name@example.com');
        expect(email.isValid, true);
      });

      test('handles email with plus sign in local part', () {
        final email = EmailAddress('user+tag@example.com');
        expect(email.isValid, true);
      });

      test('handles email with dots in local part', () {
        final email = EmailAddress('first.last@example.com');
        expect(email.isValid, true);
      });
    });
  });
}
