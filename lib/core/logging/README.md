# Logging & Observability System

Production-grade, environment-aware logging with Sentry integration.

## 🎯 Features

- ✅ **Environment-Aware**: Console in development, Sentry in staging/production
- ✅ **Debug Mode Support**: Console logging always available in debug mode
- ✅ **Security**: Automatic sensitive data filtering (passwords, tokens, etc.)
- ✅ **Performance**: Lazy evaluation, async Sentry, non-blocking
- ✅ **Structured**: JSON-serializable log entries with metadata
- ✅ **Testable**: Interface-based design with easy mocking

---

## 📁 Architecture

```text
lib/core/logging/
├── i_app_logger.dart         # Interface (inject this)
├── models/
│   ├── log_level.dart        # Debug, Info, Warning, Error, Fatal
│   └── log_entry.dart        # Structured log model
├── loggers/
│   └── console_logger.dart   # Pretty console output (dev only)
├── LOGGING_STRATEGY.md       # Detailed strategy and architecture
└── README.md                 # Quick reference (this file)

lib/core/error/
├── sensitive_data_filter.dart # Filters sensitive keys
└── reporters/
    ├── sentry_error_reporter.dart  # Sentry implementation
    └── no_op_error_reporter.dart   # Dev no-op

lib/core/domain/ports/
├── i_error_reporter.dart     # Error tracking interface
└── i_data_filter.dart        # Data filtering interface
```

---

## 🚀 Quick Start

### 1. Inject IAppLogger

```dart
@injectable
class ProductRepository {
  final IAppLogger _logger;
  
  ProductRepository(this._logger);
  
  Future<Either<Failure, Product>> getProduct(String id) async {
    _logger.info('Fetching product', data: {'productId': id});
    
    try {
      final product = await _api.getProduct(id);
      return Right(product);
    } catch (e, stack) {
      _logger.error(
        'Failed to fetch product',
        error: e,
        stackTrace: stack,
        data: {'productId': id},
      );
      return Left(Failure.server());
    }
  }
}
```

### 2. Run with Environment

```bash
# Development (console only)
flutter run --dart-define-from-file=config/development.json

# Staging (console + Sentry)
flutter run --dart-define-from-file=config/staging.json

# Production (Sentry only in release)
flutter build apk --release --dart-define-from-file=config/production.json
```

---

## 📊 Logging Rules

| Environment | Build Mode | Console | Sentry |
|-------------|------------|---------|--------|
| Development | Debug | ✅ Yes | ❌ No |
| Development | Release | ✅ Yes | ❌ No |
| Staging | Debug | ✅ Yes | ✅ Yes |
| Staging | Release | ❌ No | ✅ Yes |
| Production | Debug | ✅ Yes | ✅ Yes |
| Production | Release | ❌ No | ✅ Yes |

---

## 🔒 Security

### Automatic Filtering

```dart
_logger.info('User login', data: {
  'email': 'user@example.com',
  'password': 'secret123',  // ← Automatically filtered
});

// Output to Sentry:
// { "email": "user@example.com", "password": "***REDACTED***" }
```

### Filtered Terms

- `password`, `token`, `authorization`, `api_key`
- `secret`, `credential`, `credit_card`
- `ssn`, `pin`, `cvv`, `card_number`

---

## 📚 Log Levels

```dart
// 🐛 Debug - Verbose information (debug mode only)
_logger.debug('Cache hit for key: $key');

// ℹ️ Info - General information
_logger.info('User logged in', data: {'userId': user.id});

// ⚠️ Warning - Potential issues
_logger.warning('API rate limit approaching', data: {'remaining': 10});

// ❌ Error - Error events
_logger.error('API call failed', error: exception, stackTrace: stack);

// 💀 Fatal - Critical errors
_logger.fatal('Database connection lost', error: error);
```

---

## 🎨 Console Output

Development console logging includes:

- **Color coding** by severity (ANSI colors)
- **Emojis** for quick scanning
- **Structured data** formatting
- **Stack traces** for errors
- **Timestamps** (HH:MM:SS.MS format)
- **Uses official Dart `logging` package** (industry standard)

Example:

```text
ℹ️ [Repository] Fetching product
  └─ Data: {productId: 123}

❌ [API] Request failed (500 Internal Server Error)
  └─ Data: {url: /api/products/123, duration: 3420ms}
  └─ Error: ServerException: Internal Server Error
  └─ Stack: #0  ProductApi.getProduct
           #1  ProductRepository.getProduct
```

---

## 🧪 Testing

```dart
import 'package:mocktail/mocktail.dart';

class MockLogger extends Mock implements IAppLogger {}

void main() {
  late MockLogger logger;
  late ProductRepository repository;
  
  setUp(() {
    logger = MockLogger();
    repository = ProductRepository(logger);
  });
  
  test('logs errors on failure', () async {
    await repository.getProduct('invalid');
    
    verify(() => logger.error(
      any(),
      error: any(named: 'error'),
      stackTrace: any(named: 'stackTrace'),
    )).called(1);
  });
}
```

