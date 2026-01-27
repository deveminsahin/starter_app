/// Exception thrown when a network connectivity issue occurs.
///
/// This exception is thrown when there's no internet connection or
/// network-related errors occur during API calls.
/// It should be caught in the repository layer
/// and converted to an InfrastructureFailure.network.
///
/// Note: You can also catch dart:io's SocketException
/// directly in repositories.
///
/// Example:
/// ```dart
/// // In RemoteDataSource or NetworkInfo
/// if (!await _networkInfo.isConnected) {
///   throw const NetworkException(
///     message: 'No internet connection',
///   );
/// }
///
/// // In Repository - convert to Failure
/// try {
///   final data = await _remoteDataSource.getData();
///   return Right(data.toDomain());
/// } on NetworkException catch (e) {
///   return Left(InfrastructureFailure.network(
///     message: e.message,
///   ));
/// } on SocketException catch (_) {
///   return Left(const InfrastructureFailure.network(
///     message: 'No internet connection',
///   ));
/// }
/// ```
final class NetworkException implements Exception {
  /// Creates a [NetworkException].
  const NetworkException({
    this.message = 'No internet connection',
    this.originalError,
  });

  /// The error message describing the network issue.
  final String message;

  /// The original error that caused this exception (for debugging).
  final Object? originalError;

  @override
  String toString() {
    final buffer = StringBuffer('NetworkException: $message');
    if (originalError != null) {
      buffer.write(' (Original error: $originalError)');
    }
    return buffer.toString();
  }
}
