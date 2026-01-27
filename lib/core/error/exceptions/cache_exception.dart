/// Exception thrown when a local cache/storage operation fails.
///
/// This exception is thrown by local data sources when cache operations fail
/// (e.g., database queries, SharedPreferences, file operations).
/// It should be caught in the repository layer
/// and converted to an InfrastructureFailure.cache.
///
/// Example:
/// ```dart
/// // In LocalDataSource
/// try {
///   await _database.insert(data);
/// } catch (e) {
///   throw CacheException(
///     message: 'Failed to cache data',
///     originalError: e,
///   );
/// }
///
/// // In Repository - convert to Failure
/// try {
///   await _localDataSource.cacheData(data);
///   return const Right(unit);
/// } on CacheException catch (e) {
///   return Left(InfrastructureFailure.cache(message: e.message));
/// }
/// ```
final class CacheException implements Exception {
  /// Creates a [CacheException].
  const CacheException({
    this.message = 'Cache operation failed',
    this.originalError,
  });

  /// The error message describing what went wrong.
  final String message;

  /// The original error that caused this exception (for debugging).
  final Object? originalError;

  @override
  String toString() {
    final buffer = StringBuffer('CacheException: $message');
    if (originalError != null) {
      buffer.write(' (Original error: $originalError)');
    }
    return buffer.toString();
  }
}
