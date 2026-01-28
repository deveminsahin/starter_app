# Data Modeling Rules (Freezed & Immutability)

## Core Principles

- All data classes MUST be immutable
- Use `freezed` for **specific patterns only** (see ADR-008):
  - ✅ **Failures** - Sealed class pattern with exhaustive matching
  - ✅ **BLoC Events** - Discriminated unions for event handling
  - ✅ **BLoC States** - Discriminated unions for state handling
  - ✅ **DTOs/Models** - Data transfer objects in infrastructure
- **DO NOT use freezed for**:
  - ❌ **Entities** - Use plain Dart classes with `Entity`/`AggregateRoot` base class
  - ❌ **Value Objects** - Use `ValueObject` base class with validation
- Leverage union types for mutually exclusive states
- Separate domain entities from data transfer objects (DTOs)

## Freezed Setup

### Basic Data Class

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart'; // Only if you need JSON serialization

@freezed
class Product with _$Product {
  const Product._(); // Required for custom getters/methods
  
  const factory Product({
    required String id,
    required String name,
    required double price,
    @Default('') String description,
    @Default([]) List<String> tags,
  }) = _Product;
  
  // JSON serialization (optional)
  factory Product.fromJson(Map<String, dynamic> json) => 
      _$ProductFromJson(json);
}
```

### Rules (for DTOs/Models)

- ✅ **DO**: Use `@freezed` annotation for DTOs in infrastructure layer
- ✅ **DO**: Add `const ClassName._();` for custom methods
- ✅ **DO**: Use required for mandatory fields
- ✅ **DO**: Use `@Default()` for optional fields with defaults
- ❌ **DON'T**: Use nullable fields when a default makes sense
- ❌ **DON'T**: Forget part directives
- ❌ **DON'T**: Use `@freezed` for domain entities (see ADR-008)

## Custom Methods and Getters

### DTO Business Logic

When DTOs need custom computed properties:

```dart
@freezed
class ProductModel with _$ProductModel {
  const ProductModel._();
  
  const factory ProductModel({
    required String id,
    required String name,
    required double price,
    DateTime? lastModified,
  }) = _ProductModel;
  
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
  
  // Custom getters for computed properties
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}
```

### Custom Method Rules

- ✅ **DO**: Add computed properties as getters
- ✅ **DO**: Use `const ClassName._();` constructor
- ✅ **DO**: Keep logic pure (no side effects)
- ❌ **DON'T**: Mutate state in methods
- ❌ **DON'T**: Put business logic in DTOs (that belongs in entities)

## Union Types (Sealed Classes)

### State Representation

**Example from auth feature:**

```dart
// lib/features/auth/presentation/bloc/auth_state.dart
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.initial({
    required EmailAddress email,
    required bool isSubmitting,
    required FieldValidationState validation,
    ErrorModel? error,
  }) = Initial;

  const factory AuthState.unauthenticated() = Unauthenticated;

  const factory AuthState.loginRequired({
    required EmailAddress email,
    required Password password,
    required bool isSubmitting,
    required FieldValidationState validation,
    ErrorModel? error,
  }) = LoginRequired;

  const factory AuthState.registrationRequired({
    required EmailAddress email,
    required Password password,
    required Name name,
    required bool isSubmitting,
    required FieldValidationState validation,
    ErrorModel? error,
  }) = RegistrationRequired;

  const factory AuthState.authenticated(User user) = Authenticated;
}

// Usage with pattern matching
state.when(
  initial: (email, isSubmitting, validation, error) => const EmailForm(),
  unauthenticated: () => const LoginPrompt(),
  loginRequired: (email, password, isSubmitting, validation, error) =>
      const LoginForm(),
  registrationRequired: (email, password, name, isSubmitting, validation, error) =>
      const RegistrationForm(),
  authenticated: (user) => HomePage(user: user),
);

// Partial matching
state.mapOrNull(
  authenticated: (s) => s.user,
);

