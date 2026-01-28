import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_app/core/l10n/arb/app_localizations.dart';
import 'package:starter_app/core/presentation/bloc/bloc.dart';
import 'package:starter_app/core/theme/app_theme.dart';
import 'package:starter_app/core/theme/app_theme_extension.dart';
import 'package:starter_app/features/auth/l10n/auth_localizations.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:starter_app/features/auth/presentation/pages/auth_page.dart';
import 'package:starter_app/features/dashboard/l10n/dashboard_localizations.dart';
import 'package:starter_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:starter_app/features/orders/l10n/orders_localizations.dart';
import 'package:starter_app/features/profile/l10n/profile_localizations.dart';
import 'package:starter_app/features/profile/presentation/pages/profile_page.dart';
import 'package:starter_app/features/settings/l10n/settings_localizations.dart';
import 'package:starter_app/features/settings/presentation/pages/settings_page.dart';

import 'fake_auth_bloc.dart';
import 'fake_locale_cubit.dart';
import 'fake_theme_cubit.dart';

/// Test app configuration for integration tests.
///
/// Creates a fully functional app with fake dependencies that can be
/// controlled during tests without network calls or persistence.
class TestAppConfig {
  TestAppConfig({
    FakeAuthBlocController? authBlocController,
    FakeThemeCubit? themeCubit,
    FakeLocaleCubit? localeCubit,
  }) : authBlocController = authBlocController ?? FakeAuthBlocController(),
       themeCubit = themeCubit ?? FakeThemeCubit(),
       localeCubit = localeCubit ?? FakeLocaleCubit() {
    authBloc = FakeAuthBloc(controller: this.authBlocController);
  }

  late final FakeAuthBloc authBloc;
  final FakeAuthBlocController authBlocController;
  final FakeThemeCubit themeCubit;
  final FakeLocaleCubit localeCubit;

  /// Resets all fakes to their initial state.
  void reset() {
    authBlocController.reset();
  }
}

/// Creates a test app widget with fake dependencies.
///
/// The returned widget is a fully functional app that can be used
/// for integration testing without network calls.
///
/// Example:
/// ```dart
/// final config = TestAppConfig();
/// await tester.pumpWidget(createTestApp(config));
/// await tester.pumpAndSettle();
///
/// // App is now ready for testing
/// expect(find.byType(DashboardPage), findsOneWidget);
/// ```
Widget createTestApp(TestAppConfig config) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: config.authBloc),
      BlocProvider<ThemeCubit>.value(value: config.themeCubit),
      BlocProvider<LocaleCubit>.value(value: config.localeCubit),
    ],
    child: BlocBuilder<ThemeCubit, AppThemeMode>(
      builder: (context, appThemeMode) {
        return BlocBuilder<LocaleCubit, AppLocale>(
          builder: (context, appLocale) {
            const appTheme = AppTheme();
            return MaterialApp.router(
              routerConfig: _createTestRouter(config.authBloc),
              theme: appTheme.lightTheme,
              darkTheme: appTheme.darkTheme,
              themeMode: appThemeMode.toThemeMode(),
              locale: Locale(appLocale.languageCode, appLocale.countryCode),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                AppLocalizations.delegate,
                AuthLocalizations.delegate,
                DashboardLocalizations.delegate,
                OrdersLocalizations.delegate,
                ProfileLocalizations.delegate,
                SettingsLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        );
      },
    ),
  );
}

/// Creates a simple test router for integration tests.
GoRouter _createTestRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Shell route with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _TestNavigationScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Dashboard branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'Dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          // Profile branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
          // Settings branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      // Auth route (outside shell)
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthPage(),
      ),
    ],
  );
}

/// Simple navigation scaffold for testing.
class _TestNavigationScaffold extends StatelessWidget {
  const _TestNavigationScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
