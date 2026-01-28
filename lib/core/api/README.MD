# API Layer

This directory contains the HTTP client interceptors and utilities for API communication.

## Overview

The API layer is responsible for:

- **Request/response interception** (auth, logging, error handling)
- **Token management** (automatic refresh, authentication headers)
- **Resilience patterns** (circuit breaker, retry logic)
- **Security** (sensitive data sanitization in logs)

This layer works with [Chopper](https://pub.dev/packages/chopper) HTTP client and integrates with the infrastructure layer's ports.

## Structure

```text
api/
├── README.md                        # This file
├── extensions/
│   └── response_extensions.dart     # Response utility extensions
└── interceptors/
    ├── interceptors.dart            # Barrel export
    ├── api_key_interceptor.dart     # API key header injection
    ├── auth_interceptor.dart        # Bearer token authentication
    ├── circuit_breaker_interceptor.dart  # Circuit breaker pattern
    ├── error_interceptor.dart       # Error normalization
    ├── logging_interceptor.dart     # Request/response logging
    ├── network_error_handler.dart   # Network exception conversion
    └── refresh_token_interceptor.dart    # Automatic token refresh
```

## Interceptor Chain

Interceptors execute in order. The recommended configuration:

```dart
final chopperClient = ChopperClient(
  baseUrl: Uri.parse(config.apiBaseUrl),
  interceptors: [
    // 1. Add API key first (before any logging)
    ApiKeyInterceptor(config.apiKey),
    
    // 2. Add authentication header
    AuthInterceptor(tokenStorage.getAccessToken),
    
    // 3. Circuit breaker to fail-fast
    CircuitBreakerInterceptor(circuitBreaker),
    
    // 4. Token refresh BEFORE error handling
    RefreshTokenInterceptor(
      tokenStorage: tokenStorage,
      refreshTokenEndpoint: '/auth/refresh',
      onRefreshFailed: sessionManager.notifySessionExpired,
      onRefreshSuccess: tokenRefreshNotifier.notifyTokenRefreshed,
      baseUrl: Uri.parse(config.apiBaseUrl),
      refreshLock: getIt<Lock>(),
    ),
    
    // 5. Logging (auto-sanitizes sensitive data)
    LoggingInterceptor(logger),
    
    // 6. Error handling last (converts to exceptions)
    ErrorInterceptor(networkErrorHandler),
  ],
);
```

## Interceptors

### ApiKeyInterceptor

Injects API key into requests via header or query parameter:

```dart
// Header mode (default)
ApiKeyInterceptor(
  apiKey: envConfig.apiKey,
  headerName: 'X-API-Key',  // default
);

// Query parameter mode
ApiKeyInterceptor(
  apiKey: envConfig.apiKey,
  mode: ApiKeyMode.queryParam,
  parameterName: 'api_key',  // default
);
```

### AuthInterceptor

Adds `Authorization: Bearer <token>` header for authenticated requests:

```dart
AuthInterceptor(
  () async => await tokenStorage.getAccessToken(),
);
```

**Behavior:**
- Skips header if token is `null` or empty
- Uses Bearer token format only
- Token provider is called for each request (fresh token)

### CircuitBreakerInterceptor

Prevents requests when the circuit is open (service unavailable):

```dart
CircuitBreakerInterceptor(circuitBreaker);

// Circuit states:
// - Closed: Requests pass through
// - Open: Throws CircuitBreakerException immediately
// - Half-Open: Allows one test request
```

**Integration with Infrastructure:**
- Uses `ICircuitBreaker` port from domain
- Implementation in `lib/core/infrastructure/circuit_breaker/`
- See infrastructure README for configuration presets

### ErrorInterceptor

Normalizes error responses into `ServerException`:

```dart
ErrorInterceptor(networkErrorHandler);
```

**Behavior:**
- 2xx: Pass through
- 4xx/5xx: Extract error message and throw `ServerException`
- Network errors: Delegate to `NetworkErrorHandler`

**Error message extraction:**
```dart
// From JSON body
{"error": "Invalid credentials"}  → "Invalid credentials"
{"message": "Not found"}          → "Not found"

// From string body
"Rate limit exceeded"             → "Rate limit exceeded"

// Fallback
→ "HTTP Error 500"
```

### LoggingInterceptor

Logs HTTP traffic with automatic sensitive data sanitization:

```dart
LoggingInterceptor(appLogger);
```

**Security Features:**
- Redacts sensitive headers: `Authorization`, `Cookie`, `X-API-Key`
- Redacts sensitive body fields: `password`, `token`, `refreshToken`, `accessToken`, `secret`, `apiKey`, `pin`, `otp`, `cvv`, `cardNumber`, `creditCard`, `ssn`, `socialSecurityNumber`
- Truncates large response bodies (>1000 chars)
- Sanitizes **both** request AND response data

**Log Output:**
```
[API] HTTP Request
  method: POST
  url: https://api.example.com/auth/login
  headers: {authorization: ***REDACTED***}
  body: {email: user@example.com, password: ***REDACTED***}

[API] HTTP Response (200) - 142ms
  statusCode: 200
  body: {access_token: ***REDACTED***, user: {...}}
```

### NetworkErrorHandler

Converts network-level errors into `ServerException`:

```dart
final handler = NetworkErrorHandler();

// Usage in ErrorInterceptor
handler.handleError(
  exception: SocketException(...),
  requestMethod: 'GET',
  requestUrl: Uri.parse('https://api.example.com/users'),
);
```

**Handled Exceptions:**
| Exception Type | Error Message |
|---------------|---------------|
| `SocketException` | "No internet connection" |
| `TimeoutException` | "Request timed out" |
| `CircuitBreakerException` | Uses exception's message |
| `ChopperHttpException` | Extracts from response |
| Unknown | "An unexpected error occurred" |

### RefreshTokenInterceptor

Automatically refreshes expired access tokens on 401 responses:

```dart
RefreshTokenInterceptor(
  tokenStorage: tokenStorage,
  refreshTokenEndpoint: '/auth/refresh',
  baseUrl: Uri.parse(config.apiBaseUrl),
  refreshLock: getIt<Lock>(),        // Singleton lock for thread-safety
  onRefreshFailed: () => sessionManager.notifySessionExpired(),
  onRefreshSuccess: () => tokenRefreshNotifier.notifyTokenRefreshed(),
  logger: appLogger,                  // Optional: debug token flow
);
```

**Flow:**
```
Request → 401 Response
    ↓
Check if refresh endpoint → No, attempt refresh
    ↓
Lock acquired (blocks other 401s)
    ↓
POST /auth/refresh with refresh_token
    ↓
Success: Save new tokens, notify listeners, retry original request
Failed: Call onRefreshFailed, return original 401
```

**Thread-Safety:**
- Uses `synchronized` package for lock
- Multiple simultaneous 401s wait for single refresh
- Lock is injected via DI (singleton across app)

## Response Extensions

Utility extensions for Chopper responses:

```dart
import 'package:starter_app/core/api/extensions/response_extensions.dart';

final response = await apiService.getUser(userId);

// Throws if body is null
final user = response.requireBody;

// Safe with null check
final user = response.body;
if (user == null) {
  return Left(Failure.unexpected());
}
```

## Best Practices

### DO ✅

- Place interceptors in the correct order (see chain above)
- Use the provided interceptors instead of custom logging
- Inject dependencies (token storage, logger) rather than direct access
- Handle sensitive data through LoggingInterceptor's sanitization
- Use `@visibleForTesting` for testing hooks

### DON'T ❌

- Don't log raw requests/responses (use LoggingInterceptor)
- Don't hardcode API keys or tokens
- Don't put ErrorInterceptor before RefreshTokenInterceptor
- Don't create multiple ChopperClient instances
- Don't ignore the circuit breaker state

## Security Considerations

### Sensitive Data Protection

1. **Headers**: `Authorization`, `Cookie`, `X-API-Key` are automatically redacted
2. **Request Bodies**: Password fields, tokens, PII are redacted
3. **Response Bodies**: Same sanitization applied to responses
4. **No Raw Logging**: All logging goes through LoggingInterceptor

### Token Security

1. Tokens stored via `ITokenStorage` (secure storage)
2. Refresh token never exposed in logs
3. Failed refresh triggers session expiration
4. Lock prevents race conditions during refresh

## Testing

Mock interceptors for unit testing:

```dart
// Create mock ChopperClient
final mockClient = ChopperClient(
  baseUrl: Uri.parse('https://test.api.com'),
  interceptors: [
    // Only add interceptors needed for test
  ],
);

// Test interceptor in isolation
final interceptor = AuthInterceptor(() async => 'test-token');
final chain = MockChain(request);

final response = await interceptor.intercept(chain);
expect(chain.capturedRequest.headers['Authorization'], 'Bearer test-token');
```

For RefreshTokenInterceptor, inject mock HTTP client:

```dart
final interceptor = RefreshTokenInterceptor(
  tokenStorage: mockTokenStorage,
  refreshTokenEndpoint: '/auth/refresh',
  baseUrl: Uri.parse('https://api.example.com'),
  refreshLock: Lock(),
  onRefreshFailed: () {},
  onRefreshSuccess: () {},
  httpClient: mockHttpClient,  // Inject mock
);
```

## References

- Chopper Documentation: [pub.dev/packages/chopper](https://pub.dev/packages/chopper)
- Infrastructure Layer: `lib/core/infrastructure/README.md`
- Circuit Breaker: `lib/core/infrastructure/circuit_breaker/`
- Token Storage: `lib/core/infrastructure/storage/`
- Error Handling: `lib/core/error/README.md`
