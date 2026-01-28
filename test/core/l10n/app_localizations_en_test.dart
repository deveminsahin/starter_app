import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/l10n/arb/app_localizations_en.dart';

void main() {
  late AppLocalizationsEn localizations;

  setUp(() {
    localizations = AppLocalizationsEn();
  });

  group('AppLocalizationsEn', () {
    group('static getters', () {
      test('appName returns expected value', () {
        expect(localizations.appName, 'Starter App');
      });

      test('unexpectedError returns expected value', () {
        expect(localizations.unexpectedError, isNotEmpty);
      });

      test('serverError returns expected value', () {
        expect(localizations.serverError, isNotEmpty);
      });

      test('networkError returns expected value', () {
        expect(localizations.networkError, isNotEmpty);
      });

      test('cacheError returns expected value', () {
        expect(localizations.cacheError, isNotEmpty);
      });

      test('parseError returns expected value', () {
        expect(localizations.parseError, isNotEmpty);
      });

      test('circuitBreakerError returns expected value', () {
        expect(localizations.circuitBreakerError, isNotEmpty);
      });

      test('passwordEmpty returns expected value', () {
        expect(localizations.passwordEmpty, isNotEmpty);
      });

      test('passwordMissingUppercase returns expected value', () {
        expect(localizations.passwordMissingUppercase, contains('uppercase'));
      });

      test('passwordMissingLowercase returns expected value', () {
        expect(localizations.passwordMissingLowercase, contains('lowercase'));
      });

      test('passwordMissingDigit returns expected value', () {
        expect(localizations.passwordMissingDigit, contains('digit'));
      });

      test('passwordMissingSpecialCharacter returns expected value', () {
        expect(
          localizations.passwordMissingSpecialCharacter,
          contains('special'),
        );
      });

      test('emailEmpty returns expected value', () {
        expect(localizations.emailEmpty, isNotEmpty);
      });

      test('emailInvalidFormat returns expected value', () {
        expect(localizations.emailInvalidFormat, contains('valid'));
      });

      test('nameEmpty returns expected value', () {
        expect(localizations.nameEmpty, isNotEmpty);
      });
    });

    group('parameterized methods', () {
      test('passwordTooShort includes minLength parameter', () {
        // Arrange
        const minLength = 8;

        // Act
        final result = localizations.passwordTooShort(minLength);

        // Assert
        expect(result, contains('$minLength'));
        expect(result.toLowerCase(), contains('password'));
      });

      test('passwordTooLong includes maxLength parameter', () {
        // Arrange
        const maxLength = 128;

        // Act
        final result = localizations.passwordTooLong(maxLength);

        // Assert
        expect(result, contains('$maxLength'));
        expect(result.toLowerCase(), contains('password'));
      });

      test('emailTooLong includes maxLength parameter', () {
        // Arrange
        const maxLength = 254;

        // Act
        final result = localizations.emailTooLong(maxLength);

        // Assert
        expect(result, contains('$maxLength'));
        expect(result.toLowerCase(), contains('email'));
      });
    });

    group('constructor', () {
      test('default locale is en', () {
        final l10n = AppLocalizationsEn();
        expect(l10n.localeName, 'en');
      });

      test('custom locale is accepted', () {
        final l10n = AppLocalizationsEn('en_US');
        expect(l10n.localeName, 'en_US');
      });
    });
  });
}
