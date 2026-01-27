import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter_app/core/logging/i_app_logger.dart';

/// BlocObserver that logs all BLoC events and state changes.
///
/// Uses AppLogger to route logs to console and/or Sentry based on
/// the current environment and build mode.
///
/// Logs include:
/// - **State changes** (onChange): Every state transition
/// - **Errors** (onError): Any errors thrown in Cubits/Blocs
/// - **Event emissions** (onEvent): Events dispatched to Blocs
/// - **Transitions** (onTransition): Full event → state transitions
///
/// All logs are tagged with 'BLoC' for easy filtering.
///
/// Usage:
/// ```dart
/// Bloc.observer = AppBlocObserver(getIt<IAppLogger>());
/// ```
final class AppBlocObserver extends BlocObserver {
  const AppBlocObserver(this._logger);

  final IAppLogger _logger;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _logger.debug(
      'BLoC state changed',
      data: {
        'bloc': bloc.runtimeType.toString(),
        'currentState': change.currentState.toString(),
        'nextState': change.nextState.toString(),
      },
      tag: 'BLoC',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.error(
      'BLoC error',
      error: error,
      stackTrace: stackTrace,
      data: {'bloc': bloc.runtimeType.toString()},
      tag: 'BLoC',
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.debug(
      'BLoC event added',
      data: {
        'bloc': bloc.runtimeType.toString(),
        'event': event.toString(),
      },
      tag: 'BLoC',
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _logger.debug(
      'BLoC transition',
      data: {
        'bloc': bloc.runtimeType.toString(),
        'event': transition.event.toString(),
        'currentState': transition.currentState.toString(),
        'nextState': transition.nextState.toString(),
      },
      tag: 'BLoC',
    );
  }
}
