/// Failure types for error handling throughout the application.
///
/// **Architecture:**
/// ```text
/// Failure (abstract)
/// ├── TechnicalFailure (abstract) - isRetryable, stackTrace
/// │   ├── InfrastructureFailure (freezed) - server, network, cache, parse
/// │   └── AuthFailure (freezed) - unauthorized, forbidden, etc.
/// └── ValueFailure<T> (abstract) - domain validation base
///     ├── PasswordFailure - empty, tooShort, missingUppercase, etc.
///     ├── EmailFailure - empty, tooLong, invalidFormat
///     ├── NameFailure - empty
///     ├── TokenFailure - empty
///     └── UniqueIdFailure - empty
/// ```
///
/// **Separation of Concerns:**
/// - Technical failures = External system errors (API, database, network, auth)
/// - Value failures = Domain validation errors with specific failure types
/// - Features can define their own specific failure types
///
/// **Usage:**
/// ```dart
/// // Infrastructure layer
/// return Left(InfrastructureFailure.server(message: 'API error'));
///
/// // Auth layer (also technical)
/// return Left(AuthFailure.unauthorized(message: 'Session expired'));
///
/// // Domain validation with specific failures
/// return Left(PasswordFailure.missingUppercase());
/// return Left(EmailFailure.invalidFormat(failedValue: input));
/// ```
library;

export 'failure.dart';
export 'infrastructure_failures.dart';
export 'technical_failure.dart';
export 'value_failure.dart';
