# Infrastructure Layer

This directory contains the infrastructure implementations (adapters) that connect the domain layer to external systems.

## Overview

The infrastructure layer is responsible for:

- **External service integrations** (HTTP clients, WebSocket connections)
- **Data persistence** (secure storage, token management)
- **Platform-specific implementations** (iOS/Android/Web differences)
- **Cross-cutting concerns** (circuit breaker, session management)

This layer implements the **ports** defined in `lib/core/domain/ports/`, following hexagonal architecture.

## Structure

```text
infrastructure/
├── base_remote_data_source.dart   # Base class for remote data sources
├── base_repository.dart           # Base class for repositories
├── circuit_breaker/               # Circuit breaker pattern
│   ├── circuit_breaker_config.dart
│   └── circuit_breaker_impl.dart
├── networking/                    # HTTP client factory
│   ├── http_client_factory.dart       # Platform-aware barrel
│   ├── http_client_factory_io.dart    # Native implementation (SSL pinning)
│   ├── http_client_factory_web.dart   # Web implementation
│   └── i_http_client_factory_interface.dart
├── platform/                      # Platform information
│   ├── platform_info.dart         # Platform-aware barrel
│   ├── platform_info_io.dart      # Native implementation
│   └── platform_info_web.dart     # Web implementation
├── security/                      # Security services
│   └── certificate_service.dart   # SSL certificate loading
├── session/                       # Session management
│   ├── session.dart               # Barrel export
│   └── session_manager_impl.dart  # Session expiration notifications
├── storage/                       # Data storage
│   ├── storage.dart               # Barrel export
│   ├── secure_storage_impl.dart   # Secure storage adapter
│   └── token_storage_impl.dart    # Token storage adapter
├── token/                         # Token management
│   └── token_refresh_notifier_impl.dart
└── websocket/                     # WebSocket connections
    ├── websocket.dart             # Barrel export
    ├── websocket_connection.dart  # Single connection management
    ├── websocket_manager.dart     # Multiple connection factory
    ├── websocket_reconnection_config.dart  # Reconnection policy
    ├── README.md                  # WebSocket-specific documentation
    ├── EXAMPLES.md                # Usage examples
    └── RECONNECTION.md            # Reconnection strategy docs
```

## Core Concepts

### Hexagonal Architecture (Ports & Adapters)

```
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                           │
│                                                             │
│    ┌─────────────────────────────────────────────────────┐  │
│    │                    Ports                              │  │
│    │  ITokenStorage  ISecureStorage  IWebSocketManager   │  │
│    │  ISessionManager  ICircuitBreaker  IPlatformInfo    │  │
│    └─────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────┘
                            │ implements
┌───────────────────────────▼─────────────────────────────────┐
│                  Infrastructure Layer                        │
│                                                             │
│    ┌─────────────────────────────────────────────────────┐  │
│    │                   Adapters                           │  │
│    │  TokenStorageImpl  SecureStorageImpl  WebSocketMgr  │  │
│    │  SessionManagerImpl  CircuitBreakerImpl  PlatformInfo│  │
│    └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

**Ports** (in domain): Define *what* the application needs  
**Adapters** (here): Define *how* it's provided

### Base Classes

#### BaseRemoteDataSource

Handles error conversion for remote data sources:

```dart
@LazySingleton(as: IAuthRemoteDataSource)
class AuthRemoteDataSourceImpl extends BaseRemoteDataSource
    implements IAuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiService);
  final AuthApiService _apiService;

  @override
  Future<bool> checkUserExists(CheckUserExistsRequestModel request) =>
    execute(() async {
      final response = await _apiService.checkUserExists(request.toJson());
      return CheckUserExistsResponseModel.fromJson(response.body!).exists;
    });
}
```

The `execute()` method converts Dart `Error` types (like `TypeError` from JSON parsing) into `FormatException` that can be properly handled.

#### BaseRepository

Handles exception-to-failure conversion for repositories:

```dart
@LazySingleton(as: IProductRepository)
class ProductRepositoryImpl extends BaseRepository
    implements IProductRepository {
  ProductRepositoryImpl(
    this._remoteDataSource,
    super.exceptionHandler,
    super.failureMapper, // Optional: feature-specific mapper
  );

  final IProductRemoteDataSource _remoteDataSource;

  @override
  FutureResult<Product> getProduct(String id) =>
    execute(() async {
      final model = await _remoteDataSource.getProduct(id);
      return model.toDomain();
    });
}
```

## Components

### Circuit Breaker

Implements the circuit breaker pattern for network resilience:

```dart
// Configuration presets
const config = CircuitBreakerConfig.defaultConfig;  // 3 failures, 30s reset
const config = CircuitBreakerConfig.aggressive;     // 2 failures, 10s reset
const config = CircuitBreakerConfig.conservative;   // 5 failures, 60s reset

