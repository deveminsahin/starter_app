import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';
import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/domain/value_objects/password_failure.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

/// Password strength levels.
enum PasswordStrength implements Comparable<PasswordStrength> {
  /// Does not meet basic requirements.
  invalid(0, 'Invalid'),

  /// Meets minimum requirements.
  weak(1, 'Weak'),

  /// Good password (longer, more variety).
  good(2, 'Good'),

  /// Strong password (very long, high variety).
  strong(3, 'Strong')
  ;

  const PasswordStrength(this.value, this.label);

  /// Numeric value for comparison.
  final int value;

  /// User-friendly label.
  final String label;

  @override
  int compareTo(PasswordStrength other) => value.compareTo(other.value);

  /// Returns true if this strength is greater than or equal to [other].
  bool operator >=(PasswordStrength other) => value >= other.value;

  /// Returns true if this strength is strictly greater than [other].
  bool operator >(PasswordStrength other) => value > other.value;

  /// Returns true if this strength is less than or equal to [other].
  bool operator <=(PasswordStrength other) => value <= other.value;

  /// Returns true if this strength is strictly less than [other].
  bool operator <(PasswordStrength other) => value < other.value;
}

/// Password value object with validation.
///
/// Ensures passwords meet security requirements before being used
/// in the domain.
/// This is a core value object used across features (auth, settings, etc.).
///
/// Validation rules:
/// - Minimum 8 characters
/// - Maximum 128 characters
/// - At least one uppercase letter
/// - At least one lowercase letter
/// - At least one digit
/// - At least one special character
///
/// Returns ALL validation failures at once for better UX.
/// Each failure is a specific [PasswordFailure] type for clear error messages.
///
/// Example:
/// ```dart
/// // User input validation
/// final password = Password('weak');
/// if (!password.isValid) {
///   // Shows specific failures: PasswordTooShort, PasswordMissingUppercase, etc.
///   final failures = password.getFailuresOrNull();
///   for (final failure in failures!) {
///     failure.when(
///       empty: () => print('Password is required'),
///       tooShort: (min, actual) => print('Too short: $actual < $min'),
///       tooLong: (max, actual) => print('Too long'),
///       missingUppercase: () => print('Need uppercase'),
///       missingLowercase: () => print('Need lowercase'),
///       missingDigit: () => print('Need digit'),
///       missingSpecialCharacter: () => print('Need special char'),
///     );
///   }
/// }
///
/// // For password comparison (from backend)
/// final storedPassword = Password.fromTrustedSource('hashed_password');
/// ```
@immutable
final class Password extends ValueObject<String> {
  /// Creates a password with validation.
  ///
  /// Validates password strength and format.
  /// Returns ALL validation failures at once.
  factory Password(String input) {
    return Password._(_validatePassword(input));
  }

  /// Creates a password from a trusted source (e.g., backend hash).
  ///
  /// Bypasses validation. Use for already validated or hashed passwords.
  factory Password.fromTrustedSource(String input) {
    return Password._(right(input));
  }
  const Password._(this.value);

  /// Constant empty password.
  static const empty = Password._(
    Left([PasswordFailure.empty()]),
  );

  @override
  final Either<List<ValueFailure<String>>, String> value;

  /// Minimum password length.
  static const int minLength = 8;

  /// Maximum password length.
  static const int maxLength = 128;

  /// Regex for uppercase letter requirement.
  static final RegExp _uppercaseRegex = RegExp('[A-Z]');

  /// Regex for lowercase letter requirement.
  static final RegExp _lowercaseRegex = RegExp('[a-z]');

  /// Regex for digit requirement.
  static final RegExp _digitRegex = RegExp('[0-9]');

  /// Regex for special character requirement.
  static final RegExp _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}<>]');

  /// Validates password strength and format.
  ///
  /// Accumulates ALL validation failures for better UX.
  /// Users see all requirements they need to meet at once.
  /// Each failure is a specific [PasswordFailure] type.
  static Either<List<ValueFailure<String>>, String> _validatePassword(
    String? input,
  ) {
    // Early return for empty (no point checking other rules)
    if (input == null || input.isEmpty) {
      return left([const PasswordFailure.empty()]);
    }

    final failures = <PasswordFailure>[];

    // Check length constraints
    if (input.length < minLength) {
      failures.add(
        PasswordFailure.tooShort(
          minLength: minLength,
          actualLength: input.length,
        ),
      );
    }

    if (input.length > maxLength) {
      failures.add(
        PasswordFailure.tooLong(
          maxLength: maxLength,
          actualLength: input.length,
        ),
      );
    }

    // Check character requirements with specific failure types
    if (!_uppercaseRegex.hasMatch(input)) {
      failures.add(const PasswordFailure.missingUppercase());
    }

    if (!_lowercaseRegex.hasMatch(input)) {
      failures.add(const PasswordFailure.missingLowercase());
    }

    if (!_digitRegex.hasMatch(input)) {
      failures.add(const PasswordFailure.missingDigit());
    }

    if (!_specialCharRegex.hasMatch(input)) {
      failures.add(const PasswordFailure.missingSpecialCharacter());
    }

    // Return all failures or success
    return failures.isEmpty ? right(input) : left(failures);
  }

  /// Checks password strength level.
  ///
  /// Returns strength level:
  /// - invalid: Does not meet basic requirements
  /// - weak: Meets minimum requirements
  /// - good: Good password (longer, more variety)
  /// - strong: Strong password (very long, high variety)
  PasswordStrength get strengthLevel {
    if (!isValid) return PasswordStrength.invalid;

    final password = getOrCrash();
    var strength = 1;

    // Length bonus
    if (password.length >= 12) strength++;
    if (password.length >= 16) strength++;

    // Variety bonus (capped at 3)
    final hasMultipleSpecialChars =
        _specialCharRegex.allMatches(password).length >= 2;
    final hasMultipleDigits = _digitRegex.allMatches(password).length >= 2;

    if (hasMultipleSpecialChars && hasMultipleDigits && strength < 3) {
      strength++;
    }

    final finalStrength = strength.clamp(0, 3);

    return switch (finalStrength) {
      0 => PasswordStrength.invalid,
      1 => PasswordStrength.weak,
      2 => PasswordStrength.good,
      3 => PasswordStrength.strong,
      _ => PasswordStrength.invalid,
    };
  }

  /// Returns a user-friendly strength label.
  String get strengthLabel => strengthLevel.label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Password && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Password(${isValid ? "****" : "invalid"})';
}
