# Core Presentation Layer

The presentation layer is responsible for UI rendering, user interactions, and visual state management. It follows Clean Architecture principles by depending only on the domain layer, never on infrastructure.

## Architecture Overview

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────────┐ │
│  │   Pages     │    │  Widgets    │    │        BLoC/Cubit           │ │
│  │ (Routes)    │───▶│ (Reusable)  │    │ (ThemeCubit, LocaleCubit)   │ │
│  └─────────────┘    └─────────────┘    └─────────────────────────────┘ │
│         │                  │                        │                   │
│         ▼                  ▼                        ▼                   │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     Models & Services                            │   │
│  │  ErrorModel, FailureMessageService, FailureMapperRegistry       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │               Responsive Utilities                               │   │
│  │  ScreenSize, AdaptiveLayoutBuilder, BuildContext Extensions     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                           ┌────────────────┐
                           │  DOMAIN LAYER  │
                           │ (Value Objects │
                           │  Entities)     │
                           └────────────────┘
```

## Directory Structure

```text
presentation/
├── bloc/                      # Cross-cutting state management
│   ├── README.md              # Detailed bloc documentation
│   ├── bloc.dart              # Barrel file
│   ├── theme_cubit.dart       # Theme mode management (dark/light/system)
│   └── locale_cubit.dart      # Locale/language management
├── extensions/                # BuildContext extensions
│   └── context_extensions.dart
├── failure_message/           # Failure-to-message mapping system
│   ├── failure_message.dart   # Barrel file
│   ├── failure_mapper_registry.dart
│   ├── failure_message_mapper.dart
│   └── infrastructure_failure_mapper.dart
├── models/                    # Presentation models
│   ├── error_model.dart       # UI error wrapper for Failures
│   └── error_model.freezed.dart
├── pages/                     # Shared pages
│   ├── pages.dart             # Barrel file
│   └── error_page.dart        # 404 and error display
├── responsive/                # Adaptive UI utilities (Material 3)
│   ├── README.md              # Comprehensive responsive docs
│   ├── COMPATIBILITY.md       # Migration guide
│   ├── responsive.dart        # Barrel file
│   ├── screen_size.dart       # Five-class breakpoint system
│   ├── adaptive_layout_builder.dart
│   ├── build_context_extension.dart
│   ├── responsive_container.dart
│   └── responsive_spacing.dart
├── services/                  # Presentation services
│   └── failure_message_service.dart
└── widgets/                   # Reusable widgets
    ├── widgets.dart           # Barrel file
    ├── adaptive_navigation_scaffold.dart
    ├── app_snackbar.dart
    ├── app_text_field.dart
    ├── email_text_field.dart
    ├── loading_overlay.dart
    └── password_text_field.dart
```

## Core Principles

### 1. Dependency Direction

The presentation layer **only** depends on the domain layer:

```dart
// ✅ ALLOWED - Domain imports
import 'package:starter_app/core/domain/value_objects/email_address.dart';
import 'package:starter_app/core/error/failures/failure.dart';

// ❌ FORBIDDEN - Infrastructure imports
// import 'package:starter_app/core/infrastructure/...';
```

### 2. No Business Logic

Presentation components display data and delegate actions. They never:
- Make business decisions
- Transform domain data (use mappers)
- Access repositories directly

```dart
// ✅ GOOD - Delegate to BLoC
onPressed: () => context.read<AuthBloc>().add(LoginSubmitted())

