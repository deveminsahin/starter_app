# Security Rules

## Core Principles

- Store sensitive data securely using platform-specific encrypted storage
- Never hardcode secrets or API keys in source code
- Use HTTPS for all network communication
- Implement proper authentication token management
- Validate all user inputs
- Follow principle of least privilege

## Secure Storage

### Token Storage

**Actual implementation:**

```dart
// lib/core/storage/token_storage.dart
@lazySingleton
class TokenStorage {
  TokenStorage(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  /// Get the stored access token.
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  /// Save authentication tokens.
  Future<void> saveTokens({
    String? accessToken,
    String? refreshToken,
  }) async {
    if (accessToken != null) {
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    }
    if (refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  /// Clear all stored tokens.
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
    ]);
  }
}
```

**Platform-specific storage:**

- **iOS**: Keychain
- **Android**: EncryptedSharedPreferences (AES encryption)
- **Web**: Web Cryptography API
- **Desktop**: Encrypted storage

### FlutterSecureStorage Configuration

**From StorageModule:**

```dart
@lazySingleton
FlutterSecureStorage provideFlutterSecureStorage() {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
}
```

### Storage Rules

- ✅ **DO**: Use `FlutterSecureStorage` for tokens, API keys, credentials
- ✅ **DO**: Use `SharedPreferences` for non-sensitive settings
- ✅ **DO**: Clear secure storage on logout
- ✅ **DO**: Handle storage errors gracefully
- ❌ **DON'T**: Store tokens in SharedPreferences
- ❌ **DON'T**: Store sensitive data in plain text
- ❌ **DON'T**: Store passwords (use tokens instead)

## Authentication

### Token-Based Authentication

**Auth Interceptor:**

```dart
// lib/core/api/interceptors/auth_interceptor.dart
final class AuthInterceptor implements Interceptor {
  AuthInterceptor(this._tokenProvider);

  final Future<String?> Function() _tokenProvider;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final token = await _tokenProvider();

    // If no token, proceed without auth
    if (token == null || token.isEmpty) {
      return chain.proceed(chain.request);
    }

    // Add authorization header
    final authenticatedRequest = applyHeader(
      chain.request,
      'Authorization',
      'Bearer $token',
    );

    return chain.proceed(authenticatedRequest);
  }
}
```

### Token Refresh Pattern

**Automatic token refresh on 401:**

```dart
// lib/core/api/interceptors/refresh_token_interceptor.dart
final class RefreshTokenInterceptor implements Interceptor {
  RefreshTokenInterceptor({
    required this.tokenStorage,
    required this.refreshTokenEndpoint,
    required this.onRefreshFailed,
    required this.onRefreshSuccess,
    required this.baseUrl,
    required this.refreshLock,
  });

  final ITokenStorage tokenStorage;
  final String refreshTokenEndpoint;
  final VoidCallback onRefreshFailed;
  final VoidCallback onRefreshSuccess;
  final Uri baseUrl;
  final Lock refreshLock;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final response = await chain.proceed(chain.request);

    // If 401, attempt token refresh
    if (response.statusCode == 401) {
      // Use lock to prevent multiple simultaneous refreshes
      return refreshLock.synchronized(() async {
        // Attempt refresh...
        // on success: onRefreshSuccess();
        // on failure: onRefreshFailed();
      });
    }

    return response;
  }
}
```

### Authentication Rules

- ✅ **DO**: Use Bearer token authentication
- ✅ **DO**: Implement automatic token refresh
- ✅ **DO**: Use locks to prevent concurrent refresh attempts
- ✅ **DO**: Clear tokens on refresh failure
- ✅ **DO**: Redirect to login on auth failure
- ❌ **DON'T**: Store tokens in URL parameters
- ❌ **DON'T**: Log tokens or sensitive data
- ❌ **DON'T**: Send tokens over HTTP

## API Security

### HTTPS Only

**Enforce HTTPS:**

```dart
// In environment configuration
class AppEnvironment {
  static String get apiBaseUrl => _current.apiBaseUrl;

  const AppEnvironment._({
    required this.apiBaseUrl,
  });

  final String apiBaseUrl; // Always use https:// URLs
}
```

### API Key Protection

**For services requiring API keys:**

```dart
final class ApiKeyInterceptor implements Interceptor {
  const ApiKeyInterceptor({
    required this.apiKey,
    this.headerName = 'X-API-Key',
    this.useHeader = true,
  });

  final String apiKey;
  final String headerName;
  final bool useHeader;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    if (useHeader) {
      final authenticatedRequest = applyHeader(
        chain.request,
        headerName,
        apiKey,
      );
      return chain.proceed(authenticatedRequest);
    }
    // ... query parameter handling
  }
}
```

### API Security Rules

- ✅ **DO**: Use HTTPS for all API calls
- ✅ **DO**: Use environment-specific API keys
- ✅ **DO**: Add API keys in headers (not query params)
- ✅ **DO**: Implement request timeouts
- ✅ **DO**: Validate server certificates
- ❌ **DON'T**: Hardcode API keys in source
- ❌ **DON'T**: Commit .env files with secrets
- ❌ **DON'T**: Use HTTP for production

## Input Validation

### Value Objects for Validation

**Domain-level validation:**

