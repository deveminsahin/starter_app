import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/domain/value_objects/email_failure.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

/// Email address value object with validation.
///
/// Ensures email addresses are valid before being used in the domain.
/// This is a core value object used across features (auth, profiles, etc.).
///
/// Returns specific [EmailFailure] types for clear error messages:
/// - [EmailEmpty] - Email is empty
/// - [EmailTooLong] - Email exceeds 254 characters
/// - [EmailInvalidFormat] - Email doesn't match RFC 5322 pattern
///
/// Example:
/// ```dart
/// // User input validation
/// final email = EmailAddress('user@example.com');
/// if (email.isValid) {
///   // Use email.getOrCrash()
/// } else {
///   final failures = email.getFailuresOrNull();
///   for (final failure in failures!) {
///     failure.when(
///       empty: () => print('Email is required'),
///       tooLong: (max, actual) => print('Email too long'),
///       invalidFormat: (value) => print('Invalid email format'),
///     );
///   }
/// }
///
/// // From trusted backend
/// final backendEmail = EmailAddress.fromTrustedSource('admin@app.com');
/// ```
@immutable
final class EmailAddress extends ValueObject<String> {
  /// Creates an email address with validation.
  ///
  /// Validates the email format using RFC 5322 compliant regex.
  factory EmailAddress(String input) {
    return EmailAddress._(_validateEmailAddress(input));
  }

  /// Creates an email address from a trusted source (e.g., backend).
  ///
  /// Bypasses validation. Use only when certain the email is valid.
  factory EmailAddress.fromTrustedSource(String input) {
    return EmailAddress._(right(input));
  }
  const EmailAddress._(this.value);

  /// Constant empty email address.
  static const empty = EmailAddress._(
    Left([EmailFailure.empty()]),
  );

  @override
  final Either<List<ValueFailure<String>>, String> value;

  /// Email validation regex (RFC 5322 simplified).
  ///
  /// Validates:
  /// - Local part: alphanumeric + allowed special chars
  /// - @ symbol
  /// - Domain labels: alphanumeric with hyphens (not at start/end)
  /// - Subdomains: multiple domain labels separated by dots
  /// - TLD: 2+ alphabetic characters
  ///
  /// Uses `$` anchor to prevent trailing garbage from passing validation.
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@"
    r'[a-zA-Z0-9](?:[a-zA-Z0-9\-]*[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9\-]*[a-zA-Z0-9])?)*'
    r'\.[a-zA-Z]{2,}$',
  );

  /// Maximum email length (RFC 5321).
  static const int maxLength = 254;

  /// Validates email address format and length.
  ///
  /// Returns specific [EmailFailure] types for sequential validation
  /// (if empty, no need to check format).
  static Either<List<ValueFailure<String>>, String> _validateEmailAddress(
    String? input,
  ) {
    if (input == null || input.isEmpty) {
      return left([const EmailFailure.empty()]);
    }

    if (input.length > maxLength) {
      return left([
        EmailFailure.tooLong(
          maxLength: maxLength,
          actualLength: input.length,
        ),
      ]);
    }

    if (!_emailRegex.hasMatch(input)) {
      return left([
        EmailFailure.invalidFormat(
          failedValue: input,
        ),
      ]);
    }

    return right(input.trim().toLowerCase());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EmailAddress && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'EmailAddress(${getOrNull() ?? "invalid"})';
}
