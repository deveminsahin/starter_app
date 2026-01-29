import 'package:freezed_annotation/freezed_annotation.dart';

part '{{feature_name.snakeCase()}}_event.freezed.dart';

/// Events for {{feature_name.pascalCase()}}Bloc.
///
/// Uses freezed for discriminated unions (ADR-008).
@freezed
class {{feature_name.pascalCase()}}Event with _${{feature_name.pascalCase()}}Event {
  /// Triggered when the feature is started/initialized.
  const factory {{feature_name.pascalCase()}}Event.started() = {{feature_name.pascalCase()}}Started;

  /// Triggered to refresh data.
  const factory {{feature_name.pascalCase()}}Event.refreshed() = {{feature_name.pascalCase()}}Refreshed;

  /// Triggered to reset state.
  const factory {{feature_name.pascalCase()}}Event.reset() = {{feature_name.pascalCase()}}Reset;

  // TODO: Add more events as needed
}
