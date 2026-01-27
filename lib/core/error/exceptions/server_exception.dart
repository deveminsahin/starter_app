/// Exception thrown when a server/API error occurs.
///
/// This exception is thrown by remote data sources when API calls fail.
/// It should be caught in the repository layer
/// and converted to an InfrastructureFailure.server.
///
/// Example:
/// ```dart
/// // In RemoteDataSource
/// if (!response.isSuccessful) {
///   throw ServerException(
///     message: 'Failed to fetch data',
///     statusCode: response.statusCode,
///   );
/// }
///
/// // In Repository - convert to Failure
/// try {
///   final data = await _remoteDataSource.getData();
///   return Right(data.toDomain());
/// } on ServerException catch (e) {
///   return Left(InfrastructureFailure.server(
///     message: e.message,
///     statusCode: e.statusCode,
///   ));
/// }
/// ```
final class ServerException implements Exception {
  /// Creates a [ServerException].
  const ServerException({
    required this.message,
    required this.statusCode,
    this.responseBody,
  });

  /// The error message from the server.
  final String message;

  /// The HTTP status code (e.g., 400, 500).
  final int statusCode;

  /// The raw response body from the server (for debugging).
  final String? responseBody;

  @override
  String toString() => 'ServerException [$statusCode]: $message';
}
