/// Base class for the Specification Pattern.
///
/// A Specification encapsulates a business rule or validation condition
/// that can be tested against a candidate object.
///
/// **Use Cases:**
/// - **Validation**: Check if an object satisfies a requirement.
/// - **Selection**: Select a subset of objects that satisfy criteria.
/// - **Construction**: Specify the creation criteria for an object.
///
/// **Usage:**
/// ```dart
/// class UserIsAdultSpec extends Specification<User> {
///   @override
///   bool isSatisfiedBy(User candidate) {
///     return candidate.age >= 18;
///   }
/// }
/// ```
abstract class Specification<T> {
  /// Checks if [candidate] satisfies the specification.
  bool isSatisfiedBy(T candidate);

  /// AND operator: Both specifications must be satisfied.
  Specification<T> and(Specification<T> other) =>
      _AndSpecification(this, other);

  /// OR operator: Either specification must be satisfied.
  Specification<T> or(Specification<T> other) => _OrSpecification(this, other);

  /// NOT operator: The specification must NOT be satisfied.
  Specification<T> toNot() => _NotSpecification(this);
}

class _AndSpecification<T> extends Specification<T> {
  _AndSpecification(this._left, this._right);
  final Specification<T> _left;
  final Specification<T> _right;

  @override
  bool isSatisfiedBy(T candidate) {
    return _left.isSatisfiedBy(candidate) && _right.isSatisfiedBy(candidate);
  }
}

class _OrSpecification<T> extends Specification<T> {
  _OrSpecification(this._left, this._right);
  final Specification<T> _left;
  final Specification<T> _right;

  @override
  bool isSatisfiedBy(T candidate) {
    return _left.isSatisfiedBy(candidate) || _right.isSatisfiedBy(candidate);
  }
}

class _NotSpecification<T> extends Specification<T> {
  _NotSpecification(this._spec);
  final Specification<T> _spec;

  @override
  bool isSatisfiedBy(T candidate) {
    return !_spec.isSatisfiedBy(candidate);
  }
}
