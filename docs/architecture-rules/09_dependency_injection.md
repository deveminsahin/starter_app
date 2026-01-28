# Dependency Injection Rules (Injectable & GetIt)

## Core Principles

- Use constructor injection exclusively
- Never use service locator pattern in business logic
- Register interfaces, inject implementations
- Feature modules should be independently injectable

## Injectable Annotations

### Singleton (Single Instance, Lazy)

```dart
@singleton
class AppDatabase {
  // Created once when first requested
}

@lazySingleton
class NetworkInfo {
  // Created once when first requested
}
```

### Factory (New Instance Every Time)

**Example from auth feature:**

```dart
// Use case: New instance per injection
@injectable
class Login {
  const Login(this._repository);
  final IAuthRepository _repository;

  FutureResult<User> call(AuthCredentials credentials) async {
    return _repository.login(credentials);
  }
}

// BLoC: New instance per BlocProvider
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._login,
    this._register,
    this._logout,
    this._getCurrentUser,
    this._watchAuthChanges,
  ) : super(AuthState.initial(/*...*/)) {
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
  }

  final Login _login;
  final Register _register;
  // ... other use cases
}
```

### Interface Binding

**Example from auth feature:**

```dart
// Register implementation as interface
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
  FutureResult<User> login(AuthCredentials credentials) => execute(/*...*/);
}

// Inject as interface (not implementation)
@injectable
class Login {
  const Login(this._repository);
  final IAuthRepository _repository; // Interface, not AuthRepositoryImpl

  FutureResult<User> call(AuthCredentials credentials) async {
    return _repository.login(credentials);
  }
}
```

### Rules

- ✅ **DO**: Use `@singleton` for stateful services (database, cache)
- ✅ **DO**: Use `@lazySingleton` for stateless services (network, logger)
- ✅ **DO**: Use `@injectable` for BLoCs, use cases, and transient objects
- ✅ **DO**: Inject interfaces, not implementations
- ✅ **DO**: Use `as: Interface` when registering implementations
- ❌ **DON'T**: Use `@singleton` for stateful objects that shouldn't persist
- ❌ **DON'T**: Inject concrete implementations in domain/application layers

## Module Registration

### Injectable Module Definition

**Example from NetworkModule:**

```dart
// lib/core/di/modules/network_module.dart
@module
abstract class NetworkModule {
  /// Provides the main Chopper HTTP client with interceptors.
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

  /// Provides the AuthApiService from ChopperClient.
  @lazySingleton
  AuthApiService provideAuthApiService(ChopperClient client) {
    return client.getService<AuthApiService>();
  }
}
```

### Async Registration

**Example from StorageModule:**

```dart
// lib/core/di/modules/storage_module.dart
@module
abstract class StorageModule {
  /// Provides HydratedBloc storage for state persistence.
  /// @preResolve ensures async initialization completes before app starts.
  @preResolve
  @singleton
  Future<HydratedStorage> provideHydratedStorage() async {
    final storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorageDirectory.web
          : HydratedStorageDirectory((await getTemporaryDirectory()).path),
    );
    return storage;
  }

  /// Provides SharedPreferences for simple key-value storage.
  @preResolve
  @lazySingleton
  Future<SharedPreferences> provideSharedPreferences() async {
    return SharedPreferences.getInstance();
  }

  /// Provides FlutterSecureStorage for secure token storage.
  @lazySingleton
  FlutterSecureStorage provideFlutterSecureStorage() {
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }
}
```

### Async Registration Rules

- ✅ **DO**: Group related dependencies in modules
- ✅ **DO**: Use `@preResolve` for async initialization
- ✅ **DO**: Keep modules focused (one responsibility)
- ✅ **DO**: Document complex dependency graphs
- ❌ **DON'T**: Mix unrelated dependencies in one module
- ❌ **DON'T**: Perform heavy operations in module methods

## Feature-Specific DI

### Feature Module Definition

**Note:** In this starter app, feature modules are not explicitly created. Instead:

- Use `@LazySingleton(as: Interface)` directly on repositories
- Use `@injectable` on use cases and BLoCs
- Core modules (NetworkModule, StorageModule) provide shared infrastructure

**If you need feature-specific modules**, follow this pattern:

```dart
// features/your_feature/di/your_feature_module.dart
@module
abstract class YourFeatureModule {
  @lazySingleton
  IYourRemoteDataSource provideRemoteDataSource(ChopperClient client) {
    return client.getService<YourApiService>();
  }
}
```

