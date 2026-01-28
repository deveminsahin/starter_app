# ADR-0012: Chopper HTTP Client with Interceptor Chain

## Status

Accepted

## Context

Flutter apps need an HTTP client for API communication. Options considered:

| Client | Pros | Cons |
|--------|------|------|
| **Chopper** | Code generation, interceptors, type-safe | Requires build_runner |
| **Dio** | Popular, many plugins | Larger footprint |
| **http** | Simple, Flutter team | No interceptors, minimal features |
| **Retrofit** | Code generation | Heavier, Java-style |

I needed:
1. Type-safe service definitions
2. Interceptor chain for cross-cutting concerns
3. Request/response transformation
4. Testability (mockable services)

## Decision

I adopt **Chopper** with a carefully ordered interceptor chain.

### Interceptor Chain

```
Request flow:
  CircuitBreaker → Auth → RefreshToken → Logging → Error → [Server]

Response flow:
  [Server] → Error → Logging → RefreshToken → Auth → CircuitBreaker
```

### Interceptors

| # | Interceptor | Purpose |
|---|-------------|---------|
| 1 | `CircuitBreakerInterceptor` | Fail fast if service is down |
| 2 | `AuthInterceptor` | Add Bearer token header |
| 3 | `RefreshTokenInterceptor` | Auto-refresh on 401, retry request |
| 4 | `LoggingInterceptor` | Log requests/responses (redacts sensitive data) |
| 5 | `ErrorInterceptor` | Convert HTTP errors to exceptions |

### Implementation

```dart
// network_module.dart
ChopperClient provideChopperClient(...) {
  return ChopperClient(
    baseUrl: Uri.parse(apiBaseUrl),
    converter: const JsonConverter(),
    interceptors: [
      CircuitBreakerInterceptor(circuitBreaker),
      AuthInterceptor(() => tokenStorage.getAccessToken()),
      RefreshTokenInterceptor(
        tokenStorage: tokenStorage,
        refreshTokenEndpoint: AuthEndpoints.refreshToken,
        onRefreshFailed: sessionManager.notifySessionExpired,
        onRefreshSuccess: tokenRefreshNotifier.notifyTokenRefreshed,
      ),
      LoggingInterceptor(logger),
      ErrorInterceptor(networkErrorHandler),
    ],
  );
}
```

### Key Features

**Circuit Breaker Pattern**
- Opens after N consecutive failures
- Fails fast (no network call)
- Auto-recovers after cooldown

**Token Refresh with Lock**
- Detects 401 Unauthorized
- Uses `synchronized` package for thread-safety
- Queues concurrent requests during refresh
- Notifies WebSocket to reconnect on success

**Certificate Pinning**
- Platform-specific HTTP client factory
- iOS: Uses trusted certificate bytes
- Android: Uses Network Security Config

See: `lib/core/api/interceptors/`

## Consequences

### Positive
- **Separation of concerns**: Each interceptor handles one concern
- **Order control**: Predictable request/response flow
- **Resilience**: Circuit breaker prevents cascading failures
- **Security**: Auto token refresh, certificate pinning

### Negative
- **Complexity**: Multiple interceptors to understand
- **Order sensitivity**: Wrong order causes bugs

### Neutral
- Chopper services generated via build_runner
- Each feature defines its own Chopper service
