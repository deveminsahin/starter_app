import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/presentation/models/error_model.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/presentation/bloc/{{feature_name.snakeCase()}}_event.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/presentation/bloc/{{feature_name.snakeCase()}}_state.dart';
// TODO: Import use cases
// import 'package:starter_app/features/{{feature_name.snakeCase()}}/application/usecases/get_all_{{feature_name.snakeCase()}}s.dart';

/// BLoC for {{feature_name.pascalCase()}} feature.
///
/// Handles UI state and delegates business logic to use cases.
/// Follows ADR-002 (flutter_bloc for state management).
@injectable
class {{feature_name.pascalCase()}}Bloc extends Bloc<{{feature_name.pascalCase()}}Event, {{feature_name.pascalCase()}}State> {
  {{feature_name.pascalCase()}}Bloc(
    // TODO: Inject use cases
    // this._getAll,
  ) : super(const {{feature_name.pascalCase()}}State.initial()) {
    on<{{feature_name.pascalCase()}}Event>((event, emit) async {
      await event.when(
        started: () => _onStarted(emit),
        refreshed: () => _onRefreshed(emit),
        reset: () {
          emit(const {{feature_name.pascalCase()}}State.initial());
          return Future<void>.value();
        },
      );
    });
  }

  // TODO: Add use case dependencies
  // final GetAll{{feature_name.pascalCase()}}s _getAll;

  Future<void> _onStarted(Emitter<{{feature_name.pascalCase()}}State> emit) async {
    emit(const {{feature_name.pascalCase()}}State.loading());

    // TODO: Call use case and handle result
    // final result = await _getAll();
    // result.fold(
    //   (failure) => emit({{feature_name.pascalCase()}}State.error(ErrorModel.fromFailure(failure))),
    //   (items) => emit({{feature_name.pascalCase()}}State.loaded(items)),
    // );

    // Placeholder - replace with actual implementation
    emit(const {{feature_name.pascalCase()}}State.loaded([]));
  }

  Future<void> _onRefreshed(Emitter<{{feature_name.pascalCase()}}State> emit) async {
    // Optionally show loading or keep current state
    await _onStarted(emit);
  }
}
