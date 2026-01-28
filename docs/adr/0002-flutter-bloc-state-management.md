# ADR-0002: flutter_bloc for State Management

## Status

Accepted

## Context

Flutter applications need a state management solution. The main contenders were:

| Solution | Pros | Cons |
|----------|------|------|
| **flutter_bloc** | Predictable, testable, separation of UI/logic | Verbose, event classes |
| **Riverpod** | Compile-safe, modern, less boilerplate | Different paradigm, smaller community |
| **Provider** | Simple, Flutter-native | Limited structure, scaling issues |

I needed a solution that:
1. Enforces unidirectional data flow
2. Is highly testable without UI
3. Scales to large applications
4. Has strong community and documentation
5. Aligns with Clean Architecture principles

## Decision

I adopt **flutter_bloc** as the state management solution.

### Implementation Pattern

```dart
// Events - What happened
@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.loginRequested(String email, String password) = LoginRequested;
  const factory AuthEvent.logoutRequested() = LogoutRequested;
}

// States - Current UI state
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
}

// BLoC - Business Logic Component
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._loginUseCase) : super(const AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
  }
  
  final Login _loginUseCase;
  
  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await _loginUseCase(LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(const AuthState.unauthenticated()),
      (user) => emit(AuthState.authenticated(user)),
    );
  }
}
```

### BLoC Responsibilities

- **DO**: Transform events into states, call use cases, handle UI logic
- **DON'T**: Contain business logic, directly call repositories, manage data persistence

## Consequences

### Positive

- **Predictability**: Clear event → state flow, easy debugging
- **Testability**: BLoCs tested independently of Flutter
- **Tooling**: DevTools integration, event replay
- **Freezed Integration**: Type-safe events/states with exhaustive matching
- **Team Standards**: Consistent patterns across features

### Negative

- **Verbosity**: Event/State classes for everything
- **Boilerplate**: More files per feature (mitigated by Mason bricks)

### Neutral

- Requires `bloc_test` package for testing
- Events are explicit rather than implicit method calls

## References

- [flutter_bloc Documentation](https://bloclibrary.dev/)
- [Bloc Library](https://pub.dev/packages/flutter_bloc)
