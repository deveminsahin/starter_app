import 'package:starter_app/core/domain/base/command.dart';
import 'package:starter_app/core/domain/base/query.dart';
import 'package:starter_app/core/types/types.dart';

/// Base class for use cases that require parameters and return a [Future].
///
/// **Note:** This class is kept for backward compatibility.
/// For new code, prefer using [Command] for write operations
/// and [Query] for read operations
/// to follow the CQRS (Command Query Responsibility Segregation) pattern.
///
/// Use cases encapsulate a single piece of business logic following
/// the Single Responsibility Principle. Each use case represents
/// one application service / interactor in hexagonal architecture.
///
/// - [Params]: The input parameters for the use case
/// - [Output]: The success output type
///
/// Example:
/// ```dart
/// @injectable
/// class GetUser extends UseCase<UserId, User> {
///   GetUser(this._repository);
///   final IUserRepository _repository;
///
///   @override
///   FutureResult<User> call(UserId id) => _repository.getUser(id);
/// }
/// ```
///
/// **Recommended:** Use [Query] for read operations:
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
abstract class UseCase<Params, Output> {
  const UseCase();

  /// Executes the use case with the given [params].
  FutureResult<Output> call(Params params);
}

/// Base class for use cases without parameters that return a [Future].
///
/// **Note:** This class is kept for backward compatibility.
/// For new code, prefer using [CommandNoParams] for write operations
/// or [QueryNoParams] for read operations.
///
/// Use this when a use case doesn't require any input.
///
/// - [Output]: The success output type
///
/// Example:
/// ```dart
/// @injectable
/// class Logout extends UseCaseNoParams<Unit> {
///   Logout(this._repository);
///   final IAuthRepository _repository;
///
///   @override
///   FutureResult<Unit> call() => _repository.logout();
/// }
/// ```
///
/// **Recommended:** Use [CommandNoParams] for write operations:
/// ```dart
/// @injectable
/// class Logout extends CommandNoParams<Unit> {
///   const Logout(this._repository);
///   final IAuthRepository _repository;
///
///   @override
///   FutureResult<Unit> call() => _repository.logout();
/// }
/// ```
abstract class UseCaseNoParams<Output> {
  const UseCaseNoParams();

  /// Executes the use case.
  FutureResult<Output> call();
}

/// Base class for stream-based use cases that require parameters.
///
/// **Note:** This class is kept for backward compatibility.
/// For new code, prefer using [StreamCommand] for write operations
/// or [StreamQuery] for read operations.
///
/// Used for reactive operations like watching real-time changes
/// that need input parameters.
///
/// - [Params]: The input parameters for the use case
/// - [Output]: The success output type emitted by the stream
///
/// Example:
/// ```dart
/// @injectable
/// class WatchUserOrders extends StreamUseCase<UserId, List<Order>> {
///   WatchUserOrders(this._repository);
///   final IOrderRepository _repository;
///
///   @override
///   StreamResult<List<Order>> call(UserId userId) {
///     return _repository.watchOrders(userId);
///   }
/// }
/// ```
///
/// **Recommended:** Use [StreamQuery] for read operations:
/// ```dart
/// @injectable
/// class WatchUserOrders extends StreamQuery<UserId, List<Order>> {
///   const WatchUserOrders(this._repository);
///   final IOrderRepository _repository;
///
///   @override
///   StreamResult<List<Order>> call(UserId userId) {
///     return _repository.watchOrders(userId);
///   }
/// }
/// ```
abstract class StreamUseCase<Params, Output> {
  const StreamUseCase();

  /// Executes the use case with the given [params] and returns a stream.
  StreamResult<Output> call(Params params);
}

/// Base class for stream-based use cases without parameters.
///
/// **Note:** This class is kept for backward compatibility.
/// For new code, prefer using [StreamCommandNoParams] for write operations
/// or [StreamQueryNoParams] for read operations.
///
/// Used for reactive operations like watching real-time changes
/// that don't require input.
///
/// - [Output]: The success output type emitted by the stream
///
/// Example:
/// ```dart
/// @injectable
/// class WatchAuthChanges extends StreamUseCaseNoParams<User?> {
///   WatchAuthChanges(this._repository);
///   final IAuthRepository _repository;
///
///   @override
///   StreamResult<User?> call() => _repository.watchAuthChanges();
/// }
/// ```
///
/// **Recommended:** Use [StreamQueryNoParams] for read operations:
/// ```dart
/// @injectable
/// class WatchAuthChanges extends StreamQueryNoParams<User?> {
///   const WatchAuthChanges(this._repository);
///   final IAuthRepository _repository;
///
///   @override
///   StreamResult<User?> call() => _repository.watchAuthChanges();
/// }
/// ```
abstract class StreamUseCaseNoParams<Output> {
  const StreamUseCaseNoParams();

  /// Executes the use case and returns a stream.
  StreamResult<Output> call();
}
