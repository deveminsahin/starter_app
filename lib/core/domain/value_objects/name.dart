import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

/// Name value object with validation.
///
/// Ensures names are non-empty before being used in the domain.
/// This is a core value object used across features (auth, profiles, etc.).
///
/// Example:
/// ```dart
/// // User input validation
/// final name = Name('John Doe');
/// if (name.isValid) {
///   // Use name.getOrCrash()
/// }
///
/// // From trusted backend
/// final backendName = Name.fromTrustedSource('Admin User');
/// ```
@immutable
final class Name extends ValueObject<String> {
  factory Name(String input) {
    return Name._(_validateName(input));
  }
  const Name._(this.value);

  factory Name.fromTrustedSource(String input) {
    return Name._(right(input));
  }

  @override
  final Either<List<ValueFailure<String>>, String> value;

  /// Validates name is not empty.
  static Either<List<ValueFailure<String>>, String> _validateName(
    String? input,
  ) {
    if (input == null || input.trim().isEmpty) {
      return left([const ValueFailure.empty(fieldName: 'Name')]);
    }
    return right(input.trim());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Name && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Name(${getOrNull() ?? "invalid"})';
}
