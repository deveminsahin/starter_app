# Logging Rules

## Core Principles

- Use structured logging with consistent format
- Log at appropriate levels
- Never log sensitive data (tokens, passwords, PII)
- Use dependency injection for logger instances
- Configure different outputs per environment

## AppLogger Interface

### Abstract Interface

**Actual implementation:**

```dart
// lib/core/logging/app_logger.dart
abstract class AppLogger {
  /// Log a debug message (detailed diagnostic information).
  void debug(
    String message, {
    Map<String, dynamic>? data,
    String? tag,
  });

  /// Log an informational message (normal application events).
  void info(
    String message, {
    Map<String, dynamic>? data,
    String? tag,
  });

  /// Log a warning message (situations needing attention).
  void warning(
    String message, {
    Map<String, dynamic>? data,
    String? tag,
  });

  /// Log an error message (error events).
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
    String? tag,
  });

  /// Log a fatal error message (severe errors).
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
    String? tag,
  });
}
```

## Log Levels

### Log Level Enum

**Actual implementation:**

```dart
// lib/core/logging/models/log_level.dart
enum LogLevel {
  /// Verbose debug information for development.
  debug(0),

  /// General informational messages.
  info(1),

  /// Warning messages for potentially harmful situations.
  warning(2),

  /// Error messages for error events.
  error(3),

  /// Fatal error messages for very severe error events.
  fatal(4);

  const LogLevel(this.value);
  final int value;

  bool isEnabled(LogLevel minimumLevel) => value >= minimumLevel.value;

  String get emoji => switch (this) {
    LogLevel.debug => '🐛',
    LogLevel.info => 'ℹ️',
    LogLevel.warning => '⚠️',
    LogLevel.error => '❌',
    LogLevel.fatal => '💀',
  };
}
```

### When to Use Each Level

**Debug** (Development only):

```dart
logger.debug('User tapped button', data: {'buttonId': 'submit'});
logger.debug('Cache hit for key: $key');
```

**Info** (Production):

```dart
logger.info('User logged in', data: {'userId': user.id.value});
logger.info('Feature flag enabled: darkMode');
```

**Warning** (Production):

```dart
logger.warning('API rate limit approaching', data: {'remaining': 10});
logger.warning('Cache expired, fetching from network');
```

**Error** (Production):

```dart
logger.error('Failed to load products', error: e, stackTrace: stack);
logger.error('Network request failed', data: {'endpoint': '/api/products'});
```

**Fatal** (Production):

```dart
logger.fatal('Database initialization failed', error: e, stackTrace: stack);
logger.fatal('Critical service unavailable');
```

## Console Logger Implementation

### Actual Implementation

**ConsoleLogger with color-coded output:**

```dart
// lib/core/logging/loggers/console_logger.dart
final class ConsoleLogger implements AppLogger {
  ConsoleLogger() : _logger = Logger('StarterApp') {
    if (kDebugMode) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen(_handleLogRecord);
    }
  }

  final Logger _logger;

  void _handleLogRecord(LogRecord record) {
    if (!kDebugMode) return;

    final emoji = _getEmoji(record.level);
    final color = _getColorCode(record.level);
    const reset = '\x1B[0m';

    final buffer = StringBuffer()
      ..write('$color$emoji ')
      ..write('[${_formatTime(record.time)}] ')
      ..write(record.message)
      ..write(reset);

    developer.log(
      buffer.toString(),
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  }

  @override
  void info(String message, {Map<String, dynamic>? data, String? tag}) {
    final formattedMessage = _formatMessage(message, data, tag);
    _logger.info(formattedMessage);
  }

  String _formatMessage(
    String message,
    Map<String, dynamic>? data,
    String? tag,
  ) {
    final buffer = StringBuffer();

    if (tag != null) {
      buffer.write('[$tag] ');
    }

    buffer.write(message);

    if (data != null && data.isNotEmpty) {
      buffer.write(' | Data: $data');
    }

    return buffer.toString();
  }
}
```

