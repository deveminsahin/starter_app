import 'package:starter_app/core/error/failures/failure.dart';
import 'package:starter_app/core/error/failures/infrastructure_failures.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';
import 'package:starter_app/features/auth/domain/failure/auth_failure.dart';

/// Abstract base class for technical/infrastructure failures.
///
/// Technical failures represent errors from external systems (API, database,
/// network) and internal technical issues (authentication, authorization).
/// They are distinct from [ValueFailure] which represents domain validation
/// errors.
///
/// All technical failures have:
/// - [isRetryable] - Whether the operation can be retried
/// - [stackTrace] - Optional stack trace for debugging
///
/// Example:
/// ```dart
/// // Infrastructure failures
/// return Left(InfrastructureFailure.network(message: 'No connection'));
///
/// // Auth failures (also technical)
/// return Left(AuthFailure.unauthorized(message: 'Session expired'));
/// ```
///
/// See also:
/// - [InfrastructureFailure] - Server, network, cache errors
/// - [AuthFailure] - Authentication/authorization errors
abstract class TechnicalFailure extends Failure {
  /// Creates a [TechnicalFailure].
  const TechnicalFailure();

  /// Returns true if this failure type can be retried.
  bool get isRetryable;

  /// Original stack trace for debugging purposes.
  StackTrace? get stackTrace;
}
