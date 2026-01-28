# Layer Architecture & Dependency Rules

## Hexagonal Architecture Principles

### The Dependency Rule (SACRED)

Dependencies MUST ONLY point inward

```text
Presentation → Application → Domain ← Infrastructure
     ↓              ↓           ↑          ↑
   core/      core/domain    core/    core/api
```

### Layer Responsibilities

#### Domain Layer (Innermost - The Hexagon Core)

- **Purpose**: Pure business logic and rules
- **Contains**: Entities, Value Objects, Repository Interfaces, and Ports (Core Interfaces)
- **Dependencies**: ONLY `core/domain/` - nothing else
- **NEVER**: Import Flutter, infrastructure, or presentation code
- **NEVER**: Contain serialization logic (no toJson/fromJson)

#### Application Layer (Orchestration)

- **Purpose**: Coordinate business workflows
- **Contains**: Use Cases (Interactors)
- **Dependencies**: Domain layer, `core/domain/`
- **NEVER**: Import infrastructure or presentation layers
- **NEVER**: Contain UI logic or data access implementation

#### Infrastructure Layer (Driven Adapters)

- **Purpose**: Implement domain interfaces for external systems
- **Contains**: Repository implementations, Data Sources, Models (DTOs)
- **Dependencies**: Domain interfaces ONLY (for contracts)
- **MUST**: Implement repository interfaces defined in domain
- **MUST**: Handle all serialization/deserialization

#### Presentation Layer (Driving Adapters)

- **Purpose**: Display UI and manage UI state
- **Contains**: Pages, Widgets, BLoCs/Cubits
- **Dependencies**: Application layer (use cases), Domain entities
- **NEVER**: Import infrastructure layer directly
- **NEVER**: Contain business logic (delegate to BLoCs and use cases)

## Dependency Inversion

### Ports (Interfaces)

- Defined in Domain layer
- Abstract contracts for external dependencies
- Named with `I` prefix: `IAuthRepository`, `ITokenStorage`

**Example from auth domain:**

```dart
// lib/features/auth/domain/repositories/i_auth_repository.dart
abstract class IAuthRepository {
  FutureResult<User> login(AuthCredentials credentials);
  FutureResult<User> register(AuthCredentials credentials);
  FutureResult<User?> getCurrentUser();
  // ... more methods
}
```

### Adapters (Implementations)

- Concrete implementations in Infrastructure layer
- Satisfy port contracts
- Named with `Impl` suffix: `AuthRepositoryImpl`
- Injected via dependency injection with `@LazySingleton(as: Interface)`

**Example from auth infrastructure:**

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

  @override
  FutureResult<User> login(AuthCredentials credentials) => execute(
    () async {
      final result = await _remoteDataSource.login(/* ... */);
      await _tokenStorage.saveTokens(/* ... */);
      return result.user.toDomain(); // DTO → Entity
    },
  );
}
```

## Real-World Example: Auth Feature

### Domain Layer (Port)

```dart
// Only depends on core/domain
import 'package:starter_app/core/domain/value_objects/email_address.dart';
import 'package:starter_app/features/auth/domain/entities/user.dart';

abstract class IAuthRepository {
  FutureResult<User> login(AuthCredentials credentials);
}
```

### Infrastructure Layer (Adapter)

```dart
// Implements domain port, uses external systems
import 'package:starter_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:starter_app/features/auth/infrastructure/datasources/auth_remote_data_source.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;

  @override
  FutureResult<User> login(AuthCredentials credentials) {
    // Maps domain types → DTOs → API call → DTOs → domain types
  }
}
```

### Application Layer (Use Case)

```dart
// Uses domain port (injected via DI)
import 'package:starter_app/features/auth/domain/repositories/i_auth_repository.dart';

@injectable
class Login {
  final IAuthRepository _repository;

  FutureResult<User> call(AuthCredentials credentials) {
    return _repository.login(credentials);
  }
}
```

### Presentation Layer (BLoC)

```dart
// Calls use case, never touches infrastructure
import 'package:starter_app/features/auth/application/usecases/login.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login _login;

  Future<void> _onLoginSubmitted(event, emit) async {
    final result = await _login(event.credentials);
    result.fold(
      (failure) => emit(state.copyWith(error: ErrorModel.fromFailure(failure))),
      (user) => emit(AuthState.authenticated(user)),
    );
  }
}
```

## Enforcement

- Use import linter to enforce dependency rules
- Code review must verify no dependency rule violations
- Domain layer must have ZERO external dependencies except:
  - `fpdart` - for Either, Option, and other functional types
  - `flutter/foundation.dart` - for `@immutable` annotation only

