# Orders Feature

Deep-link protected route demonstrating route protection patterns.

## Structure

```
lib/features/orders/
├── l10n/                          # Feature-scoped localizations
│   ├── orders_en.arb              # English strings with @key descriptions
│   ├── orders_es.arb              # Spanish translations
│   ├── orders_localizations.dart
│   └── l10n_extensions.dart       # BuildContext extension
├── presentation/
│   ├── orders_page.dart           # Main orders page
│   └── routes/
│       └── orders_route.dart      # TypedGoRoute definition
└── orders.dart                    # Barrel export
```

## Features

| Feature | Description |
|---------|-------------|
| **Deep-link Protection** | Route accessible only when authenticated |
| **Type-safe Routing** | Uses `TypedGoRoute` for compile-time safety |
| **Localization** | Full EN/ES support |

## Usage

```dart
// Navigate to orders (requires authentication)
const OrdersRoute().go(context);
```

## Route Protection

The orders feature demonstrates deep-link protection:

```dart
@TypedGoRoute<OrdersRoute>(
  path: RouteDefinitions.ordersPath,
  name: RouteDefinitions.ordersName,
)
final class OrdersRoute extends BaseRoute with $OrdersRoute {
  const OrdersRoute();
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OrdersPage();
  }
}
```

## Localization

Access orders-scoped localizations:

```dart
final l10n = context.ordersL10n;
Text(l10n.appBarTitle);  // "Orders" or "Pedidos"
```

## Tests

```bash
very_good test test/features/orders/
```

| Test File | Coverage |
|-----------|----------|
| `orders_localizations_test.dart` | Delegate, lookup, all strings, context access |
