# ADR-0005: injectable + get_it for Dependency Injection

## Status

Accepted

## Context

Dependency Injection (DI) is essential for:
1. Decoupling components for testability
2. Managing object lifecycles (singletons, factories)
3. Swapping implementations (prod vs mock)
4. Configuring dependencies per environment

I evaluated:

| Solution | Pros | Cons |
|----------|------|------|
| **injectable + get_it** | Code generation, annotations, modular | Requires build_runner |
| **get_it alone** | Simple, no codegen | Manual registration, verbose |
| **Riverpod** | Compile-safe, no service locator | Different paradigm, not a pure DI |
| **Provider** | Flutter-native | Widget-tree coupled |

I needed:
1. Service locator pattern for Clean Architecture
2. Module-based registration for features
3. Environment-based configuration
4. Easy mocking in tests

## Decision

I adopt **injectable** with **get_it** for dependency injection.

### Implementation Pattern

```dart
// Configuration
@InjectableInit(preferRelativeImports: true)
Future<void> configureDependencies({required AppEnvironment environment}) async {
  await getIt.init(environment: environment.name);
}

// Registrations via annotations
@singleton
class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(this._dataSource, this._tokenStorage);
  
  final IAuthRemoteDataSource _dataSource;
  final ITokenStorage _tokenStorage;
}

@injectable
class Login extends Command<LoginParams, User> {
  Login(this._repository);
  final IAuthRepository _repository;
}

// Module-based registration
@module
abstract class NetworkModule {
  @singleton
  HttpClient get httpClient => HttpClient();
}
```

### Annotation Reference

| Annotation | Lifecycle | Use Case |
|------------|-----------|----------|
| `@singleton` | One instance | Repositories, services |
| `@lazySingleton` | One instance, lazy init | Heavy initializations |
| `@injectable` | New instance each time | Use cases, BLoCs |
| `@module` | Group factory methods | External dependencies |

### Environment Configuration

```dart
@Environment('development')
@Singleton(as: IApiClient)
class MockApiClient implements IApiClient {}

@Environment('production')
@Singleton(as: IApiClient)
class ProductionApiClient implements IApiClient {}
```

## Consequences

### Positive

- **Clean Registration**: Annotations instead of manual setup
- **Modular**: Features register their own dependencies
- **Environment Aware**: Different implementations per environment
- **Testable**: Easy to override dependencies in tests
- **Type Safe**: Compile-time verification of dependencies

### Negative

- **Build Step**: Requires `dart run build_runner build`
- **Service Locator**: Some consider anti-pattern (mitigated by constructor injection)

### Neutral

- Dependencies resolved at startup via `getIt`
- Tests use `getIt.registerFactory()` for mocking

## References

- [injectable Package](https://pub.dev/packages/injectable)
- [get_it Package](https://pub.dev/packages/get_it)
