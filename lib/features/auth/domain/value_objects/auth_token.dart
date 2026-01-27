import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';
import 'package:starter_app/features/auth/domain/value_objects/token_failure.dart';

/// Authentication token (JWT) value object with validation.
///
/// Represents an access token used for API authentication.
/// This is a feature-specific value object for the auth module.
///
/// Validates JWT format:
/// - Not empty
/// - Valid JWT structure (three base64url parts separated by dots)
/// - Header.Payload.Signature format
///
/// Returns [TokenFailure] types for clear error messages:
/// - [TokenEmpty] - Token is empty
/// - [TokenInvalidFormat] - Token doesn't match JWT format
///
/// Example:
/// ```dart
/// // From API response
/// final token = AuthToken.fromTrustedSource(apiResponse.accessToken);
///
/// // Manual validation (rarely needed)
/// final token = AuthToken('eyJhbGc...');
/// if (token.isValid) {
///   // Use token
/// }
/// ```
@immutable
class AuthToken extends ValueObject<String> {
  /// Creates an auth token with validation.
  ///
  /// Validates JWT format.
  factory AuthToken(String input) {
    return AuthToken._(_validateAuthToken(input));
  }
  const AuthToken._(this.value);

  /// Creates an auth token from a trusted source (e.g., backend API).
  ///
  /// Bypasses validation. Use for tokens received from authenticated APIs.
  factory AuthToken.fromTrustedSource(String input) {
    return AuthToken._(right(input));
  }

  @override
  final Either<List<ValueFailure<String>>, String> value;

  /// JWT regex pattern: three base64url parts separated by dots.
  ///
  /// Format: header.payload.signature
  /// Each part is base64url encoded (A-Za-z0-9_-)
  static final RegExp _jwtRegex = RegExp(
    r'^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$',
  );

  /// Validates auth token format.
  static Either<List<ValueFailure<String>>, String> _validateAuthToken(
    String? input,
  ) {
    if (input == null || input.isEmpty) {
      return left([const TokenFailure.empty()]);
    }

    if (!_jwtRegex.hasMatch(input)) {
      return left([
        const TokenFailure.invalidFormat(
          expectedFormat: 'Valid JWT token (header.payload.signature)',
        ),
      ]);
    }

    return right(input);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthToken &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'AuthToken(${isValid ? "***" : "invalid"})';
}