// State machine: Closed → Open → Half-Open → Closed
final breaker = CircuitBreakerImpl(logger: logger, config: config);

if (breaker.isOpen) {
  return Left(InfrastructureFailure.circuitBreaker());
}

try {
  final result = await apiCall();
  breaker.onSuccess();
  return result;
} catch (e) {
  breaker.onFailure(e);
  rethrow;
}
```

### HTTP Client Factory

Platform-specific HTTP client creation with SSL pinning support:

```dart
// Automatically selects correct implementation
final factory = getHttpClientFactory();

// Without SSL pinning
final client = factory.createClient();

// With SSL pinning (native platforms only)
final client = factory.createClient(
  trustedCertificateBytes: certificateBytes,
);
```

### Platform Info

Access platform-specific information:

```dart
final platformInfo = getIt<IPlatformInfo>();
print(platformInfo.operatingSystemVersion);
// iOS: "iOS 17.4.1 21E230"
// Android: "Android 14"  
// Web: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)..."
```

### Certificate Service

Load SSL certificates from assets during bootstrap:

```dart
@Singleton(as: ICertificateService)
class CertificateService implements ICertificateService {
  // Loads from assets/certificates/server.pem
  Future<void> initialize() async { ... }
  
  // Available for HTTP client factory
  List<int>? get trustedCertificateBytes;
}
```

### Session Manager

Broadcast session expiration events:

```dart
final sessionManager = getIt<ISessionManager>();

// Listen for session expiration (e.g., in AuthBloc)
sessionManager.onSessionExpired.listen((_) {
  emit(AuthState.unauthenticated());
});

// Trigger from token refresh interceptor
sessionManager.notifySessionExpired();
```

### Secure Storage

Platform-specific secure storage:

```dart
final storage = getIt<ISecureStorage>();

await storage.write(key: 'api_key', value: 'secret');
final value = await storage.read(key: 'api_key');
await storage.delete(key: 'api_key');
await storage.deleteAll();
```

Platform implementations:
- **iOS**: Keychain
- **Android**: EncryptedSharedPreferences (AES)
- **Web**: Web Cryptography API
- **Desktop**: Encrypted storage

### Token Storage

Higher-level token management built on secure storage:

```dart
final tokenStorage = getIt<ITokenStorage>();

// Save tokens after login
await tokenStorage.saveTokens(
  accessToken: 'eyJhbGciOiJIUzI1NiIs...',
  refreshToken: 'dGhpcyBpcyBhIHJlZnJlc2g=',
);

// Check if authenticated
final hasTokens = await tokenStorage.hasTokens();

// Get tokens for API calls
final accessToken = await tokenStorage.getAccessToken();

// Clear on logout
await tokenStorage.clearTokens();
```

### Token Refresh Notifier

Coordinate token refresh across components:

```dart
final notifier = getIt<ITokenRefreshNotifier>();

// Listen in WebSocket connections
notifier.onTokenRefreshed.listen((_) {
  reconnectWithNewToken();
});

// Notify from token refresh interceptor
notifier.notifyTokenRefreshed();
```

### WebSocket

Full-featured WebSocket management with reconnection:

```dart
final manager = getIt<IWebSocketManager>();

// Create connection to specific endpoint
final connection = manager.createConnection(
  '/ws/notifications',
  reconnectionPolicy: WebSocketReconnectionConfig.defaultConfig,
);

// Connect with authentication
await connection.connect(headers: {'Authorization': 'Bearer $token'});

// Listen to messages
connection.messages.listen((message) {
  final data = jsonDecode(message);
  handleNotification(data);
});

