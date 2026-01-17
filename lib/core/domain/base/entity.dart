import 'package:flutter/foundation.dart';
import 'package:starter_app/core/domain/base/unique_id.dart';

/// Base interface for all domain entities.
///
/// An entity is a domain object with a distinct identity that persists
/// over time, identified by its [id].
///
/// Entities use [UniqueId] value objects instead of primitive strings
/// to avoid primitive obsession and make the domain model more expressive.
///
/// ## Equality Strategies
///
/// Use `freezed` for entity implementations. You can choose between:
///
/// **Identity-based equality** (DDD):
/// Two entities with the same [id] are equal,
/// even if other properties differ. Override `==` and `hashCode`:
/// ```dart
/// @freezed
/// class Product with _$Product implements Entity {
///   const Product._();
///   const factory Product({required UniqueId id, required String name})
///   = _Product;
///
///   @override
///   bool operator ==(Object other) =>
///       identical(this, other) || other is Product && id == other.id;
///   @override
///   int get hashCode => id.hashCode;
/// }
/// ```
///
/// **Value-based equality**:
/// Use freezed's default behavior to compare all properties:
/// ```dart
/// @freezed
/// class Product with _$Product implements Entity {
///   const factory Product({required UniqueId id, required String name})
///   = _Product;
/// }
/// ```
@immutable
abstract class Entity {
  /// The unique identifier for this entity.
  ///
  /// This ID must be unique within the entity's domain.
  UniqueId get id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => Object.hash(runtimeType, id);
}
