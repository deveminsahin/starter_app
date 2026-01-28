# Theme Configuration

This directory contains all theme-related **configuration** for the application, implementing Material Design 3 principles with FlexColorScheme.

> **Note:** Theme state management (`ThemeCubit`) is in `lib/core/presentation/bloc/` to follow Clean Architecture layering. This directory contains only theme configuration (colors, styles, ThemeData).

## Structure

```text
theme/
├── app_theme.dart          # Main theme configuration (light & dark)
├── app_theme_extension.dart # Extension to convert AppThemeMode → ThemeMode
├── color_palette.dart      # Color definitions and palette
├── text_styles.dart        # Typography configuration
├── theme_extensions.dart   # Custom theme extensions (semantic colors)
├── theme_helper.dart       # Helper utilities for theme access
└── theme.dart              # Barrel file for exports

# State management is in:
lib/core/presentation/bloc/
├── theme_cubit.dart        # Theme state management with persistence
├── locale_cubit.dart       # Locale state management with persistence
└── bloc.dart               # Barrel file
```

## Usage

### Basic Theme Application with DI

The app uses constructor injection (not service locator). Dependencies are injected via the constructor:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter_app/core/presentation/bloc/bloc.dart';
import 'package:starter_app/core/theme/theme.dart';
import 'package:starter_app/core/theme/app_theme_extension.dart';

// App widget with constructor injection
@injectable
class App extends StatelessWidget {
  const App({
    required this.themeCubit,
    required this.localeCubit,
    required this.appTheme,
    // ... other dependencies
  });

  final ThemeCubit themeCubit;
  final LocaleCubit localeCubit;
  final AppTheme appTheme;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => themeCubit),
        BlocProvider(create: (context) => localeCubit),
      ],
      child: BlocBuilder<ThemeCubit, AppThemeMode>(
        builder: (context, appThemeMode) {
          return MaterialApp(
            theme: appTheme.lightTheme,
            darkTheme: appTheme.darkTheme,
            themeMode: appThemeMode.toThemeMode(),
            // ...
          );
        },
      ),
    );
  }
}
```

### Switching Themes with ThemeCubit

```dart
import 'package:starter_app/core/presentation/bloc/bloc.dart';

// Get the ThemeCubit from context
final themeCubit = context.read<ThemeCubit>();

// Switch to light theme
themeCubit.setLightTheme();

// Switch to dark theme
themeCubit.setDarkTheme();

// Switch to system theme
themeCubit.setSystemTheme();

// Toggle between light and dark
themeCubit.toggleTheme();

// Set specific mode
themeCubit.setThemeMode(AppThemeMode.dark);
```

### Accessing Colors

```dart
// Using context extension
final primaryColor = context.primaryColor;
final backgroundColor = context.backgroundColor;
final errorColor = context.errorColor;

// Semantic colors (via theme extension)
final successColor = context.semanticColors.success;
final warningColor = context.semanticColors.warning;
final infoColor = context.semanticColors.info;

// Direct ColorScheme access
final colors = Theme.of(context).colorScheme;
final primary = colors.primary;
```

### Accessing Typography

```dart
// Using context extension
Text(
  'Headline',
  style: context.headlineMedium,
)

// Using ThemeHelper
Text(
  'Body text',
  style: ThemeHelper.bodyLarge(context),
)

// Direct access
Text(
  'Title',
  style: Theme.of(context).textTheme.titleMedium,
)
```

### Theme Toggle Button Example

```dart
import 'package:starter_app/core/presentation/bloc/bloc.dart';

class ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppThemeMode>(
      builder: (context, themeMode) {
        return IconButton(
          icon: Icon(
            themeMode == AppThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode,
          ),
          onPressed: () {
            context.read<ThemeCubit>().toggleTheme();
          },
          tooltip: 'Toggle theme',
        );
      },
    );
  }
}
```

### Theme Settings Page Example

```dart
import 'package:starter_app/core/presentation/bloc/bloc.dart';

class ThemeSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings')),
      body: BlocBuilder<ThemeCubit, AppThemeMode>(
        builder: (context, themeMode) {
          return ListView(
            children: [
              RadioListTile<AppThemeMode>(
                title: const Text('Light'),
                value: AppThemeMode.light,
                groupValue: themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    context.read<ThemeCubit>().setThemeMode(mode);
                  }
                },
              ),
              RadioListTile<AppThemeMode>(
                title: const Text('Dark'),
                value: AppThemeMode.dark,
                groupValue: themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    context.read<ThemeCubit>().setThemeMode(mode);
                  }
                },
              ),
              RadioListTile<AppThemeMode>(
                title: const Text('System'),
                value: AppThemeMode.system,
                groupValue: themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    context.read<ThemeCubit>().setThemeMode(mode);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
```

## Dependency Injection

### ThemeCubit

Located in `lib/core/presentation/bloc/theme_cubit.dart`. Uses `HydratedBloc` for automatic state persistence:

```dart
// Registered in BlocModule (lib/core/di/modules/bloc_module.dart)
@lazySingleton
ThemeCubit provideThemeCubit() {
  return ThemeCubit(AppThemeMode.system);
}
```

### AppThemeMode

Framework-independent enum for theme modes:

```dart
enum AppThemeMode {
  light,
  dark,
  system;
}
```

Convert to Flutter's `ThemeMode` using the extension:

```dart
import 'package:starter_app/core/theme/app_theme_extension.dart';

final themeMode = appThemeMode.toThemeMode();
```

### ThemeCubit State Flow

```text
User Action → ThemeCubit.setThemeMode()
           → emit(AppThemeMode.dark)
           → toJson() auto-persisted by HydratedBloc
           → BlocBuilder rebuilds UI
           → appThemeMode.toThemeMode() converts for MaterialApp
```

### Persistence

- **ThemeCubit**: Uses HydratedBloc storage (JSON format)
- **Storage Location**: Platform-dependent (SharedPreferences-like)
- **Storage Key**: `ThemeCubit` (based on cubit runtime type)

## Architecture

### Separation of Concerns

This architecture follows Clean Architecture principles:

```text
lib/core/theme/              → Configuration (data)
├── app_theme.dart           # ThemeData definitions
├── color_palette.dart       # Color constants
├── text_styles.dart         # Typography definitions
└── theme_extensions.dart    # Custom ThemeExtensions

lib/core/presentation/bloc/  → State Management (presentation)
├── theme_cubit.dart         # UI state: which theme is active?
└── locale_cubit.dart        # UI state: which locale is active?
```

**Why this separation?**
1. **Theme configuration** = What colors/styles to use (pure data)
2. **Theme state** = Which theme is currently selected (UI state)
3. Cubits are presentation layer concerns → belong in `presentation/`
4. Configuration is infrastructure → can stay in `core/theme/`

## Material Design 3 Type Scale

The typography follows the MD3 type scale:

| Style | Size | Weight | Letter Spacing |
|-------|------|--------|----------------|
| displayLarge | 57 | 400 | -0.25 |
| displayMedium | 45 | 400 | 0 |
| displaySmall | 36 | 400 | 0 |
| headlineLarge | 32 | 400 | 0 |
| headlineMedium | 28 | 400 | 0 |
| headlineSmall | 24 | 400 | 0 |
| titleLarge | 22 | 400 | 0 |
| titleMedium | 16 | 500 | 0.15 |
| titleSmall | 14 | 500 | 0.1 |
| labelLarge | 14 | 500 | 0.1 |
| labelMedium | 12 | 500 | 0.5 |
| labelSmall | 11 | 500 | 0.5 |
| bodyLarge | 16 | 400 | 0.5 |
| bodyMedium | 14 | 400 | 0.25 |
| bodySmall | 12 | 400 | 0.4 |

## Color Palette

Based on Material Design 3 color roles:

### Primary Colors
- `primary` / `onPrimary`
- `primaryContainer` / `onPrimaryContainer`

### Secondary Colors
- `secondary` / `onSecondary`
- `secondaryContainer` / `onSecondaryContainer`

### Tertiary Colors
- `tertiary` / `onTertiary`
- `tertiaryContainer` / `onTertiaryContainer`

### Semantic Colors (Custom Extension)
- `success` / `onSuccess` (green tones)
- `warning` / `onWarning` (amber tones)
- `info` / `onInfo` (blue tones)

### Surface Colors
- `surface` / `onSurface`
- `surfaceContainerHighest`
- `outline` / `outlineVariant`

## Customization

### Adding New Colors

1. Add to `color_palette.dart`:
```dart
static const customColor = Color(0xFF123456);
```

2. Use in theme or components as needed.

### Adding Semantic Colors

1. Extend `SemanticColors` in `theme_extensions.dart`:
```dart
final Color? newColor;
```

2. Update `copyWith`, `lerp`, and constructors.

3. Add to `AppTheme.lightTheme` and `darkTheme` extensions.

## FlexColorScheme Configuration

The app uses FlexColorScheme for advanced theming:

```dart
FlexThemeData.light(
  scheme: FlexScheme.deepPurple,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 7,
  subThemesData: const FlexSubThemesData(
    // Component-specific theming
  ),
  useMaterial3: true,
)
```

## Best Practices

### Do
- Use `ThemeCubit` for theme state management
- Use `AppThemeMode` (not Flutter's `ThemeMode`) for state
- Access colors via context extensions or `Theme.of(context)`
- Use semantic colors for success/warning/info states
- Inject `ThemeCubit` at app level
- Import from `core/presentation/bloc/bloc.dart` for cubits
- Import from `core/theme/theme.dart` for configuration

### Don't
- Hardcode colors in widgets
- Create multiple ThemeCubit instances
- Forget to provide `ThemeCubit` at app level
- Mix `AppThemeMode` and Flutter's `ThemeMode` incorrectly

## Testing

Theme cubit tests are located at:
```
test/core/presentation/bloc/theme_cubit_test.dart
```

Example test:
```dart
blocTest<ThemeCubit, AppThemeMode>(
  'emits [AppThemeMode.dark] when setDarkTheme is called',
  build: () => ThemeCubit(AppThemeMode.light),
  act: (cubit) => cubit.setDarkTheme(),
  expect: () => [AppThemeMode.dark],
);
```
