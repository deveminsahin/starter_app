import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

part 'email_failure.freezed.dart';

/// Email validation failures.
///
/// Each variant represents a specific email validation requirement
/// that was not met. Use pattern matching to handle each case:
///
/// ```dart
/// // In UI mapper
/// final message = failure.when(
///   empty: () => context.l10n.emailRequired,
///   tooLong: (max, actual) => context.l10n.emailTooLong(max),
///   invalidFormat: (value) => context.l10n.emailInvalid,
/// );
/// ```
@freezed
sealed class EmailFailure extends ValueFailure<String> with _$EmailFailure {
  const EmailFailure._();

  /// Email is empty.
  const factory EmailFailure.empty() = EmailEmpty;

  /// Email exceeds maximum length.
  const factory EmailFailure.tooLong({
    required int maxLength,
    required int actualLength,
  }) = EmailTooLong;

  /// Email format is invalid.
  const factory EmailFailure.invalidFormat({
    required String failedValue,
  }) = EmailInvalidFormat;
}
