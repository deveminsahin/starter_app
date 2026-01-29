# Environment Configuration Files

Configuration files for different environments using `--dart-define-from-file`.

## 📁 Files

**Templates (committed to git):**
- `development.json.example` - Development environment template
- `staging.json.example` - Staging environment template
- `production.json.example` - Production environment template

**Your configs (gitignored):**
- `development.json` - Your local development config
- `staging.json` - Your staging config
- `production.json` - Your production config

## 🔒 Security

**⚠️ IMPORTANT: Actual configs are gitignored by default!**

```gitignore
# Already in .gitignore
config/*.json
!config/*.json.example
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

1. **Copy example files:**

   ```bash
   cp config/development.json.example config/development.json
   cp config/staging.json.example config/staging.json
   cp config/production.json.example config/production.json
   ```

2. **Update values:**
   Edit each `.json` file with your actual values.

3. **Verify .gitignore:**
   Ensure credentials are not committed:

   ```bash
   git status config/
   # Should only show .example files, NOT actual .json files
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
| `development.json.example` | development | - | localhost | ✅ Yes |
| `staging.json.example` | staging | Placeholder | Placeholder | ✅ Yes |
| `production.json.example` | production | Placeholder | Placeholder | ✅ Yes |
| `*.json` (actual) | varies | Real values | Real values | ❌ No |

## ✅ Benefits

- ✅ Single command to run/build
- ✅ No long command lines
- ✅ Version control friendly (example committed)
- ✅ Easy to switch environments
- ✅ CI/CD friendly (dynamic file generation)
- ✅ No credentials in terminal history
