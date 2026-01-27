import 'package:starter_app/core/error/exceptions/server_exception.dart';
import 'package:starter_app/core/error/failures/failures.dart';
import 'package:starter_app/core/infrastructure/base_repository.dart';

/// Interface for mapping [ServerException] to domain-specific [Failure]s.
///
/// Each feature should provide its own implementation that maps HTTP status
/// codes to appropriate domain failures.
///
/// This allows repositories to:
/// - Have feature-specific failure mapping
/// - Be testable (mock the mapper)
/// - Follow dependency injection principles
///
/// Example implementation:
/// ```dart
/// @injectable
/// class AuthExceptionMapper implements IExceptionMapper {
///   const AuthExceptionMapper();
///
///   @override
///   TechnicalFailure mapToFailure(ServerException exception) {
///     return switch (exception.statusCode) {
///       HttpStatus.unauthorized => AuthFailure.unauthorized(
///           message: exception.message,
///         ),
///       HttpStatus.forbidden => AuthFailure.forbidden(
///           message: exception.message,
///         ),
///       HttpStatus.notFound => AuthFailure.notFound(
///           message: exception.message,
///         ),
///       _ => InfrastructureFailure.server(
///           message: exception.message,
///           statusCode: exception.statusCode,
///         ),
///     };
///   }
/// }
/// ```
///
/// Usage in repository:
/// ```dart
/// @LazySingleton(as: IAuthRepository)
/// class AuthRepositoryImpl extends BaseRepository
///     implements IAuthRepository {
///   AuthRepositoryImpl(
///     this._remoteDataSource,
///     super.exceptionHandler,
///     super.failureMapper, // Injected mapper
///   );
///
///   final IAuthRemoteDataSource _remoteDataSource;
///
///   @override
///   Future<Either<Failure, User>> login(Credentials creds) =>
///     execute(() async {
///       final result = await _remoteDataSource.login(creds);
///       return result.user.toDomain();
///     });
/// }
/// ```
abstract interface class IExceptionMapper {
  /// Maps a [ServerException] to an appropriate [TechnicalFailure].
  ///
  /// This method is called by [BaseRepository] when a [ServerException]
  /// is caught during repository operations.
  ///
  /// Implementations should map HTTP status codes to domain-specific
  /// failures (e.g., 401 → AuthFailure.unauthorized) or fall back to
  /// infrastructure failures for generic errors.
  TechnicalFailure mapToFailure(ServerException exception);
}
