import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/l10n/arb/app_localizations.dart';
import 'package:starter_app/core/logging/i_app_logger.dart';
import 'package:starter_app/core/navigation/app_router.dart';
import 'package:starter_app/core/navigation/page_builder.dart';
import 'package:starter_app/core/navigation/route_definitions.dart';
import 'package:starter_app/core/presentation/bloc/bloc.dart';
import 'package:starter_app/core/presentation/pages/error_page.dart';
import 'package:starter_app/core/presentation/widgets/adaptive_navigation_scaffold.dart';
import 'package:starter_app/features/auth/l10n/auth_localizations.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:starter_app/features/dashboard/l10n/dashboard_localizations.dart';
import 'package:starter_app/features/orders/l10n/orders_localizations.dart';
import 'package:starter_app/features/profile/l10n/profile_localizations.dart';
import 'package:starter_app/features/settings/l10n/settings_localizations.dart';

import '../../helpers/mock_helpers.dart';

class FakeBuildContext extends Fake implements BuildContext {}

class FakeGoRouterState extends Fake implements GoRouterState {}

class FakeWidget extends Fake implements Widget {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'FakeWidget';
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeGoRouterState());
    registerFallbackValue(FakeWidget());
  });

  group('AppRouter', () {
    late MockPageBuilder mockPageBuilder;
    late MockAppLogger mockLogger;
    late MockAuthChangeNotifier mockAuthChangeNotifier;

    setUp(() async {
      mockPageBuilder = MockPageBuilder();
      mockLogger = MockAppLogger();
      mockAuthChangeNotifier = MockAuthChangeNotifier();
      await GetIt.I.reset();

      // Default mock behavior for AuthChangeNotifier
      when(() => mockAuthChangeNotifier.isAuthenticated).thenReturn(false);
    });

    tearDown(() async {
      await GetIt.I.reset();
    });

    test('creates router with page builder and auth notifier', () {
      final appRouter = AppRouter(
        mockPageBuilder,
        mockAuthChangeNotifier,
      );

      expect(appRouter.routerConfig, isA<GoRouter>());
    });

    test('routerConfig is created successfully', () {
      final appRouter = AppRouter(
        mockPageBuilder,
        mockAuthChangeNotifier,
      );

      expect(appRouter.routerConfig, isA<GoRouter>());
    });

    test('errorPageBuilder is configured', () {
      final appRouter = AppRouter(
        mockPageBuilder,
        mockAuthChangeNotifier,
      );
      final router = appRouter.routerConfig;

      // Verify router is created (errorPageBuilder is set internally)
      expect(router, isA<GoRouter>());
    });

    testWidgets('rootNavigator returns null when navigator not mounted', (
      tester,
    ) async {
      // Need to pump a widget to initialize the binding
      await tester.pumpWidget(const SizedBox());

      // Advance past Sentry timer
      await tester.pump(const Duration(seconds: 4));
      expect(AppRouter.rootNavigator, null);
    });

    testWidgets('rootNavigator returns navigator when mounted', (
      tester,
    ) async {
      final appRouter = AppRouter(
        mockPageBuilder,
        mockAuthChangeNotifier,
      );
      final router = appRouter.routerConfig;

      // Need to mock dependencies for pages loaded by the router
      final mockAuthBloc = MockAuthBloc();
      final mockThemeCubit = MockThemeCubit();
      final mockLocaleCubit = MockLocaleCubit();

      when(() => mockAuthBloc.state).thenReturn(AuthState.empty());
      when(() => mockThemeCubit.state).thenReturn(AppThemeMode.system);
      when(() => mockLocaleCubit.state).thenReturn(AppLocale.en);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: mockAuthBloc),
            BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
            BlocProvider<LocaleCubit>.value(value: mockLocaleCubit),
          ],
          child: MultiRepositoryProvider(
            providers: [
              RepositoryProvider<PageBuilder>.value(value: mockPageBuilder),
              RepositoryProvider<IAppLogger>.value(value: mockLogger),
            ],
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                AuthLocalizations.delegate,
                DashboardLocalizations.delegate,
                ProfileLocalizations.delegate,
                SettingsLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        ),
      );
      // Advance past Sentry timer
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(); // Just pump once, don't wait for settle

      // Navigator should be available after pumping
      final navigator = AppRouter.rootNavigator;
      expect(navigator, isNotNull);
    });

    testWidgets(
      'redirects to Dashboard when unauthenticated on protected route',
      (
        tester,
      ) async {
        when(() => mockAuthChangeNotifier.isAuthenticated).thenReturn(false);

        final appRouter = AppRouter(
          mockPageBuilder,
          mockAuthChangeNotifier,
        );

        final mockAuthBloc = MockAuthBloc();
        final mockThemeCubit = MockThemeCubit();
        final mockLocaleCubit = MockLocaleCubit();

        when(() => mockAuthBloc.state).thenReturn(AuthState.empty());
        when(() => mockThemeCubit.state).thenReturn(AppThemeMode.system);
        when(() => mockLocaleCubit.state).thenReturn(AppLocale.en);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: mockAuthBloc),
              BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
              BlocProvider<LocaleCubit>.value(value: mockLocaleCubit),
            ],
            child: MultiRepositoryProvider(
              providers: [
                RepositoryProvider<PageBuilder>.value(value: mockPageBuilder),
                RepositoryProvider<IAppLogger>.value(value: mockLogger),
              ],
              child: MaterialApp.router(
                routerConfig: appRouter.routerConfig,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  AuthLocalizations.delegate,
                  DashboardLocalizations.delegate,
                  ProfileLocalizations.delegate,
                  SettingsLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
              ),
            ),
          ),
        );
        // Advance past Sentry timer
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();

        // Try to navigate to orders (protected)
        appRouter.routerConfig.go(RouteDefinitions.ordersPath);
        await tester.pumpAndSettle();

        // Verify we were redirected to Dashboard
        expect(
          appRouter.routerConfig.routerDelegate.currentConfiguration.uri.path,
          RouteDefinitions.dashboardPath,
        );
      },
    );

    testWidgets('allows navigation to protected route when authenticated', (
      tester,
    ) async {
      when(() => mockAuthChangeNotifier.isAuthenticated).thenReturn(true);

      final appRouter = AppRouter(
        mockPageBuilder,
        mockAuthChangeNotifier,
      );

      final mockAuthBloc = MockAuthBloc();
      final mockThemeCubit = MockThemeCubit();
      final mockLocaleCubit = MockLocaleCubit();

      // Create a mock user
      final mockUser = MockUser();
      when(
        () => mockAuthBloc.state,
      ).thenReturn(AuthState.authenticated(mockUser));
      when(() => mockThemeCubit.state).thenReturn(AppThemeMode.system);
      when(() => mockLocaleCubit.state).thenReturn(AppLocale.en);

      // Mock PageBuilder to return pages for routes
      when(
        () => mockPageBuilder.build(
          context: any(named: 'context'),
          state: any(named: 'state'),
          child: any(named: 'child'),
        ),
      ).thenAnswer((invocation) {
        final child = invocation.namedArguments[#child] as Widget;
        return NoTransitionPage(child: child);
      });

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: mockAuthBloc),
            BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
            BlocProvider<LocaleCubit>.value(value: mockLocaleCubit),
          ],
          child: MultiRepositoryProvider(
            providers: [
              RepositoryProvider<PageBuilder>.value(value: mockPageBuilder),
              RepositoryProvider<IAppLogger>.value(value: mockLogger),
            ],
            child: MaterialApp.router(
              routerConfig: appRouter.routerConfig,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                AuthLocalizations.delegate,
                DashboardLocalizations.delegate,
                OrdersLocalizations.delegate,
                ProfileLocalizations.delegate,
                SettingsLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        ),
      );
      // Advance past Sentry timer
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Navigate to orders (protected) - should be allowed when authenticated
      appRouter.routerConfig.go(RouteDefinitions.ordersPath);
      await tester.pumpAndSettle();

      // Verify we arrived at orders
      expect(
        appRouter.routerConfig.routerDelegate.currentConfiguration.uri.path,
        RouteDefinitions.ordersPath,
      );
    });
    testWidgets('errorPageBuilder is triggered on unknown route', (
      tester,
    ) async {
      final appRouter = AppRouter(
        mockPageBuilder,
        mockAuthChangeNotifier,
      );

      // Need to mock dependencies
      final mockAuthBloc = MockAuthBloc();
      final mockThemeCubit = MockThemeCubit();
      final mockLocaleCubit = MockLocaleCubit();

      when(() => mockAuthBloc.state).thenReturn(AuthState.empty());
      when(() => mockThemeCubit.state).thenReturn(AppThemeMode.system);
      when(() => mockLocaleCubit.state).thenReturn(AppLocale.en);

      // Mock PageBuilder to return a specific page for errors
      // The errorPageBuilder calls _pageBuilder.build
      when(
        () => mockPageBuilder.build(
          context: any(named: 'context'),
          state: any(named: 'state'),
          child: any(named: 'child'),
        ),
      ).thenAnswer((invocation) {
        final child = invocation.namedArguments[#child] as Widget;
        return NoTransitionPage(child: child);
      });

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: mockAuthBloc),
            BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
            BlocProvider<LocaleCubit>.value(value: mockLocaleCubit),
          ],
          child: MultiRepositoryProvider(
            providers: [
              RepositoryProvider<PageBuilder>.value(value: mockPageBuilder),
              RepositoryProvider<IAppLogger>.value(value: mockLogger),
            ],
            child: MaterialApp.router(
              routerConfig: appRouter.routerConfig,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                AuthLocalizations.delegate,
                DashboardLocalizations.delegate,
                ProfileLocalizations.delegate,
                SettingsLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        ),
      );
      // Advance past Sentry timer
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Navigate to unknown route
      // We expect this to trigger the error page builder
      appRouter.routerConfig.go('/unknown-route-123');
      await tester.pumpAndSettle();

      // Verify page builder was called
      verify(
        () => mockPageBuilder.build(
          context: any(named: 'context'),
          state: any(named: 'state'),
          child: any(named: 'child'),
        ),
      ).called(greaterThan(0)); // Called for initial Dashboard and error

      // Verify we are on the error page (handled by ErrorPage internally)
      expect(find.byType(ErrorPage), findsOneWidget);
    });
  });

  group('AppShellRoute', () {
    late MockAppLogger mockLogger;

    setUp(() async {
      mockLogger = MockAppLogger();
    });

    testWidgets('builder returns AdaptiveNavigationScaffold', (
      tester,
    ) async {
      const route = AppShellRoute();
      final mockState = MockGoRouterState();

      // Use FakeStatefulNavigationShell instead of Mock
      final fakeNavigationShell = FakeStatefulNavigationShell(currentIndex: 0);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            DashboardLocalizations.delegate,
            ProfileLocalizations.delegate,
            SettingsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepositoryProvider<IAppLogger>.value(
            value: mockLogger,
            child: Builder(
              builder: (context) {
                return route.builder(
                  context,
                  mockState,
                  fakeNavigationShell,
                );
              },
            ),
          ),
        ),
      );
      // Advance past Sentry timer
      await tester.pump(const Duration(seconds: 4));

      expect(find.byType(AdaptiveNavigationScaffold), findsOneWidget);
    });

    test('has static navigatorKey', () {
      expect(AppShellRoute.$navigatorKey, isNotNull);
      expect(AppShellRoute.$navigatorKey, isA<GlobalKey<NavigatorState>>());
    });
  });
}

class MockPageBuilder extends Mock implements PageBuilder {}

/// A fake implementation of StatefulNavigationShell for testing.
///
/// This extends Fake to provide noSuchMethod for unimplemented members,
/// and properly implements the Widget interface so it can be rendered.
class FakeStatefulNavigationShell extends Fake
    implements StatefulNavigationShell {
  FakeStatefulNavigationShell({
    required this.currentIndex,
    this.onGoBranch,
  });

  @override
  final int currentIndex;

  /// Callback invoked when goBranch is called.
  final void Function(int index, {bool initialLocation})? onGoBranch;

  @override
  void goBranch(int index, {bool initialLocation = false}) {
    onGoBranch?.call(index, initialLocation: initialLocation);
  }

  // Provide a working createElement so this can be rendered as a Widget
  @override
  StatefulElement createElement() => _FakeStatefulElement(this);

  @override
  State<StatefulWidget> createState() => _FakeState();

  @override
  Key? get key => null;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'FakeStatefulNavigationShell';
}

class _FakeStatefulElement extends StatefulElement {
  _FakeStatefulElement(super.widget);
}

class _FakeState extends State<FakeStatefulNavigationShell> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
