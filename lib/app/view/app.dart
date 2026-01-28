import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/l10n/arb/app_localizations.dart';
import 'package:starter_app/core/logging/i_app_logger.dart';
import 'package:starter_app/core/navigation/app_router.dart';
import 'package:starter_app/core/navigation/auth_change_notifier.dart';
import 'package:starter_app/core/navigation/page_builder.dart';
import 'package:starter_app/core/presentation/bloc/bloc.dart';
import 'package:starter_app/core/presentation/services/failure_message_service.dart';
import 'package:starter_app/core/theme/app_theme.dart';
import 'package:starter_app/core/theme/app_theme_extension.dart';
import 'package:starter_app/features/auth/l10n/auth_localizations.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:starter_app/features/dashboard/l10n/dashboard_localizations.dart';
import 'package:starter_app/features/orders/l10n/orders_localizations.dart';
import 'package:starter_app/features/profile/l10n/profile_localizations.dart';
import 'package:starter_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:starter_app/features/settings/l10n/settings_localizations.dart';

/// Root application widget.
///
/// Provides:
/// - ThemeCubit for dynamic theme switching with persistence
/// - LocaleCubit for language/locale management
/// - AuthBloc for authentication state
/// - GoRouter for type-safe navigation with reactive auth redirects
/// - Localization support (English, Spanish)
/// - PageBuilder for custom transitions
///
/// ## Authentication Redirects
///
/// Auth-based redirects (logout, session expiry, protected routes) are handled
/// by [GoRouter] via refreshListenable with [AuthChangeNotifier].
/// See [AppRouter] for redirect logic.
///
/// All dependencies are resolved from GetIt DI container.
@injectable
final class App extends StatelessWidget {
  const App({
    required this.routerConfig,
    required this.logger,
    required this.pageBuilder,
    required this.themeCubit,
    required this.localeCubit,
    required this.authBloc,
    required this.profileBloc,
    required this.failureMessageService,
    required this.appTheme,
    @factoryParam super.key,
  });

  final GoRouter routerConfig;
  final IAppLogger logger;
  final PageBuilder pageBuilder;
  final ThemeCubit themeCubit;
  final LocaleCubit localeCubit;
  final AuthBloc authBloc;
  final ProfileBloc profileBloc;
  final FailureMessageService failureMessageService;
  final AppTheme appTheme;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: pageBuilder),
        RepositoryProvider.value(value: logger),
        RepositoryProvider.value(value: failureMessageService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => themeCubit),
          BlocProvider(create: (context) => localeCubit),
          BlocProvider(
            create: (context) => authBloc..add(const AuthGetCurrentUser()),
          ),
          BlocProvider(
            create: (context) => profileBloc,
          ),
        ],
        child: BlocBuilder<ThemeCubit, AppThemeMode>(
          builder: (context, appThemeMode) {
            return BlocBuilder<LocaleCubit, AppLocale>(
              builder: (context, appLocale) {
                return MaterialApp.router(
                  routerConfig: routerConfig,
                  // Theme configuration
                  // (Material Design 3 with FlexColorScheme)
                  theme: appTheme.lightTheme,
                  darkTheme: appTheme.darkTheme,
                  // Dynamic theme from ThemeCubit
                  themeMode: appThemeMode.toThemeMode(),
                  // Localization
                  locale: Locale(
                    appLocale.languageCode,
                    appLocale.countryCode,
                  ), // Dynamic locale from LocaleCubit
                  localizationsDelegates: const [
                    // Flutter's built-in delegates
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    // App-level localizations
                    AppLocalizations.delegate,
                    // Feature-specific localizations
                    AuthLocalizations.delegate,
                    DashboardLocalizations.delegate,
                    ProfileLocalizations.delegate,
                    OrdersLocalizations.delegate,
                    SettingsLocalizations.delegate,
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
