import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/l10n/arb/app_localizations.dart';
import 'package:starter_app/core/presentation/pages/error_page.dart';

class MockGoRouterState extends Mock implements GoRouterState {}

void main() {
  late MockGoRouterState mockState;

  setUp(() {
    mockState = MockGoRouterState();
    when(() => mockState.uri).thenReturn(Uri.parse('/wrong-path'));
  });

  group('ErrorPage', () {
    testWidgets('renders correct error information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ErrorPage(state: mockState),
        ),
      );

      // Use localized text - in English locale
      expect(find.text('An unexpected error occurred'), findsOneWidget);
      expect(find.text('Page not found'), findsOneWidget);
      expect(find.text('/wrong-path'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    // Note: Testing the navigation button
    // requires setting up a GoRouter environment
    // or intercepting the context.go call.
    //  Since DashboardRoute().go(context) is type-safe
    // and generated, we trust the generator.
    // However, we can check if the button is tappable.

    testWidgets('go Dashboard button navigates to Dashboard', (tester) async {
      final router = GoRouter(
        initialLocation: '/error',
        routes: [
          GoRoute(
            path: '/error',
            builder: (context, state) => ErrorPage(state: state),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) =>
                const Scaffold(body: Text('Dashboard Page')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );

      await tester.tap(find.text('Go Back'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Page'), findsOneWidget);
    });
  });
}
