# Theming Rules

## Overview

This project uses **FlexColorScheme** with **Material Design 3** for theming. See ADR-0015 for the decision rationale.

---

## Architecture

```text
lib/core/theme/              → Configuration (pure data)
├── app_theme.dart           # ThemeData definitions (light/dark)
├── color_palette.dart       # Color constants
├── text_styles.dart         # Typography definitions
├── theme_extensions.dart    # Custom ThemeExtensions (semantic colors)
├── theme_helper.dart        # Helper utilities
└── theme.dart               # Barrel file

lib/core/presentation/bloc/  → State Management
├── theme_cubit.dart         # UI state: which theme is active?
└── theme_state.dart         # AppThemeMode enum
```

---

## Rules

### Theme Configuration

- ✅ **DO**: Use `FlexColorScheme` for Material 3 compliance
- ✅ **DO**: Define semantic colors via `ThemeExtension`
- ✅ **DO**: Keep theme configuration in `core/theme/`
- ✅ **DO**: Use `HydratedBloc` for theme persistence
- ❌ **DON'T**: Hardcode colors in widgets
- ❌ **DON'T**: Mix theme config with state management

### Accessing Theme

```dart
// ✅ Use static .of() constructors
final textTheme = TextTheme.of(context);
final colorScheme = ColorScheme.of(context);

// ✅ Access semantic colors extension
final semantic = context.semanticColors;
final success = semantic.success;
final warning = semantic.warning;

// ❌ DON'T use the old verbose pattern
final colors = Theme.of(context).colorScheme; // Old way
final text = Theme.of(context).textTheme; // Old way

// ❌ DON'T hardcode colors
Container(color: Colors.blue) // Bad!
Container(color: colorScheme.primary) // Good!
```

### Theme Switching

```dart
// Toggle theme mode
context.read<ThemeCubit>().toggleTheme();

// Set specific mode
context.read<ThemeCubit>().setThemeMode(AppThemeMode.dark);
```

### Semantic Colors

Use `SemanticColors` extension for business states:

| Color | Use Case |
|-------|----------|
| `success` | Positive actions, confirmations |
| `warning` | Caution, pending states |
| `info` | Informational messages |
| `error` | Errors (use `colorScheme.error`) |

---

## Best Practices

1. **Use theme tokens**: Reference `colorScheme` and extensions, not raw colors
2. **Test both modes**: Verify UI in light and dark themes
3. **Semantic naming**: Use descriptive names (`onSurfaceVariant` vs `grey600`)
4. **Contrast ratios**: Ensure WCAG 2.1 AA compliance (4.5:1 text)

---

## Related

- [ADR-0015: Theme & Responsive Design](../adr/0015-theme-responsive-design.md)
- [ADR-0016: Design Token Constants](../adr/0016-design-token-constants.md)
- [lib/core/theme/README.md](../../lib/core/theme/README.md)
