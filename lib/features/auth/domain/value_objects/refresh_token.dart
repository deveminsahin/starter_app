import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';
import 'package:starter_app/features/auth/domain/value_objects/token_failure.dart';

/// Refresh token value object with validation.
///
/// Represents a refresh token used to obtain new access tokens.
/// This is a feature-specific value object for the auth module.
///
/// Refresh tokens can be:
/// - Opaque strings
/// - UUIDs
/// - JWTs
/// - Custom formats
///
/// Validates:
/// - Not empty
/// - Minimum length (16 characters for security)
///
/// Returns [TokenFailure] types for clear error messages:
/// - [TokenEmpty] - Token is empty
/// - [TokenTooShort] - Token is too short
///
/// Example:
/// ```dart
/// // From API response
/// final refreshToken = RefreshToken.fromTrustedSource(
///   apiResponse.refreshToken,
/// );
///
/// // Manual validation (rarely needed)
/// final refreshToken = RefreshToken('refresh_token_string');
/// if (refreshToken.isValid) {
///   // Store securely
/// }
/// ```
@immutable
class RefreshToken extends ValueObject<String> {
  /// Creates a refresh token with validation.
  ///
  /// Validates token format and length.
  factory RefreshToken(String input) {
    return RefreshToken._(_validateRefreshToken(input));
  }
  const RefreshToken._(this.value);

  /// Creates a refresh token from a trusted source (e.g., backend API).
  ///
  /// Bypasses validation. Use for tokens received from authenticated APIs.
  factory RefreshToken.fromTrustedSource(String input) {
    return RefreshToken._(right(input));
  }

  @override
  final Either<List<ValueFailure<String>>, String> value;

  /// Minimum refresh token length for security.
  static const int minLength = 16;

  /// Validates refresh token.
  static Either<List<ValueFailure<String>>, String> _validateRefreshToken(
    String? input,
  ) {
    if (input == null || input.isEmpty) {
      return left([const TokenFailure.empty()]);
    }

    if (input.length < minLength) {
      return left([
        TokenFailure.tooShort(
          minLength: minLength,
          actualLength: input.length,
        ),
      ]);
    }

    return right(input);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefreshToken &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'RefreshToken(${isValid ? "***" : "invalid"})';
}
