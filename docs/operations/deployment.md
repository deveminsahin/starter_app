# Deployment Runbook

This document covers deployment procedures for the Starter App across all environments.

---

## Environments

| Environment | Purpose | API URL |
|-------------|---------|---------|
| Development | Local development | `http://localhost:8080` |
| Staging | Pre-production testing | `https://staging-api.example.com` |
| Production | Live users | `https://api.example.com` |

---

## Environment Configuration

This project uses `--dart-define-from-file` with JSON config files:

```
config/
├── development.json   # STRICT_ENV: false
├── staging.json       # STRICT_ENV: true
├── production.json    # STRICT_ENV: true
└── example.json       # Template
```

---

## Build Commands

### Android

```bash
# Development APK
flutter build apk --flavor development --target lib/main_development.dart \
  --dart-define-from-file=config/development.json

# Production Release (with obfuscation)
flutter build appbundle --flavor production --target lib/main_production.dart \
  --dart-define-from-file=config/production.json \
  --obfuscate --split-debug-info=build/debug-info
```

### iOS

```bash
# Development (simulator)
flutter build ios --flavor development --target lib/main_development.dart \
  --dart-define-from-file=config/development.json --simulator

# Production Release (with obfuscation)
flutter build ipa --flavor production --target lib/main_production.dart \
  --dart-define-from-file=config/production.json \
  --obfuscate --split-debug-info=build/debug-info
```

### Web

```bash
# Production Web
flutter build web --target lib/main_production.dart \
  --dart-define-from-file=config/production.json
```

> **Note:** Web builds do not support `--obfuscate` flag (JavaScript minification is automatic).

---

## Security: Obfuscation

For production builds, always use obfuscation to protect your code:

```bash
--obfuscate --split-debug-info=build/debug-info
```

- `--obfuscate`: Renames classes, methods, and variables to meaningless names
- `--split-debug-info`: Saves symbol map for crash symbolication

**Important:** Keep the `build/debug-info` folder secure for crash report symbolication.

---

## CI/CD Pipeline

### GitHub Actions Workflow

```yaml
name: Release

on:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.2'
      
      - run: very_good packages get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: very_good test --coverage
      - run: flutter build appbundle --release
```

---

## Pre-Deployment Checklist

- [ ] All tests pass (`very_good test`)
- [ ] Coverage at 100%
- [ ] No analyzer warnings (`flutter analyze`)
- [ ] Version bumped in `pubspec.yaml`
- [ ] CHANGELOG.md updated
- [ ] Environment variables configured
- [ ] Code review approved

---

## Rollback Procedure

### Mobile (App Store / Play Store)

1. Identify the last stable version
2. Build and submit that version as a new release
3. Mark as phased rollout (10% → 50% → 100%)

### Web

1. Revert deployment in hosting provider
2. Or: Deploy previous build artifacts

---

## Post-Deployment Verification

1. **Smoke Test**: Login, navigate core flows
2. **Error Monitoring**: Check crash reporting dashboard
3. **Performance**: Verify startup time within baseline
4. **API Health**: Confirm backend connectivity
