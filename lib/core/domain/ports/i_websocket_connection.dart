import 'dart:async';
import 'dart:io' show WebSocketException;

import 'package:starter_app/core/domain/types/websocket_connection_state.dart';

/// Interface for WebSocket connection operations.
///
/// This is a **port** in hexagonal architecture - it defines the contract
/// that the domain/application layer expects from WebSocket infrastructure.
///
/// Implementations (adapters) handle the actual connection lifecycle,
/// authentication, reconnection, and message streaming.
///
/// Usage:
/// ```dart
/// final connection = getIt<IWebSocketConnection>();
///
/// // Listen to connection state changes
/// connection.connectionState.listen((state) {
///   print('State: ${state.displayName}');
/// });
///
/// // Connect to WebSocket endpoint
/// await connection.connect(headers: {'Authorization': 'Bearer $token'});
///
/// // Listen to messages
/// connection.messages.listen((message) {
///   print('Received: $message');
/// });
///
/// // Send messages
/// connection.send('{"type": "ping"}');
///
/// // Disconnect
/// await connection.disconnect();
/// ```
abstract interface class IWebSocketConnection {
  /// Stream of incoming WebSocket messages.
  ///
  /// Emits:
  /// - Raw JSON string messages from the server
  /// - Never emits errors (errors are handled internally)
  /// - Completes when connection is closed permanently
  Stream<String> get messages;

  /// Stream of connection state changes.
  ///
  /// Emits whenever the connection state changes:
  /// - disconnected → connecting → connected
  /// - connected → reconnecting → connected
  /// - reconnecting → failed (if max attempts exceeded)
  Stream<WebSocketConnectionState> get connectionState;

  /// Current connection state.
  WebSocketConnectionState get currentState;

  /// Returns true if WebSocket is connected and ready to send messages.
  bool get isConnected;

  /// Returns true if connection is actively trying to connect or reconnect.
  bool get isConnecting;

  /// Establishes WebSocket connection.
  ///
  /// Parameters:
  /// - [headers]: Optional HTTP headers (e.g., for authentication)
  ///
  /// Throws:
  /// - [WebSocketException] if connection fails
  /// - [StateError] if already connected or disposed
  ///
  /// Returns: Future that completes when connected
  Future<void> connect({Map<String, String>? headers});

  /// Sends a message through the WebSocket connection.
  ///
  /// Parameters:
  /// - [message]: JSON string message to send
  ///
  /// Throws:
  /// - [StateError] if not connected or disposed
  void send(String message);

  /// Closes the WebSocket connection.
  ///
  /// Gracefully closes the connection and prevents automatic reconnection.
  Future<void> disconnect();

  /// Disposes resources and closes connection.
  ///
  /// Should be called when the connection is no longer needed.
  /// After disposal, the connection cannot be reused.
  Future<void> dispose();
}
