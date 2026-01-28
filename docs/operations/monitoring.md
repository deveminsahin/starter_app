# Monitoring Setup Guide

Configure monitoring, logging, and crash reporting for the Starter App.

---

## Monitoring Stack

| Component | Tool | Purpose |
|-----------|------|---------|
| Crash Reporting | Sentry (`sentry_flutter`) | Crash logs, stack traces |
| Logging | `ConsoleLogger` (dev only) | Debug logs |
| Error Tracking | `SentryErrorReporter` | Error capture, breadcrumbs |
| Performance | Sentry Tracing | App startup, API timing |

---

## Sentry Configuration

### Environment Setup

Sentry is enabled for **staging** and **production** only (not development).

Configure DSN in your environment config files:

```json
// config/production.json
{
  "SENTRY_DSN": "https://xxx@sentry.io/production",
  "SENTRY_SAMPLE_RATE": 0.1
}

// config/staging.json
{
  "SENTRY_DSN": "https://xxx@sentry.io/staging",
  "SENTRY_SAMPLE_RATE": 1.0
}
```

### Sample Rates

| Environment | Sample Rate | Reason |
|-------------|-------------|--------|
| Development | 0% (disabled) | No noise |
| Staging | 100% | Capture everything |
| Production | 10% | Performance balance |

---

## Logging Configuration

### Log Levels

| Level | Use Case | Sentry Action |
|-------|----------|---------------|
| `debug` | Verbose dev info | Breadcrumb |
| `info` | Important events | Breadcrumb |
| `warning` | Recoverable issues | Breadcrumb + Message |
| `error` | Failures | Exception capture |
| `fatal` | Critical failures | Fatal exception capture |

### Using the Logger

```dart
// Get logger via dependency injection
final logger = getIt<IAppLogger>();

// Log levels
logger.debug('Fetching user profile', tag: 'ProfileBloc');
logger.info('User logged in', data: {'userId': user.id});
logger.warning('Retry attempt', data: {'count': retryCount});
logger.error('Failed to fetch profile', error: e, stackTrace: stack);
logger.fatal('Database corrupted', error: e, stackTrace: stack);
```

### Sensitive Data Redaction

`SensitiveDataFilter` automatically redacts sensitive fields before sending to Sentry:

```dart
// These keys are automatically redacted:
const sensitiveTerms = [
  'password', 'token', 'authorization', 'auth',
  'api_key', 'apikey', 'secret', 'credential',
  'credit_card', 'creditcard', 'ssn', 'social_security',
  'pin', 'cvv', 'card_number', 'cardnumber',
];
```

See: `lib/core/error/sensitive_data_filter.dart`

---

## Performance Monitoring

### Key Metrics

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| App startup | < 2s | > 3s |
| API response (p95) | < 500ms | > 1s |
| Frame rate | 60 fps | < 45 fps |

### Sentry Tracing

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

// Custom transaction
final transaction = Sentry.startTransaction('login_flow', 'user.action');
try {
  await performLogin();
  transaction.status = const SpanStatus.ok();
} catch (e) {
  transaction.status = const SpanStatus.internalError();
} finally {
  await transaction.finish();
}
```

---

## Alerting Rules

### P1 Alerts (Immediate)

- Crash rate > 1% in 5 minutes
- Login success rate < 95%
- API error rate > 5%

### P2 Alerts (Within 1 hour)

- Crash rate > 0.5% in 1 hour
- API latency p95 > 2s
- Memory usage > 80%

Configure alerts in Sentry: **Settings → Alerts → Create Alert Rule**

---

## Dashboard

In Sentry dashboard, monitor:

1. **Real-time**
   - Active issues
   - Error rate
   - Release health

2. **Trends**
   - Crash-free users %
   - App version distribution
   - Error frequency over time

3. **Performance**
   - Transaction durations
   - Web vitals (if web)

---

## Log Viewing

### Development

```bash
# Console output (development only)
flutter run --flavor development

# Filter logs
flutter logs | grep "ERROR"
```

### Staging/Production

- View in **Sentry Dashboard** → Issues
- Check **Breadcrumbs** for context leading to errors
- Use **Discover** for custom queries

---

## Best Practices

1. **Log meaningful events**: Login, navigation, errors
2. **Include context**: User ID, session ID, feature flag states
3. **Don't log PII**: Emails, addresses, phone numbers (auto-redacted)
4. **Set up alerts**: Configure in Sentry → Alerts
5. **Monitor releases**: Use Sentry release tracking
