import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/app/app.dart';
import 'package:starter_app/core/logging/i_app_logger.dart';
import 'package:starter_app/core/navigation/page_builder.dart';
import 'package:starter_app/core/presentation/bloc/bloc.dart';
import 'package:starter_app/core/presentation/services/failure_message_service.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:starter_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:starter_app/features/profile/presentation/bloc/profile_state.dart';

import '../../helpers/mock_helpers.dart';

void main() {
  late MockThemeCubit mockThemeCubit;
  late MockLocaleCubit mockLocaleCubit;
  late MockAuthBloc mockAuthBloc;
  late MockAppRouter mockAppRouter;
  late MockAppLogger mockLogger;
  late MockPageBuilder mockPageBuilder;
  late MockFailureMessageService mockFailureMessageService;
  late MockAppTheme mockAppTheme;
  late MockProfileBloc mockProfileBloc;
  late GoRouter router;

  setUp(() {
    mockThemeCubit = MockThemeCubit();
    mockLocaleCubit = MockLocaleCubit();
    mockAuthBloc = MockAuthBloc();
    mockAppRouter = MockAppRouter();
    mockLogger = MockAppLogger();
    mockPageBuilder = MockPageBuilder();
    mockFailureMessageService = MockFailureMessageService();
    mockAppTheme = MockAppTheme();
    mockProfileBloc = MockProfileBloc();

    when(() => mockThemeCubit.state).thenReturn(AppThemeMode.system);
    when(
      () => mockThemeCubit.stream,
    ).thenAnswer((_) => const Stream<AppThemeMode>.empty());
    when(() => mockLocaleCubit.state).thenReturn(AppLocale.en);
    when(
      () => mockLocaleCubit.stream,
    ).thenAnswer((_) => const Stream<AppLocale>.empty());
    when(() => mockAuthBloc.state).thenReturn(AuthState.empty());
    when(() => mockAppTheme.lightTheme).thenReturn(ThemeData.light());
    when(() => mockAppTheme.darkTheme).thenReturn(ThemeData.dark());
    when(() => mockProfileBloc.state).thenReturn(const ProfileState.initial());

    // Setup Mock Router with a test page
    router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) {
            context.read<AuthBloc>();
            return const Scaffold(
              body: SizedBox(key: Key('Dashboard_page')),
            );
          },
        ),
      ],
    );
    when(() => mockAppRouter.routerConfig).thenReturn(router);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Widget buildApp() {
    return App(
      routerConfig: mockAppRouter.routerConfig,
      logger: mockLogger,
      pageBuilder: mockPageBuilder,
      themeCubit: mockThemeCubit,
      localeCubit: mockLocaleCubit,
      authBloc: mockAuthBloc,
      profileBloc: mockProfileBloc,
      failureMessageService: mockFailureMessageService,
      appTheme: mockAppTheme,
    );
  }

  group('App', () {
    testWidgets('renders DashboardPage via Router', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('Dashboard_page')), findsOneWidget);
      verify(() => mockAuthBloc.add(const AuthGetCurrentUser())).called(1);
    });

    group('theme switching', () {
      testWidgets('applies light theme when ThemeCubit emits light mode', (
        tester,
      ) async {
        when(() => mockThemeCubit.state).thenReturn(AppThemeMode.light);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.themeMode, ThemeMode.light);
      });

      testWidgets('applies dark theme when ThemeCubit emits dark mode', (
        tester,
      ) async {
        when(() => mockThemeCubit.state).thenReturn(AppThemeMode.dark);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.themeMode, ThemeMode.dark);
      });

      testWidgets('applies system theme when ThemeCubit emits system mode', (
        tester,
      ) async {
        when(() => mockThemeCubit.state).thenReturn(AppThemeMode.system);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.themeMode, ThemeMode.system);
      });
    });

    group('locale switching', () {
      testWidgets('applies English locale when LocaleCubit emits en', (
        tester,
      ) async {
        when(() => mockLocaleCubit.state).thenReturn(AppLocale.en);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.locale?.languageCode, 'en');
      });

      testWidgets('applies Spanish locale when LocaleCubit emits es', (
        tester,
      ) async {
        when(() => mockLocaleCubit.state).thenReturn(AppLocale.es);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.locale?.languageCode, 'es');
      });
    });

    group('providers', () {
      testWidgets('provides PageBuilder via RepositoryProvider', (
        tester,
      ) async {
        late PageBuilder capturedPageBuilder;

        final testRouter = GoRouter(
          initialLocation: '/test',
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) {
                capturedPageBuilder = context.read<PageBuilder>();
                return const SizedBox();
              },
            ),
          ],
        );
        when(() => mockAppRouter.routerConfig).thenReturn(testRouter);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        expect(capturedPageBuilder, mockPageBuilder);
      });

      testWidgets('provides IAppLogger via RepositoryProvider', (tester) async {
        late IAppLogger capturedLogger;

        final testRouter = GoRouter(
          initialLocation: '/test',
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) {
                capturedLogger = context.read<IAppLogger>();
                return const SizedBox();
              },
            ),
          ],
        );
        when(() => mockAppRouter.routerConfig).thenReturn(testRouter);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        expect(capturedLogger, mockLogger);
      });

      testWidgets('provides FailureMessageService via RepositoryProvider', (
        tester,
      ) async {
        late FailureMessageService capturedService;

        final testRouter = GoRouter(
          initialLocation: '/test',
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) {
                capturedService = context.read<FailureMessageService>();
                return const SizedBox();
              },
            ),
          ],
        );
        when(() => mockAppRouter.routerConfig).thenReturn(testRouter);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        expect(capturedService, mockFailureMessageService);
      });

      testWidgets('provides AuthBloc via BlocProvider', (tester) async {
        late AuthBloc capturedAuthBloc;

        final testRouter = GoRouter(
          initialLocation: '/test',
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) {
                capturedAuthBloc = context.read<AuthBloc>();
                return const SizedBox();
              },
            ),
          ],
        );
        when(() => mockAppRouter.routerConfig).thenReturn(testRouter);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        expect(capturedAuthBloc, mockAuthBloc);
      });

      testWidgets('provides ProfileBloc via BlocProvider', (tester) async {
        late ProfileBloc capturedProfileBloc;

        final testRouter = GoRouter(
          initialLocation: '/test',
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) {
                capturedProfileBloc = context.read<ProfileBloc>();
                return const SizedBox();
              },
            ),
          ],
        );
        when(() => mockAppRouter.routerConfig).thenReturn(testRouter);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        expect(capturedProfileBloc, mockProfileBloc);
      });

      testWidgets('provides ThemeCubit via BlocProvider', (tester) async {
        late ThemeCubit capturedThemeCubit;

        final testRouter = GoRouter(
          initialLocation: '/test',
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) {
                capturedThemeCubit = context.read<ThemeCubit>();
                return const SizedBox();
              },
            ),
          ],
        );
        when(() => mockAppRouter.routerConfig).thenReturn(testRouter);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        expect(capturedThemeCubit, mockThemeCubit);
      });

      testWidgets('provides LocaleCubit via BlocProvider', (tester) async {
        late LocaleCubit capturedLocaleCubit;

        final testRouter = GoRouter(
          initialLocation: '/test',
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) {
                capturedLocaleCubit = context.read<LocaleCubit>();
                return const SizedBox();
              },
            ),
          ],
        );
        when(() => mockAppRouter.routerConfig).thenReturn(testRouter);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        expect(capturedLocaleCubit, mockLocaleCubit);
      });
    });
  });
}
