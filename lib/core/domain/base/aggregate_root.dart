import 'package:starter_app/core/domain/base/domain_event.dart';
import 'package:starter_app/core/domain/base/entity.dart';

/// Base class for Aggregate Roots.
///
/// An Aggregate Root is an Entity that binds together a cluster of associated
/// objects (entities and value objects) that are treated as a unit for
/// data changes.
///
/// **Rules:**
/// - Aggregates are the only objects your Repositories should load/save.
/// - External objects can only hold references to the Aggregate Root (by ID),
///   not internal members.
/// - Aggregates enforce consistency boundaries.
/// - Aggregates can register Domain Events to be dispatched upon saving.
///
/// **Example:**
/// ```dart
/// class Order extends AggregateRoot {
///   final List<OrderItem> _items = [];
///
///   void addItem(Product product, int quantity) {
///     // Business logic ensuring consistency
///     _items.add(OrderItem(product, quantity));
///     // Record event
///     addDomainEvent(OrderUpdated(this));
///   }
/// }
/// ```
abstract class AggregateRoot extends Entity {
  final List<DomainEvent> _domainEvents = [];

  /// Returns a read-only list of domain events that occurred.
  List<DomainEvent> get domainEvents => List.unmodifiable(_domainEvents);

  /// Registers a domain event to be dispatched later.
  /// Typically, these are dispatched by the Repository or Application Service
  /// after the aggregate is successfully persisted.
  void addDomainEvent(DomainEvent event) {
    _domainEvents.add(event);
  }

  /// Clears all registered domain events.
  void clearDomainEvents() {
    _domainEvents.clear();
  }
}
