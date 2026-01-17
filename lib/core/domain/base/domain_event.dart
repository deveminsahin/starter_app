import 'package:flutter/foundation.dart';

/// Base class for all domain events.
///
/// A Domain Event is something
///  that happened in the domain that experts care about.
/// It captures the memory of something interesting which affects the domain.
///
/// Events are:
/// - **Immutable**: They represent a fact in the past.
/// - **Named in past tense**: e.g., `UserRegistered`, `OrderPlaced`.
/// - **Self-contained**:
///  Should contain minimal necessary data to react to the event.
///
/// Usage:
/// ```dart
/// class UserRegistered extends DomainEvent {
///   final User user;
///   final DateTime occurredAt;
///
///   UserRegistered(this.user) : occurredAt = DateTime.now();
/// }
/// ```
@immutable
abstract class DomainEvent {
  const DomainEvent();
}
