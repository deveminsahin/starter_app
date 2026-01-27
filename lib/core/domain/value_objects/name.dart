import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/domain/value_objects/name_failure.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

/// Name value object with validation.
///
/// Ensures names are non-empty before being used in the domain.
/// This is a core value object used across features (auth, profiles, etc.).
///
/// Returns specific [NameFailure] types for clear error messages:
/// - [NameEmpty] - Name is empty or whitespace only
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

  /// Validates name is not empty.
  ///
  /// Returns [NameFailure.empty] if the name is null or whitespace only.
  static Either<List<ValueFailure<String>>, String> _validateName(
    String? input,
  ) {
    if (input == null || input.trim().isEmpty) {
      return left([const NameFailure.empty()]);
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
