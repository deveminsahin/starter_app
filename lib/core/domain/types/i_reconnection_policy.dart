/// Abstract interface for reconnection policies.
///
/// This is a **domain-level abstraction** that defines the contract for
/// reconnection behavior. Concrete implementations (e.g., exponential backoff)
/// belong in the infrastructure layer.
///
/// This follows the Dependency Inversion Principle:
/// - Domain defines the abstract policy (what reconnection behavior is needed)
/// - Infrastructure provides concrete implementations (how to calculate delays)
///
/// Usage:
/// ```dart
/// // In domain/application layer - specify the policy
/// final connection = manager.createConnection(
///   '/ws/notifications',
///   reconnectionPolicy: getIt<IReconnectionPolicy>(),
/// );
///
/// // In infrastructure - implement the policy
/// class ExponentialBackoffPolicy implements IReconnectionPolicy {
///   @override
///   Duration getDelayForAttempt(int attempt) => ...;
/// }
/// ```
abstract interface class IReconnectionPolicy {
  /// Whether automatic reconnection is enabled.
  ///
  /// If false, connections will not automatically reconnect when lost.
  bool get enabled;

  /// Maximum number of reconnection attempts.
  ///
  /// Returns null for infinite reconnection attempts (not recommended).
  /// After max attempts, the connection state becomes failed.
  int? get maxAttempts;

  /// Returns true if more reconnection attempts are allowed.
  ///
  /// Implementations should check [enabled] and compare [currentAttempt]
  /// against [maxAttempts].
  bool canRetry(int currentAttempt);

  /// Calculates the delay before the next reconnection attempt.
  ///
  /// Implementations may use strategies like:
  /// - Fixed delay
  /// - Linear backoff
  /// - Exponential backoff with jitter
  ///
  /// The [attempt] parameter is zero-indexed (0 = first retry).
  Duration getDelayForAttempt(int attempt);
}
