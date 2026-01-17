import 'package:fpdart/fpdart.dart';

import 'package:starter_app/core/error/failures/value_failure.dart';

/// Base interface for all value objects in the domain layer.
///
/// A value object is a domain concept without identity, defined entirely by
/// its attributes. Unlike entities, value objects are compared by their values,
/// not by an ID.
///
/// Value objects encapsulate validation rules and ensure that invalid states
/// are unrepresentable in the domain.
///
/// The interface uses `Either<List<ValueFailure<T>>, T>` to support
/// returning multiple validation failures at once, improving UX by showing
/// all validation errors simultaneously.
///
/// Example:
/// ```dart
/// @immutable
/// class EmailAddress implements ValueObject<String> {
///   const EmailAddress._(this.value);
///
///   factory EmailAddress(String input) {
///     return EmailAddress._(_validateEmailAddress(input));
///   }
///
///   @override
///   final Either<List<ValueFailure<String>>, String> value;
///
///   static Either<List<ValueFailure<String>>, String> _validateEmailAddress(
///     String? input,
///   ) {
///     if (input == null || input.isEmpty) {
///       return left([const ValueFailure.empty(fieldName: 'Email')]);
///     }
///     if (!_emailRegex.hasMatch(input)) {
///       return left([
///         ValueFailure.invalidFormat(
///           expectedFormat: 'Valid email',
///           failedValue: input,
///         ),
///       ]);
///     }
///     return right(input);
///   }
///
///   @override
///   String getOrCrash() => value.fold(
///     (failures) => throw UnexpectedValueError(failures),
///     (s) => s,
///   );
///
///   @override
///   bool get isValid => value.isRight();
/// }
/// ```
abstract class ValueObject<T> {
  const ValueObject();

  /// The underlying value wrapped in an Either.
  ///
  /// Left represents a list of validation failures,
  /// Right represents a valid value.
  Either<List<ValueFailure<T>>, T> get value;

  /// Returns the value if valid, or throws [UnexpectedValueError] if invalid.
  ///
  /// Use this only when you're certain the value is valid (e.g., from a
  /// trusted source like the backend).
  T getOrCrash() {
    return value.fold(
      (f) => throw UnexpectedValueError(f),
      (s) => s,
    );
  }

  /// Returns the value if valid, or null if invalid.
  T? getOrNull() {
    return value.fold(
      (_) => null,
      (s) => s,
    );
  }

  /// Returns the validation failures if invalid, otherwise returns null.
  List<ValueFailure<T>>? getFailuresOrNull() {
    return value.fold(
      (failures) => failures,
      (_) => null,
    );
  }

  /// Returns true if the value is valid (Right), false otherwise (Left).
  bool get isValid => value.isRight();
}

/// Exception thrown when attempting to access an invalid value object.
final class UnexpectedValueError extends Error {
  /// Creates an [UnexpectedValueError] with the given [valueFailures].
  UnexpectedValueError(this.valueFailures);

  /// The validation failures that caused this error.
  final List<ValueFailure<dynamic>> valueFailures;

  @override
  String toString() {
    const explanation =
        'Encountered ValueFailure(s) at an unrecoverable point. '
        'Terminating.';
    final failuresStr = valueFailures.map((f) => f.toString()).join(', ');
    return Error.safeToString('$explanation Failures: [$failuresStr]');
  }
}
