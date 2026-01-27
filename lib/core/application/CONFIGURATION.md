# Application Layer

The application layer provides application-level services that orchestrate app initialization, configuration, error handling, and monitoring.

---

## 📁 Module Structure

```text
lib/core/application/
├── application_environment.dart   # Environment configuration enum
├── bootstrap_service.dart         # App initialization orchestrator
├── app_error_handling_service.dart # Global error handlers
├── app_monitoring_service.dart    # Sentry & diagnostics
└── CONFIGURATION.md               # This file
```

---

## 🏗️ Services Overview

### AppEnvironment

Determines the current environment (development, staging, production) based on compile-time constants.

```dart
// Check current environment
if (AppEnvironment.isDevelopment) {
  // Development-specific logic
}

// Access configuration
final apiUrl = AppEnvironment.current.apiBaseUrl;
final wsUrl = AppEnvironment.current.webSocketUrl;
```

**Properties:**
| Property | Dev | Staging | Prod |
|----------|-----|---------|------|
| `sentryEnabled` | ❌ | ✅ | ✅ |
| `sslPinningEnabled` | ❌ | ✅ | ✅ |
| `sentrySampleRate` | 0% | 100% | 10% |

---

### BootstrapService

Orchestrates application initialization. Called from `bootstrap.dart`.

**Responsibilities:**
- Set `HydratedBloc.storage` for state persistence
- Set `Bloc.observer` for BLoC logging
- Initialize monitoring via `AppMonitoringService`
- Initialize SSL certificates via `ICertificateService`

**Dependencies (via DI):**
- `HydratedStorage` - State persistence
- `BlocObserver` - BLoC event logging
- `AppMonitoringService` - Sentry initialization
- `AppErrorHandlingService` - Error handler setup
- `ICertificateService` - SSL certificate loading

---

### AppErrorHandlingService

Sets up global error handlers for uncaught errors.

**Handlers:**
- `FlutterError.onError` - Flutter framework errors
- `PlatformDispatcher.instance.onError` - Platform-level errors
- Zone errors - Uncaught async errors

**Dependencies:**
- `IAppLogger` - Console logging
- `IErrorReporter` - Sentry error tracking

---

### AppMonitoringService

Handles Sentry SDK initialization and startup diagnostics.

**Responsibilities:**
- Initialize Sentry SDK via `ISentryInitializer` (staging/production only)
- Log startup configuration
- Add lifecycle breadcrumbs

**Dependencies:**
- `IAppLogger` - Console logging
- `IErrorReporter` - Sentry breadcrumbs
- `IPlatformInfo` - Platform and OS version info
- `IMonitoringInitializer` - SDK initialization (keeps infrastructure decoupled)

---

## 🚀 Build Commands

### Development

```bash
flutter run \
  --flavor development \
  --target lib/main_development.dart \
  --dart-define-from-file=config/development.json
```

### Staging

```bash
flutter run \
  --flavor staging \
  --target lib/main_staging.dart \
  --dart-define-from-file=config/staging.json
```

### Production

```bash
flutter build apk --release \
  --flavor production \
  --target lib/main_production.dart \
  --dart-define-from-file=config/production.json
```

---

## 📝 Configuration Files

Located in `config/` directory:

```json
// config/development.json
{
  "ENVIRONMENT": "development"
}

// config/staging.json
{
  "ENVIRONMENT": "staging",
  "SENTRY_DSN": "https://xxx@sentry.io/staging",
  "API_URL": "https://api-staging.example.com"
}

// config/production.json
{
  "ENVIRONMENT": "production",
  "SENTRY_DSN": "https://xxx@sentry.io/prod",
  "API_URL": "https://api.example.com"
}
```

**Variables:**
| Variable | Required | Default |
|----------|----------|---------|
| `ENVIRONMENT` | ✅ | `development` |
| `SENTRY_DSN` | ❌ | `null` |
| `API_URL` | ❌ | Environment default |
| `WS_URL` | ❌ | Derived from API_URL |

---

## 🧪 Testing

All services have comprehensive unit tests in `test/core/application/`:

```bash
# Run application layer tests
very_good test --coverage test/core/application/
```

| Test File | Coverage |
|-----------|----------|
| `application_environment_test.dart` | 100% |
| `bootstrap_service_test.dart` | 100% |
| `app_error_handling_service_test.dart` | 100% |
| `app_monitoring_service_test.dart` | 100% |

---

## 🏛️ Architecture

**Layer:** Application (orchestration between domain and infrastructure)

**Dependencies:**
- Uses domain ports (`IPlatformInfo`, `ICertificateService`)
- Depends on infrastructure indirectly via DI
- Uses Flutter framework for error handling hooks

**Follows:**
- ✅ Single Responsibility (one service per concern)
- ✅ Dependency Inversion (depends on interfaces)
- ✅ Hexagonal Architecture (uses ports)
