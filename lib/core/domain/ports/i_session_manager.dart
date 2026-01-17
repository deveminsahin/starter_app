/// Interface for managing session lifecycle events.
///
/// This is a **port** in hexagonal architecture - it defines the contract
/// for session-related events, decoupling the network layer from the
/// presentation layer.
///
/// The network layer (e.g., RefreshTokenInterceptor) notifies session
/// expiration via [notifySessionExpired], while the presentation layer
/// (e.g., AuthBloc) listens to [onSessionExpired] to handle the event.
///
/// This approach ensures:
/// - Network layer has no knowledge of AuthBloc or navigation
/// - Clean separation between infrastructure and presentation
/// - Testable session management
///
/// Usage:
/// ```dart
/// // In network layer (interceptor)
/// if (tokenRefreshFailed) {
///   sessionManager.notifySessionExpired();
/// }
///
/// // In presentation layer (AuthBloc)
/// sessionManager.onSessionExpired.listen((_) {
///   add(const AuthEvent.sessionExpired());
/// });
/// ```
abstract interface class ISessionManager {
  /// Stream that emits when the session has expired.
  ///
  /// Listeners (e.g., AuthBloc) should handle this by:
  /// 1. Clearing local auth state
  /// 2. Navigating to appropriate screen (Dashboard/login)
  Stream<void> get onSessionExpired;

  /// Notifies listeners that the session has expired.
  ///
  /// Called by the network layer when:
  /// - Refresh token is expired/invalid
  /// - Refresh endpoint returns an error
  /// - Server explicitly invalidates the session
  void notifySessionExpired();

  /// Disposes of resources (stream controller).
  ///
  /// Should be called when the app is shutting down.
  void dispose();
}
