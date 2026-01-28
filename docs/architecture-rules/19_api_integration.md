# API Integration

API integration in this project uses **Chopper** for type-safe HTTP client generation with a clean interceptor-based architecture.

## Table of Contents

- [API Service Setup](#api-service-setup)
- [Endpoint Management](#endpoint-management)
- [ChopperClient Configuration](#chopperclient-configuration)
- [Interceptors](#interceptors)
- [Environment Configuration](#environment-configuration)
- [Request/Response Models](#requestresponse-models)
- [Error Handling](#error-handling)
- [Testing](#testing)

---

## API Service Setup

### Defining API Services

Create feature-specific API services using Chopper annotations. Services use `Map<String, dynamic>` for flexibility, while typed models are used at the data source layer.

```dart
// lib/features/auth/infrastructure/datasources/auth_api_service.dart
@ChopperApi(baseUrl: AuthEndpoints.authBasePath)
abstract class AuthApiService extends ChopperService {
  static AuthApiService create([ChopperClient? client]) {
    return _$AuthApiService(client);
  }

  /// Login with email and password.
  /// Returns authentication token and user data.
  @POST(path: AuthEndpoints.login)
  Future<Response<Map<String, dynamic>>> login(
    @Body() Map<String, dynamic> credentials,
  );

  /// Register a new user account.
  /// Returns authentication token and user data.
  @POST(path: AuthEndpoints.register)
  Future<Response<Map<String, dynamic>>> register(
    @Body() Map<String, dynamic> userData,
  );

  /// Get current user profile.
  /// Requires authentication token.
  @GET(path: AuthEndpoints.currentUser)
  Future<Response<Map<String, dynamic>>> getCurrentUser();

  /// Logout current user.
  /// Invalidates the authentication token on the server.
  @POST(path: AuthEndpoints.logout)
  Future<Response<void>> logout();
}
```

**Key Points:**

- Use `@ChopperApi(baseUrl: ...)` with feature-specific base path (e.g., `/api/v1/auth`)
- All methods return `Future<Response<T>>` where T is typically `Map<String, dynamic>` or `void`
- Use annotations: `@GET`, `@POST`, `@PUT`, `@PATCH`, `@DELETE`
- Use `@Body()` for request bodies, `@Path()` for path parameters, `@Query()` for query params
- Maps provide flexibility; typed models are used in data source layer (see [Request/Response Models](#requestresponse-models))
- Generate implementation with: `dart run build_runner build --delete-conflicting-outputs`

### Registering Services

Register services in the DI module:

```dart
// lib/core/di/modules/network_module.dart
@module
abstract class NetworkModule {
  @singleton
  ChopperClient provideChopperClient(
    AppLogger logger,
    NetworkErrorHandler networkErrorHandler,
    TokenStorage tokenStorage,
    Lock refreshLock,
  ) {
    return ChopperClient(
      baseUrl: Uri.parse(AppEnvironment.current.apiBaseUrl),
      services: [
        AuthApiService.create(),
        // Register other services here
      ],
      converter: const JsonConverter(),
      interceptors: [ /* ... */ ],
    );
  }

  @lazySingleton
  AuthApiService provideAuthApiService(ChopperClient client) {
    return client.getService<AuthApiService>();
  }
}
```

---

## Endpoint Management

### Feature-Specific Endpoint Constants

Define endpoint constants per feature to follow the feature-first architecture:

```dart
// lib/features/auth/infrastructure/datasources/auth_endpoints.dart
final class AuthEndpoints {
  const AuthEndpoints._();

  /// API version from environment configuration
  static const String version = String.fromEnvironment(
    'API_VERSION',
    defaultValue: 'v1',
  );

  /// Base auth API path with version
  static const String authBasePath = '/api/$version/auth';

  // Relative paths (combined with baseUrl + authBasePath)
  static const String login = '/login';
  static const String logout = '/logout';
  static const String register = '/register';
  static const String refreshToken = '/refresh';
  static const String currentUser = '/me';
}
```

**URL Construction:**

- Base URL: `https://api.example.com` (from `AppEnvironment`)
- Service baseUrl: `/api/v1/auth` (from `@ChopperApi`)
- Endpoint path: `/login` (from constant)
- **Final URL**: `https://api.example.com/api/v1/auth/login`

**Best Practices:**

- Create separate endpoint classes per feature (`AuthEndpoints`, `ProfileEndpoints`, etc.)
- Use environment-based API version (`String.fromEnvironment`)
- Never hardcode paths in service methods
- Use relative paths (starting with `/`)

---

## ChopperClient Configuration

### Core Configuration

```dart
@singleton
ChopperClient provideChopperClient(
  AppLogger logger,
  NetworkErrorHandler networkErrorHandler,
  TokenStorage tokenStorage,
  ISessionManager sessionManager,
  ITokenRefreshNotifier tokenRefreshNotifier,
  Lock refreshLock,
) {
  final apiBaseUrl = AppEnvironment.current.apiBaseUrl;

  return ChopperClient(
    baseUrl: Uri.parse(apiBaseUrl),

    services: [
      AuthApiService.create(),
    ],

    converter: const JsonConverter(),
    errorConverter: const JsonConverter(),

    // Interceptors in order
    interceptors: [
      AuthInterceptor(() => tokenStorage.getAccessToken()),
      RefreshTokenInterceptor(
        tokenStorage: tokenStorage,
        refreshTokenEndpoint: AuthEndpoints.refreshToken,
        onRefreshFailed: sessionManager.notifySessionExpired,
        onRefreshSuccess: tokenRefreshNotifier.notifyTokenRefreshed,
        baseUrl: Uri.parse(apiBaseUrl),
        refreshLock: refreshLock,
      ),
      LoggingInterceptor(logger),
      ErrorInterceptor(networkErrorHandler),
    ],
  );
}
```

**Interceptor Order Matters:**

1. **AuthInterceptor**: Adds Bearer token to requests
2. **RefreshTokenInterceptor**: Handles 401 responses and token refresh (before ErrorInterceptor!)
3. **LoggingInterceptor**: Logs requests/responses with timing
4. **ErrorInterceptor**: Converts HTTP errors to domain exceptions

---

## Interceptors

### 1. AuthInterceptor

Adds authentication headers to requests:

```dart
final class AuthInterceptor implements Interceptor {
  const AuthInterceptor(this._getToken);

  final Future<String?> Function() _getToken;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final token = await _getToken();

    final request = token != null
        ? applyHeader(chain.request, 'Authorization', 'Bearer $token')
        : chain.request;

    return chain.proceed(request);
  }
}
```

**Usage:**

- Inject as: `AuthInterceptor(() => tokenStorage.getAccessToken())`
- Automatically adds `Authorization: Bearer <token>` header
- Skips header if token is null

### 2. RefreshTokenInterceptor

Automatically refreshes expired tokens on 401 responses:

```dart
final class RefreshTokenInterceptor implements Interceptor {
  RefreshTokenInterceptor({
    required this.tokenStorage,
    required this.refreshTokenEndpoint,
    required this.onRefreshFailed,
    required this.baseUrl,
    required Lock refreshLock,
  }) : _lock = refreshLock;

  final Lock _lock; // Prevents concurrent refresh requests

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final response = await chain.proceed(chain.request);

    if (response.statusCode != 401) return response;

    // Don't retry if refresh endpoint itself failed
    if (chain.request.url.path.contains(refreshTokenEndpoint)) {
      onRefreshFailed();
      return response;
    }

    // Attempt refresh with lock (prevents concurrent requests)
    final newToken = await _refreshToken();

    if (newToken == null) {
      onRefreshFailed();
      return response;
    }

    // Retry with new token
    final newRequest = applyHeader(
      chain.request,
      'Authorization',
      'Bearer $newToken',
    );

    return chain.proceed(newRequest);
  }
}
```

**Features:**

- Thread-safe token refresh using `synchronized` package
- Multiple simultaneous 401s will wait for the same refresh operation
- Automatically retries original request with new token
- Calls `onRefreshFailed()` callback when refresh fails (logout user)

**Must be placed BEFORE ErrorInterceptor** so it can handle 401s before they're converted to exceptions.

### 3. LoggingInterceptor

Logs all HTTP requests/responses:

```dart
final class LoggingInterceptor implements Interceptor {
  const LoggingInterceptor(this._logger);

  final AppLogger _logger;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final stopwatch = Stopwatch()..start();

    _logRequest(chain.request);

    try {
      final response = await chain.proceed(chain.request);
      stopwatch.stop();

      _logResponse(response, stopwatch.elapsedMilliseconds);
      return response;
    } catch (error, stackTrace) {
      stopwatch.stop();
      _logError(chain.request, error, stackTrace, stopwatch.elapsedMilliseconds);
      rethrow;
    }
  }
}
```

**Security Features:**

- **Sanitizes sensitive headers**: `authorization`, `cookie`, `api-key` → `***REDACTED***`
- **Sanitizes request body fields**: `password`, `token`, `secret` → `***REDACTED***`
- **Truncates large responses**: Shows first 1000 characters + length
- Logs to AppLogger (console in dev, Sentry in staging/production)

### 4. ErrorInterceptor

Converts HTTP errors to domain exceptions:

```dart
final class ErrorInterceptor implements Interceptor {
  const ErrorInterceptor(this._networkErrorHandler);

  final NetworkErrorHandler _networkErrorHandler;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    try {
      final response = await chain.proceed(chain.request);

      if (!response.isSuccessful) {
        _handleErrorResponse(response);
      }

      return response;
    } catch (error, stackTrace) {
      _networkErrorHandler.handleError(error, stackTrace);
    }
  }

  Never _handleErrorResponse(Response<dynamic> response) {
    throw ServerException(
      message: _extractErrorMessage(response),
      statusCode: response.statusCode,
    );
  }
}
```

**Error Mapping:**

- `200-299`: Success (passes through)
- `400-599`: `ServerException` with status code and message
- `SocketException`: `NetworkException` - "No internet connection"
- `TimeoutException`: `NetworkException` - "Request timeout"
- Other errors: `NetworkException` - Generic network error

---

## Environment Configuration

### Configuration Files

Create environment-specific JSON files in `config/` directory:

```json
// config/development.json
{
  "ENVIRONMENT": "development",
  "API_URL": "http://localhost:3000",
  "API_VERSION": "v1"
}
```

```json
// config/staging.json
{
  "ENVIRONMENT": "staging",
  "API_URL": "https://api-staging.example.com",
  "API_VERSION": "v1",
  "SENTRY_DSN": "https://xxx@sentry.io/staging"
}
```

```json
// config/production.json
{
  "ENVIRONMENT": "production",
  "API_URL": "https://api.example.com",
  "API_VERSION": "v1",
  "SENTRY_DSN": "https://xxx@sentry.io/production"
}
```

### Running with Configuration

```bash
# Development
flutter run --dart-define-from-file=config/development.json

# Staging
flutter run --dart-define-from-file=config/staging.json

# Production build
flutter build apk --release --dart-define-from-file=config/production.json
```

### Accessing Configuration

```dart
// lib/core/app/app_environment.dart
enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment get current {
    const envString = String.fromEnvironment('ENVIRONMENT');
    return AppEnvironment.values.firstWhere(
      (e) => e.name == envString.toLowerCase(),
      orElse: () => AppEnvironment.development,
    );
  }

  String get apiBaseUrl {
    const url = String.fromEnvironment('API_URL');
    if (url.isNotEmpty) return url;

    // Fallback defaults
    return switch (this) {
      development => 'http://localhost:3000',
      staging => 'https://api-staging.example.com',
      production => 'https://api.example.com',
    };
  }
}
```

---

## Request/Response Models

### Hybrid Approach (Current Implementation)

This project uses a **hybrid approach** combining flexibility and type safety:

- **API Service Layer**: Uses `Map<String, dynamic>` for Chopper compatibility
- **Data Source Layer**: Uses typed models (DTOs) for type safety
- **Conversion happens at the data source boundary**

#### Step 1: Define Typed Models

```dart
// lib/features/auth/infrastructure/models/login_request_model.dart
@freezed
abstract class LoginRequestModel with _$LoginRequestModel {
  const factory LoginRequestModel({
    required String email,
    required String password,
  }) = _LoginRequestModel;
  const LoginRequestModel._();

  factory LoginRequestModel.fromJson(Json json) =>
      _$LoginRequestModelFromJson(json);
}
```

```dart
// lib/features/auth/infrastructure/models/auth_response_model.dart
@freezed
abstract class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    required UserModel user,
    required AuthTokensModel tokens,
  }) = _AuthResponseModel;
  const AuthResponseModel._();

  factory AuthResponseModel.fromJson(Json json) =>
      _$AuthResponseModelFromJson(json);
}
```

#### Step 2: API Service with Maps

```dart
// lib/features/auth/infrastructure/datasources/auth_api_service.dart
@ChopperApi(baseUrl: AuthEndpoints.authBasePath)
abstract class AuthApiService extends ChopperService {
  @POST(path: AuthEndpoints.login)
  Future<Response<Map<String, dynamic>>> login(
    @Body() Map<String, dynamic> credentials,
  );

  @POST(path: AuthEndpoints.register)
  Future<Response<Map<String, dynamic>>> register(
    @Body() Map<String, dynamic> userData,
  );
}
```

#### Step 3: Data Source with Type Conversion

```dart
// lib/features/auth/infrastructure/datasources/auth_remote_data_source.dart
@LazySingleton(as: IAuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiService);
  final AuthApiService _apiService;

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) =>
      execute(() async {
        // Convert model to JSON for API service
        final response = await _apiService.login(request.toJson());

        // Convert JSON response to typed model
        return AuthResponseModel.fromJson(response.body!);
      });

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) =>
      execute(() async {
        final response = await _apiService.register(request.toJson());
        return AuthResponseModel.fromJson(response.body!);
      });
}
```

#### Step 4: Repository with Domain Conversion

```dart
// lib/features/auth/infrastructure/repositories/auth_repository_impl.dart
@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  final IAuthRemoteDataSource _remoteDataSource;
  final ITokenStorage _tokenStorage;

  @override
  FutureResult<User> login(AuthCredentials credentials) => execute(
        () async {
          // Create request model from domain
          final result = await _remoteDataSource.login(
            LoginRequestModel(
              email: credentials.email.getOrCrash(),
              password: credentials.password.getOrCrash(),
            ),
          );

          // Save tokens
          await _tokenStorage.saveTokens(
            accessToken: result.tokens.accessToken,
            refreshToken: result.tokens.refreshToken,
          );

          // Convert model to domain entity
          return result.user.toDomain();
        },
      );
}
```

### Advantages of Hybrid Approach

**✅ Type Safety Where It Matters:**

- Data source has full type safety with freezed models
- Compile-time checks for model structure
- Auto-generated `toJson()` and `fromJson()`

**✅ Flexibility at API Layer:**

- Chopper service uses simple maps (easier setup)
- No custom converters needed
- Easy to handle varying response structures

**✅ Clear Separation of Concerns:**

- API service: Raw HTTP communication
- Data source: Type conversion boundary
- Repository: Domain logic and entity mapping

**✅ Testing Benefits:**

- Mock data source with typed models (not maps)
- Type-safe test data creation
- Easier to verify response structure

---

## Error Handling

### Exception Hierarchy

```dart
// Domain exceptions thrown by interceptors
abstract class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

// HTTP errors (4xx, 5xx)
class ServerException extends AppException {
  const ServerException({required String message, this.statusCode})
      : super(message);
  final int statusCode;
}

// Network/connection errors
class NetworkException extends AppException {
  const NetworkException({required String message, this.originalError})
      : super(message);
  final Object? originalError;
}
```

### Handling in Repositories

```dart
@override
FutureResult<User> login(EmailAddress email, Password password) {
  return execute(
    action: () async {
      final response = await _apiService.login({
        'email': email.value,
        'password': password.value,
      });

      return User.fromJson(response.body!['user']);
    },
    // execute() automatically catches:
    // - ServerException → ServerFailure
    // - NetworkException → NetworkFailure
    // - Exception → UnexpectedFailure
  );
}
```

The `BaseRepository.execute()` method handles exception-to-failure mapping automatically (see `08_error_handling.md`).

---

## Testing

### Mocking API Services

Use `mockito` to mock Chopper services:

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([AuthApiService])
import 'auth_repository_test.mocks.dart';

void main() {
  late MockAuthApiService mockApiService;
  late AuthRepository repository;

  setUp(() {
    mockApiService = MockAuthApiService();
    repository = AuthRepository(mockApiService);
  });

  group('login', () {
    test('returns user on successful login', () async {
      // Arrange
      final response = Response<Map<String, dynamic>>(
        Response(MockRequest(), 200),
        {
          'user': {'id': '1', 'email': 'test@example.com'},
          'accessToken': 'token123',
        },
      );

      when(mockApiService.login(any))
          .thenAnswer((_) async => response);

      // Act
      final result = await repository.login(
        EmailAddress('test@example.com'),
        Password('password123'),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success'),
        (user) {
          expect(user.id, '1');
          expect(user.email, 'test@example.com');
        },
      );
    });

    test('returns failure on network error', () async {
      // Arrange
      when(mockApiService.login(any))
          .thenThrow(const NetworkException(message: 'No connection'));

      // Act
      final result = await repository.login(
        EmailAddress('test@example.com'),
        Password('password123'),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });
}
```

### Testing Interceptors

Test interceptors in isolation:

```dart
void main() {
  group('AuthInterceptor', () {
    test('adds authorization header when token exists', () async {
      // Arrange
      final interceptor = AuthInterceptor(() async => 'test_token');
      final request = Request('GET', Uri.parse('/api/test'), Uri.parse('http://example.com'));
      final chain = _MockChain(request);

      // Act
      await interceptor.intercept(chain);

      // Assert
      expect(
        chain.lastRequest.headers['Authorization'],
        'Bearer test_token',
      );
    });
  });
}
```

### Integration Testing

For integration tests with real HTTP, use a mock server:

```dart
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late DioAdapter dioAdapter;
  late ChopperClient client;

  setUp(() {
    final dio = Dio();
    dioAdapter = DioAdapter(dio: dio);

    client = ChopperClient(
      baseUrl: Uri.parse('http://localhost:3000'),
      services: [AuthApiService.create()],
      client: dio,
    );
  });

  test('login flow', () async {
    // Mock endpoint
    dioAdapter.onPost(
      '/api/v1/auth/login',
      (server) => server.reply(200, {
        'user': {'id': '1', 'email': 'test@example.com'},
        'accessToken': 'token123',
      }),
    );

    // Test
    final service = client.getService<AuthApiService>();
    final response = await service.login({
      'email': 'test@example.com',
      'password': 'password123',
    });

    expect(response.isSuccessful, true);
    expect(response.body!['accessToken'], 'token123');
  });
}
```

---

## Summary

✅ **DO:**

- Use Chopper for type-safe API service generation
- Define feature-specific endpoint constants (e.g., `AuthEndpoints`)
- Use hybrid approach: Maps at API service, typed models at data source
- Define request/response models with `@freezed` for type safety
- Convert models to/from JSON at data source boundary
- Order interceptors correctly (Auth → Refresh → Logging → Error)
- Use environment-based configuration with `--dart-define-from-file`
- Sanitize sensitive data in logging
- Handle errors at repository boundary with `execute()`
- Mock data sources (not API services) in unit tests for typed testing

❌ **DON'T:**

- Don't hardcode API URLs or paths in code
- Don't place RefreshTokenInterceptor after ErrorInterceptor
- Don't log sensitive data (passwords, tokens)
- Don't catch exceptions in repositories (let `execute()` handle them)
- Don't forget to register services in ChopperClient
- Don't skip error converter configuration
- Don't use typed models directly in Chopper services (use maps for flexibility)
- Don't bypass the data source layer (always convert models there)
