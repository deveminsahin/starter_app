# ADR-0007: Specification Pattern for Business Rules

## Status

Accepted

## Context

Business rules often need to be:
1. Reusable across multiple contexts
2. Composable (AND, OR, NOT conditions)
3. Testable in isolation
4. Named for clarity

Embedding rules directly in entities/services makes them hard to reuse and test.

## Decision

I adopt the **Specification Pattern** for encapsulating business rules.

### Implementation

```dart
// Base specification with composition operators
abstract class Specification<T> {
  bool isSatisfiedBy(T candidate);
  
  Specification<T> and(Specification<T> other);
  Specification<T> or(Specification<T> other);
  Specification<T> toNot();
}

// Concrete specification
class UserIsAdultSpec extends Specification<User> {
  @override
  bool isSatisfiedBy(User candidate) => candidate.age >= 18;
}

class UserHasVerifiedEmailSpec extends Specification<User> {
  @override
  bool isSatisfiedBy(User candidate) => candidate.isEmailVerified;
}

// Composition
final canAccessPremium = UserIsAdultSpec().and(UserHasVerifiedEmailSpec());
if (canAccessPremium.isSatisfiedBy(user)) {
  // Allow access
}
```

See: `lib/core/domain/base/specification.dart`

## Consequences

### Positive
- **Reusability**: Use same spec across features
- **Composability**: Build complex rules from simple ones
- **Testability**: Test specs in isolation
- **Readability**: Named specs document business rules

### Negative
- **More classes**: One class per rule

### Neutral
- Specs should be pure (no side effects)