### Feature DI Rules

- ✅ **DO**: Create separate module for each feature
- ✅ **DO**: Keep feature dependencies isolated
- ✅ **DO**: Use interfaces for cross-feature dependencies
- ❌ **DON'T**: Let features depend on each other's implementations

## Configuration

### injection.dart

**Actual implementation:**

```dart
// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/app/app_environment.dart';
import 'package:starter_app/core/di/injection.config.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Configures all application dependencies using Injectable code generation.
@injectableInit
Future<void> configureDependencies(AppEnvironment environment) async =>
    getIt.init(environment: environment.name);
```

### Initialization

**Actual bootstrap pattern:**

```dart
// In main.dart or bootstrap.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies with environment
  await configureDependencies(AppEnvironment.current);

  runApp(const MyApp());
}
```

### build.yaml Configuration

```yaml
targets:
  $default:
    builders:
      injectable_generator:injectable_builder:
        options:
          auto_register: true
          # Generate for all injectable classes
```

## Environment-Specific Registration

### Environments

```dart
@Environment('dev')
@singleton
class MockAuthService implements IAuthService {
  // Mock implementation for development
}

@Environment('prod')
@singleton
class AuthService implements IAuthService {
  // Real implementation for production
}
```

### Usage

```dart
// Initialize with environment
await configureDependencies(environment: Environment.dev);
```

### Environment Rules

- ✅ **DO**: Use environments for different implementations
- ✅ **DO**: Provide mocks for development/testing
- ❌ **DON'T**: Use environments for configuration values

## Testing with DI

### Test Setup

```dart
@TestOn('vm')
void main() {
  late ProductBloc productBloc;
  late MockGetAllProducts mockGetAllProducts;
  
  setUp(() {
    // Create mocks
    mockGetAllProducts = MockGetAllProducts();
    
    // Create BLoC with mock dependency
    productBloc = ProductBloc(mockGetAllProducts);
  });
  
  tearDown(() {
    productBloc.close();
  });
  
  // Tests...
}
```

### Widget Testing with DI

```dart
testWidgets('ProductListPage displays products', (tester) async {
  // Setup mock
  final mockBloc = MockProductBloc();
  when(() => mockBloc.state).thenReturn(
    ProductState.success(products: testProducts),
  );
  
  // Provide mock via BlocProvider
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<ProductBloc>.value(
        value: mockBloc,
        child: const ProductListPage(),
      ),
    ),
  );
  
  expect(find.text('Test Product'), findsOneWidget);
});
```

### Testing Rules

- ✅ **DO**: Use constructor injection for easy testing
- ✅ **DO**: Mock dependencies, not implementations
- ✅ **DO**: Reset GetIt between integration tests
- ❌ **DON'T**: Use GetIt directly in business logic
- ❌ **DON'T**: Mock classes that shouldn't be mocked

## GetIt Direct Access (Presentation Only)

### When to Use GetIt Directly

- **ONLY** in presentation layer for BLoC creation
- Widget registration points
- Navigation setup

**Example from auth feature:**

```dart
// lib/features/auth/presentation/pages/auth_page.dart
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>()
        ..add(const AuthEvent.watchStarted()),
      child: const AuthView(),
    );
  }
}
```

### Direct GetIt Access Rules

- ✅ **DO**: Use GetIt in presentation layer for BLoC creation
- ✅ **DO**: Use GetIt in main.dart for app setup
- ❌ **DON'T**: Use GetIt in domain layer (pure logic)
- ❌ **DON'T**: Use GetIt in application layer (use cases)
- ❌ **DON'T**: Use GetIt in infrastructure layer (repositories)

## Common Patterns

### Named Dependencies

```dart
@Named('apiUrl')
@singleton
String get apiUrl => 'https://api.example.com';

@injectable
class ApiClient {
  final String _baseUrl;
  
  ApiClient(@Named('apiUrl') this._baseUrl);
}
```

### Dispose Pattern

```dart
@singleton
class DatabaseService implements Disposable {
  @override
  @disposeMethod
  void dispose() {
    // Cleanup resources
  }
}
```

## Code Generation

### Generate DI Code

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Code Generation Rules

- ✅ **DO**: Run build_runner after adding @injectable
- ✅ **DO**: Commit generated files to version control
- ✅ **DO**: Use watch mode during active development
- ❌ **DON'T**: Manually edit generated files
