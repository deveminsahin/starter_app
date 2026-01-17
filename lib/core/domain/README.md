# Domain Layer - Core

This directory contains the foundational building blocks for domain-driven design across all features.

## Overview

The domain layer is the heart of the application, containing:

- **Business entities** with identity
- **Value objects** without identity
- **Business rules** and validation logic
- **Repository interfaces** (ports)

This folder specifically contains **shared/core domain concepts** used across multiple features. Feature-specific domain models belong in their respective feature folders.

## Structure

```text
domain/
├── base/                       # Base abstractions
│   ├── base.dart              # Barrel export
│   ├── command.dart           # Command base classes (CQRS)
│   ├── entity.dart            # Entity interface
│   ├── query.dart             # Query base classes (CQRS)
│   ├── unique_id.dart         # UniqueId value object
│   ├── usecase.dart           # UseCase base classes (legacy)
│   └── value_object.dart      # ValueObject interface
├── ports/                      # Port interfaces (hexagonal architecture)
│   ├── ports.dart             # Barrel export
│   ├── i_secure_storage.dart  # Secure storage port
│   ├── i_session_manager.dart # Session management port
│   ├── i_token_refresh_notifier.dart # Token refresh notification port
│   ├── i_token_storage.dart   # Token storage port
│   ├── i_websocket_connection.dart # WebSocket connection port
│   └── i_websocket_manager.dart # WebSocket manager port
├── types/                      # Domain-level types
│   ├── types.dart             # Barrel export
│   ├── i_reconnection_policy.dart # Abstract reconnection policy interface
│   └── websocket_connection_state.dart # WebSocket state enum
└── value_objects/             # Shared value objects
    ├── value_objects.dart     # Barrel export
    ├── email_address.dart     # Email validation
    ├── image_url.dart         # Image URL validation
    ├── name.dart              # Name validation
    └── password.dart          # Password validation
```

## Core Concepts

### Entity vs Value Object

| Aspect | Entity | Value Object |
| -------- | -------- | -------------- |
| **Identity** | Has unique ID | No identity |
| **Equality** | By ID | By value |
| **Mutability** | Immutable (via copyWith) | Immutable |
| **Lifecycle** | Long-lived | Short-lived |
| **Example** | User, Product, Order | Email, Price, Address |

### Entity

An object with a unique identity that persists over time.

**Interface:**

```dart
abstract class Entity {
  UniqueId get id;
}
```

**Example:**

```dart
@freezed
class Product with _$Product implements Entity {
  const Product._();

  const factory Product({
    required UniqueId id,
    required String name,
    required double price,
    required String description,
  }) = _Product;

  // Business logic
  bool get isExpensive => price > 100;
  bool get isValid => name.isNotEmpty && price > 0;
}
```

**Rules:**

- ✅ Use `UniqueId` for identity (not String)
- ✅ Make immutable with `@freezed`
- ✅ Add business logic as methods/getters
- ✅ Keep pure (no I/O, no side effects)
- ❌ Don't add serialization (that's for DTOs/models)
- ❌ Don't depend on infrastructure

### Value Object

An object defined by its attributes, not identity.

**Interface:**

```dart
abstract class ValueObject<T> {
  Either<ValueFailure<T>, T> get value;
}
```

**Example - Email:**

```dart
@immutable
final class EmailAddress extends ValueObject<String> {
  factory EmailAddress(String input) {
    return EmailAddress._(_validateEmail(input));
  }
  
  const EmailAddress._(this.value);

  @override
  final Either<List<ValueFailure<String>>, String> value;

  static Either<List<ValueFailure<String>>, String> _validateEmail(String input) {
    if (input.isEmpty) {
      return left([const ValueFailure.empty()]);
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(input)) {
      return left([ValueFailure.invalidEmail(failedValue: input)]);
    }

    return right(input);
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EmailAddress && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
```

**Example - Price:**

