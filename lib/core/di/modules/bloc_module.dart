import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/logging/i_app_logger.dart';
import 'package:starter_app/core/presentation/bloc/bloc.dart';

/// Module for BLoC-related dependencies.
///
/// Provides:
/// - **BlocObserver**: Global observer for logging all BLoC/Cubit events
///
/// The observer integrates with the app's logging infrastructure to provide
/// comprehensive state management debugging and monitoring.
@module
abstract class BlocModule {
  /// Provides BlocObserver for logging all BLoC and Cubit events.
  ///
  /// The observer automatically logs:
  /// - **State changes** (onChange): Every state transition
  /// - **Errors** (onError): Any errors thrown in Cubits/Blocs
  /// - **Event emissions** (onEvent): Events dispatched to Blocs
  /// - **Transitions** (onTransition): Full event → state transitions
  ///
  /// All logs are routed through AppLogger, which means:
  /// - **Development**: Logs to console with pretty formatting
  /// - **Staging/Production**: Logs to Sentry for centralized monitoring
  ///
  /// This provides excellent debugging in development and production
  /// monitoring without any additional code in your Cubits/Blocs.
  ///
  /// Registered as singleton and set globally in bootstrap.dart.
  @singleton
  BlocObserver provideBlocObserver(IAppLogger logger) {
    return AppBlocObserver(logger);
  }

  /// Provides ThemeCubit for dynamic theme switching with persistence.
  ///
  /// Uses [AppThemeMode.system] as default, which follows device settings.
  /// State is automatically persisted via HydratedBloc.
  ///
  /// Must be @lazySingleton (not @singleton) because HydratedBloc.storage
  /// must be set before any HydratedCubit is created.
  @lazySingleton
  ThemeCubit provideThemeCubit() {
    return ThemeCubit(AppThemeMode.system);
  }

  /// Provides LocaleCubit for locale/language management with persistence.
  ///
  /// Uses [AppLocale.en] (English) as default.
  /// State is automatically persisted via HydratedBloc.
  ///
  /// Must be @lazySingleton (not @singleton) because HydratedBloc.storage
  /// must be set before any HydratedCubit is created.
  @lazySingleton
  LocaleCubit provideLocaleCubit() {
    return LocaleCubit(AppLocale.en);
  }
}
