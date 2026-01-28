# ADR-0010: CQRS with Command/Query Base Classes

## Status

Accepted

## Context

Use cases in Clean Architecture often mix read and write operations.
This leads to:
- Unclear intent
- Harder testing
- Difficult optimization (reads vs writes have different needs)

## Decision

I adopt **CQRS (Command Query Responsibility Segregation)** with explicit base classes.

### Command/Query Hierarchy

```
UseCase (abstract)
├── Command<Params, Output>        # Write with params
├── CommandNoParams<Output>        # Write without params
├── Query<Params, Output>          # Read with params
├── QueryNoParams<Output>          # Read without params
├── StreamCommand<Params, Output>  # Reactive write
├── StreamQuery<Params, Output>    # Reactive read
└── ...NoParams variants
```

### Implementation

```dart
// Command - mutates state
@injectable
class Login extends Command<LoginParams, User> {
  const Login(this._repository);
  final IAuthRepository _repository;

  @override
  FutureResult<User> call(LoginParams params) =>
      _repository.login(params.email, params.password);
}

// Query - reads state (no mutation)
@injectable
class GetUserProfile extends Query<UserId, UserProfile> {
  const GetUserProfile(this._repository);
  final IProfileRepository _repository;

  @override
  FutureResult<UserProfile> call(UserId userId) =>
      _repository.getProfile(userId);
}
```

See: `lib/core/domain/base/command.dart`, `lib/core/domain/base/query.dart`

### Naming Conventions

| Type | Naming | Example |
|------|--------|---------|
| Command | Verb (imperative) | `Login`, `UpdateProfile`, `DeleteUser` |
| Query | `Get*`, `Fetch*`, `Watch*` | `GetUser`, `WatchAuthState` |

## Consequences

### Positive
- **Clear intent**: Command = write, Query = read
- **Optimization**: Cache queries, throttle commands
- **Testability**: Test reads/writes separately
- **Type safety**: `FutureResult<T>` consistent return type

### Negative
- **More base classes**: Command, Query, StreamCommand, etc.
- **Classification effort**: Must decide command vs query

### Neutral
- BLoC events trigger commands/queries
- All return `FutureResult<T>` or `StreamResult<T>`
