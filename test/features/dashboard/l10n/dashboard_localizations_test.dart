import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/features/dashboard/l10n/dashboard_localizations.dart';
import 'package:starter_app/features/dashboard/l10n/dashboard_localizations_en.dart';
import 'package:starter_app/features/dashboard/l10n/dashboard_localizations_es.dart';

void main() {
  group('DashboardLocalizations', () {
    group('lookupDashboardLocalizations', () {
      test('returns English localizations for en locale', () {
        final localizations = lookupDashboardLocalizations(const Locale('en'));

        expect(localizations, isA<DashboardLocalizationsEn>());
        expect(localizations.appBarTitle, equals('Dashboard'));
      });

      test('returns Spanish localizations for es locale', () {
        final localizations = lookupDashboardLocalizations(const Locale('es'));

        expect(localizations, isA<DashboardLocalizationsEs>());
        expect(localizations.appBarTitle, equals('Tablero'));
      });

      test('throws FlutterError for unsupported locale', () {
        expect(
          () => lookupDashboardLocalizations(const Locale('fr')),
          throwsA(isA<FlutterError>()),
        );
      });
    });

    group('DashboardLocalizationsDelegate', () {
      test('isSupported returns true for en', () {
        const delegate = DashboardLocalizations.delegate;

        expect(delegate.isSupported(const Locale('en')), isTrue);
      });

      test('isSupported returns true for es', () {
        const delegate = DashboardLocalizations.delegate;

        expect(delegate.isSupported(const Locale('es')), isTrue);
      });

      test('isSupported returns false for unsupported locale', () {
        const delegate = DashboardLocalizations.delegate;

        expect(delegate.isSupported(const Locale('fr')), isFalse);
      });

      test('load returns correct localizations for en', () async {
        const delegate = DashboardLocalizations.delegate;
        final localizations = await delegate.load(const Locale('en'));

        expect(localizations, isA<DashboardLocalizationsEn>());
      });

      test('load returns correct localizations for es', () async {
        const delegate = DashboardLocalizations.delegate;
        final localizations = await delegate.load(const Locale('es'));

        expect(localizations, isA<DashboardLocalizationsEs>());
      });

      test('shouldReload returns false', () {
        const delegate = DashboardLocalizations.delegate;

        expect(delegate.shouldReload(delegate), isFalse);
      });
    });

    group('supportedLocales', () {
      test('contains en and es', () {
        expect(
          DashboardLocalizations.supportedLocales,
          containsAll([const Locale('en'), const Locale('es')]),
        );
      });
    });

    group('localizationsDelegates', () {
      test('contains the dashboard delegate', () {
        expect(
          DashboardLocalizations.localizationsDelegates,
          contains(DashboardLocalizations.delegate),
        );
      });
    });
  });

  group('DashboardLocalizationsEn', () {
    test('has correct localeName', () {
      final localizations = DashboardLocalizationsEn();

      expect(localizations.localeName, equals('en'));
    });

    test('appBarTitle returns Dashboard', () {
      final localizations = DashboardLocalizationsEn();

      expect(localizations.appBarTitle, equals('Dashboard'));
    });
  });

  group('DashboardLocalizationsEs', () {
    test('has correct localeName', () {
      final localizations = DashboardLocalizationsEs();

      expect(localizations.localeName, equals('es'));
    });

    test('appBarTitle returns Tablero', () {
      final localizations = DashboardLocalizationsEs();

      expect(localizations.appBarTitle, equals('Tablero'));
    });
  });
}
