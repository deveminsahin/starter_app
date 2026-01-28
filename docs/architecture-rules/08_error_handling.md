# Error Handling Rules

## Core Principles

- NEVER use exceptions for business logic flow
- Use `FutureResult<T>` (alias for `Future<Either<Failure, T>>`) for all operations that can fail
- All errors are represented as explicit Failure types
- Domain failures are separate from technical failures

## Either Type Pattern

### Basic Usage

```dart
// Function that can fail (using FutureResult type alias)
FutureResult<Product> getProduct(String id) async {
  try {
    final product = await _api.fetchProduct(id);
    return Right(product); // Success
  } catch (e) {
    return Left(InfrastructureFailure.server(message: e.toString())); // Failure
  }
}

// Handling the result
final result = await getProduct('123');
result.fold(
  (failure) => print('Error: $failure'), // uses toString()
  (product) => print('Success: ${product.name}'),
);
```

### Chaining Operations

```dart
FutureResult<Order> createOrder(OrderData data) async {
  return (await validateOrderData(data))
      .flatMap((validData) => checkInventory(validData))
      .flatMap((checkedData) => processPayment(checkedData))
      .flatMap((paidData) => saveOrder(paidData));
}
```

## Failure Types

### Failure Hierarchy

```text
Failure (abstract) - pure marker interface, no message
├── TechnicalFailure (abstract) - adds isRetryable, stackTrace
│   ├── InfrastructureFailure - server, network, cache errors
│   └── AuthFailure - authentication/authorization errors
└── ValueFailure<T> (abstract) - domain validation errors
    ├── PasswordFailure - password requirements
    ├── EmailFailure - email format/length
    ├── NameFailure - name validation
    ├── TokenFailure - token validation
    └── UniqueIdFailure - ID validation
```

### Base Failure Interface

```dart
// core/error/failures/failure.dart
/// Base interface - pure marker, no message getter.
/// Use toString() for logging, FailureMessageService for UI.
abstract class Failure {
  const Failure();
}
```

### TechnicalFailure Base

```dart
// core/error/failures/technical_failure.dart
abstract class TechnicalFailure extends Failure {
  const TechnicalFailure();

  /// Returns true if this failure type can be retried.
  bool get isRetryable;

  /// Original stack trace for debugging purposes.
  StackTrace? get stackTrace;
}
```

### Infrastructure Failures

```dart
// core/error/failures/infrastructure_failures.dart
@freezed
class InfrastructureFailure extends TechnicalFailure with _$InfrastructureFailure {
  const InfrastructureFailure._();

  const factory InfrastructureFailure.server({
    required String message,
    int? statusCode,
    StackTrace? stackTrace,
  }) = ServerFailure;

  const factory InfrastructureFailure.network({
    @Default('No internet connection') String message,
    StackTrace? stackTrace,
  }) = NetworkFailure;

  const factory InfrastructureFailure.cache({
    @Default('Cache operation failed') String message,
    StackTrace? stackTrace,
  }) = CacheFailure;

  const factory InfrastructureFailure.unexpected({
    required String message,
    StackTrace? stackTrace,
  }) = UnexpectedFailure;

  @override
  bool get isRetryable => when(
    server: (_, _, _) => true,
    network: (_, _) => true,
    cache: (_, _) => true,
    unexpected: (_, _) => false,
  );
}
```

### Feature-Specific Failures

Each feature should define its own failure types to represent business logic errors specific to that domain. This ensures decoupling and precision.

```dart
// features/auth/domain/failures/auth_failure.dart
@freezed
class AuthFailure extends TechnicalFailure with _$AuthFailure {
  const AuthFailure._();

  const factory AuthFailure.unauthorized({
    required String message,
    StackTrace? stackTrace,
  }) = _Unauthorized;

  const factory AuthFailure.forbidden({
    required String message,
    StackTrace? stackTrace,
  }) = _Forbidden;

  const factory AuthFailure.notFound({
    required String message,
    StackTrace? stackTrace,
  }) = _NotFound;

  // message is a constructor parameter, not an override
  // Freezed provides toString() automatically

  @override
  bool get isRetryable => false;
}
```

### Rules

- ✅ **DO**: Use union types for different failure scenarios
- ✅ **DO**: Include context information in failures
- ✅ **DO**: Make failures serializable for persistence
- ❌ **DON'T**: Use generic Exception classes
- ❌ **DON'T**: Include stack traces in domain failures

## Value Object Failures

