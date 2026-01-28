# Project Structure & Organization Rules

## Feature-First Architecture

### Core Principle

- **ALWAYS** organize code by business features/domains, NOT by technical layers
- Each feature represents a DDD Bounded Context, not a UI screen
- Features must be self-contained with all layers co-located
- **Exception:** Simple presentation-only features (static UI, navigation shells) may contain only the `presentation/` layer

### Directory Structure

```text
lib/
├── app/                        # Application-level configuration only
├── bootstrap.dart             # Shared initialization logic
├── core/                      # Shared utilities (strict dependency rules)
│   ├── api/                  # API interceptors and shared network components (configuration in di/modules)
│   ├── application/          # Core application-level services
│   ├── constants/            # Application-wide constants (sizes, durations, keys)
│   ├── di/                   # Global dependency injection setup (configureDependencies function)
│   ├── domain/               # Shared domain logic
│   │   ├── base/            # Base interfaces (Entity, ValueObject, UniqueId)
│   │   ├── ports/           # Abstract interfaces for infrastructure adapters (e.g., SessionManager)
│   │   ├── types/           # Domain-specific types and enums (e.g., WebSocketConnectionState)
│   │   └── value_objects/   # Shared value objects used across multiple features (e.g., EmailAddress)
│   ├── error/                # Error handling
│   │   ├── exceptions/      # Common exception definitions (e.g., ServerException)
│   │   └── failures/        # Failure types (Failure, InfrastructureFailure, ValueFailure)
│   ├── infrastructure/       # Shared infrastructure implementations
│   ├── l10n/                 # Flutter localization (arb files, generated AppLocalizations)
│   ├── logging/              # Flavor-based logging setup, BlocObserver, RouterObserver
│   ├── navigation/           # Global GoRouter configuration and observers
│   │   ├── app_router.dart          # Main router hub (imports all feature routes)
│   │   ├── route_definitions.dart   # Centralized path and name constants
│   │   ├── base_route.dart          # Base route class with custom transitions
│   │   ├── page_builder.dart        # Page transition builders
│   │   ├── app_router_observer.dart # Navigation debugging and tracking
│   │   └── adaptive_navigation_scaffold.dart  # Adaptive navigation patterns
│   ├── presentation/         # Shared presentation logic
│   │   ├── extensions/      # Shared BuildContext/Widget extensions
│   │   ├── failure_message/ # Failure to message mapping infrastructure
│   │   ├── models/          # Presentation models (e.g., ErrorModel)
│   │   ├── pages/           # Shared pages (e.g., error pages, splash screens)
│   │   ├── responsive/      # Responsive utilities (breakpoints, adaptive layouts)
│   │   ├── services/        # Presentation services (e.g., FailureMessageService)
│   │   └── widgets/         # Truly generic, reusable widgets (e.g., AppTextField)
│   ├── theme/                # App-wide theme data, color palettes, typography
│   └── types/                # Common application types (Result, FutureResult, Json)
├── features/                 # Business domain features
│   └── feature_name/
│       ├── domain/
│       │   ├── entities/       # Core business objects (e.g., User entity)
│       │   ├── failure/        # Feature-specific failures (e.g., AuthFailure)
│       │   ├── value_objects/  # Domain concepts without identity (e.g., AuthToken)
│       │   └── repositories/   # Abstract contracts (ports) for data access
│       ├── application/
│       │   └── usecases/       # Application-specific business operations
│       ├── infrastructure/
│       │   ├── datasources/    # Direct interaction with external data (e.g., API clients)
│       │   ├── mappers/        # DTO to entity mappers
│       │   ├── models/         # Data Transfer Objects (DTOs) with serialization logic
│       │   └── repositories/   # Concrete implementations of domain repository interfaces
│       └── presentation/
│           ├── bloc/           # BLoCs/Cubits for state management
│           ├── failure_message/  # Feature-specific failure message mappers
│           ├── pages/          # Top-level screen widgets
│           ├── widgets/        # Reusable widgets specific to this feature
│           └── routes/         # Route declarations (part of core/navigation/app_router.dart)
├── main_development.dart
├── main_staging.dart
└── main_production.dart
```