```dart
@immutable
final class Price extends ValueObject<double> {
  factory Price(double amount) {
    return Price._(_validatePrice(amount));
  }
  
  const Price._(this.value);

  @override
  final Either<List<ValueFailure<double>>, double> value;

  static Either<List<ValueFailure<double>>, double> _validatePrice(double amount) {
    if (amount < 0) {
      return left([const ValueFailure.negative()]);
    }

    if (amount > 1000000) {
      return left([const ValueFailure.tooHigh(maxValue: 1000000)]);
    }

    return right(amount);
  }

  // Business logic
  String get formatted => value.fold(
    (_) => 'Invalid',
    (amount) => '\$${amount.toStringAsFixed(2)}',
  );
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Price && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
```

**Rules:**

- ✅ Encapsulate validation in factory constructor
- ✅ Return `Either<ValueFailure, T>` for validation
- ✅ Make immutable with `@freezed`
- ✅ Use private `_internal` constructor
- ✅ Add formatting/business logic as getters
- ❌ Don't allow invalid state
- ❌ Don't make validation optional

### UniqueId

A type-safe wrapper for entity IDs.

**Usage:**

```dart
// Creating from String (from database/API)
final id = UniqueId.fromString('user-123');

// Creating new (for new entities)
final newId = UniqueId.generate();

// Getting String value (for persistence)
final stringValue = id.value; // 'user-123'

// Equality
final id1 = UniqueId.fromString('123');
final id2 = UniqueId.fromString('123');
print(id1 == id2); // true
```

**Implementation:**

```dart
final class UniqueId {
  const UniqueId._(this.value);
  final String value;

  factory UniqueId.generate() {
    return UniqueId._(const Uuid().v4());
  }

  factory UniqueId.fromString(String value) {
    return UniqueId._(value);
  }

  static Either<ValueFailure<String>, UniqueId> fromUntrusted(String? input) {
    if (input == null || input.trim().isEmpty) {
      return left(const ValueFailure.empty());
    }
    return right(UniqueId._(input.trim()));
  }
}
```

**Benefits:**

