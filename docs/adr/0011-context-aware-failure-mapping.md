# ADR-0011: Context-Aware Failure Mapping

## Status

Accepted

## Context

Error handling spans multiple layers:
1. **Infrastructure**: Catches exceptions, maps to domain failures
2. **Domain**: Defines feature-specific failure types
3. **Presentation**: Shows user-friendly messages (localized)

Challenges:
- Failures in domain layer must be framework-agnostic (no `BuildContext`)
- UI messages need localization (requires context)
- Each feature has its own failures and messages

## Decision

I adopt a **two-layer mapper pattern** with auto-registration:

### Layer 1: Exception → Failure (Infrastructure)

```dart
// lib/features/auth/infrastructure/mappers/auth_exception_mapper.dart
@injectable
class AuthExceptionMapper implements IExceptionMapper {
  @override
  Failure mapToFailure(ServerException exception) {
    return switch (exception.statusCode) {
      HttpStatus.unauthorized => AuthFailure.unauthorized(),
      HttpStatus.forbidden => AuthFailure.forbidden(),
      HttpStatus.conflict => const AuthFailure.emailAlreadyInUse(),
      _ => InfrastructureFailure.server(message: exception.message),
    };
  }
}
```

### Layer 2: Failure → UI Message (Presentation)

```dart
// lib/features/auth/presentation/failure_message/auth_failure_mapper.dart
@injectable
class AuthFailureMessageMapper extends FailureMessageMapper {
  AuthFailureMessageMapper(super.registry);  // Auto-registers!

  @override
  bool canHandle(Failure failure) => failure is AuthFailure;

  @override
  String map(BuildContext context, Failure failure) {
    final f = failure as AuthFailure;
    return f.map(
      unauthorized: (_) => context.authL10n.unauthorized,
      forbidden: (_) => context.authL10n.forbidden,
      emailAlreadyInUse: (_) => context.authL10n.emailAlreadyInUse,
    );
  }
}
```

### Auto-Registration via Registry

```dart
@singleton
class FailureMapperRegistry {
  final List<FailureMessageMapper> _mappers = [];
  
  void register(FailureMessageMapper mapper, {bool highPriority = true}) {
    highPriority ? _mappers.insert(0, mapper) : _mappers.add(mapper);
  }
}
```

Mappers register themselves in their constructor - impossible to forget!

### Flow Diagram

```
Exception
    ↓
[AuthExceptionMapper]  ← Infrastructure layer
    ↓
AuthFailure (domain)
    ↓
[AuthFailureMessageMapper]  ← Presentation layer
    ↓
"Invalid credentials" (localized string)
```

## Consequences

### Positive
- **Separation of concerns**: Domain stays framework-agnostic
- **Localized messages**: Full access to `BuildContext` and `l10n`
- **Auto-registration**: No manual list to maintain
- **Feature-first**: Each feature owns its mappers
- **Priority control**: Feature mappers override infrastructure fallbacks

### Negative
- **Two mapper layers**: More files per feature

### Neutral
- Exception mappers in infrastructure/mappers/
- Failure message mappers in presentation/failure_message/