// Listen to connection state
connection.connectionState.listen((state) {
  print('WebSocket: ${state.displayName}');
});

// Send messages
connection.send(jsonEncode({'type': 'ping'}));

// Disconnect when done
await connection.disconnect();
```

#### Reconnection Configuration

```dart
// Presets
WebSocketReconnectionConfig.defaultConfig    // 10 attempts, 1-30s delay
WebSocketReconnectionConfig.aggressive       // 20 attempts, 0.5-10s delay
WebSocketReconnectionConfig.conservative     // 5 attempts, 5s-2min delay
WebSocketReconnectionConfig.noReconnection   // Disabled

// Custom
const config = WebSocketReconnectionConfig(
  enabled: true,
  maxAttempts: 5,                    // null for infinite
  initialDelay: Duration(seconds: 1),
  maxDelay: Duration(seconds: 30),
  backoffMultiplier: 2.0,            // Exponential backoff
  jitterFactor: 0.25,                // ±25% random variation
);
```

## Dependency Injection

All adapters are registered via injectable:

```dart
// Singletons (shared state)
@Singleton(as: ISessionManager)
class SessionManagerImpl implements ISessionManager { ... }

@Singleton(as: ITokenRefreshNotifier)  
class TokenRefreshNotifierImpl implements ITokenRefreshNotifier { ... }

// Lazy singletons (created on first use)
@LazySingleton(as: ISecureStorage)
class SecureStorageImpl implements ISecureStorage { ... }

@LazySingleton(as: ITokenStorage)
class TokenStorageImpl implements ITokenStorage { ... }

@LazySingleton(as: IWebSocketManager)
class WebSocketManager implements IWebSocketManager { ... }
```

Named parameters for configuration:

```dart
@LazySingleton(as: IWebSocketManager)
class WebSocketManager implements IWebSocketManager {
  WebSocketManager(
    @Named('websocketBaseUrl') this._baseUrl,  // From InjectableModule
    this._logger,
  );
}
```

## Best Practices

### DO ✅

- Implement domain ports (interfaces from `lib/core/domain/ports/`)
- Use dependency injection for all external dependencies
- Handle platform differences with conditional imports
- Provide configuration objects for tunable behavior
- Use broadcast streams for events with multiple listeners
- Add `@disposeMethod` for cleanup in DI container
- Include `@visibleForTesting` hooks for testability
- Log significant events (connection state changes, errors)

### DON'T ❌

- Don't import infrastructure in domain layer
- Don't expose implementation details through interfaces
- Don't hardcode configuration values
- Don't create tight coupling to specific packages
- Don't ignore resource cleanup (streams, connections)
- Don't skip error handling at boundaries

## Testing

Infrastructure tests use mocks for external dependencies:

```dart
class MockSecureStorage extends Mock implements ISecureStorage {}
class MockAppLogger extends Mock implements IAppLogger {}

void main() {
  late MockSecureStorage mockStorage;
  late TokenStorageImpl tokenStorage;

  setUp(() {
    mockStorage = MockSecureStorage();
    tokenStorage = TokenStorageImpl(mockStorage);
  });

  test('saves tokens correctly', () async {
    when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});

    await tokenStorage.saveTokens(accessToken: 'token', refreshToken: 'refresh');

    verify(() => mockStorage.write(key: 'auth_access_token', value: 'token')).called(1);
    verify(() => mockStorage.write(key: 'auth_refresh_token', value: 'refresh')).called(1);
  });
}
```

For WebSocket testing, use the `channelFactory` parameter:

```dart
final fakeChannel = FakeWebSocketChannel();
final connection = WebSocketConnection(
  url: 'wss://test.example.com/ws',
  logger: mockLogger,
  channelFactory: (uri, {protocols}) => fakeChannel,
);

await connection.connect();
fakeChannel.addMessage('{"type": "test"}');
// Assert messages received
```

## References

- Domain Ports: `lib/core/domain/ports/`
- Architecture Rules: `docs/architecture-rules/04_infrastructure_layer.md`
- WebSocket Details: `lib/core/infrastructure/websocket/README.md`
- Error Handling: `lib/core/error/README.md`
