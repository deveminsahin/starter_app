# Environment Configuration Files

Configuration files for different environments using `--dart-define-from-file`.

## 📁 Files

- `development.json` - Development environment (local development)
- `staging.json` - Staging environment (pre-production testing)
- `production.json` - Production environment (live)
- `example.json` - Example template (committed to git)

## 🔒 Security

**⚠️ IMPORTANT: Never commit actual credentials!**

```gitignore
# Add to .gitignore
config/*.json
!config/example.json
!config/README.md
```

## 🚀 Usage

### Development

```bash
flutter run --dart-define-from-file=config/development.json
```

### Staging

```bash
flutter run --dart-define-from-file=config/staging.json
```

### Production

```bash
flutter build apk --release --dart-define-from-file=config/production.json
```

## 📝 Configuration Variables

### Required

- `ENVIRONMENT` - Environment name (`development`, `staging`, `production`)

### Optional

- `SENTRY_DSN` - Sentry Data Source Name for error tracking
- `API_URL` - API base URL for backend communication

## 🎯 Setup Instructions

1. **Copy example file:**

   ```bash
   cp config/example.json config/staging.json
   cp config/example.json config/production.json
   ```

2. **Update values:**
   Edit `staging.json` and `production.json` with your actual values.

3. **Verify .gitignore:**
   Ensure credentials are not committed:

   ```bash
   git status config/
   # Should NOT show staging.json or production.json
   ```

4. **Run with config:**

   ```bash
   flutter run --dart-define-from-file=config/staging.json
   ```

## 🔧 CI/CD Integration

### GitHub Actions

```yaml
- name: Create config file
  run: |
    echo '{
      "ENVIRONMENT": "production",
      "SENTRY_DSN": "${{ secrets.SENTRY_DSN }}",
      "API_URL": "${{ secrets.API_URL }}"
    }' > config/production.json

- name: Build
  run: flutter build apk --release --dart-define-from-file=config/production.json
```

### GitLab CI

```yaml
build:production:
  script:
    - echo "{\"ENVIRONMENT\":\"production\",\"SENTRY_DSN\":\"$SENTRY_DSN\",\"API_URL\":\"$API_URL\"}" > config/production.json
    - flutter build apk --release --dart-define-from-file=config/production.json
```

## 📊 Configuration Matrix

| File | ENVIRONMENT | SENTRY_DSN | API_URL | Committed |
|------|-------------|------------|---------|-----------|
| `development.json` | development | - | Default | ❌ No |
| `staging.json` | staging | Staging DSN | Staging URL | ❌ No |
| `production.json` | production | Prod DSN | Prod URL | ❌ No |
| `example.json` | staging | Example | Example | ✅ Yes |

## ✅ Benefits

- ✅ Single command to run/build
- ✅ No long command lines
- ✅ Version control friendly (example committed)
- ✅ Easy to switch environments
- ✅ CI/CD friendly (dynamic file generation)
- ✅ No credentials in terminal history
