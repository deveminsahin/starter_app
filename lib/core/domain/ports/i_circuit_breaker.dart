/// Contract for the Circuit Breaker pattern.
///
/// Manages the state of the connection to external services to prevent
/// cascading failures and allow for graceful degradation.
abstract interface class ICircuitBreaker {
  /// Whether the circuit is currently open (requests blocked).
  bool get isOpen;

  /// Records a successful operation.
  void onSuccess();

  /// Records a failed operation.
  void onFailure(Object error);
}
