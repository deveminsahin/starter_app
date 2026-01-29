import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/l10n/arb/app_localizations_es.dart';

void main() {
  late AppLocalizationsEs localizations;

  setUp(() {
    localizations = AppLocalizationsEs();
  });

  group('AppLocalizationsEs', () {
    group('static getters', () {
      test('appName returns expected value', () {
        expect(localizations.appName, 'Aplicación Inicial');
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
        expect(localizations.passwordMissingUppercase, contains('mayúscula'));
      });

      test('passwordMissingLowercase returns expected value', () {
        expect(localizations.passwordMissingLowercase, contains('minúscula'));
      });

      test('passwordMissingDigit returns expected value', () {
        expect(localizations.passwordMissingDigit, contains('dígito'));
      });

      test('passwordMissingSpecialCharacter returns expected value', () {
        expect(
          localizations.passwordMissingSpecialCharacter,
          contains('especial'),
        );
      });

      test('emailEmpty returns expected value', () {
        expect(localizations.emailEmpty, isNotEmpty);
      });

      test('emailInvalidFormat returns expected value', () {
        expect(localizations.emailInvalidFormat, contains('válido'));
      });

      test('nameEmpty returns expected value', () {
        expect(localizations.nameEmpty, isNotEmpty);
        expect(localizations.nameEmpty, 'El nombre es requerido');
      });

      test('pageNotFound returns expected value', () {
        expect(localizations.pageNotFound, isNotEmpty);
        expect(localizations.pageNotFound, 'Página no encontrada');
      });

      test('goBack returns expected value', () {
        expect(localizations.goBack, isNotEmpty);
        expect(localizations.goBack, 'Volver');
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
        expect(result.toLowerCase(), contains('contraseña'));
      });

      test('passwordTooLong includes maxLength parameter', () {
        // Arrange
        const maxLength = 128;

        // Act
        final result = localizations.passwordTooLong(maxLength);

        // Assert
        expect(result, contains('$maxLength'));
        expect(result.toLowerCase(), contains('contraseña'));
      });

      test('emailTooLong includes maxLength parameter', () {
        // Arrange
        const maxLength = 254;

        // Act
        final result = localizations.emailTooLong(maxLength);

        // Assert
        expect(result, contains('$maxLength'));
        expect(result.toLowerCase(), contains('correo'));
      });

      test('nameTooLong includes maxLength parameter', () {
        // Arrange
        const maxLength = 50;

        // Act
        final result = localizations.nameTooLong(maxLength);

        // Assert
        expect(result, contains('$maxLength'));
        expect(result.toLowerCase(), contains('nombre'));
      });
    });

    group('constructor', () {
      test('default locale is es', () {
        final l10n = AppLocalizationsEs();
        expect(l10n.localeName, 'es');
      });

      test('custom locale is accepted', () {
        final l10n = AppLocalizationsEs('es_MX');
        expect(l10n.localeName, 'es_MX');
      });
    });
  });
}
