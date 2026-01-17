/// Represents the current state of a WebSocket connection.
///
/// This is a domain-level type that can be used by both domain ports
/// and infrastructure adapters to track connection lifecycle.
///
/// States:
/// - [disconnected]: Not connected, not attempting to connect
/// - [connecting]: Actively attempting to establish connection
/// - [connected]: Successfully connected and ready to send/receive
/// - [reconnecting]: Disconnected but automatically attempting to reconnect
/// - [failed]: Connection failed and won't reconnect (max retries exceeded)
enum WebSocketConnectionState {
  /// Not connected and not attempting to connect.
  ///
  /// This is the initial state before [connect()] is called.
  disconnected,

  /// Actively attempting to establish a connection.
  ///
  /// Transitions to [connected] on success or [reconnecting]/[failed] on failure.
  connecting,

  /// Successfully connected and ready to send/receive messages.
  ///
  /// Can transition to [reconnecting] if connection drops unexpectedly.
  connected,

  /// Disconnected but automatically attempting to reconnect.
  ///
  /// Uses exponential backoff between reconnection attempts.
  /// Transitions to [connected] on success or [failed] if max retries exceeded.
  reconnecting,

  /// Connection failed and won't automatically reconnect.
  ///
  /// This happens when max reconnection attempts are exceeded.
  /// Manual intervention (calling [connect()]) is required.
  failed,
}

/// Extension methods for [WebSocketConnectionState].
extension WebSocketConnectionStateX on WebSocketConnectionState {
  /// Returns true if the connection is in a state where it can send messages.
  bool get canSendMessages => this == WebSocketConnectionState.connected;

  /// Returns true if the connection is actively trying to connect.
  bool get isConnecting =>
      this == WebSocketConnectionState.connecting ||
      this == WebSocketConnectionState.reconnecting;

  /// Returns true if the connection is established.
  bool get isConnected => this == WebSocketConnectionState.connected;

  /// Returns true if the connection has failed permanently.
  bool get isFailed => this == WebSocketConnectionState.failed;

  /// Returns true if the connection is disconnected (not connecting).
  bool get isDisconnected => this == WebSocketConnectionState.disconnected;

  /// Returns a user-friendly display name for the state.
  String get displayName {
    switch (this) {
      case WebSocketConnectionState.disconnected:
        return 'Disconnected';
      case WebSocketConnectionState.connecting:
        return 'Connecting';
      case WebSocketConnectionState.connected:
        return 'Connected';
      case WebSocketConnectionState.reconnecting:
        return 'Reconnecting';
      case WebSocketConnectionState.failed:
        return 'Failed';
    }
  }
}