- Type safety (can't confuse different ID types)
- Prevents primitive obsession
- Clear semantics in code
- Easy to add validation/formatting

## Creating New Domain Objects

### 1. Create an Entity

```bash
# Create in feature domain folder
touch lib/features/shop/domain/entities/product.dart
```

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:starter_app/core/domain/base/entity.dart';
import 'package:starter_app/core/domain/base/unique_id.dart';

part 'product.freezed.dart';

@freezed
class Product with _$Product implements Entity {
  const Product._();

  const factory Product({
    required UniqueId id,
    required String name,
    required double price,
    @Default([]) List<String> tags,
  }) = _Product;

  @override
  bool get isValid => name.isNotEmpty && price > 0;

  bool get isExpensive => price > 100;
}
```

### 2. Create a Value Object

```bash
# If shared across features
touch lib/core/domain/value_objects/phone_number.dart

# If feature-specific
touch lib/features/user/domain/value_objects/username.dart
```

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

part 'phone_number.freezed.dart';

@freezed
class PhoneNumber with _$PhoneNumber implements ValueObject<String> {
  const PhoneNumber._();

  const factory PhoneNumber._internal({
    required Either<ValueFailure<String>, String> value,
  }) = _PhoneNumber;

  factory PhoneNumber(String input) {
    return PhoneNumber._internal(
      value: _validate(input),
    );
  }

  static Either<ValueFailure<String>, String> _validate(String input) {
    if (input.isEmpty) {
      return left(const ValueFailure.empty());
    }

    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(input)) {
      return left(ValueFailure.invalidFormat(
        expectedFormat: 'E.164',
        failedValue: input,
      ));
    }

    return right(input);
  }
}
```

### 3. Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Validation Patterns

### Simple Validation

```dart
static Either<ValueFailure<String>, String> _validate(String input) {
  if (input.isEmpty) {
    return left(const ValueFailure.empty());
  }

  if (input.length < 3) {
    return left(ValueFailure.tooShort(
      minLength: 3,
      actualLength: input.length,
    ));
  }

  return right(input);
}
```

### Multiple Validations

```dart
static Either<ValueFailure<String>, String> _validate(String input) {
  return right(input)
    .flatMap(_validateNotEmpty)
    .flatMap(_validateLength)
    .flatMap(_validateFormat);
}

static Either<ValueFailure<String>, String> _validateNotEmpty(String input) {
  return input.isEmpty
    ? left(const ValueFailure.empty())
    : right(input);
}

static Either<ValueFailure<String>, String> _validateLength(String input) {
  return input.length < 3
    ? left(ValueFailure.tooShort(minLength: 3, actualLength: input.length))
    : right(input);
}
```

### Using Value Objects in Entities

```dart
@freezed
class User with _$User implements Entity {
  const User._();

  const factory User({
    required UniqueId id,
    required EmailAddress email,
    required Username username,
    PhoneNumber? phoneNumber,
  }) = _User;

  // Validation across multiple value objects
  bool get isValid => email.value.isRight() && username.value.isRight();

  // Extract validated values
  String? get validEmail => email.value.getOrElse(() => null);
}
```

## Best Practices

### DO ✅

- Use `UniqueId` for all entity IDs
- Validate in value object constructors
- Keep domain layer pure (no I/O, no framework dependencies)
- Use `Either<Failure, T>` for operations that can fail
- Add business logic as methods/getters in entities
- Use freezed for immutability
- Separate domain entities from DTOs/models
- Keep validation close to data (in value objects)

### DON'T ❌

- Don't use primitive types for IDs (String, int)
- Don't allow invalid state in value objects
- Don't add JSON serialization to domain classes
- Don't depend on infrastructure (database, API)
- Don't mix presentation logic in domain
- Don't use mutable state
- Don't create anemic domain models (data without behavior)
- Don't bypass validation

## Testing Domain Objects

### Testing Entities

```dart
test('Product is expensive when price > 100', () {
  final product = Product(
    id: UniqueId.generate(),
    name: 'Test',
    price: 150,
  );

  expect(product.isExpensive, isTrue);
});

test('Product equality by ID', () {
  final id = UniqueId.generate();

  final product1 = Product(id: id, name: 'A', price: 10);
  final product2 = Product(id: id, name: 'B', price: 20);

  expect(product1.id, equals(product2.id));
});
```

### Testing Value Objects

```dart
group('EmailAddress', () {
  test('valid email passes', () {
    final email = EmailAddress('test@example.com');

    expect(email.value.isRight(), isTrue);
  });

  test('empty email fails', () {
    final email = EmailAddress('');

    expect(
      email.value.isLeft(),
      isTrue,
    );
  });

  test('invalid format fails', () {
    final email = EmailAddress('notanemail');

    email.value.fold(
      (failure) => expect(failure, isA<InvalidEmail>()),
      (_) => fail('Should have failed'),
    );
  });
});
```

### Testing with UniqueId

```dart
test('UniqueId generates unique values', () {
  final id1 = UniqueId.generate();
  final id2 = UniqueId.generate();

  expect(id1, isNot(equals(id2)));
});

test('UniqueId equality by value', () {
  final id1 = UniqueId.fromString('123');
  final id2 = UniqueId.fromString('123');

  expect(id1, equals(id2));
});
```

## Common Value Objects

Consider creating these shared value objects:

- `EmailAddress` - Email validation
- `PhoneNumber` - Phone number validation
- `Url` - URL validation
- `PositiveInt` - Positive integer constraint
- `NonNegativeDouble` - Non-negative double
- `DateRange` - Date range validation
- `Percentage` - 0-100 constraint
- `Money` - Currency amount with precision

## References

- Architecture Rules: `docs/architecture-rules/03_domain_layer.md`
- Error Handling: `docs/architecture-rules/08_error_handling.md`
- Data Modeling: `docs/architecture-rules/11_data_modeling.md`
- [Domain-Driven Design Fundamentals](https://martinfowler.com/bliki/DomainDrivenDesign.html)
