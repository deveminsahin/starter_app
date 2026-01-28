# ADR-0008: freezed for Immutable Data Classes

## Status

Accepted

## Context

Dart requires significant boilerplate for immutable classes:
- `copyWith` methods
- `==` and `hashCode` overrides
- `toString`

I needed code generation for immutable data classes while keeping domain entities as pure Dart classes.

## Decision

I adopt **freezed** for:
- ✅ **Failures** - Sealed class pattern with exhaustive matching
- ✅ **BLoC Events** - Discriminated unions for event handling
- ✅ **BLoC States** - Discriminated unions for state handling
- ✅ **DTOs/Models** - Data transfer objects in infrastructure

I do **NOT** use freezed for:
- ❌ **Entities** - Use plain Dart classes with `Entity` base class
- ❌ **Value Objects** - Use `ValueObject` base class with validation

### Why Not Entities?

Entities require:
1. **Identity-based equality** (not value-based)
2. **Domain events** via `AggregateRoot`
3. **Custom behavior methods**

Using freezed with `@Freezed(equal: false)` adds complexity without benefit.

### Implementation

```dart
// Failures - freezed for sealed class pattern
@freezed
sealed class AuthFailure with _$AuthFailure {
  const factory AuthFailure.invalidCredentials() = InvalidCredentials;
  const factory AuthFailure.serverError(String message) = ServerError;
}

// Entity - plain Dart class
class User extends AggregateRoot {
  User({required this.id, required this.email});
  
  @override
  final UserId id;
  final EmailAddress email;
  
  // Manual copyWith for full control
  User copyWith({UserId? id, EmailAddress? email}) => User(...);
}
```

## Consequences

### Positive
- **Less boilerplate**: Automatic copyWith, ==, hashCode, toString
- **Exhaustive matching**: Compiler ensures all cases handled
- **Type safety**: Sealed classes for failures and states

### Negative
- **Build step**: Requires `build_runner`
- **Generated code**: Larger output

### Neutral
- Entities remain pure Dart for DDD semantics
