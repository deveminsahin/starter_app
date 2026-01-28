# Logging Strategy & Architecture

## Chopper Logging Evaluation

### Option 1: pretty_chopper_logger

**Pros:**

- Pre-built solution
- Pretty console output
- Easy to integrate

**Cons:**

- ❌ External dependency (another package)
- ❌ Not customizable for our needs
- ❌ Doesn't integrate with our unified logging
- ❌ Can't route to Sentry
- ❌ No environment-aware behavior

### Option 2: Custom Chopper Interceptor ✅ CHOSEN

**Pros:**

- ✅ Integrates with our unified logging system
- ✅ Routes to Sentry in production/staging
- ✅ Environment-aware (debug vs release)
- ✅ Consistent log format across app
- ✅ Can filter sensitive data
- ✅ Performance monitoring integration
- ✅ No extra dependencies

**Cons:**

- Requires implementation (but provides full control)

Decision: Custom interceptor for better integration and control

---

## Logging Architecture

### Environment-Aware Strategy

```text
┌─────────────────────────────────────────────────────────────┐
│                    Application Code                          │
│            (BLoC, Repository, Use Cases, etc.)               │
└────────────────────┬────────────────────────────────────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
         ▼                       ▼
┌────────────────┐       ┌──────────────────┐
│  IAppLogger    │       │  IErrorReporter  │
│  (Logging)     │       │  (Error Tracking)│
└───────┬────────┘       └────────┬─────────┘
        │                         │
        ▼                         ▼
┌───────────────┐         ┌────────────────────┐
│ ConsoleLogger │         │ SentryErrorReporter│
│ (Dev only)    │         │ (Staging/Prod)     │
└───────────────┘         └────────────────────┘
        │                         │
        ▼                         ▼
  Dart Console              Sentry Dashboard
```

### Logging Rules

| Environment | Build Mode | Console | Sentry |
|-------------|------------|---------|--------|
| Development | Debug | ✅ Yes | ❌ No |
| Development | Release | ✅ Yes | ❌ No |
| Staging | Debug | ✅ Yes | ✅ Yes |
| Staging | Release | ❌ No | ✅ Yes |
| Production | Debug | ✅ Yes | ✅ Yes |
| Production | Release | ❌ No | ✅ Yes |

### Log Levels

```dart
enum LogLevel {
  debug,    // Verbose information for debugging
  info,     // General information
  warning,  // Warnings that don't prevent operation
  error,    // Errors that need attention
  fatal,    // Critical errors that may crash the app
}
```

### Components

1. **IAppLogger** (Interface)
   - Single entry point for all logging
   - Injectable via DI
   - Environment-aware

2. **ConsoleLogger**
   - Uses official `logging` package (dart.dev)
   - Color-coded by level with ANSI colors
   - Stack traces for errors
   - Active only in development environment
   - Industry standard (used by Google internally)

3. **IErrorReporter / SentryErrorReporter**
   - Separate interface for error tracking
   - Sends exceptions to Sentry dashboard
   - User context and breadcrumbs
   - Only for staging/production

4. **BlocObserver**
   - Logs all BLoC events and state changes
   - Routes through IAppLogger
   - Helps debug state management

5. **ChopperLogInterceptor**
   - Logs HTTP requests/responses
   - Filters sensitive data (tokens, passwords)
   - Performance tracking
   - Routes through IAppLogger

---

## Usage Examples

### Basic Logging

```dart
@injectable
class ProductRepository {
  final IAppLogger _logger;
  
  ProductRepository(this._logger);
  
  Future<Either<Failure, Product>> getProduct(String id) async {
    _logger.info('Fetching product', data: {'productId': id});
    
    try {
      final product = await _api.getProduct(id);
      _logger.debug('Product fetched successfully');
      return Right(product);
    } catch (e, stack) {
      _logger.error('Failed to fetch product', error: e, stackTrace: stack);
      return Left(Failure.server(message: e.toString()));
    }
  }
}
```

### BLoC Logging (Automatic)