### ValueFailure Base Class

```dart
// core/error/failures/value_failure.dart
/// Abstract base class for all domain validation failures.
abstract class ValueFailure<T> extends Failure {
  const ValueFailure();
}
```

### Domain-Specific Failure Types

Each value object has its own specific failure type for precise error handling:

**PasswordFailure:**
```dart
@freezed
class PasswordFailure extends ValueFailure<String> with _$PasswordFailure {
  const factory PasswordFailure.empty() = PasswordEmpty;
  const factory PasswordFailure.tooShort({required int minLength, required int actualLength}) = PasswordTooShort;
  const factory PasswordFailure.tooLong({required int maxLength, required int actualLength}) = PasswordTooLong;
  const factory PasswordFailure.missingUppercase() = PasswordMissingUppercase;
  const factory PasswordFailure.missingLowercase() = PasswordMissingLowercase;
  const factory PasswordFailure.missingDigit() = PasswordMissingDigit;
  const factory PasswordFailure.missingSpecialCharacter() = PasswordMissingSpecialCharacter;
}
```

**EmailFailure:**
```dart
@freezed
class EmailFailure extends ValueFailure<String> with _$EmailFailure {
  const factory EmailFailure.empty() = EmailEmpty;
  const factory EmailFailure.tooLong({required int maxLength, required int actualLength}) = EmailTooLong;
  const factory EmailFailure.invalidFormat({required String failedValue}) = EmailInvalidFormat;
}
```

**NameFailure:**
```dart
@freezed
class NameFailure extends ValueFailure<String> with _$NameFailure {
  const factory NameFailure.empty() = NameEmpty;
}
```

### Usage in Value Objects

**Value objects return `Either<List<ValueFailure<T>>, T>` with domain-specific failures:**

```dart
// core/domain/value_objects/password.dart
final class Password extends ValueObject<String> {
  factory Password(String? input) => Password._(_validatePassword(input));

  const Password._(this.value);

  @override
  final Either<List<ValueFailure<String>>, String> value;

  static Either<List<ValueFailure<String>>, String> _validatePassword(String? input) {
    if (input == null || input.isEmpty) {
      return left([const PasswordFailure.empty()]);
    }

    final failures = <PasswordFailure>[];

    if (input.length < minLength) {
      failures.add(PasswordFailure.tooShort(minLength: minLength, actualLength: input.length));
    }

    if (!_uppercaseRegex.hasMatch(input)) {
      failures.add(const PasswordFailure.missingUppercase());
    }

    // ... other validations

    if (failures.isNotEmpty) return left(failures);
    return right(input);
  }
}
```

**Pattern matching for localized messages:**
```dart
final message = failure.when(
  empty: () => context.l10n.passwordEmpty,
  tooShort: (min, actual) => context.l10n.passwordTooShort(min),
  missingUppercase: () => context.l10n.passwordMissingUppercase,
  // ...
);
```

## Exception to Failure Mapping

### Infrastructure Layer

```dart
@LazySingleton(as: IProductRepository)
class ProductRepositoryImpl extends BaseRepository implements IProductRepository {
  ProductRepositoryImpl(
    this._remoteDataSource,
    ExceptionHandler exceptionHandler,
    ProductFailureMapper failureMapper,
  ) : super(exceptionHandler, failureMapper);

  final IProductRemoteDataSource _remoteDataSource;

  @override
  FutureResult<Product> getProduct(String id) => execute(
    () async {
      final model = await _remoteDataSource.getProduct(id);
      return model.toDomain();
    },
  );
}
```

**Note**: `BaseRepository.execute()` automatically handles exception-to-failure mapping using the injected `ExceptionHandler` and `FailureMapper`.

### General Rules

- ✅ **DO**: Catch specific exceptions first
- ✅ **DO**: Log unexpected errors before mapping
- ✅ **DO**: Provide context in failures
- ✅ **DO**: Map all exceptions to domain failures
- ❌ **DON'T**: Let exceptions escape repositories
- ❌ **DON'T**: Expose technical details in failure messages

## Presentation Layer Error Handling

**IMPORTANT**: Domain Failures must be mapped to `ErrorModel` at the BLoC boundary. UI should never handle domain Failures directly.

### Architecture Flow

```text
Domain Failure → BLoC (maps to ErrorModel) → State (contains ErrorModel) → UI (displays message)
```

### BLoC: Mapping Failures to ErrorModel

**Example from auth feature:**

