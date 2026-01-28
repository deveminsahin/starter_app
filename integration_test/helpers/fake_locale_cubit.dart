import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:starter_app/core/presentation/bloc/bloc.dart';

/// Fake LocaleCubit for integration testing.
///
/// Simple Cubit implementation without HydratedBloc persistence.
class FakeLocaleCubit extends Cubit<AppLocale> implements LocaleCubit {
  /// Creates a FakeLocaleCubit with English locale as default.
  FakeLocaleCubit() : super(AppLocale.en);

  @override
  void setEnglish() => emit(AppLocale.en);

  @override
  void setSpanish() => emit(AppLocale.es);

  @override
  void setLocale(AppLocale locale) => emit(locale);

  @override
  AppLocale? fromJson(Map<String, dynamic> json) => null;

  @override
  Map<String, dynamic>? toJson(AppLocale state) => null;

  @override
  Future<void> clear() async {}

  @override
  String get id => 'fake_locale_cubit';

  @override
  String get storagePrefix => '';

  @override
  String get storageToken => 'fake_locale_cubit';

  @override
  void hydrate({
    Storage? storage,
    HydrationErrorBehavior Function(Object, StackTrace)? onError,
  }) {}
}
