# Dashboard Feature

The dashboard feature provides the main landing page for authenticated users, displaying a responsive grid layout that adapts to different screen sizes.

## Structure

```
dashboard/
├── l10n/                           # Feature-specific localization
│   ├── dashboard_en.arb            # English translations
│   ├── dashboard_es.arb            # Spanish translations
│   ├── dashboard_localizations.dart    # Generated delegate
│   ├── dashboard_localizations_en.dart # Generated English
│   ├── dashboard_localizations_es.dart # Generated Spanish
│   └── l10n_extensions.dart        # BuildContext extension
├── presentation/
│   ├── pages/
│   │   └── dashboard_page.dart
│   └── routes/
│       └── dashboard_routes.dart
└── dashboard.dart                  # Barrel file
```

## Architecture

Currently a **presentation-only** feature. Future expansions may include:
- `domain/` - Dashboard entities and repository interfaces
- `application/` - Dashboard use cases (Commands/Queries)
- `infrastructure/` - Data sources and repository implementations

## Localization

Uses feature-scoped localization with `DashboardLocalizations`:

```dart
// Access via extension
final title = context.dashboardL10n.appBarTitle;
```

Supported locales: `en`, `es`

## Routing

The dashboard is part of the shell navigation (bottom tab bar):

```dart
const DashboardRoute() // Renders DashboardPage
```

Route is defined as a `StatefulShellBranchData` for navigation observer support.

## Responsive Design

Uses `ResponsiveGrid` from core presentation layer:

| Screen Size | Columns |
|-------------|---------|
| Compact     | 2       |
| Medium      | 3       |
| Expanded    | 4       |
| Large       | 5       |
| Extra Large | 6       |

## Testing

```bash
# Run dashboard tests
very_good test --no-optimization test/features/dashboard/

# With coverage
very_good test --coverage test/features/dashboard/
```
