# Domain Layer Rules

## Core Principles

- Domain layer is the heart of the application
- Must be completely independent and technology-agnostic
- Contains pure business logic only
- Zero dependencies on outer layers

## Entities

### Definition

- Objects with distinct identity that persists over time
- **DO NOT use freezed** - use plain Dart classes (see ADR-008)
- Extend `Entity` or `AggregateRoot` from `core/domain/base/`
- AggregateRoots can emit domain events for rich DDD behavior

### Structure

**Example from auth feature:**

```dart
// lib/features/auth/domain/entities/user.dart
import 'package:starter_app/core/domain/base/aggregate_root.dart';

/// User entity representing an authenticated user.
///
/// This is the Auth Aggregate - strictly handles authentication identity.
class User extends AggregateRoot {
  User({
    required this.id,
    required this.email,
    required this.isEmailVerified,
  });

  @override
  final UserId id;
  final EmailAddress email;
  final bool isEmailVerified;

  /// Marks the user's email as verified.
  /// Emits [UserEmailVerified] domain event.
  User verifyEmail() {
    if (isEmailVerified) return this;
    final updatedUser = copyWith(isEmailVerified: true);
    updatedUser.addDomainEvent(UserEmailVerified(updatedUser));
    return updatedUser;
  }

  /// Manual copyWith for full control over domain behavior.
  User copyWith({
    UserId? id,
    EmailAddress? email,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email)';
}
```

### Why NOT Freezed for Entities? (ADR-008)

Entities require:
1. **Identity-based equality** (not value-based) - handled by `Entity` base class
2. **Domain events** via `AggregateRoot.addDomainEvent()`
3. **Custom behavior methods** with domain logic

Using freezed adds complexity without benefit and conflicts with DDD semantics.

### Rules

- ✅ **DO**: Extend `Entity` or `AggregateRoot` base class
- ✅ **DO**: Implement manual `copyWith()` for immutable updates
- ✅ **DO**: Use value objects for properties (EmailAddress, not String)
- ✅ **DO**: Add domain behavior methods (verifyEmail, changePassword)
- ✅ **DO**: Emit domain events for significant state changes
- ❌ **DON'T**: Use `@freezed` annotation on entities (ADR-008)
- ❌ **DON'T**: Add serialization logic (no toJson/fromJson)
- ❌ **DON'T**: Import Flutter or external packages
- ❌ **DON'T**: Include infrastructure concerns (DB, API)

## Value Objects

### Value Object Definition

- Domain concepts without identity
- Encapsulate validation rules
- Use `Either<List<ValueFailure<T>>, T>` for validation (supports multiple failures)
- Simple immutable classes (DO NOT use freezed)
- Use `@immutable` annotation from Flutter foundation

### Value Object Structure

**Example from core domain:**

```dart
// lib/core/domain/value_objects/email_address.dart
@immutable
class EmailAddress implements ValueObject<String> {
  /// Creates an email address with validation.
  factory EmailAddress(String input) {
    return EmailAddress._(_validateEmailAddress(input));
  }
  const EmailAddress._(this.value);

  /// Creates from trusted source (bypasses validation).
  factory EmailAddress.fromTrustedSource(String input) {
    return EmailAddress._(right(input));
  }

  @override
  final Either<List<ValueFailure<String>>, String> value;

  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  /// Validates and returns either failures list or valid value.
  static Either<List<ValueFailure<String>>, String> _validateEmailAddress(
    String? input,
  ) {
    if (input == null || input.isEmpty) {
      return left([const EmailFailure.empty()]);
    }

    if (!_emailRegex.hasMatch(input)) {
      return left([
        EmailFailure.invalidFormat(failedValue: input),
      ]);
    }

    return right(input.trim().toLowerCase());
  }

  @override
  String getOrCrash() => value.fold(
    (failures) => throw UnexpectedValueError(failures),
    (s) => s,
  );

  @override
  bool get isValid => value.isRight();

  List<ValueFailure<String>>? getFailuresOrNull() => value.fold(
    (failures) => failures,
    (_) => null,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailAddress && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'EmailAddress(${getOrNull() ?? "invalid"})';
}
```

