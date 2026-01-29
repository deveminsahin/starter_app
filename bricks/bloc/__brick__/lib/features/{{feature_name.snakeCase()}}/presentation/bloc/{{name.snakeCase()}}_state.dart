import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:starter_app/core/presentation/models/error_model.dart';

part '{{name.snakeCase()}}_state.freezed.dart';

/// States for {{name.pascalCase()}}Bloc.
///
/// Uses freezed for discriminated unions (ADR-008).
@freezed
class {{name.pascalCase()}}State with _${{name.pascalCase()}}State {
  /// Initial state before any action.
  const factory {{name.pascalCase()}}State.initial() = _Initial;

  /// Loading state while fetching data.
  const factory {{name.pascalCase()}}State.loading() = _Loading;

  /// Success state with loaded data.
  const factory {{name.pascalCase()}}State.loaded({
    // TODO: Add state properties
  }) = _Loaded;

  /// Error state with error model.
  const factory {{name.pascalCase()}}State.error(ErrorModel error) = _Error;
}