**Console output format:**

``` text
ℹ️ [14:32:15.42] [AuthBloc] User logged in | Data: {userId: 123}
⚠️ [14:32:20.11] Cache miss for key: products
❌ [14:32:25.03] Failed to fetch products
  └─ Error: SocketException: Connection refused
  │  #0  ProductRepository.getProducts (package:app/...)
  │  #1  GetProducts.call (package:app/...)
```

## Usage in Classes

### Inject Logger via Constructor

```dart
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._login,
    this._logger, // ✅ Inject logger
  ) : super(const AuthState.initial());

  final Login _login;
  final AppLogger _logger;

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Login attempt started');

    final result = await _login(event.credentials);

    result.fold(
      (failure) {
        _logger.error(
          'Login failed',
          error: failure,
          data: {'reason': '$failure'}, // Use toString() for logging
        );
        emit(state.copyWith(error: ErrorModel.fromFailure(failure)));
      },
      (user) {
        _logger.info(
          'Login successful',
          data: {'userId': user.id.value},
        );
        emit(AuthState.authenticated(user));
      },
    );
  }
}
```

### Repository Logging

```dart
@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl extends BaseRepository implements IAuthRepository {
  AuthRepositoryImpl(
    this._remoteDataSource,
    this._tokenStorage,
    this._logger,
    ExceptionHandler exceptionHandler,
    AuthFailureMapper failureMapper,
  ) : super(exceptionHandler, failureMapper);

  final IAuthRemoteDataSource _remoteDataSource;
  final ITokenStorage _tokenStorage;
  final AppLogger _logger;

  @override
  FutureResult<User> login(AuthCredentials credentials) => execute(
    () async {
      _logger.debug('Logging in user');

      final result = await _remoteDataSource.login(
        LoginRequestModel(
          email: credentials.email.getOrCrash(),
          password: credentials.password.getOrCrash(),
        ),
      );

      await _tokenStorage.saveTokens(
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      );

      _logger.info('User logged in successfully');

      return result.user.toDomain();
    },
  );
}
```

### What to Log

- ✅ **DO**: Log important state changes
- ✅ **DO**: Log API calls and responses (without sensitive data)
- ✅ **DO**: Log errors with context
- ✅ **DO**: Log feature usage for analytics
- ✅ **DO**: Log performance metrics

### What NOT to Log

- ❌ **DON'T**: Log authentication tokens
- ❌ **DON'T**: Log passwords or credentials
- ❌ **DON'T**: Log PII (email, phone, address) in production
- ❌ **DON'T**: Log credit card or payment data
- ❌ **DON'T**: Log API keys or secrets
- ❌ **DON'T**: Log full request/response bodies in production

### Safe Logging Examples

```dart
// ❌ BAD - Logs sensitive data
logger.info('Login response: ${response.toJson()}'); // Contains tokens!
logger.debug('User data: $user'); // Contains email!

// ✅ GOOD - Logs safely
logger.info('Login successful', data: {'userId': user.id.value});
logger.debug('User profile loaded', data: {'hasEmail': user.email.isValid});

// ❌ BAD - Logs password
logger.debug('Login attempt', data: {
  'email': email,
  'password': password, // NEVER!
});

// ✅ GOOD - No sensitive data
logger.debug('Login attempt', data: {
  'emailDomain': email.split('@').last,
});
```

## Structured Logging

### Add Context with Data

```dart
// ✅ Structured data for easy filtering
logger.info(
  'Product purchased',
  data: {
    'productId': product.id.value,
    'price': product.price,
    'category': product.category,
    'userId': user.id.value,
  },
);

// ✅ Add tags for categorization
logger.error(
  'Payment failed',
  error: exception,
  tag: 'Payment',
  data: {
    'amount': order.total,
    'paymentMethod': 'card',
  },
);
```

### Tag Usage

```dart
// Use tags to categorize logs
logger.info('Processing order', tag: 'Order');
logger.warning('Low inventory', tag: 'Inventory');
logger.error('Payment declined', tag: 'Payment');
```

