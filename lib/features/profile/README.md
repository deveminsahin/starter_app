# Profile Feature

User profile management for the starter app.

## Structure

```
lib/features/profile/
├── domain/
│   ├── entities/          # UserProfile, ProfileId
│   ├── events/            # ProfileDomainEvent
│   ├── failure/           # ProfileFailure, ProfileExceptionMapper
│   └── repositories/      # IUserProfileRepository
├── application/
│   └── usecases/          # GetProfile query
├── infrastructure/
│   ├── datasources/       # UserProfileRemoteDataSource
│   ├── mappers/           # ProfileExceptionMapper impl
│   ├── models/            # UserProfileModel
│   └── repositories/      # UserProfileRepositoryImpl
├── presentation/
│   ├── bloc/              # ProfileBloc, ProfileEvent, ProfileState
│   ├── failure_message/   # ProfileFailureMapper
│   ├── pages/             # ProfilePage
│   ├── routes/            # ProfileRoute (TypedGoRoute)
│   └── widgets/           # LoginButton, ProfileContent
├── l10n/                  # Feature-scoped localizations
└── profile.dart           # Barrel export
```

## Key Components

### Domain Layer
- **UserProfile** - Aggregate root with `displayName` (Name value object)
- **ProfileId** - Type-safe extension type wrapping UniqueId
- **ProfileFailure** - Domain failures extending `TechnicalFailure` (`isRetryable`, `stackTrace`)
- **IUserProfileRepository** - Repository interface returning `FutureResult<UserProfile>`

### Application Layer
- **GetProfile** - CQRS query (no params) delegating to repository

### Infrastructure Layer
- **UserProfileRepositoryImpl** - Uses `BaseRepository` and `ProfileExceptionMapper`
- **ProfileExceptionMapper** - Maps `ServerException` (404, 500) to `ProfileFailure`
- **UserProfileRemoteDataSource** - Uses `response.requireBody` for null safety
- **ProfileApiService** - Chopper-based API client

### Presentation Layer
- **ProfileBloc** - Listens to auth events via `IEventDispatcher`
- **ProfileFailureMapper** - Maps failures to localized user messages
- **ProfilePage** - Displays profile or login button based on auth state
- **ProfileContent** - Isolated widget for displaying profile details
- **LoginButton** - Navigation widget shown when unauthenticated

## Key Patterns

### 1. Railway-Oriented Error Handling
Returns `FutureResult<UserProfile>` (alias for `Future<Either<Failure, UserProfile>>`).
Failures are strongly typed (`ProfileFailure`) and mapped from exceptions in the infrastructure layer.

### 2. Event-Driven Architecture

The `ProfileBloc` subscribes to `AuthDomainEvent` stream:

```dart
_eventDispatcher.on<AuthDomainEvent>().listen((event) {
  final profileEvent = switch (event) {
    UserRegistered() ||
    UserLoggedIn() ||
    UserSessionRestored() => const ProfileEvent.getMyProfile(),
    UserLoggedOut() => const ProfileEvent.reset(),
  };

  add(profileEvent);
});
```

## Tests

```bash
very_good test --no-optimization test/features/profile/
```

87 tests covering all layers.

