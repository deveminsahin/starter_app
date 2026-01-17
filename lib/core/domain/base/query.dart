import 'package:starter_app/core/types/types.dart';

/// Base class for queries (read operations) that require parameters.
///
/// Queries represent operations that read data without mutating state.
/// They follow the Command Query Responsibility Segregation (CQRS) pattern,
/// separating read operations from write operations.
///
/// Queries should:
/// - Only read data (no side effects)
/// - Be idempotent (same input = same output)
/// - Not modify application state
/// - Return data in a format suitable for presentation
///
/// - [Params]: The input parameters for the query
/// - [Output]: The data returned by the query
///
/// Example:
/// ```dart
/// @injectable
/// class GetUser extends Query<UserId, User> {
///   const GetUser(this._repository);
///   final IUserRepository _repository;
///
///   @override
///   FutureResult<User> call(UserId id) => _repository.getUser(id);
/// }
/// ```
abstract class Query<Params, Output> {
  const Query();

  /// Executes the query with the given [params].
  ///
  /// Returns [FutureResult<Output>] which contains either:
  /// - [Right(Output)] on successful query
  /// - [Left(Failure)] if the query fails
  FutureResult<Output> call(Params params);
}

/// Base class for queries that don't require parameters.
///
/// Use this when a query doesn't need any input.
///
/// - [Output]: The data returned by the query
///
/// Example:
/// ```dart
/// @injectable
/// class GetCurrentUser extends QueryNoParams<User?> {
///   const GetCurrentUser(this._repository);
///   final IAuthRepository _repository;
///
///   @override
///   FutureResult<User?> call() => _repository.getCurrentUser();
/// }
/// ```
abstract class QueryNoParams<Output> {
  const QueryNoParams();

  /// Executes the query.
  ///
  /// Returns [FutureResult<Output>] which contains either:
  /// - [Right(Output)] on successful query
  /// - [Left(Failure)] if the query fails
  FutureResult<Output> call();
}

/// Base class for stream-based queries that require parameters.
///
/// Used for reactive read operations that need input parameters.
///
/// - [Params]: The input parameters for the query
/// - [Output]: The data type emitted by the stream
///
/// Example:
/// ```dart
/// @injectable
/// class WatchUserOrders extends StreamQuery<UserId, List<Order>> {
///   WatchUserOrders(this._repository);
///   final IOrderRepository _repository;
///
///   @override
///   StreamResult<List<Order>> call(UserId userId) {
///     return _repository.watchOrders(userId);
///   }
/// }
/// ```
abstract class StreamQuery<Params, Output> {
  const StreamQuery();

  /// Executes the query with the given [params] and returns a stream.
  StreamResult<Output> call(Params params);
}

/// Base class for stream-based queries without parameters.
///
/// Used for reactive read operations that don't require input.
///
/// - [Output]: The data type emitted by the stream
///
/// Example:
/// ```dart
/// @injectable
/// class WatchAuthChanges extends StreamQueryNoParams<User?> {
///   WatchAuthChanges(this._repository);
///   final IAuthRepository _repository;
///
///   @override
///   StreamResult<User?> call() => _repository.watchAuthChanges();
/// }
/// ```
abstract class StreamQueryNoParams<Output> {
  const StreamQueryNoParams();

  /// Executes the query and returns a stream.
  StreamResult<Output> call();
}