## Environment-Specific Configuration

### Configure Per Environment

```dart
@module
abstract class LoggingModule {
  @lazySingleton
  AppLogger provideAppLogger(AppEnvironment environment) {
    // ConsoleLogger for all environments
    // Console output is disabled in staging/prod via AppEnvironment check
    return ConsoleLogger();
  }
}

// Error tracking is handled separately by IErrorReporter
// See ErrorModule for SentryErrorReporter registration
```

### Debug vs Production Logging

```dart
final class ConsoleLogger implements AppLogger {
  @override
  void debug(String message, {Map<String, dynamic>? data, String? tag}) {
    // ✅ Only log debug messages in debug mode
    if (!kDebugMode) return;

    _logger.fine(_formatMessage(message, data, tag));
  }

  @override
  void info(String message, {Map<String, dynamic>? data, String? tag}) {
    // ✅ Info logs work in all modes
    _logger.info(_formatMessage(message, data, tag));
  }
}
```

## Error Logging

### Log Errors with Context

```dart
try {
  final products = await _repository.getAllProducts();
  logger.info('Products loaded', data: {'count': products.length});
} catch (e, stack) {
  logger.error(
    'Failed to load products',
    error: e,
    stackTrace: stack,
    data: {
      'timestamp': DateTime.now().toIso8601String(),
      'userId': currentUser?.id.value,
    },
  );
  rethrow;
}
```

### Error Logging Rules

- ✅ **DO**: Always include error and stackTrace parameters
- ✅ **DO**: Add contextual data
- ✅ **DO**: Log before rethrowing
- ✅ **DO**: Use appropriate log level
- ❌ **DON'T**: Swallow exceptions after logging
- ❌ **DON'T**: Log same error multiple times
- ❌ **DON'T**: Log sensitive data in errors

## Performance Logging

### Log Performance Metrics

```dart
Future<List<Product>> loadProducts() async {
  final stopwatch = Stopwatch()..start();

  try {
    final products = await _repository.getAllProducts();

    stopwatch.stop();
    logger.info(
      'Products loaded',
      data: {
        'count': products.length,
        'durationMs': stopwatch.elapsedMilliseconds,
      },
    );

    return products;
  } catch (e, stack) {
    stopwatch.stop();
    logger.error(
      'Failed to load products',
      error: e,
      stackTrace: stack,
      data: {'durationMs': stopwatch.elapsedMilliseconds},
    );
    rethrow;
  }
}
```

## Testing with Logs

### Mock Logger for Tests

```dart
class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late AuthBloc authBloc;
  late MockAppLogger mockLogger;

  setUp(() {
    mockLogger = MockAppLogger();
    authBloc = AuthBloc(mockLogin, mockLogger);
  });

  test('logs on successful login', () async {
    // Arrange
    when(() => mockLogin(any())).thenAnswer((_) async => Right(testUser));

    // Act
    authBloc.add(AuthLoginSubmitted(credentials));
    await Future.delayed(Duration.zero);

    // Assert
    verify(() => mockLogger.info(
      'Login successful',
      data: any(named: 'data'),
    )).called(1);
  });
}
```

## Logging Checklist

### Pre-Release Logging Review

- [ ] No sensitive data logged (tokens, passwords, PII)
- [ ] Appropriate log levels used
- [ ] Errors include context and stack traces
- [ ] Logger injected via DI (not instantiated directly)
- [ ] Debug logs only in debug mode
- [ ] Structured data for important events
- [ ] Tags used for categorization
- [ ] Performance metrics logged
- [ ] No excessive logging (performance impact)

### Common Logging Mistakes

- ❌ Logging tokens or passwords
- ❌ Using `print()` instead of logger
- ❌ Creating logger instances manually
- ❌ Logging in every method (too verbose)
- ❌ Not logging errors with context
- ❌ Logging same event multiple times
- ❌ Not using log levels appropriately
