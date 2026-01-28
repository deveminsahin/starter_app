# Localization Guide

This project uses Flutter's built-in localization with ARB (Application Resource Bundle) files.

---

## Project Structure

```
lib/
├── core/l10n/            # Core app translations
│   └── arb/
│       ├── app_en.arb    # English (source)
│       └── app_es.arb    # Spanish
└── features/
    ├── auth/l10n/        # Auth feature translations
    ├── dashboard/l10n/   # Dashboard translations
    ├── profile/l10n/     # Profile translations
    └── settings/l10n/    # Settings translations
```

---

## Adding Strings

### 1. Add to ARB File

Open the appropriate ARB file (e.g., `lib/core/l10n/arb/app_en.arb`):

```json
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    },
    "helloWorld": "Hello World",
    "@helloWorld": {
        "description": "Hello World Text"
    }
}
```

### 2. Use in Code

```dart
import 'package:starter_app/core/l10n/l10n_extensions.dart';

@override
Widget build(BuildContext context) {
  final l10n = context.appL10n;
  return Text(l10n.appName);
}
```

---

## Adding Supported Locales

### 1. Update iOS Info.plist

Add the locale to `ios/Runner/Info.plist`:

```xml
<key>CFBundleLocalizations</key>
<array>
    <string>en</string>
    <string>es</string>
    <!-- Add new locale here -->
</array>
```

### 2. Create ARB Files

For each supported locale, add a new ARB file in the appropriate directory:

```text
lib/core/l10n/arb/
├── app_en.arb
├── app_es.arb
└── app_fr.arb    # New locale
```

### 3. Add Translations

`app_en.arb` (English - Source):
```json
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    }
}
```

`app_es.arb` (Spanish):
```json
{
    "@@locale": "es",
    "counterAppBarTitle": "Contador",
    "@counterAppBarTitle": {
        "description": "Texto mostrado en la AppBar de la página del contador"
    }
}
```

---

## Generating Translations

Run the localization generation script:

```bash
./scripts/generate_localizations.sh
```

This generates translations for all features:
- Core app (`AppLocalizations`)
- Auth (`AuthLocalizations`)
- Dashboard (`DashboardLocalizations`)
- Profile (`ProfileLocalizations`)
- Settings (`SettingsLocalizations`)

Alternatively, run `flutter run` and code generation will take place automatically.

---

## Best Practices

1. **Use descriptive keys**: `loginButtonText` not `btn1`
2. **Add descriptions**: Help translators understand context
3. **Use placeholders** for dynamic values:
   ```json
   "greeting": "Hello, {name}!",
   "@greeting": {
       "placeholders": { "name": {} }
   }
   ```
4. **Keep translations organized**: Each feature has its own l10n directory
5. **Test with different locales**: Verify layout doesn't break with longer text

---

## References

- [Flutter Internationalization Guide](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
- [flutter_localizations](https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html)
