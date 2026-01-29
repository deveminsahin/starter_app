import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:starter_app/core/types/types.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}_id.dart';

part '{{feature_name.snakeCase()}}_model.freezed.dart';
part '{{feature_name.snakeCase()}}_model.g.dart';

/// Data transfer object for [{{feature_name.pascalCase()}}].
///
/// Uses freezed for JSON serialization (ADR-008).
/// Models are in infrastructure layer - they handle serialization.
@freezed
abstract class {{feature_name.pascalCase()}}Model with _${{feature_name.pascalCase()}}Model {
  const factory {{feature_name.pascalCase()}}Model({
    required String id,
    // TODO: Add model properties matching API response
  }) = _{{feature_name.pascalCase()}}Model;
  const {{feature_name.pascalCase()}}Model._();

  factory {{feature_name.pascalCase()}}Model.fromJson(Json json) =>
      _${{feature_name.pascalCase()}}ModelFromJson(json);

  factory {{feature_name.pascalCase()}}Model.fromDomain({{feature_name.pascalCase()}} entity) {
    return {{feature_name.pascalCase()}}Model(
      id: entity.id.value.value,
      // TODO: Map entity properties to model
    );
  }

  /// Converts this model to a domain entity.
  {{feature_name.pascalCase()}} toDomain() {
    return {{feature_name.pascalCase()}}(
      id: {{feature_name.pascalCase()}}Id.fromString(id),
      // TODO: Map model properties to entity
    );
  }
}
