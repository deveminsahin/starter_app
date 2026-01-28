import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/l10n/arb/app_localizations.dart';
import 'package:starter_app/core/theme/app_theme.dart';
import 'package:starter_app/features/auth/l10n/auth_localizations.dart';
import 'package:starter_app/features/dashboard/l10n/dashboard_localizations.dart';
import 'package:starter_app/features/profile/l10n/profile_localizations.dart';
import 'package:starter_app/features/settings/l10n/settings_localizations.dart';

extension PumpApp on WidgetTester {
  /// Pump a widget with basic MaterialApp wrapper
  Future<void> pumpApp(
    Widget widget, {
    ThemeMode themeMode = ThemeMode.light,
    Locale locale = const Locale('en'),
  }) {
    const appTheme = AppTheme();
    return pumpWidget(
      MaterialApp(
        theme: appTheme.lightTheme,
        darkTheme: appTheme.darkTheme,
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          AuthLocalizations.delegate,
          DashboardLocalizations.delegate,
          ProfileLocalizations.delegate,
          SettingsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: widget,
      ),
    );
  }

  /// Pump a widget with BLoC providers
  Future<void> pumpAppWithBloc(
    Widget widget, {
    List<BlocProvider> providers = const [],
    ThemeMode themeMode = ThemeMode.light,
    Locale locale = const Locale('en'),
  }) {
    const appTheme = AppTheme();
    return pumpWidget(
      MultiBlocProvider(
        providers: providers,
        child: MaterialApp(
          theme: appTheme.lightTheme,
          darkTheme: appTheme.darkTheme,
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            AuthLocalizations.delegate,
            DashboardLocalizations.delegate,
            ProfileLocalizations.delegate,
            SettingsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
      ),
    );
  }
}
