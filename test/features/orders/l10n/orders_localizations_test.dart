import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/features/orders/l10n/orders_localizations.dart';
import 'package:starter_app/features/orders/l10n/orders_localizations_en.dart';
import 'package:starter_app/features/orders/l10n/orders_localizations_es.dart';

void main() {
  group('OrdersLocalizations', () {
    test('supports expected locales', () {
      expect(
        OrdersLocalizations.supportedLocales,
        containsAll([
          const Locale('en'),
          const Locale('es'),
        ]),
      );
    });

    test('delegate is supported for en and es', () {
      expect(
        OrdersLocalizations.delegate.isSupported(const Locale('en')),
        isTrue,
      );
      expect(
        OrdersLocalizations.delegate.isSupported(const Locale('es')),
        isTrue,
      );
      expect(
        OrdersLocalizations.delegate.isSupported(const Locale('fr')),
        isFalse,
      );
    });

    test('delegate.shouldReload returns false', () {
      expect(
        OrdersLocalizations.delegate.shouldReload(OrdersLocalizations.delegate),
        isFalse,
      );
    });

    test('load returns correct localization instance', () async {
      final en = await OrdersLocalizations.delegate.load(const Locale('en'));
      expect(en, isA<OrdersLocalizationsEn>());

      final es = await OrdersLocalizations.delegate.load(const Locale('es'));
      expect(es, isA<OrdersLocalizationsEs>());
    });

    testWidgets('localizations are accessible via context', (tester) async {
      late OrdersLocalizations localizations;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: OrdersLocalizations.localizationsDelegates,
          supportedLocales: OrdersLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Builder(
            builder: (context) {
              localizations = OrdersLocalizations.of(context);
              return Container();
            },
          ),
        ),
      );

      expect(localizations, isA<OrdersLocalizationsEs>());
      expect(localizations.appBarTitle, 'Pedidos');
      expect(localizations.body, 'Ruta protegida por enlace profundo');
    });

    group('OrdersLocalizationsEs', () {
      test('provides correct translations', () {
        final l10n = OrdersLocalizationsEs();
        expect(l10n.appBarTitle, 'Pedidos');
        expect(l10n.body, 'Ruta protegida por enlace profundo');
      });
    });

    group('OrdersLocalizationsEn', () {
      test('provides correct translations', () {
        final l10n = OrdersLocalizationsEn();
        // values from orders_localizations.dart
        // comments usually match EN implementation
        // Verifying actual En implementation is good practice
        expect(l10n.appBarTitle, 'Orders');
        expect(l10n.body, 'Deeplink protected route');
      });
    });

    test(
      'lookupOrdersLocalizations throws FlutterError for unsupported locale',
      () {
        expect(
          () => lookupOrdersLocalizations(const Locale('fr')),
          throwsFlutterError,
        );
      },
    );
  });
}
