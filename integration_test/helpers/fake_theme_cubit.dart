import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:starter_app/core/presentation/bloc/bloc.dart';

/// Fake ThemeCubit for integration testing.
///
/// Simple Cubit implementation without HydratedBloc persistence.
class FakeThemeCubit extends Cubit<AppThemeMode> implements ThemeCubit {
  /// Creates a FakeThemeCubit with system theme as default.
  FakeThemeCubit() : super(AppThemeMode.system);

  @override
  void setLightTheme() => emit(AppThemeMode.light);

  @override
  void setDarkTheme() => emit(AppThemeMode.dark);

  @override
  void setSystemTheme() => emit(AppThemeMode.system);

  @override
  void setThemeMode(AppThemeMode mode) => emit(mode);

  @override
  void toggleTheme() {
    if (state == AppThemeMode.light) {
      emit(AppThemeMode.dark);
    } else {
      emit(AppThemeMode.light);
    }
  }

  @override
  AppThemeMode? fromJson(Map<String, dynamic> json) => null;

  @override
  Map<String, dynamic>? toJson(AppThemeMode state) => null;

  @override
  Future<void> clear() async {}

  @override
  String get id => 'fake_theme_cubit';

  @override
  String get storagePrefix => '';

  @override
  String get storageToken => 'fake_theme_cubit';

  @override
  void hydrate({
    Storage? storage,
    HydrationErrorBehavior Function(Object, StackTrace)? onError,
  }) {}
}
