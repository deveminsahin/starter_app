import 'package:freezed_annotation/freezed_annotation.dart';

part '{{name.snakeCase()}}_event.freezed.dart';

/// Events for {{name.pascalCase()}}Bloc.
///
/// Uses freezed for discriminated unions (ADR-008).
@freezed
class {{name.pascalCase()}}Event with _${{name.pascalCase()}}Event {
  /// Triggered when started/initialized.
  const factory {{name.pascalCase()}}Event.started() = {{name.pascalCase()}}Started;

  /// Triggered to refresh data.
  const factory {{name.pascalCase()}}Event.refreshed() = {{name.pascalCase()}}Refreshed;

  /// Triggered to reset state.
  const factory {{name.pascalCase()}}Event.reset() = {{name.pascalCase()}}Reset;

  // TODO: Add more events as needed
}