### Value Object Rules

- ✅ **DO**: Use simple immutable classes with `@immutable` annotation
- ✅ **DO**: Use `Either<List<ValueFailure<T>>, T>` to support multiple failures
- ✅ **DO**: Accumulate all validation failures for better UX (especially for passwords)
- ✅ **DO**: Use factory constructors for creation
- ✅ **DO**: Provide `fromTrustedSource` for backend data
- ✅ **DO**: Include `getOrCrash()`, `isValid`, and `getFailuresOrNull()` methods
- ✅ **DO**: Implement `==`, `hashCode`, and `toString()` for value equality
- ✅ **DO**: Private const constructor before factory constructors (linter rule)
- ❌ **DON'T**: Use freezed for value objects (too heavy, unnecessary)
- ❌ **DON'T**: Allow direct construction without validation
- ❌ **DON'T**: Throw exceptions in factory constructors
- ❌ **DON'T**: Return single failure when multiple checks fail (bad UX)

### Multiple Failures Pattern

For value objects with multiple validation rules (e.g., passwords), accumulate all failures for better UX:

**Example from Password value object:**

```dart
// lib/core/domain/value_objects/password.dart
static Either<List<ValueFailure<String>>, String> _validatePassword(
  String? input,
) {
  // Early return for empty (no point checking other rules)
  if (input == null || input.isEmpty) {
    return left([const PasswordFailure.empty()]);
  }

  final failures = <PasswordFailure>[];

  // Accumulate all failures with domain-specific types
  if (input.length < 8) {
    failures.add(PasswordFailure.tooShort(minLength: 8, actualLength: input.length));
  }
  if (!_uppercaseRegex.hasMatch(input)) {
    failures.add(const PasswordFailure.missingUppercase());
  }
  if (!_digitRegex.hasMatch(input)) {
    failures.add(const PasswordFailure.missingDigit());
  }

  // Return all failures or success
  return failures.isEmpty ? right(input) : left(failures);
}
```

This allows users to see all validation errors at once, rather than fixing one error at a time.

**Domain-Specific Failure Types:**
- `PasswordFailure` - password strength requirements
- `EmailFailure` - email format/length
- `NameFailure` - name validation
- `TokenFailure` - token format
- `UniqueIdFailure` - ID validation

## Repository Interfaces (Ports)

### Repository Interface Definition

- Abstract contracts for data operations
- Define what can be done, not how
- Always return `Either<Failure, T>` or `Stream<Either<Failure, T>>`

### Repository Interface Structure

**Example from auth domain:**

```dart
// lib/features/auth/domain/repositories/i_auth_repository.dart
abstract class IAuthRepository {
  FutureResult<bool> checkUserExists(EmailAddress email);

  FutureResult<User> login(AuthCredentials credentials);

  FutureResult<User> register(AuthCredentials credentials);

  FutureResult<Unit> logout();

  FutureResult<User?> getCurrentUser();

  StreamResult<User?> watchAuthChanges();
}
```

**Note:** `FutureResult<T>` and `StreamResult<T>` are type aliases:

```dart
// lib/core/types/types.dart
typedef FutureResult<T> = Future<Either<Failure, T>>;
typedef StreamResult<T> = Stream<Either<Failure, T>>;
```

### Repository Interface Rules

- ✅ **DO**: Use `Either<Failure, T>` for operations that can fail
- ✅ **DO**: Name with `I` prefix: `IProductRepository`
- ✅ **DO**: Work with domain Entities, not DTOs
- ✅ **DO**: Keep methods focused and single-purpose
- ❌ **DON'T**: Include implementation details
- ❌ **DON'T**: Return raw types that can throw exceptions

## Folder Structure

```text
domain/
├── entities/          # Core business objects
├── value_objects/     # Validated domain values
└── repositories/      # Abstract data access contracts
```
