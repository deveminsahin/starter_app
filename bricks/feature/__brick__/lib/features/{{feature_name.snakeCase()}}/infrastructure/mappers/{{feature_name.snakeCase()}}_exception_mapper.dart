import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:starter_app/core/error/exceptions/server_exception.dart';
import 'package:starter_app/core/error/failures/infrastructure_failures.dart';
import 'package:starter_app/core/error/failures/technical_failure.dart';
import 'package:starter_app/core/error/i_exception_mapper.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/failure/{{feature_name.snakeCase()}}_failure.dart';

/// Maps [ServerException] to {{feature_name.snakeCase()}}-specific failures.
///
/// This mapper implements [IExceptionMapper] and provides domain-specific
/// mapping for {{feature_name.snakeCase()}}-related HTTP errors.
@injectable
final class {{feature_name.pascalCase()}}ExceptionMapper implements IExceptionMapper {
  const {{feature_name.pascalCase()}}ExceptionMapper();

  @override
  TechnicalFailure mapToFailure(ServerException exception) {
    return switch (exception.statusCode) {
      HttpStatus.notFound => {{feature_name.pascalCase()}}Failure.notFound(
        message: exception.message,
      ),
      HttpStatus.internalServerError => {{feature_name.pascalCase()}}Failure.serverError(
        message: exception.message,
      ),
      _ => InfrastructureFailure.server(
        message: exception.message,
        statusCode: exception.statusCode,
      ),
    };
  }
}
