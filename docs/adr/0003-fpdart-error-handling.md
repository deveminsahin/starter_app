# ADR-0003: fpdart for Functional Error Handling

## Status

Accepted

## Context

Error handling in Dart applications typically uses exceptions:

```dart
// Traditional approach
try {
  final user = await repository.login(email, password);
  return user;
} catch (e) {
  // Handle error
}
```

Problems with exception-based error handling:
1. **Hidden control flow**: Exceptions can be thrown anywhere, caught anywhere
2. **No compile-time safety**: Caller may forget to handle exceptions
3. **Mixing concerns**: Business errors mixed with runtime exceptions
4. **Testing complexity**: Must test try/catch paths

I needed an error handling approach that:
1. Makes errors explicit in the type system
2. Forces callers to handle both success and failure
3. Separates business failures from unexpected exceptions
4. Enables clean, composable error handling

## Decision

I adopt **fpdart** for functional error handling using the `Either` type.

### Implementation Pattern

```dart
// Repository returns FutureResult<T> (typedef for Future<Either<Failure, T>>)
// See lib/core/types/ for type definitions
FutureResult<User> login(EmailAddress email, Password password);

// Use case propagates the Either using FutureResult typedef (see lib/core/types/)
class Login extends Command<LoginParams, User> {
  @override
  FutureResult<User> execute(LoginParams params) async {
    return _repository.login(params.email, params.password);
  }
}

// BLoC handles both cases - maps Failure to ErrorModel at boundary
final result = await _loginUseCase(params);
result.fold(
  (failure) => emit(AuthState.error(ErrorModel.fromFailure(failure))),
  (user) => emit(AuthState.authenticated(user)),
);
```

### Error Type Hierarchy

```
Either<Failure, T>
       │
       ├── InfrastructureFailure (network, storage, parsing)
       │   ├── server
       │   ├── network  
       │   ├── cache
       │   └── unexpected
       │
       └── Feature-specific failures
           ├── AuthFailure
           ├── ProfileFailure
           └── ...
```

### Exception Boundary

Exceptions are caught at the Infrastructure layer and converted to Failures:

```dart
class ExceptionHandler {
  FutureResult<T> handle<T>({required Future<T> Function() operation}) async {
    try {
      return Right(await operation());
    } on ServerException catch (e) {
      return Left(InfrastructureFailure.server(message: e.message));
    } on NetworkException catch (e) {
      return Left(InfrastructureFailure.network(message: e.message));
    }
  }
}
```

## Consequences

### Positive

- **Explicit Errors**: Return type shows function can fail
- **Compile-time Safety**: Must handle `Left` case to get value
- **Composability**: Chain operations with `flatMap`, `map`
- **Testability**: Test success and failure paths easily
- **Clean BLoCs**: No try/catch, just `fold`

### Negative

- **Learning Curve**: Functional programming concepts required
- **Verbosity**: `Either<Failure, T>` in signatures
- **Third-party Dependency**: Relies on fpdart package

### Neutral

- Exceptions still used internally in Infrastructure for interop with external libraries
- Stack traces preserved in Failure for debugging

## References

- [fpdart Package](https://pub.dev/packages/fpdart)
- [Railway Oriented Programming](https://fsharpforfunandprofit.com/rop/)
