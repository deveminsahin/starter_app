# Settings Feature

User settings management including theme, language, and account preferences.

## Structure

```
lib/features/settings/
├── l10n/                          # Feature-scoped localizations
│   ├── settings_en.arb            # English strings with @key descriptions
│   ├── settings_es.arb            # Spanish translations
│   ├── settings_localizations.dart
│   └── l10n_extensions.dart       # BuildContext extension
├── presentation/
│   ├── pages/
│   │   └── settings_page.dart     # Main settings page
│   ├── routes/
│   │   └── settings_routes.dart   # Shell branch route
│   └── widgets/
│       ├── language_selector.dart # Language switching widget
│       └── theme_selector.dart    # Theme switching widget
└── settings.dart                  # Barrel export
```

## Features

| Feature | Description |
|---------|-------------|
| **Theme Selection** | Light, Dark, System modes via `ThemeCubit` |
| **Language Selection** | English, Spanish via `LocaleCubit` |
| **Logout** | Logout button for authenticated users |
| **Responsive** | Adapts to mobile/tablet/desktop layouts |

## Usage

```dart
// Navigate to settings
const SettingsRoute().go(context);

// Theme switching
context.read<ThemeCubit>().setDarkTheme();
context.read<ThemeCubit>().setLightTheme();
context.read<ThemeCubit>().setSystemTheme();

// Language switching
context.read<LocaleCubit>().setEnglish();
context.read<LocaleCubit>().setSpanish();
```

## Localization

Access settings-scoped localizations:

```dart
final l10n = context.settingsL10n;
Text(l10n.appBarTitle);  // "Settings" or "Configuración"
```

## Tests

```bash
very_good test test/features/settings/
```

| Test File | Coverage |
|-----------|----------|
| `settings_localizations_test.dart` | Delegate, lookup, all strings |
| `settings_page_test.dart` | Widget interactions, button callbacks |
