import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

part 'token_failure.freezed.dart';

/// Token validation failures.
///
/// Each variant represents a specific token validation requirement
/// that was not met. Use pattern matching to handle each case:
///
/// ```dart
/// // In UI mapper
/// final message = failure.when(
///   empty: () => context.l10n.tokenRequired,
///   tooShort: (min, actual) => context.l10n.tokenTooShort(min),
///   invalidFormat: (expected) => context.l10n.tokenInvalid,
///   expired: () => context.l10n.tokenExpired,
/// );
/// ```
@freezed
sealed class TokenFailure extends ValueFailure<String> with _$TokenFailure {
  const TokenFailure._();

  /// Token is empty.
  const factory TokenFailure.empty() = TokenEmpty;

  /// Token is too short.
  const factory TokenFailure.tooShort({
    required int minLength,
    required int actualLength,
  }) = TokenTooShort;

  /// Token format is invalid.
  const factory TokenFailure.invalidFormat({
    required String expectedFormat,
  }) = TokenInvalidFormat;

  /// Token has expired.
  const factory TokenFailure.expired() = TokenExpired;
}
