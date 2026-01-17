/// Port interfaces for hexagonal architecture.
///
/// Ports define contracts between domain/application layer and infrastructure.
/// They ensure loose coupling and enable easy testing/mocking.
library;

// Platform ports
export 'i_platform_info.dart';
// Storage ports
export 'i_secure_storage.dart';
// Session ports
export 'i_session_manager.dart';
export 'i_token_refresh_notifier.dart';
export 'i_token_storage.dart';
// WebSocket ports
export 'i_websocket_connection.dart';
export 'i_websocket_manager.dart';
