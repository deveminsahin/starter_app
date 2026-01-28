# Failure Handling Architecture

A **Clean Architecture** compliant system for handling and displaying errors.

## Architecture Overview

This system follows **Hexagonal/Clean Architecture**, **DDD**, and **SOLID** principles:

```text
┌─────────────────────────────────────────────┐
│ UI Layer (Widgets)                          │
│ - Uses ErrorModel + FailureMessageService   │
│ - Has BuildContext for localization         │
└─────────────────┬───────────────────────────┘
                 │
┌─────────────────▼───────────────────────────┐
│ Presentation Layer (BLoC/Cubit)             │
│ - ADAPTER between domain and UI             │
│ - Maps Failure → ErrorModel                 │
│ - Keeps domain layer free of BuildContext   │
└─────────────────┬───────────────────────────┘
                 │
┌─────────────────▼───────────────────────────┐
│ Application Layer (Use Cases)               │
│ - Returns Either<Failure, T>                │
│ - No knowledge of presentation              │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┘
│ Domain Layer (Entities, Failures)           │
│ - Pure business logic                       │
│ - Framework agnostic                        │
│ - No BuildContext, no Flutter               │
└─────────────────────────────────────────────┘
```

## Flow: Domain → Presentation → UI

### 1. Domain Layer: Pure Failures

```dart
// lib/features/auth/domain/failure/auth_failure.dart
@freezed
class AuthFailure extends Failure with _$AuthFailure {
  const factory AuthFailure.unauthorized() = Unauthorized;
  const factory AuthFailure.forbidden() = Forbidden;

  @override
  bool get isRetryable => false;
}
```

### 2. Presentation Layer: Failure Mapper

```dart
// Feature-local mapper (example)
// Named *MessageMapper to avoid conflict with infrastructure mapper
@injectable
class AuthFailureMessageMapper extends FailureMessageMapper {
  @override
  bool canHandle(Failure failure) => failure is AuthFailure;

  @override
  String map(BuildContext context, Failure failure) {
    final authFailure = failure as AuthFailure;
    return authFailure.map(
      unauthorized: (_) => context.l10n.authUnauthorized,
      forbidden: (_) => context.l10n.authForbidden,
    );
  }
}
```

### 3. BLoC: Maps at Adapter Boundary

```dart
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._login,
    this._logger,
  ) : super(
          AuthState.initial(
            email: EmailAddress(''),
            isSubmitting: false,
            validation: FieldValidationState.initial(),
          ),
        );

  final Login _login;
  final AppLogger _logger;

  Future<void> _onLogin(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    // ...
    final result = await _login(credentials);

    result.fold(
      (failure) {
        // Map domain failure to presentation model HERE (no BuildContext)
        final error = ErrorModel.fromFailure(failure);
        emit(state.copyWith(error: error));
      },
      (user) => add(AuthEvent.authUserChanged(user)),
    );
  }
}
```

### 4. State: Contains View Model

```dart
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.unauthenticated({
    required EmailAddress email,
    ErrorModel? error,  // ← Presentation model, NOT domain Failure
  }) = Unauthenticated;
}
```

### 5. UI: Displays Message

```dart
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state.error != null) {
      // Get localized message (BuildContext available here!)
      // Use getIt to retrieve the service singleton
      final service = getIt<FailureMessageService>();
      final message = state.error!.getMessage(context, service);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: state.error!.isRetryable
              ? SnackBarAction(label: 'Retry', onPressed: _retry)
              : null,
        ),
      );
    }
  },
)
```

## Adding a New Feature

### Example: Profile Feature

### Step 1: Create Domain Failure

```dart
// lib/features/profile/domain/failure/profile_failure.dart
@freezed
class ProfileFailure extends Failure with _$ProfileFailure {
  const factory ProfileFailure.notFound() = ProfileNotFound;
  const factory ProfileFailure.updateFailed() = ProfileUpdateFailed;

  @override
  bool get isRetryable => map(
    notFound: (_) => false,
    updateFailed: (_) => true,
  );
}
```

### Step 2: Create Presentation Mapper

```dart
// Feature-local mapper (example)
@injectable
class ProfileFailureMapper extends FailureMessageMapper {
  @override
  bool canHandle(Failure failure) => failure is ProfileFailure;

  @override
  String map(BuildContext context, Failure failure) {
    final profileFailure = failure as ProfileFailure;
    return profileFailure.map(
      notFound: (_) => context.l10n.profileNotFound,
      updateFailed: (_) => context.l10n.profileUpdateFailed,
    );
  }
}
```

### Step 3: Run Code Generator

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 4: Use in BLoC

