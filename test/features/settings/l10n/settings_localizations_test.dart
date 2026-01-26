import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/features/settings/l10n/settings_localizations.dart';
import 'package:starter_app/features/settings/l10n/settings_localizations_en.dart';
import 'package:starter_app/features/settings/l10n/settings_localizations_es.dart';

void main() {
  group('SettingsLocalizations', () {
    group('lookupSettingsLocalizations', () {
      test('returns English localizations for en locale', () {
        final localizations = lookupSettingsLocalizations(const Locale('en'));

        expect(localizations, isA<SettingsLocalizationsEn>());
        expect(localizations.appBarTitle, equals('Settings'));
      });

      test('returns Spanish localizations for es locale', () {
        final localizations = lookupSettingsLocalizations(const Locale('es'));

        expect(localizations, isA<SettingsLocalizationsEs>());
        expect(localizations.appBarTitle, equals('Configuración'));
      });

      test('throws FlutterError for unsupported locale', () {
        expect(
          () => lookupSettingsLocalizations(const Locale('fr')),
          throwsA(isA<FlutterError>()),
        );
      });
    });

    group('SettingsLocalizationsDelegate', () {
      test('isSupported returns true for en', () {
        const delegate = SettingsLocalizations.delegate;

        expect(delegate.isSupported(const Locale('en')), isTrue);
      });

      test('isSupported returns true for es', () {
        const delegate = SettingsLocalizations.delegate;

        expect(delegate.isSupported(const Locale('es')), isTrue);
      });

      test('isSupported returns false for unsupported locale', () {
        const delegate = SettingsLocalizations.delegate;

        expect(delegate.isSupported(const Locale('fr')), isFalse);
      });

      test('load returns correct localizations for en', () async {
        const delegate = SettingsLocalizations.delegate;
        final localizations = await delegate.load(const Locale('en'));

        expect(localizations, isA<SettingsLocalizationsEn>());
      });

      test('load returns correct localizations for es', () async {
        const delegate = SettingsLocalizations.delegate;
        final localizations = await delegate.load(const Locale('es'));

        expect(localizations, isA<SettingsLocalizationsEs>());
      });

      test('shouldReload returns false', () {
        const delegate = SettingsLocalizations.delegate;

        expect(delegate.shouldReload(delegate), isFalse);
      });
    });

    group('supportedLocales', () {
      test('contains en and es', () {
        expect(
          SettingsLocalizations.supportedLocales,
          containsAll([const Locale('en'), const Locale('es')]),
        );
      });
    });

    group('localizationsDelegates', () {
      test('contains the settings delegate', () {
        expect(
          SettingsLocalizations.localizationsDelegates,
          contains(SettingsLocalizations.delegate),
        );
      });
    });
  });

  group('SettingsLocalizationsEn', () {
    test('has correct localeName', () {
      final localizations = SettingsLocalizationsEn();

      expect(localizations.localeName, equals('en'));
    });

    test('all strings are correct', () {
      final localizations = SettingsLocalizationsEn();

      expect(localizations.appBarTitle, equals('Settings'));
      expect(localizations.languageSectionTitle, equals('Language'));
      expect(localizations.languageEnglish, equals('English'));
      expect(localizations.languageSpanish, equals('Spanish'));
      expect(localizations.themeSectionTitle, equals('Theme'));
      expect(localizations.themeLight, equals('Light'));
      expect(localizations.themeDark, equals('Dark'));
      expect(localizations.themeSystem, equals('System'));
      expect(localizations.logOut, equals('Log out'));
    });
  });

  group('SettingsLocalizationsEs', () {
    test('has correct localeName', () {
      final localizations = SettingsLocalizationsEs();

      expect(localizations.localeName, equals('es'));
    });

    test('all strings are correct', () {
      final localizations = SettingsLocalizationsEs();

      expect(localizations.appBarTitle, equals('Configuración'));
      expect(localizations.languageSectionTitle, equals('Idioma'));
      expect(localizations.languageEnglish, equals('Inglés'));
      expect(localizations.languageSpanish, equals('Español'));
      expect(localizations.themeSectionTitle, equals('Tema'));
      expect(localizations.themeLight, equals('Claro'));
      expect(localizations.themeDark, equals('Oscuro'));
      expect(localizations.themeSystem, equals('Sistema'));
      expect(localizations.logOut, equals('Cerrar sesión'));
    });
  });
}
