import 'package:starter_app/core/domain/base/domain_event.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';

/// Base class for all {{feature_name.snakeCase()}}-related domain events.
abstract class {{feature_name.pascalCase()}}DomainEvent extends DomainEvent {
  const {{feature_name.pascalCase()}}DomainEvent();
}

/// Emitted when a new {{feature_name.snakeCase()}} is created.
class {{feature_name.pascalCase()}}Created extends {{feature_name.pascalCase()}}DomainEvent {
  const {{feature_name.pascalCase()}}Created(this.item);
  final {{feature_name.pascalCase()}} item;
}

/// Emitted when a {{feature_name.snakeCase()}} is updated.
class {{feature_name.pascalCase()}}Updated extends {{feature_name.pascalCase()}}DomainEvent {
  const {{feature_name.pascalCase()}}Updated(this.item);
  final {{feature_name.pascalCase()}} item;
}

/// Emitted when a {{feature_name.snakeCase()}} is deleted.
class {{feature_name.pascalCase()}}Deleted extends {{feature_name.pascalCase()}}DomainEvent {
  const {{feature_name.pascalCase()}}Deleted(this.id);
  final String id;
}
