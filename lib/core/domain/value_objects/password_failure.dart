import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

part 'password_failure.freezed.dart';

/// Password validation failures.
///
/// Each variant represents a specific password validation requirement
/// that was not met. Use pattern matching to handle each case:
///
/// ```dart
/// // In UI mapper
/// final message = failure.when(
///   empty: () => context.l10n.passwordRequired,
///   tooShort: (min, actual) => context.l10n.passwordTooShort(min),
///   tooLong: (max, actual) => context.l10n.passwordTooLong(max),
///   missingUppercase: () => context.l10n.passwordMissingUppercase,
///   missingLowercase: () => context.l10n.passwordMissingLowercase,
///   missingDigit: () => context.l10n.passwordMissingDigit,
///   missingSpecialCharacter: () => context.l10n.passwordMissingSpecialChar,
/// );
/// ```
@freezed
sealed class PasswordFailure extends ValueFailure<String>
    with _$PasswordFailure {
  const PasswordFailure._();

  /// Password is empty.
  const factory PasswordFailure.empty() = PasswordEmpty;

  /// Password is too short.
  const factory PasswordFailure.tooShort({
    required int minLength,
    required int actualLength,
  }) = PasswordTooShort;

  /// Password is too long.
  const factory PasswordFailure.tooLong({
    required int maxLength,
    required int actualLength,
  }) = PasswordTooLong;

  /// Password is missing uppercase letter.
  const factory PasswordFailure.missingUppercase() = PasswordMissingUppercase;

  /// Password is missing lowercase letter.
  const factory PasswordFailure.missingLowercase() = PasswordMissingLowercase;

  /// Password is missing digit.
  const factory PasswordFailure.missingDigit() = PasswordMissingDigit;

  /// Password is missing special character.
  const factory PasswordFailure.missingSpecialCharacter() =
      PasswordMissingSpecialCharacter;
}
