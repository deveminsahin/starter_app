import 'package:starter_app/core/domain/base/aggregate_root.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}_id.dart';

/// {{feature_name.pascalCase()}} entity - the primary aggregate root for this feature.
///
/// This is a domain entity (NOT freezed) following ADR-008.
/// Entities encapsulate business logic and emit domain events.
class {{feature_name.pascalCase()}} extends AggregateRoot {
  {{feature_name.pascalCase()}}({
    required this.id,
    // TODO: Add entity properties
  });

  @override
  final {{feature_name.pascalCase()}}Id id;

  // TODO: Add entity properties

  // TODO: Add business methods that emit domain events
  // Example:
  // {{feature_name.pascalCase()}} update({...}) {
  //   final updated = copyWith(...);
  //   updated.addDomainEvent({{feature_name.pascalCase()}}Updated(updated));
  //   return updated;
  // }

  /// Creates a copy of this entity with the given fields replaced.
  {{feature_name.pascalCase()}} copyWith({
    {{feature_name.pascalCase()}}Id? id,
    // TODO: Add copyWith parameters
  }) {
    return {{feature_name.pascalCase()}}(
      id: id ?? this.id,
      // TODO: Add property assignments
    );
  }

  @override
  String toString() {
    return '{{feature_name.pascalCase()}}(id: $id)';
  }
}
