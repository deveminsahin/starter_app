# Infrastructure Layer Rules

## Core Principles

- Implements domain interfaces (adapters for ports)
- Handles all external system interactions
- Contains all serialization/deserialization logic
- Depends ONLY on domain interfaces, not implementations

## Repository Implementations

### Structure

**Example from auth feature:**

```dart
// lib/features/auth/infrastructure/repositories/auth_repository_impl.dart
@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl extends BaseRepository implements IAuthRepository {
  AuthRepositoryImpl(
    this._remoteDataSource,
    this._tokenStorage,
    ExceptionHandler exceptionHandler,
    AuthFailureMapper failureMapper,
  ) : super(exceptionHandler, failureMapper);

  final IAuthRemoteDataSource _remoteDataSource;
  final ITokenStorage _tokenStorage;

  @override
  FutureResult<User> login(AuthCredentials credentials) => execute(
    () async {
      final result = await _remoteDataSource.login(
        LoginRequestModel(
          email: credentials.email.getOrCrash(),
          password: credentials.password.getOrCrash(),
        ),
      );
      await _tokenStorage.saveTokens(
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      );
      return result.user.toDomain(); // DTO → Entity
    },
  );
}
```

**Note:** `BaseRepository.execute()` wraps the operation in try-catch and maps exceptions to Failures using the injected `ExceptionHandler` and `FailureMapper`.

### Rules

- ✅ **DO**: Use `@LazySingleton(as: Interface)` for repositories
- ✅ **DO**: Extend `BaseRepository` for consistent exception handling
- ✅ **DO**: Inject data sources as interfaces
- ✅ **DO**: Use `execute()` method to wrap operations
- ✅ **DO**: Convert Models (DTOs) to Domain Entities with `toDomain()`
- ✅ **DO**: Inject `ExceptionHandler` and feature-specific `FailureMapper`
- ❌ **DON'T**: Let exceptions escape (BaseRepository handles it)
- ❌ **DON'T**: Depend on other repositories directly

## Offline-First Pattern

### Cache-First Strategy

```dart
@override
Future<Either<Failure, List<Product>>> getAllProducts({
  bool forceRefresh = false,
}) async {
  // 1. Check cache first (if not forcing refresh)
  if (!forceRefresh && _localDataSource != null) {
    try {
      final cachedProducts = await _localDataSource!.getCachedProducts();
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        return Right(cachedProducts.map((m) => m.toDomain()).toList());
      }
    } catch (_) {
      // Cache read failed, continue to network
    }
  }
  
  // 2. Check network availability
  if (!await _networkInfo.isConnected) {
    // Try cache as fallback
    if (_localDataSource != null) {
      try {
        final cached = await _localDataSource!.getCachedProducts();
        if (cached != null) {
          return Right(cached.map((m) => m.toDomain()).toList());
        }
      } catch (_) {}
    }
    return const Left(NetworkFailure());
  }
  
  // 3. Fetch from network
  try {
    final models = await _remoteDataSource.getAllProducts();
    await _localDataSource?.cacheProducts(models);
    return Right(models.map((m) => m.toDomain()).toList());
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
  }
}
```

## Data Sources

### Remote Data Source (API)

**Chopper API Service:**

```dart
// lib/features/auth/infrastructure/datasources/auth_api_service.dart
@ChopperApi(baseUrl: AuthEndpoints.authBasePath)
abstract class AuthApiService extends ChopperService {
  static AuthApiService create([ChopperClient? client]) {
    return _$AuthApiService(client);
  }

  @POST(path: AuthEndpoints.login)
  Future<Response<Map<String, dynamic>>> login(
    @Body() Map<String, dynamic> credentials,
  );

  @POST(path: AuthEndpoints.register)
  Future<Response<Map<String, dynamic>>> register(
    @Body() Map<String, dynamic> userData,
  );

  @GET(path: AuthEndpoints.currentUser)
  Future<Response<Map<String, dynamic>>> getCurrentUser();
}
```