```dart
@immutable
class EmailAddress implements ValueObject<String> {
  factory EmailAddress(String input) {
    return EmailAddress._(_validateEmailAddress(input));
  }
  const EmailAddress._(this.value);

  @override
  final Either<List<ValueFailure<String>>, String> value;

  static Either<List<ValueFailure<String>>, String> _validateEmailAddress(
    String? input,
  ) {
    if (input == null || input.isEmpty) {
      return left([const EmailFailure.empty()]);
    }

    if (!_emailRegex.hasMatch(input)) {
      return left([EmailFailure.invalidFormat(failedValue: input)]);
    }

    // Normalize: trim and lowercase
    return right(input.trim().toLowerCase());
  }
}
```

### Input Validation Rules

- ✅ **DO**: Validate all user inputs using value objects
- ✅ **DO**: Sanitize inputs before sending to API
- ✅ **DO**: Use regex patterns for format validation
- ✅ **DO**: Normalize inputs (trim, lowercase email)
- ✅ **DO**: Return descriptive validation errors
- ❌ **DON'T**: Trust user input without validation
- ❌ **DON'T**: Send unvalidated data to backend
- ❌ **DON'T**: Use exceptions for validation errors

## Environment-Specific Configuration

### Environment Variables

**DO NOT commit to repository:**

```bash
# .env (gitignored)
API_BASE_URL=https://api.production.com
API_KEY=prod_key_12345
SENTRY_DSN=https://...
```

### Environment Configuration

```dart
// lib/core/app/app_environment.dart
enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment get current {
    // Load from environment variables or flavor
    return AppEnvironment.development;
  }

  String get apiBaseUrl {
    return switch (this) {
      AppEnvironment.development => 'https://api.dev.example.com',
      AppEnvironment.staging => 'https://api.staging.example.com',
      AppEnvironment.production => 'https://api.example.com',
    };
  }
}
```

### Environment Rules

- ✅ **DO**: Use environment variables for secrets
- ✅ **DO**: Have separate configs per environment
- ✅ **DO**: Add .env to .gitignore
- ✅ **DO**: Document required env variables
- ❌ **DON'T**: Commit secrets to git
- ❌ **DON'T**: Use production keys in development
- ❌ **DON'T**: Share API keys in code reviews

## Certificate Pinning (Advanced)

**For high-security apps:**

```dart
// Optional: Certificate pinning with dio
class CertificatePinning {
  static SecurityContext createSecurityContext() {
    final context = SecurityContext(withTrustedRoots: true);

    // Add your certificate
    final cert = rootBundle.loadString('assets/certificates/cert.pem');
    context.setTrustedCertificatesBytes(cert.codeUnits);

    return context;
  }
}
```

**Certificate Pinning Rules:**

- ✅ **DO**: Use for banking/financial apps
- ✅ **DO**: Bundle certificates in assets
- ✅ **DO**: Plan for certificate rotation
- ❌ **DON'T**: Use for apps needing flexibility
- ❌ **DON'T**: Forget to update certificates

## Release Build Security

### Code Obfuscation (Required for Production)

**Always use obfuscation for release builds:**

```bash
# Android APK
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# iOS
flutter build ios --release --obfuscate --split-debug-info=build/debug-info
```

**Note:** Web builds use JavaScript minification automatically.

### Obfuscation Rules

- ✅ **DO**: Enable `--obfuscate` for all production builds
- ✅ **DO**: Use `--split-debug-info` to save symbol maps (for crash reporting)
- ✅ **DO**: Store debug-info securely (needed for stack trace symbolication)
- ✅ **DO**: Upload symbol maps to Sentry/Crashlytics
- ❌ **DON'T**: Ship debug builds to production
- ❌ **DON'T**: Commit debug-info to git (add to .gitignore)

### ProGuard/R8 (Android)

Ensure release builds use R8 (enabled by default):

```gradle
// android/app/build.gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

### Debug Info Storage

```bash
# Add to .gitignore
build/debug-info/
```

Store debug symbols securely for crash symbolication in production.

## Security Checklist

### Pre-Release Security Review

- [ ] All API calls use HTTPS
- [ ] No hardcoded secrets or API keys
- [ ] Tokens stored in secure storage
- [ ] Automatic token refresh implemented
- [ ] Input validation on all forms
- [ ] Error messages don't expose sensitive info
- [ ] .env files in .gitignore
- [ ] Proper auth redirect on token expiry
- [ ] No sensitive data logged
- [ ] Certificate validation enabled
- [ ] Obfuscation enabled (`--obfuscate --split-debug-info`)
- [ ] ProGuard/R8 enabled for Android release builds
- [ ] Debug symbols uploaded to crash reporting service

### Common Vulnerabilities to Avoid

- ❌ Storing tokens in SharedPreferences
- ❌ Logging sensitive data
- ❌ Hardcoding credentials
- ❌ Using HTTP in production
- ❌ Trusting user input without validation
- ❌ Exposing stack traces to users
- ❌ Committing secrets to git

## Best Practices

### Secure Logging

```dart
// ❌ DON'T log sensitive data
logger.info('Login response: $response'); // May contain tokens

// ✅ DO log safely
logger.info('Login successful for user ${user.id}');
```

### Error Messages

```dart
// ❌ DON'T expose technical details
return Left(Failure('Database connection failed: ${e.message}'));

// ✅ DO use generic messages
return Left(Failure('An error occurred. Please try again.'));
```

### Code Review Focus

- Check for hardcoded secrets
- Verify secure storage usage
- Confirm HTTPS for all APIs
- Review error messages for info leaks
- Validate input handling
- Check token storage and clearing
