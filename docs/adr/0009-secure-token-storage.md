# ADR-0009: flutter_secure_storage for Token Security

## Status

Accepted

## Context

Authentication tokens need secure storage:
- Access tokens (short-lived)
- Refresh tokens (longer-lived, more sensitive)

Options considered:

| Storage | Security | Use Case |
|---------|----------|----------|
| SharedPreferences | ❌ Plaintext | Non-sensitive data |
| flutter_secure_storage | ✅ Encrypted | Tokens, credentials |
| Hive (encrypted) | ✅ Encrypted | Larger datasets |

## Decision

I adopt **flutter_secure_storage** for all token storage.

### Platform Security

| Platform | Mechanism |
|----------|-----------|
| iOS | Keychain Services |
| Android | EncryptedSharedPreferences (API 23+) or Keystore |
| Web | Encrypted localStorage (less secure) |

### Implementation

```dart
abstract interface class ITokenStorage {
  FutureResult<String?> getAccessToken();
  FutureResult<String?> getRefreshToken();
  FutureResult<Unit> saveTokens({required String accessToken, required String refreshToken});
  FutureResult<Unit> clearTokens();
}

@LazySingleton(as: ITokenStorage)
class SecureTokenStorage implements ITokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  
  // ... implementation
}
```

### Security Best Practices

1. **Never log tokens** - Redacted in `LoggingInterceptor`
2. **Clear on logout** - Remove all tokens
3. **Use refresh tokens** - Short-lived access tokens
4. **Lock on background** - Consider requiring re-auth

## Consequences

### Positive
- **Encrypted at rest**: Platform-level encryption
- **No plaintext tokens**: Even rooted devices have protection
- **Simple API**: Key-value storage interface

### Negative
- **Platform differences**: Web less secure than mobile
- **Performance**: Slower than SharedPreferences

### Neutral
- Tokens stored per key (access_token, refresh_token)
