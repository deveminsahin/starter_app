import 'package:starter_app/core/types/types.dart';

/// Base class for commands (write operations) that require parameters.
///
/// Commands represent operations that mutate state in the application.
/// They follow the Command Query Responsibility Segregation (CQRS) pattern,
/// separating write operations from read operations.
///
/// Commands should:
/// - Mutate application state
/// - Return a result indicating success or failure
/// - Be idempotent when possible
/// - Validate input before execution
///
/// - [Params]: The input parameters for the command
/// - [Output]: The success output type (often the mutated entity)
///
/// Example:
/// ```dart
/// @injectable
/// class Login extends Command<AuthCredentials, User> {
///   const Login(this._repository);
///   final IAuthRepository _repository;
///
///   @override
///   FutureResult<User> call(AuthCredentials credentials) async {
///     return _repository.login(credentials);
///   }
/// }
/// ```
abstract class Command<Params, Output> {
  const Command();

  /// Executes the command with the given [params].
  ///
  /// Returns [FutureResult<Output>] which contains either:
  /// - [Right(Output)] on successful execution
  /// - [Left(Failure)] if the command fails
  FutureResult<Output> call(Params params);
}

/// Base class for commands that don't require parameters.
///
/// Use this when a command doesn't need any input.
///
/// - [Output]: The success output type
///
/// Example:
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
abstract class CommandNoParams<Output> {
  const CommandNoParams();

  /// Executes the command.
  ///
  /// Returns [FutureResult<Output>] which contains either:
  /// - [Right(Output)] on successful execution
  /// - [Left(Failure)] if the command fails
  FutureResult<Output> call();
}

/// Base class for stream-based commands that require parameters.
///
/// Used for reactive write operations that need input parameters.
///
/// - [Params]: The input parameters for the command
/// - [Output]: The success output type emitted by the stream
///
/// Example:
/// ```dart
/// @injectable
/// class WatchUserUpdates extends StreamCommand<UserId, User> {
///   WatchUserUpdates(this._repository);
///   final IUserRepository _repository;
///
///   @override
///   StreamResult<User> call(UserId userId) {
///     return _repository.watchUserUpdates(userId);
///   }
/// }
/// ```
abstract class StreamCommand<Params, Output> {
  const StreamCommand();

  /// Executes the command with the given [params] and returns a stream.
  StreamResult<Output> call(Params params);
}

/// Base class for stream-based commands without parameters.
///
/// Used for reactive write operations that don't require input.
///
/// - [Output]: The success output type emitted by the stream
///
/// Example:
/// ```dart
/// @injectable
/// class WatchAuthChanges extends StreamCommandNoParams<User?> {
///   WatchAuthChanges(this._repository);
///   final IAuthRepository _repository;
///
///   @override
///   StreamResult<User?> call() => _repository.watchAuthChanges();
/// }
/// ```
abstract class StreamCommandNoParams<Output> {
  const StreamCommandNoParams();

  /// Executes the command and returns a stream.
  StreamResult<Output> call();
}
