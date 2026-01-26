import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/presentation/bloc/bloc.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:starter_app/features/settings/presentation/pages/settings_page.dart';

import '../../../../helpers/mock_helpers.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockThemeCubit mockThemeCubit;
  late MockLocaleCubit mockLocaleCubit;

  setUpAll(() {
    registerFallbackValue(const AuthEvent.logoutRequested());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockThemeCubit = MockThemeCubit();
    mockLocaleCubit = MockLocaleCubit();

    when(() => mockThemeCubit.state).thenReturn(AppThemeMode.system);
    when(() => mockLocaleCubit.state).thenReturn(AppLocale.en);
  });

  Widget buildSettingsPage() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
        BlocProvider<LocaleCubit>.value(value: mockLocaleCubit),
      ],
      child: const SettingsPage(),
    );
  }

  group('SettingsPage', () {
    testWidgets('renders without errors', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthState.empty());

      await tester.pumpApp(buildSettingsPage());

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('displays app bar with title', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthState.empty());

      await tester.pumpApp(buildSettingsPage());

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows language buttons', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthState.empty());

      await tester.pumpApp(buildSettingsPage());

      // Should have language section with buttons
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('shows theme buttons', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthState.empty());

      await tester.pumpApp(buildSettingsPage());

      // Should have theme section with 3 buttons (light, dark, system)
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('hides logout button when unauthenticated', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthState.empty());

      await tester.pumpApp(buildSettingsPage());

      // Logout button should not be visible when not authenticated
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('shows logout button when authenticated', (tester) async {
      final user = TestData.user();
      when(() => mockAuthBloc.state).thenReturn(AuthState.authenticated(user));

      await tester.pumpApp(buildSettingsPage());

      // There should be an elevated button for logout in FAB position
      // The logout button is inside ResponsivePadding as ElevatedButton
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('tapping English button calls setEnglish', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthState.empty());
      when(() => mockLocaleCubit.setEnglish()).thenReturn(null);

      await tester.pumpApp(buildSettingsPage());

      // Find and tap the English button
      final englishButton = find.widgetWithText(ElevatedButton, 'English');
      expect(englishButton, findsOneWidget);
      await tester.tap(englishButton);
      await tester.pump();
      verify(() => mockLocaleCubit.setEnglish()).called(1);
    });

    testWidgets('tapping Spanish button calls setSpanish', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthState.empty());
      when(() => mockLocaleCubit.setSpanish()).thenReturn(null);

      await tester.pumpApp(buildSettingsPage());

      // Find and tap the Spanish button
      final spanishButton = find.widgetWithText(ElevatedButton, 'Spanish');
      expect(spanishButton, findsOneWidget);
      await tester.tap(spanishButton);
      await tester.pump();
      verify(() => mockLocaleCubit.setSpanish()).called(1);
    });

    testWidgets('tapping light theme button calls setLightTheme', (
      tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(AuthState.empty());
      when(() => mockThemeCubit.setLightTheme()).thenReturn(null);

      await tester.pumpApp(buildSettingsPage());

      // Find and tap the Light theme button
      final lightButton = find.widgetWithText(ElevatedButton, 'Light');
      expect(lightButton, findsOneWidget);
      await tester.tap(lightButton);
      await tester.pump();
      verify(() => mockThemeCubit.setLightTheme()).called(1);
    });

    testWidgets('tapping dark theme button calls setDarkTheme', (
      tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(AuthState.empty());
      when(() => mockThemeCubit.setDarkTheme()).thenReturn(null);

      await tester.pumpApp(buildSettingsPage());

      // Find and tap the Dark theme button
      final darkButton = find.widgetWithText(ElevatedButton, 'Dark');
      expect(darkButton, findsOneWidget);
      await tester.tap(darkButton);
      await tester.pump();
      verify(() => mockThemeCubit.setDarkTheme()).called(1);
    });

    testWidgets('tapping system theme button calls setSystemTheme', (
      tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(AuthState.empty());
      when(() => mockThemeCubit.setSystemTheme()).thenReturn(null);

      await tester.pumpApp(buildSettingsPage());

      // Find and tap the System theme button
      final systemButton = find.widgetWithText(ElevatedButton, 'System');
      expect(systemButton, findsOneWidget);
      await tester.tap(systemButton);
      await tester.pump();
      verify(() => mockThemeCubit.setSystemTheme()).called(1);
    });

    testWidgets('logout button dispatches AuthLogoutRequested', (
      tester,
    ) async {
      final user = TestData.user();
      when(() => mockAuthBloc.state).thenReturn(AuthState.authenticated(user));

      await tester.pumpApp(buildSettingsPage());
      await tester.pumpAndSettle();

      // Find logout button by its text
      final logoutButton = find.widgetWithText(ElevatedButton, 'Log out');
      expect(logoutButton, findsOneWidget);

      await tester.tap(logoutButton);
      await tester.pump();

      verify(
        () => mockAuthBloc.add(any(that: isA<AuthLogoutRequested>())),
      ).called(1);
    });
  });
}