// Type checking
if (state is Authenticated) {
  final user = state.user;
}
```

### Result Types

```dart
@freezed
class LoginResult with _$LoginResult {
  const factory LoginResult.success(User user) = LoginSuccess;
  const factory LoginResult.invalidCredentials() = InvalidCredentials;
  const factory LoginResult.accountLocked() = AccountLocked;
  const factory LoginResult.networkError() = NetworkError;
}
```

### Union Type Rules

- ✅ **DO**: Use union types for mutually exclusive states
- ✅ **DO**: Make all cases const
- ✅ **DO**: Use `when` for exhaustive handling
- ✅ **DO**: Use `maybeWhen` for partial handling
- ❌ **DON'T**: Use nullable fields instead of union types
- ❌ **DON'T**: Mix data with state tags (use union types)

## JSON Serialization

### Basic Serialization

```dart
@freezed
class ProductModel with _$ProductModel {
  const ProductModel._();
  
  const factory ProductModel({
    required String id,
    required String name,
    required double price,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ProductModel;
  
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}
```

### Custom Converters

```dart
// Date converter
class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();
  
  @override
  DateTime fromJson(String json) => DateTime.parse(json);
  
  @override
  String toJson(DateTime object) => object.toIso8601String();
}

// Usage
@freezed
class Event with _$Event {
  const factory Event({
    required String id,
    @DateTimeConverter() required DateTime timestamp,
  }) = _Event;
  
  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
```

### JSON Null and Default Values

```dart
@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    @JsonKey(defaultValue: 0.0) required double price,
    @JsonKey(defaultValue: '') required String description,
    @JsonKey(defaultValue: []) required List<String> tags,
    @JsonKey(includeIfNull: false) String? discount,
  }) = _ProductModel;
  
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}
```

### JSON Serialization Rules

- ✅ **DO**: Use `@JsonKey()` for field name mapping
- ✅ **DO**: Handle null values with defaults
- ✅ **DO**: Use custom converters for complex types
- ✅ **DO**: Use `includeIfNull: false` for optional fields
- ❌ **DON'T**: Let null propagate into domain
- ❌ **DON'T**: Use JSON serialization in domain entities

## Domain Entity vs DTO Pattern

### Domain Entity (Plain Dart Class - NOT Freezed)

**CRITICAL: Entities do NOT use freezed** (see ADR-008)

**Example from auth feature:**

```dart
// lib/features/auth/domain/entities/user.dart
import 'package:starter_app/core/domain/base/aggregate_root.dart';

/// User entity representing an authenticated user.
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

  /// Domain behavior - emits domain event
  User verifyEmail() {
    if (isEmailVerified) return this;
    final updatedUser = copyWith(isEmailVerified: true);
    updatedUser.addDomainEvent(UserEmailVerified(updatedUser));
    return updatedUser;
  }

  /// Manual copyWith for full control
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
}
```

**Key points:**
- No `@freezed` annotation
- Extends `Entity` or `AggregateRoot` base class
- Uses value objects (EmailAddress, Name)
- Identity-based equality (handled by base class)
- Manual `copyWith()` for immutable updates
- Can emit domain events via `addDomainEvent()`

### Why NOT Freezed for Entities? (ADR-008)

1. **Identity-based equality** - handled by `Entity` base class
2. **Domain events** - `AggregateRoot.addDomainEvent()` provides this
3. **Custom behavior** - methods with domain logic
4. **DDD semantics** - freezed's value semantics conflict with entity identity

### DTO/Model (With Serialization)

**Example from auth feature:**

```dart
// lib/features/auth/infrastructure/models/user_model.dart
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    required bool isEmailVerified,
    String? profileImageUrl,
  }) = _UserModel;
  const UserModel._();

  /// Creates model from JSON (from API response).
  factory UserModel.fromJson(Json json) => _$UserModelFromJson(json);

  /// Converts model to domain entity.
  /// Uses `fromTrustedSource` since data comes from backend.
  User toDomain() {
    return User(
      id: UniqueId.fromString(id),
      email: EmailAddress.fromTrustedSource(email),
      isEmailVerified: isEmailVerified,
    );
  }

  /// Creates model from domain entity (for API requests).
  factory UserModel.fromDomain(User user) {
    return UserModel(
      id: user.id.value,
      email: user.email.getOrCrash(),
      name: '', // Name moved to UserProfile
      isEmailVerified: user.isEmailVerified,
    );
  }
}
```

### DTO Pattern Rules

- ✅ **DO**: Use `@freezed` for DTOs with JSON serialization
- ✅ **DO**: Keep domain entities clean (no JSON, no freezed)
- ✅ **DO**: Provide `toDomain()` and `fromDomain()` methods
- ✅ **DO**: Handle null/missing fields in DTOs
- ✅ **DO**: Use `fromTrustedSource` when converting from backend data
- ❌ **DON'T**: Use `@freezed` on domain entities (ADR-008)
- ❌ **DON'T**: Mix domain and infrastructure concerns
- ❌ **DON'T**: Let DTOs leak into domain layer
- ❌ **DON'T**: Use JSON serialization in domain entities

## CopyWith Pattern

### Basic Usage

```dart
final product = Product(id: '1', name: 'Item', price: 100);

