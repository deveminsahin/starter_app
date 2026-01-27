import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/domain/value_objects/name_failure.dart';
import 'package:starter_app/core/error/failures/failure.dart';
import 'package:starter_app/core/l10n/l10n_extensions.dart';
import 'package:starter_app/core/presentation/failure_message/failure_message_mapper.dart';

/// Maps name validation failures to user-friendly localized messages.
///
/// Handles [NameFailure] types with specific messages for each validation
/// error (currently just empty).
///
/// Registered automatically via [FailureMessageMapper] constructor.
@singleton
class NameFailureMapper extends FailureMessageMapper {
  /// Creates this mapper. Registration is automatic via super constructor.
  NameFailureMapper(super.registry);

  @override
  bool canHandle(Failure failure) => failure is NameFailure;

  @override
  String map(BuildContext context, Failure failure) {
    final nameFailure = failure as NameFailure;
    return nameFailure.when(
      empty: () => context.appL10n.nameEmpty,
    );
  }
}