### Feature Naming

- ✅ **DO**: Name features after business domains
  - `product_catalog/`, `ordering/`, `authentication/`
- ❌ **DON'T**: Name features after UI screens
  - `product_list_page/`, `checkout_screen/`, `login_form/`

### Core Directory Rules

**The Unidirectional Dependency Rule (SACRED):**

- **Features CAN depend on core**
- **Core must NEVER depend on any feature**

This ensures that the core directory remains a stable foundation. The core directory is critical to the architecture, designed to house code that is genuinely shared across multiple features. However, it must be governed by strict rules to prevent it from becoming a miscellaneous "dumping ground" for code that lacks a clear home—a common anti-pattern that leads to tight coupling and architectural decay.

#### What Belongs in Core

- ✅ Base classes and interfaces (Entity, ValueObject, Failure)
- ✅ Truly shared utilities used by multiple features
- ✅ Application-wide configuration (theme, navigation, DI)
- ✅ Common infrastructure setup (API client, database, logging)
- ✅ Generic, reusable widgets (buttons, inputs, cards)

#### What Does NOT Belong in Core

- ❌ Feature-specific business logic
- ❌ Feature-specific widgets or pages
- ❌ Code used by only one feature (keep it in that feature)
- ❌ Generic catch-all folders without clear purpose

#### Organization by Purpose

- Avoid generic `utils/` folders
- Organize by architectural purpose (domain, infrastructure, presentation)
- Use specific folder names that describe the purpose (e.g., `extensions/`, `logging/`, `theme/`)

#### Value Objects and Failures

**Generic vs Domain-Specific:**

- `core/error/failures/value_failure.dart` contains ONLY generic validation failures (empty, tooShort, tooLong, invalidFormat, outOfRange)
- Domain-specific failures (email, URL, phone number) belong WITH their value objects
- Shared value objects go in `core/domain/value_objects/`
- Feature-specific value objects stay in `features/feature_name/domain/value_objects/`

**Example:**

```dart
// ✅ GOOD: Domain-specific failure with value object
// lib/core/domain/value_objects/email_address.dart
@freezed
class EmailFailure with _$EmailFailure {
  const factory EmailFailure.invalid() = _Invalid;
}

class EmailAddress implements ValueObject<String> {
  // Uses EmailFailure for email-specific validation
}

// ❌ BAD: Don't put email failures in core/error/failures/
```

### File Organization

- One class per file, named exactly as the class name in snake_case
- Group related files in subfolders by their architectural purpose
- Follow consistent naming conventions across all features
- Colocate domain-specific failures with their value objects
- Feature routes live in `features/[feature]/presentation/routes/` (not in core)

### Navigation Organization

**Core Navigation (Infrastructure):**

- `core/navigation/app_router.dart` - Main router hub that imports all feature routes
- `core/navigation/route_definitions.dart` - Centralized path/name constants
- `core/navigation/base_route.dart` - Base route class with transitions
- `core/navigation/page_builder.dart` - Custom page transition builders
- `core/navigation/app_router_observer.dart` - Navigation debugging
- `core/navigation/adaptive_navigation_scaffold.dart` - Adaptive navigation shell

**Feature Routes (Part of AppRouter):**

- Each feature declares routes in `presentation/routes/[feature]_routes.dart`
- Uses `part of` to join main router compilation unit
- Registered via `part` directive in `app_router.dart`

**Example Structure:**

```text
lib/
├── core/navigation/
│   ├── app_router.dart              # Main router hub
│   ├── app_router.g.dart            # Generated code
│   └── route_definitions.dart       # All route paths/names
│
└── features/
    └── product/
        └── presentation/
            ├── pages/
            │   └── product_page.dart
            └── routes/
                └── product_routes.dart    # part of app_router.dart
```

## Layer Structure Details

### A. The Domain Layer: The Business Core (The "Hexagon")

