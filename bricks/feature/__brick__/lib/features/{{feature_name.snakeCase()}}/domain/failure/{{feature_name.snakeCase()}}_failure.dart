import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:starter_app/core/error/failures/technical_failure.dart';

part '{{feature_name.snakeCase()}}_failure.freezed.dart';

/// {{feature_name.pascalCase()}} domain failures.
///
/// Represents business logic errors specific to {{feature_name.snakeCase()}} operations.
/// Extends [TechnicalFailure] which provides [isRetryable] and [stackTrace].
@freezed
abstract class {{feature_name.pascalCase()}}Failure extends TechnicalFailure with _${{feature_name.pascalCase()}}Failure {
  const {{feature_name.pascalCase()}}Failure._();

  const factory {{feature_name.pascalCase()}}Failure.unexpected({
    required String message,
    StackTrace? stackTrace,
  }) = _Unexpected;

  const factory {{feature_name.pascalCase()}}Failure.serverError({
    required String message,
    StackTrace? stackTrace,
  }) = _ServerError;

  const factory {{feature_name.pascalCase()}}Failure.notFound({
    required String message,
    StackTrace? stackTrace,
  }) = _NotFound;

  // TODO: Add more failure cases as needed

  @override
  bool get isRetryable => when(
    unexpected: (_, _) => false,
    serverError: (_, _) => true,
    notFound: (_, _) => false,
  );

  // coverage:ignore-start
  @override
  StackTrace? get stackTrace => when(
    unexpected: (_, stackTrace) => stackTrace,
    serverError: (_, stackTrace) => stackTrace,
    notFound: (_, stackTrace) => stackTrace,
  );
  // coverage:ignore-end
}
