import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/presentation/models/error_model.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/presentation/bloc/{{name.snakeCase()}}_event.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/presentation/bloc/{{name.snakeCase()}}_state.dart';

/// BLoC for {{name.titleCase()}}.
///
/// Handles UI state and delegates business logic to use cases.
/// Follows ADR-002 (flutter_bloc for state management).
@injectable
class {{name.pascalCase()}}Bloc extends Bloc<{{name.pascalCase()}}Event, {{name.pascalCase()}}State> {
  {{name.pascalCase()}}Bloc(
    // TODO: Inject use cases
  ) : super(const {{name.pascalCase()}}State.initial()) {
    on<{{name.pascalCase()}}Event>((event, emit) async {
      await event.when(
        started: () => _onStarted(emit),
        refreshed: () => _onRefreshed(emit),
        reset: () {
          emit(const {{name.pascalCase()}}State.initial());
          return Future<void>.value();
        },
      );
    });
  }

  // TODO: Add use case dependencies

  Future<void> _onStarted(Emitter<{{name.pascalCase()}}State> emit) async {
    emit(const {{name.pascalCase()}}State.loading());

    // TODO: Call use case and handle result
    // final result = await _useCase();
    // result.fold(
    //   (failure) => emit({{name.pascalCase()}}State.error(ErrorModel.fromFailure(failure))),
    //   (data) => emit({{name.pascalCase()}}State.loaded(data: data)),
    // );

    // Placeholder - replace with actual implementation
    emit(const {{name.pascalCase()}}State.loaded());
  }

  Future<void> _onRefreshed(Emitter<{{name.pascalCase()}}State> emit) async {
    await _onStarted(emit);
  }
}
