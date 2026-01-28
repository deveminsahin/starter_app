# ADR-0015: Theme & Responsive Design

## Status

Accepted

## Context

Enterprise applications require:
1. Consistent theming across light and dark modes
2. Responsive design for different screen sizes
3. Semantic color support beyond Material Design defaults
4. Separation between theme configuration and theme state management

## Decision

I adopt **FlexColorScheme** for advanced theming with Material Design 3, combined with a clean separation of concerns:

### Architecture

```text
lib/core/theme/              → Configuration (pure data)
├── app_theme.dart           # ThemeData definitions (light/dark)
├── color_palette.dart       # Color constants
├── text_styles.dart         # Typography definitions
├── theme_extensions.dart    # Custom ThemeExtensions (semantic colors)
├── theme_helper.dart        # Helper utilities
└── theme.dart               # Barrel file

lib/core/presentation/bloc/  → State Management (presentation layer)
├── theme_cubit.dart         # UI state: which theme is active?
└── locale_cubit.dart        # UI state: which locale is active?
```

### Key Decisions

1. **FlexColorScheme**: Provides advanced theming capabilities with Material 3 support, surface tinting, and component-specific customization.

2. **Semantic Colors Extension**: Custom `SemanticColors` ThemeExtension for success/warning/info colors not covered by Material Design.

3. **HydratedBloc for Persistence**: Theme preferences are automatically persisted using HydratedBloc.

4. **Framework-Independent State**: `AppThemeMode` enum (light/dark/system) is framework-independent; converted to Flutter's `ThemeMode` only at the UI boundary.

5. **Responsive Utilities**: Breakpoint constants and responsive helpers for adaptive layouts.

### Usage

```dart
// Accessing theme configuration
final theme = appTheme.lightTheme;

// Accessing semantic colors
final success = context.semanticColors.success;

// Theme state management
context.read<ThemeCubit>().toggleTheme();
```

## Consequences

### Positive
- **Consistent Design**: FlexColorScheme ensures Material 3 compliance
- **Semantic Colors**: Extended palette for business states (success/warning/info)
- **Persistence**: Theme preference survives app restarts
- **Separation**: Configuration vs state management is clearly separated
- **Testability**: Cubits are easily unit-testable

### Negative
- **Dependency**: Relies on FlexColorScheme package
- **Complexity**: Two locations for theme-related code

### Neutral
- Theme configuration is in `core/theme/`; state management is in `core/presentation/bloc/`

## Related

- ADR-0016: Design Token Constants
- `lib/core/theme/README.md`
