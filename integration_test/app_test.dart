import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke: app launches and basic navigation works', (tester) async {
    final config = TestAppConfig();

    await tester.pumpWidget(createTestApp(config));
    await tester.pumpAndSettle();

    // Basic sanity: bottom navigation is present.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.widgetWithText(NavigationDestination, 'Dashboard'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(NavigationDestination, 'Profile'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(NavigationDestination, 'Settings'),
      findsOneWidget,
    );

    // Navigate around (should not throw).
    await tester.tap(find.widgetWithText(NavigationDestination, 'Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(NavigationDestination, 'Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(NavigationDestination, 'Dashboard'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
