import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/domain/value_objects/password_failure.dart';
import 'package:starter_app/core/error/failures/failure.dart';
import 'package:starter_app/core/l10n/l10n_extensions.dart';
import 'package:starter_app/core/presentation/failure_message/failure_message_mapper.dart';

/// Maps password validation failures to user-friendly localized messages.
///
/// Handles [PasswordFailure] types with specific messages for each validation
/// requirement (empty, too short, missing uppercase, etc.).
///
/// Registered automatically via [FailureMessageMapper] constructor.
@singleton
class PasswordFailureMapper extends FailureMessageMapper {
  /// Creates this mapper. Registration is automatic via super constructor.
  PasswordFailureMapper(super.registry);

  @override
  bool canHandle(Failure failure) => failure is PasswordFailure;

  @override
  String map(BuildContext context, Failure failure) {
    final passwordFailure = failure as PasswordFailure;
    return passwordFailure.when(
      empty: () => context.appL10n.passwordEmpty,
      tooShort: (minLength, _) => context.appL10n.passwordTooShort(minLength),
      tooLong: (maxLength, _) => context.appL10n.passwordTooLong(maxLength),
      missingUppercase: () => context.appL10n.passwordMissingUppercase,
      missingLowercase: () => context.appL10n.passwordMissingLowercase,
      missingDigit: () => context.appL10n.passwordMissingDigit,
      missingSpecialCharacter: () =>
          context.appL10n.passwordMissingSpecialCharacter,
    );
  }
}