// ❌ BAD - Business logic in widget
onPressed: () async {
  final result = await userRepository.login(email, password);
  // This belongs in a use case, not the UI!
}
```

### 3. BLoC/Cubit for State

State management uses BLoC pattern with:
- `HydratedCubit` for persisted state (theme, locale)
- Feature BLoCs for complex flows (in `features/*/presentation/bloc/`)

## Key Components

### ThemeCubit & LocaleCubit

Cross-cutting cubits for app-wide preferences:

```dart
// Access in widgets
context.read<ThemeCubit>().toggleTheme();
context.read<LocaleCubit>().setSpanish();

// Listen in MaterialApp
BlocBuilder<ThemeCubit, AppThemeMode>(
  builder: (context, mode) => MaterialApp(
    themeMode: mode.toThemeMode(),
    // ...
  ),
)
```

### ErrorModel

Bridges domain failures to UI without exposing internals:

```dart
// In BLoC - wrap failure
final error = ErrorModel.fromFailure(failure);
emit(state.copyWith(error: error));

// In UI - get message
final message = error.getMessage(context, failureMessageService);
showSnackBar(message);
```

### Failure Message Mapping

Self-registering mapper system for translating failures:

```dart
@injectable
class PaymentFailureMapper extends FailureMessageMapper {
  PaymentFailureMapper(super.registry); // Auto-registers!

  @override
  bool canHandle(Failure failure) => failure is PaymentFailure;

  @override
  String map(BuildContext context, Failure failure) {
    final f = failure as PaymentFailure;
    return f.map(
      insufficientFunds: (_) => context.l10n.insufficientFunds,
      cardDeclined: (_) => context.l10n.cardDeclined,
    );
  }
}
```

### Responsive Design

Material 3 adaptive layouts with five breakpoints:

```dart
AdaptiveLayoutBuilder(
  builder: (context, screenSize) => switch (screenSize) {
    ScreenSize.compact => const MobileLayout(),
    ScreenSize.medium => const TabletLayout(),
    _ => const DesktopLayout(),
  },
)

// Context extensions
if (context.isMobile) { /* ... */ }
final padding = context.responsivePadding;
final columns = context.responsiveGridColumns;
```

### Reusable Widgets

Domain-aware input fields and common components:

```dart
// Email field with value object validation
EmailTextField(
  email: state.email,
  showError: state.validation.emailTouched,
  onChanged: (value) => bloc.add(EmailChanged(value)),
)

// Password field with visibility toggle
PasswordTextField(
  password: state.password,
  showError: state.validation.passwordTouched,
)

// Loading overlay
LoadingOverlay(
  isLoading: state.isSubmitting,
  child: content,
)
```

## Guidelines

### Widget Rules

- ✅ Use `const` constructors wherever possible
- ✅ Extract reusable widgets with callbacks (not BLoC access)
- ✅ Use domain entities, not DTOs
- ✅ Implement proper keys for list items
- ❌ Don't access BLoC directly in reusable widgets
- ❌ Don't perform logic in build methods

### Page/View Separation

```dart
// Page - Creates BLoC, triggers initial load
class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductListBloc>()
        ..add(const ProductListEvent.fetchProducts()),
      child: const ProductListView(),
    );
  }
}

// View - Pure UI
class ProductListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListBloc, ProductListState>(
      builder: (context, state) {
        return state.when(
          loading: () => const LoadingIndicator(),
          success: (products) => ProductList(products: products),
          error: (failure) => ErrorView(failure: failure),
        );
      },
    );
  }
}
```

### BLoC Listeners for Side Effects

```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    state.whenOrNull(
      error: (error) {
        final service = context.read<FailureMessageService>();
        final message = error.getMessage(context, service);
        context.showSnackBar(message: message);
      },
    );
  },
  child: const AuthView(),
)
```

## Testing

Tests are in `test/core/presentation/` with:
- Widget tests for all components
- BLoC tests using `bloc_test`
- Golden tests for visual regression

```bash
# Run presentation tests
very_good test test/core/presentation/

# Run with coverage
very_good test test/core/presentation/ --coverage
```

## See Also

- [bloc/README.md](bloc/README.md) - ThemeCubit & LocaleCubit details
- [responsive/README.md](responsive/README.md) - Adaptive UI system
- [Architecture Rules](../../../docs/architecture-rules/06_presentation_layer.md)