```dart
// Automatically logged by BlocObserver
@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  // Every event and state change is logged
}

// Console output:
// 🟦 BLoC: ProductBloc | Event: FetchProducts
// 🟩 BLoC: ProductBloc | State: Loading -> Success(products: 10)
```

### HTTP Logging (Automatic)

```dart
// Automatically logged by ChopperLogInterceptor
await _api.getProducts();

// Console output:
// 🔵 HTTP: GET /api/products
// 🟢 HTTP: 200 OK (342ms) | Body: {...}
```

---

## Configuration

### Environment Detection

```dart
enum AppEnvironment {
  development,
  staging,
  production;
  
  static AppEnvironment get current {
    // Detect from build configuration
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    return AppEnvironment.values.byName(env);
  }
}
```

### Sentry Configuration

```dart
// Development: No Sentry
// Staging: Sentry with staging DSN (passed via --dart-define=SENTRY_DSN=xxx)
// Production: Sentry with production DSN (passed via --dart-define=SENTRY_DSN=yyy)

await SentryFlutter.init(
  (options) {
    options.dsn = AppEnvironment.current.sentryDsn;
    options.environment = AppEnvironment.current.name;
    options.tracesSampleRate = AppEnvironment.current.sentrySampleRate;
  },
);
```

---

## Performance Considerations

1. **Lazy Logging**: Logs only created when level is enabled
2. **Async Sentry**: Non-blocking sends to Sentry
3. **Structured Data**: JSON-serializable for efficient storage
4. **Log Rotation**: Console logs don't accumulate (handled by system)
5. **Sampling**: High-volume logs sampled in production

---

## Security & Privacy

### Sensitive Data Filtering

```dart
final _sensitiveKeys = {
  'password', 'token', 'authorization', 'api_key',
  'secret', 'credential', 'credit_card',
};

Map<String, dynamic> _filterSensitiveData(Map<String, dynamic> data) {
  return data.map((key, value) {
    if (_sensitiveKeys.any((k) => key.toLowerCase().contains(k))) {
      return MapEntry(key, '***REDACTED***');
    }
    return MapEntry(key, value);
  });
}
```

### User Context

```dart
Sentry.configureScope((scope) {
  scope.setUser(SentryUser(
    id: user.id,
    // NO email, name, or PII in production
    environment: AppEnvironment.current.name,
  ));
});
```

---

## Testing

### Mock Logger

```dart
class MockLogger extends Mock implements IAppLogger {}

test('logs errors correctly', () {
  final mockLogger = MockLogger();
  final repository = ProductRepository(mockLogger);
  
  // Test
  await repository.getProduct('invalid');
  
  // Verify
  verify(() => mockLogger.error(
    'Failed to fetch product',
    error: any(named: 'error'),
    stackTrace: any(named: 'stackTrace'),
  )).called(1);
});
```

---

## Monitoring Dashboard

### Sentry Features We'll Use

1. **Error Tracking**
   - Automatic error capture
   - Stack traces
   - Breadcrumb trail
   - User impact

2. **Performance Monitoring**
   - Transaction tracking
   - API call performance
   - Screen load times
   - Custom spans

3. **Release Tracking**
   - Version comparison
   - Crash-free rate
   - Adoption rate

4. **Alerts**
   - Error spike alerts
   - Performance degradation
   - Custom metrics

---

## Migration from Step 9

Currently, `AppRouterObserver` logs to console directly:

```dart
debugPrint('🚦 Navigation: PUSH | Route: $routeName');
```

After Step 10, it will use `IAppLogger`:

```dart
_logger.debug('Navigation: PUSH', data: {
  'route': routeName,
  'previous': previousName,
  'stackDepth': stackDepth,
});
```

This ensures:

- ✅ Consistent formatting
- ✅ Structured data
- ✅ Routes to Sentry in staging/production
- ✅ Can be disabled/filtered centrally

---

## References

- [Sentry Flutter Documentation](https://docs.sentry.io/platforms/flutter/)
- [Logging Package](https://pub.dev/packages/logging)
- [Flutter Logging Best Practices](https://docs.flutter.dev/testing/errors)
- [Chopper Interceptors](https://pub.dev/packages/chopper)
