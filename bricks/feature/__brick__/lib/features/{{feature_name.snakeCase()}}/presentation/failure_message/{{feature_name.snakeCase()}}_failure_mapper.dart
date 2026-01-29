import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/error/failures/failure.dart';
import 'package:starter_app/core/presentation/failure_message/failure_message_mapper.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/failure/{{feature_name.snakeCase()}}_failure.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/l10n/l10n_extensions.dart';

/// Maps {{feature_name.snakeCase()}} failures to user-friendly localized messages.
///
/// Registration is automatic via the base class constructor.
@injectable
final class {{feature_name.pascalCase()}}FailureMapper extends FailureMessageMapper {
  {{feature_name.pascalCase()}}FailureMapper(super.registry);

  @override
  bool canHandle(Failure failure) => failure is {{feature_name.pascalCase()}}Failure;

  @override
  String map(BuildContext context, Failure failure) {
    final l10n = context.{{feature_name.camelCase()}}L10n;
    final {{feature_name.camelCase()}}Failure = failure as {{feature_name.pascalCase()}}Failure;
    return {{feature_name.camelCase()}}Failure.map(
      unexpected: (_) => l10n.unexpectedError,
      serverError: (_) => l10n.serverError,
      notFound: (_) => l10n.notFound,
    );
  }
}