**Data Source Interface & Implementation:**

```dart
// Interface
abstract class IAuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<UserModel> getCurrentUser();
}

// Implementation
@LazySingleton(as: IAuthRemoteDataSource)
class AuthRemoteDataSourceImpl extends BaseRemoteDataSource
    implements IAuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiService);
  final AuthApiService _apiService;

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) =>
      execute(() async {
        final response = await _apiService.login(request.toJson());
        return AuthResponseModel.fromJson(response.body!);
      });
}
```

**Note:** `BaseRemoteDataSource.execute()` handles HTTP errors via Chopper interceptors.

### Local Data Source (Database)

```dart
@injectable
abstract class IProductLocalDataSource {
  Future<List<ProductModel>?> getCachedProducts();
  Future<void> cacheProducts(List<ProductModel> products);
  Stream<List<ProductModel>> watchProducts();
}

@Injectable(as: IProductLocalDataSource)
class ProductLocalDataSourceImpl implements IProductLocalDataSource {
  final AppDatabase _database;
  
  ProductLocalDataSourceImpl(this._database);
  
  @override
  Future<List<ProductModel>?> getCachedProducts() async {
    final rows = await _database.select(_database.products).get();
    return rows.map((row) => ProductModel.fromDrift(row)).toList();
  }
  
  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    await _database.transaction(() async {
      await _database.delete(_database.products).go();
      for (final product in products) {
        await _database.into(_database.products).insert(product.toDrift());
      }
    });
  }
}
```

## Models (DTOs)

### Model Structure

**Example from auth feature:**

```dart
// lib/features/auth/infrastructure/models/user_model.dart
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required bool isEmailVerified,
  }) = _UserModel;
  const UserModel._();

  /// Creates model from JSON (from API response).
  factory UserModel.fromJson(Json json) => _$UserModelFromJson(json);

  /// Converts model to domain entity.
  ///
  /// Uses `fromTrustedSource` since data comes from authenticated backend.
  /// Note: User entity contains only auth identity; profile info is in UserProfile.
  User toDomain() {
    return User(
      id: UserId.fromString(id),
      email: EmailAddress.fromTrustedSource(email),
      isEmailVerified: isEmailVerified,
    );
  }

  /// Creates model from domain entity (for API requests).
  factory UserModel.fromDomain(User user) {
    return UserModel(
      id: user.id.value,
      email: user.email.getOrCrash(),
      isEmailVerified: user.isEmailVerified,
    );
  }
}
```

### Model Conversion Rules

- ✅ **DO**: Use `freezed` with JSON serialization
- ✅ **DO**: Provide `toDomain()` method
- ✅ **DO**: Provide `fromDomain()` factory
- ✅ **DO**: Handle null/optional fields gracefully
- ✅ **DO**: Match API response structure exactly
- ❌ **DON'T**: Include business logic
- ❌ **DON'T**: Let domain entities know about DTOs

## Folder Structure

**Example from auth feature:**

```text
infrastructure/
├── datasources/
│   ├── auth_api_service.dart           # Chopper API service
│   ├── auth_api_service.chopper.dart   # Generated code
│   ├── auth_endpoints.dart             # Endpoint constants
│   ├── auth_remote_data_source.dart    # Remote data source interface & impl
│   └── token_storage_impl.dart         # Token storage implementation
├── mappers/
│   └── auth_failure_mapper.dart        # Maps HTTP errors to AuthFailure
├── models/
│   ├── user_model.dart                 # User DTO
│   ├── auth_response_model.dart        # Login/Register response DTO
│   ├── auth_tokens_model.dart          # Access/Refresh tokens DTO
│   ├── login_request_model.dart        # Login request DTO
│   └── register_request_model.dart     # Register request DTO
└── repositories/
    └── auth_repository_impl.dart       # IAuthRepository implementation
```

## Exception Handling

- Convert all exceptions to domain Failures
- Never let exceptions escape to presentation layer
- Log errors before converting to Failures
