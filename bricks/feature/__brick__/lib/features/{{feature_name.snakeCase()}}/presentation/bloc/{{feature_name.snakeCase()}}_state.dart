import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:starter_app/core/presentation/models/error_model.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';

part '{{feature_name.snakeCase()}}_state.freezed.dart';

/// States for {{feature_name.pascalCase()}}Bloc.
///
/// Uses freezed for discriminated unions (ADR-008).
@freezed
class {{feature_name.pascalCase()}}State with _${{feature_name.pascalCase()}}State {
  /// Initial state before any action.
  const factory {{feature_name.pascalCase()}}State.initial() = _Initial;

  /// Loading state while fetching data.
  const factory {{feature_name.pascalCase()}}State.loading() = _Loading;

  /// Success state with loaded data.
  const factory {{feature_name.pascalCase()}}State.loaded(List<{{feature_name.pascalCase()}}> items) = _Loaded;

  /// Error state with error model.
  const factory {{feature_name.pascalCase()}}State.error(ErrorModel error) = _Error;
}
