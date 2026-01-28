# ADR-0016: Design Token Constants & Pre-computed Widgets

## Status

Accepted

## Context

UI consistency requires:
1. Centralized design tokens (spacing, radius, colors)
2. No magic numbers in widget code
3. Fast widget creation (avoid repeated EdgeInsets.all() calls)
4. Easy design system updates

## Decision

I adopt a **two-tier design token system**:

1. **Constants**: Raw numeric values
2. **Pre-computed Widgets**: Ready-to-use Flutter objects

### Folder Structure

```
lib/core/constants/
├── api/                         # Network/API constants
│   ├── http_header_constants.dart
│   ├── network_constants.dart
│   ├── pagination_constants.dart
│   └── query_parameter_constants.dart
├── ui/                          # UI constants and pre-computed widgets
│   ├── spacing_constants.dart   # Raw values (double)
│   ├── spacing_widgets.dart     # Pre-computed SizedBox widgets
│   ├── padding_constants.dart   # Raw values (double)
│   ├── padding_widgets.dart     # Pre-computed EdgeInsets
│   ├── border_radius_constants.dart
│   ├── border_radius_widgets.dart
│   ├── breakpoint_constants.dart
│   ├── animation_constants.dart
│   └── ...                      # Other UI constants
├── duration_constants.dart      # Duration values for timeouts, animations
└── constants.dart               # Barrel file (exports all)
```

### Raw Constants

```dart
// spacing_constants.dart
abstract final class SpacingConstants {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
```

### Pre-computed Widgets

```dart
// spacing_widgets.dart
abstract final class SpacingWidgets {
  static const verticalXs = SizedBox(height: SpacingConstants.xs);
  static const verticalSm = SizedBox(height: SpacingConstants.sm);
  static const verticalMd = SizedBox(height: SpacingConstants.md);
  static const verticalLg = SizedBox(height: SpacingConstants.lg);

  static const horizontalXs = SizedBox(width: SpacingConstants.xs);
  static const horizontalSm = SizedBox(width: SpacingConstants.sm);
  // ...
}

// padding_widgets.dart
abstract final class PaddingWidgets {
  static const allSm = EdgeInsets.all(PaddingConstants.sm);
  static const allMd = EdgeInsets.all(PaddingConstants.md);
  static const screen = EdgeInsets.symmetric(
    horizontal: PaddingConstants.screenHorizontal,
    vertical: PaddingConstants.screenVertical,
  );
}

// border_radius_widgets.dart
abstract final class BorderRadiusWidgets {
  static const allSm = BorderRadius.all(Radius.circular(BorderRadiusConstants.small));
  static const allMd = BorderRadius.all(Radius.circular(BorderRadiusConstants.medium));
}
```

### Usage

```dart
// Before (magic numbers, repeated allocations)
Column(
  children: [
    Text('Title'),
    SizedBox(height: 16),  // Magic number!
    Text('Body'),
  ],
)

// After (clean, reusable, const)
Column(
  children: [
    Text('Title'),
    SpacingWidgets.verticalMd,  // Named constant
    Text('Body'),
  ],
)
```

See: `lib/core/constants/`

## Consequences

### Positive
- **No magic numbers**: All values are named
- **Performance**: Pre-computed `const` widgets
- **Consistency**: Single source of truth
- **Easy updates**: Change once, apply everywhere

### Negative
- **More files**: One per constant category

### Neutral
- Use `abstract final class` to prevent instantiation
