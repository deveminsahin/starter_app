import 'package:starter_app/core/domain/ports/i_websocket_connection.dart';
import 'package:starter_app/core/domain/types/i_reconnection_policy.dart';

/// Interface for WebSocket connection manager.
///
/// This is a **port** in hexagonal architecture - it defines the contract
/// for creating and managing multiple WebSocket connections.
///
/// Implementations (adapters) handle the actual connection factory logic,
/// URL construction, and connection lifecycle management.
///
/// Usage:
/// ```dart
/// final manager = getIt<IWebSocketManager>();
///
/// // Create connection to auth endpoint
/// final authConnection = manager.createConnection('/ws/auth');
/// await authConnection.connect(headers: {'Authorization': 'Bearer $token'});
///
/// // Create connection to notifications endpoint
/// final notifConnection = manager.createConnection('/ws/notifications');
/// await notifConnection.connect(headers: {'Authorization': 'Bearer $token'});
///
/// // Both connections work independently
/// authConnection.messages.listen((msg) => handleAuthEvent(msg));
/// notifConnection.messages.listen((msg) => handleNotification(msg));
///
/// // Disconnect all connections
/// await manager.disconnectAll();
/// ```
abstract interface class IWebSocketManager {
  /// Creates a new WebSocket connection to the specified endpoint.
  ///
  /// Parameters:
  /// - [path]: WebSocket endpoint path (e.g., '/ws/auth')
  /// - [reconnectionPolicy]: Optional reconnection policy
  ///
  /// Returns: A new [IWebSocketConnection] instance
  IWebSocketConnection createConnection(
    String path, {
    IReconnectionPolicy? reconnectionPolicy,
  });

  /// Creates a WebSocket connection with a full custom URL.
  ///
  /// Use this when you need to connect to a WebSocket server
  /// different from the default base URL.
  ///
  /// Parameters:
  /// - [url]: Complete WebSocket URL (e.g., 'wss://custom.example.com/ws')
  /// - [reconnectionPolicy]: Optional reconnection policy
  ///
  /// Returns: A new [IWebSocketConnection] instance
  IWebSocketConnection createConnectionWithUrl(
    String url, {
    IReconnectionPolicy? reconnectionPolicy,
  });

  /// Disconnects all active connections.
  Future<void> disconnectAll();

  /// Disposes all connections and cleans up resources.
  Future<void> dispose();

  /// Returns the number of active connections.
  int get activeConnectionCount;

  /// Returns list of active connections (read-only).
  List<IWebSocketConnection> get activeConnections;
}
