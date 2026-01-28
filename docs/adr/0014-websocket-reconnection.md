# ADR-0014: WebSocket Reconnection Strategy

## Status

Accepted

## Context

WebSocket connections are inherently fragile:
- Network changes (WiFi → cellular)
- Server restarts
- Idle timeouts
- Mobile app backgrounding

I needed a robust reconnection strategy that:
- Automatically reconnects on failure
- Doesn't overwhelm the server with retries
- Provides visibility into connection state
- Integrates with token refresh

## Decision

I adopt **exponential backoff with jitter** for WebSocket reconnection.

### Reconnection Policy

```dart
abstract interface class IReconnectionPolicy {
  bool get enabled;
  int get maxAttempts;
  bool canRetry(int currentAttempt);
  Duration getDelayForAttempt(int attempt);
}
```

### Exponential Backoff with Jitter

```dart
class WebSocketReconnectionConfig implements IReconnectionPolicy {
  const WebSocketReconnectionConfig({
    this.enabled = true,
    this.maxAttempts = 5,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
  });

  @override
  Duration getDelayForAttempt(int attempt) {
    // Exponential: 1s, 2s, 4s, 8s, 16s (capped at 30s)
    final exponentialDelay = initialDelay * pow(backoffMultiplier, attempt);
    final cappedDelay = min(exponentialDelay, maxDelay);
    
    // Jitter: ±25% randomization to prevent thundering herd
    final jitter = cappedDelay * 0.25 * (Random().nextDouble() * 2 - 1);
    return cappedDelay + jitter;
  }
}
```

### Connection State Machine

```
┌─────────────┐
│ Disconnected│◄────────────────────────────┐
└──────┬──────┘                              │
       │ connect()                           │
       ▼                                     │
┌─────────────┐                              │
│ Connecting  │──────────────────────────────┤
└──────┬──────┘     failure (max retries)    │
       │ success                             │
       ▼                                     │
┌─────────────┐                              │
│  Connected  │                              │
└──────┬──────┘                              │
       │ connection lost                     │
       ▼                                     │
┌─────────────┐                              │
│Reconnecting │──────────────────────────────┘
└──────┬──────┘     failure
       │ success
       ▼
┌─────────────┐
│  Connected  │
└─────────────┘
```

### Integration with Token Refresh

```dart
// When access token is refreshed, reconnect WebSocket
tokenRefreshNotifier.onTokenRefreshed.listen((_) {
  websocketConnection.reconnect(headers: {'Authorization': 'Bearer $newToken'});
});
```

See: `lib/core/infrastructure/websocket/`

## Consequences

### Positive
- **Resilient**: Automatic recovery from transient failures
- **Server-friendly**: Exponential backoff prevents overload
- **No thundering herd**: Jitter spreads out reconnection attempts
- **Observable**: State stream for UI feedback
- **Token-aware**: Reconnects with fresh token after refresh

### Negative
- **Complexity**: State machine adds code
- **Delayed reconnection**: Backoff means slower recovery

### Neutral
- Manual disconnect prevents reconnection
- Disposal cleans up all resources