The Domain Layer is the innermost and most important part of the architecture. It contains the pure, unadulterated business logic and rules of the application, completely isolated from any external frameworks, libraries, or implementation details.

**Folder Structure:**

```text
features/feature_name/domain/
├── entities/          # Core business objects (e.g., Product, User)
├── value_objects/     # Domain concepts without identity (e.g., Price)
└── repositories/      # Abstract contracts (ports) for data access
```

### B. The Application Layer: Orchestrating Business Workflows

The Application Layer acts as a mediator between the Presentation Layer (UI) and the Domain Layer, orchestrating the execution of business logic in response to user actions.

**Folder Structure:**

```text
features/feature_name/application/
└── usecases/          # Application-specific business operations
```

### C. The Infrastructure Layer: Concrete Implementations (The "Adapters")

The Infrastructure Layer provides the concrete implementations for the abstract interfaces (ports) defined in the Domain Layer.

**Folder Structure:**

```text
features/feature_name/infrastructure/
├── datasources/       # Direct interaction with external data (e.g., API clients)
├── models/            # Data Transfer Objects (DTOs) with serialization logic
└── repositories/      # Concrete implementations of domain repository interfaces
```

### D. The Presentation Layer: UI, State, and User Interaction (Driving Adapters)

The Presentation Layer is responsible for everything the user sees and interacts with. In the context of Hexagonal Architecture, it is a "driving adapter"—it takes user input and drives the application core by calling use cases. It should contain as little logic as possible; its primary role is to display state and forward events.

**Folder Structure:**

```text
features/feature_name/presentation/
├── bloc/              # BLoCs/Cubits for state management
├── pages/             # Top-level screen widgets
├── widgets/           # Reusable widgets specific to this feature
└── routes/            # Route declarations (part of core/navigation/app_router.dart)
```

**Route Organization:**

Each feature owns its route declarations using the `part of` pattern:

```dart
// features/feature_name/presentation/routes/feature_routes.dart
part of '../../../../core/navigation/app_router.dart';

@TypedGoRoute<FeatureRoute>(
  path: RouteDefinitions.featurePath,
  name: RouteDefinitions.featureName,
)
class FeatureRoute extends BaseRoute with $FeatureRoute {
  const FeatureRoute();
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FeaturePage();
  }
}
```

Then registered in the main router:

```dart
// core/navigation/app_router.dart
part '../../features/feature_name/presentation/routes/feature_routes.dart';
```

This ensures:

- ✅ Each feature owns its routes (bounded context)
- ✅ Type-safe navigation with code generation
- ✅ Single compilation unit for all routes
- ✅ Core navigation doesn't depend on features

### Build Flavors

- Use separate entry points: `main_development.dart`, `main_staging.dart`, `main_production.dart`
- All shared initialization logic goes in `bootstrap.dart`
- Flavor-specific configuration in `core/app/flavor_config.dart`

## Reference Implementation

The **auth feature** serves as the reference implementation demonstrating all architectural layers:

```text
lib/features/auth/
├── domain/
│   ├── entities/          # User, AuthCredentials
│   ├── failure/           # AuthFailure (domain-specific failures)
│   ├── value_objects/     # AuthToken, RefreshToken
│   └── repositories/      # IAuthRepository interface
├── application/
│   └── usecases/          # Login, Register, CheckAuth, Logout
├── infrastructure/
│   ├── datasources/       # AuthRemoteDataSource, AuthLocalDataSource
│   ├── mappers/           # UserMapper (DTO ↔ Entity)
│   ├── models/            # UserModel (DTO with serialization)
│   └── repositories/      # AuthRepositoryImpl
└── presentation/
    ├── bloc/              # AuthBloc, AuthEvent, AuthState
    ├── failure_message/   # AuthFailureMapper (domain → localized messages)
    ├── pages/             # AuthPage
    ├── widgets/           # EmailTextField, PasswordTextField, etc.
    └── routes/            # auth_routes.dart
```

Use this structure as a template when creating new features.
