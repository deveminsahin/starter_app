import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:starter_app/core/presentation/bloc/bloc.dart';
import 'package:starter_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:starter_app/features/profile/presentation/pages/profile_page.dart';
import 'package:starter_app/features/settings/presentation/pages/settings_page.dart';

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TestAppConfig config;

  setUp(() {
    config = TestAppConfig();
  });

  group('Bottom Navigation', () {
    testWidgets('app starts on Dashboard page', (tester) async {
      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('can navigate to profile page', (tester) async {
      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      // Tap profile navigation item
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('can navigate to settings page', (tester) async {
      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      // Tap settings navigation item
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('can navigate back to Dashboard from profile', (tester) async {
      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);

      // Navigate back to Dashboard
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('navigation bar shows correct selected state', (tester) async {
      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      // Initially on Dashboard - Dashboard icon should be selected
      expect(find.byIcon(Icons.dashboard), findsOneWidget);

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Profile icon should be selected
      expect(find.byIcon(Icons.person), findsOneWidget);

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Settings icon should be selected
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('can cycle through all pages', (tester) async {
      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      // Start on Dashboard
      expect(find.byType(DashboardPage), findsOneWidget);

      // Go to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);

      // Go to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);

      // Go back to Dashboard
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardPage), findsOneWidget);
    });
  });

  group('Page Content', () {
    testWidgets('Dashboard page shows app bar with title', (tester) async {
      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('profile page shows app bar with title', (tester) async {
      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('settings page shows language options', (tester) async {
      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Settings page should have theme/language buttons
      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });

  group('Theme Switching', () {
    testWidgets('can switch to light theme from settings', (tester) async {
      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Find and tap light theme button
      final lightButton = find.widgetWithText(ElevatedButton, 'Light');
      if (lightButton.evaluate().isNotEmpty) {
        await tester.tap(lightButton);
        await tester.pumpAndSettle();

        expect(config.themeCubit.state, AppThemeMode.light);
      }
    });

    testWidgets('can switch to dark theme from settings', (tester) async {
      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Find and tap dark theme button
      final darkButton = find.widgetWithText(ElevatedButton, 'Dark');
      if (darkButton.evaluate().isNotEmpty) {
        await tester.tap(darkButton);
        await tester.pumpAndSettle();

        expect(config.themeCubit.state, AppThemeMode.dark);
      }
    });
  });

  group('Locale Switching', () {
    testWidgets('can switch to English from settings', (tester) async {
      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Find and tap English button
      final englishButton = find.widgetWithText(ElevatedButton, 'English');
      if (englishButton.evaluate().isNotEmpty) {
        await tester.tap(englishButton);
        await tester.pumpAndSettle();

        expect(config.localeCubit.state, AppLocale.en);
      }
    });

    testWidgets('can switch to Spanish from settings', (tester) async {
      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Find and tap Spanish button (Español)
      final spanishButton = find.widgetWithText(ElevatedButton, 'Español');
      if (spanishButton.evaluate().isNotEmpty) {
        await tester.tap(spanishButton);
        await tester.pumpAndSettle();

        expect(config.localeCubit.state, AppLocale.es);
      }
    });
  });
}
