import 'package:starter_app/core/domain/ports/i_token_storage.dart';

/// Interface for notifying when access tokens are refreshed.
///
/// This is a **port** in hexagonal architecture - it defines the contract
/// for token refresh notifications, allowing WebSocket connections and
/// other long-lived connections to update their authentication.
///
/// ## Problem Solved
/// HTTP requests automatically get new tokens via interceptors, but
/// WebSocket connections established with old tokens don't know when
/// to reconnect with fresh credentials.
///
/// ## Solution
/// The refresh token interceptor notifies via [notifyTokenRefreshed] when
/// tokens are successfully refreshed. Listeners (like WebSocket data sources)
/// can then reconnect with the new token.
///
/// ## Usage
/// ```dart
/// // In refresh token interceptor (after successful refresh)
/// tokenRefreshNotifier.notifyTokenRefreshed();
///
/// // In WebSocket data source
/// tokenRefreshNotifier.onTokenRefreshed.listen((_) async {
///   await _reconnectWithNewToken();
/// });
/// ```
abstract interface class ITokenRefreshNotifier {
  /// Stream that emits when the access token has been refreshed.
  ///
  /// Listeners should:
  /// 1. Get the new token from [ITokenStorage]
  /// 2. Reconnect their long-lived connections with the new token
  Stream<void> get onTokenRefreshed;

  /// Notifies listeners that the access token has been refreshed.
  ///
  /// Called by the refresh token interceptor after successfully refreshing
  /// the access token.
  void notifyTokenRefreshed();

  /// Disposes of resources (stream controller).
  void dispose();
}
