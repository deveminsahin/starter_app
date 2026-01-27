import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/domain/value_objects/name_failure.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

/// Name value object with validation.
///
/// Ensures names are non-empty and within length limits before being used
/// in the domain. This is a core value object used across features
/// (auth, profiles, etc.).
///
/// Validation rules:
/// - Not empty or whitespace only
/// - Maximum 100 characters (after trimming)
///
/// Returns specific [NameFailure] types for clear error messages:
/// - [NameEmpty] - Name is empty or whitespace only
/// - [NameTooLong] - Name exceeds 100 characters
///
/// Example:
/// ```dart
/// // User input validation
/// final name = Name('John Doe');
/// if (name.isValid) {
///   // Use name.getOrCrash()
/// } else {
///   final failures = name.getFailuresOrNull();
///   for (final failure in failures!) {
///     failure.when(
///       empty: () => print('Name is required'),
///       tooLong: (max, actual) => print('Name too long: $actual > $max'),
///     );
///   }
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

  /// Maximum name length.
  ///
  /// 100 characters is a reasonable limit for display names
  /// that fits most UI layouts and database schemas.
  static const int maxLength = 100;

  /// Validates name is not empty and within length limits.
  ///
  /// Returns [NameFailure.empty] if the name is null or whitespace only.
  /// Returns [NameFailure.tooLong] if the name exceeds [maxLength].
  static Either<List<ValueFailure<String>>, String> _validateName(
    String? input,
  ) {
    if (input == null || input.trim().isEmpty) {
      return left([const NameFailure.empty()]);
    }

    final trimmed = input.trim();

    if (trimmed.length > maxLength) {
      return left([
        NameFailure.tooLong(
          maxLength: maxLength,
          actualLength: trimmed.length,
        ),
      ]);
    }

    return right(trimmed);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Name && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Name(${getOrNull() ?? "invalid"})';
}