```dart
// In BLoC event handler
final result = await _login(credentials);

result.fold(
  (failure) => emit(
    s.copyWith(
      isSubmitting: false,
      error: ErrorModel.fromFailure(failure), // ← Map at boundary
    ),
  ),
  (user) => emit(AuthState.authenticated(user)),
);
```

### UI: Displaying ErrorModel

**Example from AuthPage:**

```dart
// In BLoC Listener
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) async {
    final error = state.mapOrNull(
      initial: (s) => s.error,
      loginRequired: (s) => s.error,
      registrationRequired: (s) => s.error,
    );

    if (error != null) {
      final messageService = context.read<FailureMessageService>();
      final message = error.getMessage(context, messageService);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: error.isRetryable
              ? SnackBarAction(
                  label: context.l10n.retry,
                  onPressed: () => _retryLastAction(context),
                )
              : null,
        ),
      );
    }
  },
  builder: (context, state) {
    // Build UI
  },
)
```

### Creating Feature-Specific Failure Mappers

Example: AuthFailureMapper

```dart
// lib/features/auth/presentation/failure_message/auth_failure_mapper.dart
@injectable
class AuthFailureMapper extends FailureMessageMapper {
  @override
  bool canHandle(Failure failure) => failure is AuthFailure;

  @override
  String map(BuildContext context, Failure failure) {
    return (failure as AuthFailure).map(
      unauthorized: (_) => context.l10n.authUnauthorized,
      forbidden: (_) => context.l10n.authForbidden,
      notFound: (_) => context.l10n.authNotFound,
    );
  }
}
```

**Note**: Mappers are automatically discovered and injected via `@injectable`. See `20_failure_handling_architecture.md` for complete details.

### Error Widgets

```dart
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.failure,
    required this.failureMessageService,
    this.onRetry,
    super.key,
  });
  
  final Failure failure;
  final FailureMessageService failureMessageService;
  final VoidCallback? onRetry;
  
  @override
  Widget build(BuildContext context) {
    // Get localized message via service
    final message = failureMessageService.getLocalizedMessage(context, failure);
    final isRetryable = failure is TechnicalFailure && 
        (failure as TechnicalFailure).isRetryable;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIcon(failure),
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message, // Uses FailureMessageService for localized messages
            textAlign: TextAlign.center,
            style: TextTheme.of(context).bodyLarge,
          ),
          if (onRetry != null && isRetryable) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
  
  IconData _getIcon(Failure failure) {
    if (failure is InfrastructureFailure) {
      return failure.when(
        server: (_, _, _) => Icons.error_outline,
        network: (_, _) => Icons.wifi_off,
        cache: (_, _) => Icons.storage,
        parse: (_, _) => Icons.error_outline,
        circuitBreaker: (_, _) => Icons.block,
      );
    }
    return Icons.warning;
  }
}
```

## TaskEither for Async Operations

### Advanced Usage

```dart
TaskEither<Failure, Product> getProductTask(String id) {
  return TaskEither.tryCatch(
    () => _api.fetchProduct(id),
    (error, stack) {
      if (error is ServerException) {
        return Failure.server(message: error.message);
      }
      return Failure.unexpected(message: error.toString());
    },
  );
}

// Chaining multiple async operations
TaskEither<Failure, Order> createOrderTask(OrderData data) {
  return validateOrderDataTask(data)
      .flatMap(checkInventoryTask)
      .flatMap(processPaymentTask)
      .flatMap(saveOrderTask);
}
```

## Logging Errors

### Error Logger

```dart
@singleton
class ErrorLogger {
  final Logger _logger;
  final SentryClient? _sentry;
  
  ErrorLogger(this._logger, this._sentry);
  
  void logFailure(
    Failure failure, {
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    // Use toString() for logging - Freezed provides descriptive output
    _logger.error('Failure: $failure', failure, stackTrace);
    
    // Send to error tracking service for technical failures only
    if (failure is InfrastructureFailure) {
      failure.when(
        server: (msg, statusCode, _) => _sentry?.captureException(
          ServerException(message: msg, statusCode: statusCode),
          stackTrace: stackTrace,
        ),
        network: (_, __) => {}, // Don't send network errors to Sentry
        cache: (_, __) => {},
        parse: (msg, _) => _sentry?.captureException(
          FormatException(msg),
          stackTrace: stackTrace,
        ),
        circuitBreaker: (_, __) => {},
      );
    }
  }
}
```
