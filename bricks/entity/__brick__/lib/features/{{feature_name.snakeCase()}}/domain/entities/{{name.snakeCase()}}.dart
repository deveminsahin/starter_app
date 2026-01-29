{{#is_aggregate_root}}
import 'package:starter_app/core/domain/base/aggregate_root.dart';
{{/is_aggregate_root}}{{^is_aggregate_root}}
import 'package:starter_app/core/domain/base/entity.dart';
{{/is_aggregate_root}}
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{name.snakeCase()}}_id.dart';

/// {{name.pascalCase()}} entity.
///
/// This is a domain entity (NOT freezed) following ADR-008.
{{#is_aggregate_root}}
/// Extends AggregateRoot - can emit domain events.
class {{name.pascalCase()}} extends AggregateRoot {
{{/is_aggregate_root}}{{^is_aggregate_root}}
/// Extends Entity - identity-based equality.
class {{name.pascalCase()}} extends Entity {
{{/is_aggregate_root}}
  {{name.pascalCase()}}({
    required this.id,
    // TODO: Add entity properties
  });

  @override
  final {{name.pascalCase()}}Id id;

  // TODO: Add entity properties

{{#is_aggregate_root}}
  // TODO: Add business methods that emit domain events
  // Example:
  // {{name.pascalCase()}} update({...}) {
  //   final updated = copyWith(...);
  //   updated.addDomainEvent({{name.pascalCase()}}Updated(updated));
  //   return updated;
  // }
{{/is_aggregate_root}}

  /// Creates a copy of this entity with the given fields replaced.
  {{name.pascalCase()}} copyWith({
    {{name.pascalCase()}}Id? id,
    // TODO: Add copyWith parameters
  }) {
    return {{name.pascalCase()}}(
      id: id ?? this.id,
      // TODO: Add property assignments
    );
  }

  @override
  String toString() {
    return '{{name.pascalCase()}}(id: $id)';
  }
}
