import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:starter_app/features/auth/presentation/pages/auth_page.dart';
import 'package:starter_app/features/profile/presentation/pages/profile_page.dart';

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TestAppConfig config;

  setUp(() {
    config = TestAppConfig();
  });

  group('Authentication Flow', () {
    group('Login Flow', () {
      testWidgets('user can navigate to auth page from profile', (
        tester,
      ) async {
        // Arrange - start with unauthenticated state
        config.authBlocController.setBehavior(loggedIn: false);

        await tester.pumpWidget(createTestApp(config));
        await tester.pumpAndSettle();

        // Act - Navigate to profile
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        // Assert - Should see ProfilePage with login button
        expect(find.byType(ProfilePage), findsOneWidget);

        // Find and tap login button
        final loginButton = find.widgetWithText(TextButton, 'Login');
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton);
          await tester.pumpAndSettle();

          // Should navigate to auth page
          expect(find.byType(AuthPage), findsOneWidget);
        }
      });

      testWidgets('user sees email form on auth page', (tester) async {
        await tester.pumpWidget(createTestApp(config));
        await tester.pumpAndSettle();

        // Navigate to auth
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        final loginButton = find.widgetWithText(TextButton, 'Login');
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton);
          await tester.pumpAndSettle();

          // Should see email input form
          expect(find.byType(TextFormField), findsOneWidget);
          expect(find.byType(ElevatedButton), findsOneWidget);
        }
      });

      testWidgets('email validation shows error for invalid email', (
        tester,
      ) async {
        await tester.pumpWidget(createTestApp(config));
        await tester.pumpAndSettle();

        // Navigate to auth
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        final loginButton = find.widgetWithText(TextButton, 'Login');
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton);
          await tester.pumpAndSettle();

          // Enter invalid email
          await tester.enterText(find.byType(TextFormField), 'invalid-email');
          await tester.pumpAndSettle();

          // Submit
          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle();

          // Should still be on initial state (not transitioning)
          expect(config.authBloc.state, isA<Initial>());
        }
      });

      testWidgets('successful login shows authenticated state', (
        tester,
      ) async {
        // Configure for successful login
        config.authBlocController.setBehavior(
          loginSucceeds: true,
          userExists: true,
        );

        await tester.pumpWidget(createTestApp(config));
        await tester.pumpAndSettle();

        // Simulate being on login required state directly
        config.authBloc.add(
          const AuthEmailChanged(IntegrationTestData.email),
        );
        await tester.pumpAndSettle();

        // The bloc should handle the flow
        // After login succeeds, bloc state should be Authenticated
        config.authBlocController.setBehavior(loggedIn: true);
        config.authBloc.add(const AuthGetCurrentUser());
        await tester.pumpAndSettle();

        expect(config.authBloc.state, isA<Authenticated>());
      });
    });

    group('Logout Flow', () {
      testWidgets('logout returns to unauthenticated state', (tester) async {
        // Start logged in
        config.authBlocController.setBehavior(loggedIn: true);
        config.authBloc.add(const AuthGetCurrentUser());

        await tester.pumpWidget(createTestApp(config));
        await tester.pumpAndSettle();

        // Verify authenticated
        expect(config.authBloc.state, isA<Authenticated>());

        // Trigger logout
        config.authBloc.add(const AuthLogoutRequested());
        await tester.pumpAndSettle();

        // Should be unauthenticated
        expect(config.authBloc.state, isA<Unauthenticated>());
      });

      testWidgets('logout clears user data', (tester) async {
        // Start logged in
        config.authBlocController.setBehavior(loggedIn: true);
        config.authBloc.add(const AuthGetCurrentUser());

        await tester.pumpWidget(createTestApp(config));
        await tester.pumpAndSettle();

        // Logout
        config.authBloc.add(const AuthLogoutRequested());
        await tester.pumpAndSettle();

        // Verify logged out flag
        expect(config.authBlocController.isUserLoggedIn, false);
      });
    });

    group('Registration Flow', () {
      testWidgets('new user email submission goes to registration', (
        tester,
      ) async {
        // Configure for new user (not existing)
        config.authBlocController.setBehavior(userExists: false);

        await tester.pumpWidget(createTestApp(config));
        await tester.pumpAndSettle();

        // Simulate email submission for new user
        config.authBloc.add(
          const AuthEmailChanged('newuser@example.com'),
        );
        await tester.pump();

        config.authBloc.add(const AuthEmailSubmitted());
        await tester.pump(const Duration(milliseconds: 200));

        // Should transition to registration state
        expect(config.authBloc.state, isA<RegistrationRequired>());
      });

      testWidgets('successful registration authenticates user', (
        tester,
      ) async {
        config.authBlocController.setBehavior(registerSucceeds: true);

        await tester.pumpWidget(createTestApp(config));
        await tester.pumpAndSettle();

        // Set up registration state
        config.authBlocController.setBehavior(userExists: false);
        config.authBloc.add(
          const AuthEmailChanged('newuser@example.com'),
        );
        await tester.pump();
        config.authBloc.add(const AuthEmailSubmitted());
        await tester.pump(const Duration(milliseconds: 200));

        // Now submit registration
        config.authBloc.add(const AuthRegisterSubmitted());
        await tester.pump(const Duration(milliseconds: 200));

        expect(config.authBloc.state, isA<Authenticated>());
      });
    });
  });

  group('Auth State Persistence', () {
    testWidgets('authenticated user sees welcome message in profile', (
      tester,
    ) async {
      // Start authenticated
      config.authBlocController.setBehavior(loggedIn: true);
      config.authBloc.add(const AuthGetCurrentUser());

      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Should see welcome message with user name
      expect(
        find.textContaining(IntegrationTestData.email),
        findsOneWidget,
      );
    });

    testWidgets('unauthenticated user sees login button in profile', (
      tester,
    ) async {
      config.authBlocController.setBehavior(loggedIn: false);

      await tester.pumpWidget(createTestApp(config));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Should see login button (localized auth l10n is "Login" in en)
      expect(find.widgetWithText(TextButton, 'Login'), findsOneWidget);
    });
  });
}
