# ADR-0006: Domain Events & Event Dispatcher

## Status

Accepted

## Context

In DDD, side effects from domain operations (sending emails, updating caches, analytics) need to be handled without coupling the domain to infrastructure.

Options considered:
1. **Direct calls** - Domain calls services directly (violates layer boundaries)
2. **Return events** - Domain returns events, caller dispatches
3. **Event bus** - In-memory pub/sub for domain events

## Decision

I adopt an **in-memory Event Bus** pattern with:
- `DomainEvent` base class for all domain events
- `IEventDispatcher` interface (port)
- `EventDispatcher` implementation using broadcast `StreamController`
- `AggregateRoot` collects events, repository dispatches after save

### Implementation

```dart
// Domain event
class UserEmailVerified extends DomainEvent {
  const UserEmailVerified(this.user);
  final User user;
}

// Aggregate root collects events
class User extends AggregateRoot {
  User verifyEmail() {
    final updated = copyWith(isEmailVerified: true);
    updated.addDomainEvent(UserEmailVerified(updated));
    return updated;
  }
}

// Subscribe to events
dispatcher.on<UserEmailVerified>().listen((event) {
  sendVerificationConfirmationEmail(event.user);
});
```

See: `lib/core/domain/base/event_dispatcher.dart`

## Consequences

### Positive
- **Decoupling**: Domain doesn't know about side effects
- **Extensibility**: Easy to add new listeners
- **Testability**: Mock dispatcher in tests

### Negative
- **Eventual consistency**: Events are async
- **Debugging**: Harder to trace flow

### Neutral
- Events are dispatched after successful persistence