```dart
@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._updateProfile, this._logger);

  final UpdateProfile _updateProfile;
  final AppLogger _logger;

  void _onUpdate(event, emit) async {
    final result = await _updateProfile(data);

    result.fold(
      (failure) {
        final error = ErrorModel.fromFailure(failure);
        emit(state.copyWith(error: error));
      },
      (profile) => emit(state.copyWith(profile: profile)),
    );
  }
}
```

**That's it!** No changes to core failure infrastructure, and the domain
layer remains free of `BuildContext` and localization details.

## Why This Approach?

### ✅ Clean Architecture Compliance

**Domain Layer:**

- ✅ Pure Dart, no Flutter dependencies
- ✅ No `BuildContext` in domain
- ✅ Failures are business concepts

**Application Layer:**

- ✅ Returns `Either<Failure, T>`
- ✅ No knowledge of presentation

**Presentation Layer (BLoC):**

- ✅ Acts as **Adapter** between domain and UI
- ✅ Maps domain failures to view models
- ✅ State contains presentation-ready data

**UI Layer:**

- ✅ Just displays data from state
- ✅ No knowledge of domain failures
- ✅ Has `BuildContext` for localization

### ✅ SOLID Principles

**Open/Closed:**

- Core code never changes when adding features
- Each feature owns its mapper

**Dependency Inversion:**

- Core defines mapper interface
- Features implement interface
- BLoC depends on abstractions

**Single Responsibility:**

- Domain: Business rules
- Mapper: Translation logic
- BLoC: Coordination
- UI: Display

### ✅ Dependency Injection

Failure message mappers are automatically discovered and injected into
`FailureMessageService`, which caches them for O(1) lookup:

```dart
@LazySingleton()
class FailureMessageService {
  FailureMessageService(this._mappers, this._logger);

  final List<FailureMessageMapper> _mappers;
  final AppLogger _logger;

  String getLocalizedMessage(BuildContext context, Failure failure) {
    // ...
  }
}
```

## Comparison: Before vs After

### ❌ Before (Leaky Abstraction)

```dart
// Domain Failure in State
const factory AuthState.error({
  Failure? failure,  // ← WRONG: Domain leaking into presentation
});

// UI has to know about domain
BlocListener(
  listener: (context, state) {
    if (state.failure != null) {
      // UI dealing with domain objects!
      final message = _mapFailure(context, state.failure);
    }
  },
)
```

### ✅ After (Clean Separation)

```dart
// Presentation View Model in State
const factory AuthState.error({
  ErrorModel? error,  // ← RIGHT: Presentation model
});

// BLoC maps at boundary (no BuildContext)
result.fold(
  (failure) => emit(
    state.copyWith(
      error: ErrorModel.fromFailure(failure),
    ),
  ),
);

// UI just displays, using FailureMessageService
BlocListener(
  listener: (context, state) {
    if (state.error != null) {
      final service = context.read<FailureMessageService>();
      final message = state.error!.getMessage(context, service);
    }
  },
)
```

## Key Files

**Core:**

- `lib/core/error/failures/failure.dart` - Base failure interface
- `lib/core/presentation/failure_message/failure_message_mapper.dart` - Mapper interface
- `lib/core/presentation/services/failure_message_service.dart` - Localized message service
- `lib/core/presentation/models/error_model.dart` - Presentation model

**Infrastructure:**

- `lib/core/presentation/failure_message/infrastructure_failure_mapper.dart` - Infrastructure failure mapper

**Features (Example: Auth):**

- `lib/features/auth/domain/...` - Feature-specific failures
- `lib/features/auth/presentation/bloc/auth_state.dart` - State with `ErrorModel`
- `lib/features/auth/presentation/bloc/auth_bloc.dart` - BLoC that creates `ErrorModel` from `Failure`

## Testing

**Mapper Tests:**

```dart
test('AuthFailureMapper maps unauthorized correctly', () {
  final mapper = AuthFailureMapper();
  final failure = AuthFailure.unauthorized();

  expect(mapper.canHandle(failure), isTrue);
  expect(mapper.map(context, failure), equals('Unauthorized'));
});
```

**BLoC Tests:**

```dart
blocTest<AuthBloc, AuthState>(
  'emits error when login fails',
  build: () => AuthBloc(mockLogin, [AuthFailureMapper()]),
  act: (bloc) => bloc.add(LoginSubmitted()),
  expect: () => [
    predicate<AuthState>((s) => s.error != null),
  ],
);
```

## Summary

This architecture ensures:

- **Domain layer** remains pure (no Flutter, no BuildContext)
- **BLoC/Adapter** handles translation at the boundary
- **UI** receives presentation-ready data
- **Features** are independent and auto-discovered
- **Core** never changes when adding features

Perfect compliance with Clean Architecture, Hexagonal Architecture, DDD, and SOLID.