---

## 🔗 Integration

### With BLoC

```dart
@injectable
class AppBlocObserver extends BlocObserver {
  final IAppLogger _logger;
  
  AppBlocObserver(this._logger);
  
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _logger.debug('BLoC: ${bloc.runtimeType} → ${change.nextState}');
  }
  
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _logger.error('BLoC error', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
```

### With HTTP

```dart
@injectable
class LoggingInterceptor implements Interceptor {
  final IAppLogger _logger;
  
  LoggingInterceptor(this._logger);
  
  @override
  Future<Response<T>> intercept<T>(Chain<T> chain) async {
    final request = chain.request;
    final stopwatch = Stopwatch()..start();
    
    _logger.debug('→ ${request.method} ${request.url}', tag: 'HTTP');
    
    try {
      final response = await chain.proceed(request);
      _logger.info(
        '← ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)',
        tag: 'HTTP',
      );
      return response;
    } catch (e, stack) {
      _logger.error('HTTP error', error: e, stackTrace: stack, tag: 'HTTP');
      rethrow;
    }
  }
}
```

### With Navigation

```dart
@override
void didPush(Route route, Route? previousRoute) {
  _logger.debug(
    'Navigation: PUSH',
    data: {
      'route': route.settings.name,
      'previous': previousRoute?.settings.name,
    },
    tag: 'Navigation',
  );
}
```

---

## 🎓 Best Practices

### ✅ DO

```dart
// Use structured data
_logger.info('Product viewed', data: {
  'productId': product.id,
  'category': product.category,
});

// Include context
_logger.error('Checkout failed', 
  error: e, 
  stackTrace: stack,
  data: {'cartTotal': cart.total, 'itemCount': cart.items.length},
);

// Use appropriate levels
_logger.debug('Cache operation'); // Verbose
_logger.info('User action'); // Normal
_logger.error('Exception occurred'); // Errors only
```

### ❌ DON'T

```dart
// Don't use string interpolation for data
_logger.info('Product ID: ${product.id}'); // ❌

// Don't log in loops without throttling
for (final item in items) {
  _logger.debug('Processing $item'); // ❌ (too verbose)
}

// Don't log sensitive data without filtering
_logger.info('Password: $password'); // ❌ (security risk)
```

---

## 📈 Sentry Features

When enabled in staging/production:

1. **Error Tracking**
   - Automatic exception capture
   - Stack traces with source maps
   - Breadcrumb trail (last 100 logs)

2. **Performance Monitoring**
   - Transaction tracking
   - API call performance
   - Custom spans

3. **User Context**
   - Anonymous user ID
   - Environment (staging/production)
   - Device/platform information

4. **Alerts**
   - Error spike alerts
   - Performance degradation
   - Custom metric thresholds

---

## 🔧 Configuration

### Configuration Files

```bash
# Use configuration files with --dart-define-from-file
flutter run --dart-define-from-file=config/staging.json
flutter build apk --release --dart-define-from-file=config/production.json
```

**config/staging.json:**

```json
{
  "ENVIRONMENT": "staging",
  "SENTRY_DSN": "https://xxx@sentry.io/staging",
  "API_URL": "https://api-staging.example.com"
}
```

**config/production.json:**

```json
{
  "ENVIRONMENT": "production",
  "SENTRY_DSN": "https://yyy@sentry.io/production",
  "API_URL": "https://api.example.com"
}
```

### App Environment

```dart
// Check current environment
if (AppEnvironment.isDevelopment) {
  // Development-only code
}

// Get configuration
final apiUrl = AppEnvironment.current.apiBaseUrl;
final sentryDsn = AppEnvironment.current.sentryDsn;
```

---

## 📚 Documentation

- `LOGGING_STRATEGY.md` - Detailed strategy and architecture
- `README.md` - This file (quick reference)

---

## ✅ Checklist

- [x] IAppLogger interface
- [x] LogLevel enum
- [x] LogEntry model
- [x] ConsoleLogger implementation
- [x] IErrorReporter interface (Sentry integration)
- [x] SentryErrorReporter implementation
- [x] AppEnvironment detection
- [x] Sensitive data filtering (IDataFilter)
- [x] BlocObserver integration (via BlocModule)
- [x] Chopper interceptor (via NetworkModule)
- [x] Sentry initialization in bootstrap

---

## 🎉 Result

**Production-grade logging system** used by companies like:

- Uber (error tracking + performance)
- Airbnb (user journey breadcrumbs)
- Meta (environment-aware logging)

**Ready for**: Enterprise-scale applications! 🚀