// Create modified copy
final expensive = product.copyWith(price: 200);

// Partial update
final renamed = product.copyWith(name: 'New Name');

// Multiple fields
final updated = product.copyWith(
  name: 'Updated Item',
  price: 150,
);
```

### CopyWith Nullable Fields

```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    String? bio,
  }) = _User;
}

// Update nullable field
final user = User(id: '1', name: 'John');
final withBio = user.copyWith(bio: 'Developer'); // Set value
final removedBio = user.copyWith(bio: null); // Keep as null

// To explicitly set to null, use wrapped nullable
final clearedBio = user.copyWith(bio: () => null);
```

### CopyWith Rules

- ✅ **DO**: Use copyWith for immutable updates
- ✅ **DO**: Chain copyWith calls when needed
- ❌ **DON'T**: Mutate objects directly
- ❌ **DON'T**: Create multiple intermediate variables

## Deep Copying

### Nested Objects

```dart
@freezed
class Address with _$Address {
  const factory Address({
    required String street,
    required String city,
  }) = _Address;
}

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required Address address,
  }) = _User;
}

// Update nested object
final user = User(
  id: '1',
  name: 'John',
  address: const Address(street: '123 Main', city: 'NY'),
);

final updated = user.copyWith(
  address: user.address.copyWith(city: 'LA'),
);
```

### Collections

```dart
@freezed
class ShoppingCart with _$ShoppingCart {
  const ShoppingCart._();
  
  const factory ShoppingCart({
    @Default([]) List<CartItem> items,
  }) = _ShoppingCart;
  
  // Helper method for immutable updates
  ShoppingCart addItem(CartItem item) {
    return copyWith(items: [...items, item]);
  }
  
  ShoppingCart removeItem(String itemId) {
    return copyWith(
      items: items.where((item) => item.id != itemId).toList(),
    );
  }
}
```

## Code Generation

### Commands

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean before build
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Code Generation Rules

- ✅ **DO**: Run build_runner after adding/modifying freezed classes
- ✅ **DO**: Commit generated files to version control
- ✅ **DO**: Use watch mode during active development
- ❌ **DON'T**: Manually edit generated files
- ❌ **DON'T**: Check in conflicting outputs

## Best Practices

### Equality and HashCode

```dart
// Automatically provided by freezed
final product1 = Product(id: '1', name: 'Item', price: 100);
final product2 = Product(id: '1', name: 'Item', price: 100);

print(product1 == product2); // true (value equality)
print(product1.hashCode == product2.hashCode); // true
```

### ToString

```dart
// Automatically provided by freezed
final product = Product(id: '1', name: 'Item', price: 100);
print(product); // Product(id: 1, name: Item, price: 100.0)
```

### Late and Lazy

```dart
@freezed
class ExpensiveObject with _$ExpensiveObject {
  const ExpensiveObject._();
  
  const factory ExpensiveObject({
    required String id,
  }) = _ExpensiveObject;
  
  // Lazy computed property
  @late
  String get computedValue {
    // Expensive computation
    return 'computed_$id';
  }
}
```
