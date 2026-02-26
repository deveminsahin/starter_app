# Flutter Enterprise Starter

![coverage][coverage_badge]
[![CI](https://github.com/deveminsahin/starter_app/actions/workflows/main.yaml/badge.svg)](https://github.com/deveminsahin/starter_app/actions/workflows/main.yaml)
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Flutter](https://img.shields.io/badge/Flutter-3.41.2-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.0-blue.svg)](https://dart.dev)

An **AI-ready**, enterprise-grade Flutter starter app built with **Clean Architecture**, **Domain-Driven Design (DDD)**, **Hexagonal Architecture**, and **100% test coverage**.

<p align="center">
  <img src="docs/demo.gif" alt="Demo" width="800"/>
</p>

<p align="center">
  <img src="docs/screenshot_light.png" alt="Light Mode" width="250"/>
  <img src="docs/screenshot_dark.png" alt="Dark Mode" width="250"/>
</p>

---

## ✨ What Makes This Different

| Feature | Description |
|---------|-------------|
| 🤖 **AI-Ready Architecture** | 23 architecture rules for AI-assisted development |
| 🧪 **100% Test Coverage** | Comprehensive tests across all layers |
| 🏗️ **CQRS Pattern** | Separate Commands (write) and Queries (read) |
| 🔐 **Type-Safe Routing** | go_router_builder with compile-time route safety |
| ⚙️ **Environment Config** | `--dart-define-from-file` for secure configuration |
| 🧱 **Mason Bricks** | Code generators for consistent feature scaffolding |
| 📱 **Adaptive UI** | Material 3 canonical layouts with 5-class breakpoint system |
| 🔄 **Token Refresh** | Automatic 401 handling with thread-safe refresh |
| 🛡️ **Security** | Secure storage, certificate pinning, code obfuscation |
| 🌐 **Feature-First i18n** | ARB files per feature with `gen_l10n` |
| ♿ **Accessibility** | WCAG 2.1 compliant with semantic labels |
| 📊 **Structured Logging** | IAppLogger with environment-specific outputs |

---

## 🏛️ Architecture Overview

This project follows **Hexagonal Architecture** (Ports & Adapters) with **DDD tactical patterns**:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              PRESENTATION                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Pages     │  │   Widgets   │  │    BLoC     │  │   Routes    │        │
│  │  (Views)    │  │ (Reusable)  │  │ (State Mgmt)│  │ (Type-Safe) │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────────────────────┤
│                              APPLICATION                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Commands   │  │   Queries   │  │  Use Cases  │  │   Events    │        │
│  │ (Write Ops) │  │ (Read Ops)  │  │ (Orchestr.) │  │ (Domain)    │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                DOMAIN                                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Entities   │  │Value Objects│  │    Ports    │  │   Failures  │        │
│  │ (Identity)  │  │(Validation) │  │ (Interfaces)│  │ (Either<>)  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────────────────────┤
│                            INFRASTRUCTURE                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │Repositories │  │Data Sources │  │   Chopper   │  │   Secure    │        │
│  │ (Adapters)  │  │ (Remote/DB) │  │ (HTTP/WS)   │  │  Storage    │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Core Patterns

| Pattern | Implementation |
|---------|---------------|
| **CQRS** | Commands for writes, Queries for reads |
| **Railway-Oriented** | `Either<Failure, T>` with fpdart |
| **Hexagonal** | Ports (interfaces) & Adapters (implementations) |
| **Type-Safe Routing** | `@TypedGoRoute` with go_router_builder |
| **Interceptor Chain** | Auth → Refresh → Logging → Error (Chopper) |
| **Adaptive Navigation** | Bottom nav, Rail, or Drawer based on screen size |

### Included Features

| Feature | Description |
|---------|-------------|
| 🔐 **Authentication** | Login, Register, Token refresh, Logout with secure storage |
| 📊 **Dashboard** | Home screen with adaptive navigation (Bar/Rail/Drawer) |
| 👤 **Profile** | User profile management |
| 📦 **Orders** | Order management and history |
| ⚙️ **Settings** | Theme & locale switching with HydratedBloc persistence |
| 🚩 **Feature Flags** | Runtime feature toggles without third-party services |
| 🔌 **WebSocket** | Real-time communication with auto-reconnect |
| 🌐 **API Client** | Chopper with Auth, Refresh, Logging, Error interceptors |

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.41.2 (stable)
- Dart 3.11.0
- [Very Good CLI](https://pub.dev/packages/very_good_cli): `dart pub global activate very_good_cli`

### Quick Start

```bash
# 1. Clone and install
git clone https://github.com/deveminsahin/starter_app.git
cd starter_app
very_good packages get

# 2. Run code generation
dart run build_runner build --delete-conflicting-outputs

# 3. Run tests
very_good test --coverage

# 4. Launch app
flutter run \
  --flavor development \
  --target lib/main_development.dart \
  --dart-define-from-file=config/development.json
```

---

## ⚙️ Environment Configuration

This project uses `--dart-define-from-file` for secure, type-safe environment configuration:

```
config/
├── development.json.example   # Copy and remove .example
├── staging.json.example       # Copy and remove .example
├── production.json.example    # Copy and remove .example
└── example.json               # Template reference
```

> [!IMPORTANT]
> **First-time setup**: Copy the `.example` files and remove the `.example` suffix:
> ```bash
> cd config
> cp development.json.example development.json
> cp staging.json.example staging.json
> cp production.json.example production.json
> ```

### Running with Environment Config

```bash
# Development
flutter run \
  --flavor development \
  --target lib/main_development.dart \
  --dart-define-from-file=config/development.json

# Staging
flutter run \
  --flavor staging \
  --target lib/main_staging.dart \
  --dart-define-from-file=config/staging.json

# Production
flutter run \
  --flavor production \
  --target lib/main_production.dart \
  --dart-define-from-file=config/production.json
```

### VS Code Launch Config

Pre-configured in `.vscode/launch.json` for one-click debugging.

---

## 🗺️ Type-Safe Navigation

Routes are **fully type-safe** using `go_router_builder`:

```dart
// Navigate with compile-time safety
const AuthRoute().go(context);
const DashboardRoute().go(context);

// Route definition (features/auth/presentation/routes/auth_routes.dart)
@TypedGoRoute<AuthRoute>(
  path: RouteDefinitions.authPath,
  name: RouteDefinitions.authName,
)
class AuthRoute extends BaseRoute with $AuthRoute {
  const AuthRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AuthPage();
  }
}
```

### Route Architecture

- **Centralized definitions**: `core/navigation/route_definitions.dart`
- **Feature-owned routes**: Each feature declares its routes via `part of`
- **Custom transitions**: Shared page transitions in `base_route.dart`
- **Adaptive navigation**: Bottom nav, rail, or drawer based on screen size

---

## 🧪 Testing

**100% test coverage** with comprehensive tests across all layers. Uses Very Good CLI for proper coverage reporting.

```bash
# Run all tests with coverage
very_good test --coverage

# Run specific test file
very_good test test/features/auth/application/usecases/login_test.dart

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Update golden files
very_good test --update-goldens
```

### Test Types

| Type | Location | Purpose |
|------|----------|---------|
| **Unit** | `test/` | Domain logic, use cases, repositories |
| **Widget** | `test/` | UI components with `pumpApp` helper |
| **BLoC** | `test/` | State management with `bloc_test` |
| **Golden** | `test/goldens/` | Visual regression screenshots |
| **Property-Based** | `test/` | Fuzz testing with Glados |
| **Benchmark** | `test/benchmarks/` | Performance metrics |
| **Integration** | `integration_test/` | Full user flows |

---

## 📁 Project Structure

```
lib/
├── app/                    # App entry point, providers
├── core/                   # Shared infrastructure
│   ├── api/               # Chopper HTTP client, interceptors
│   ├── application/       # Bootstrap, environment
│   ├── di/                # Dependency injection (get_it + injectable)
│   ├── domain/            # Base classes (Entity, ValueObject)
│   ├── error/             # Failure types, exception handling
│   ├── feature_flags/     # Runtime feature toggles
│   ├── infrastructure/    # Base repositories, WebSocket
│   ├── l10n/              # Localization (gen_l10n)
│   ├── navigation/        # GoRouter, type-safe routes
│   ├── presentation/      # Shared widgets, failure messages
│   └── theme/             # Material 3, flex_color_scheme
└── features/              # Business domain features
    ├── auth/              # Authentication (reference implementation)
    ├── dashboard/         # Home with adaptive navigation
    ├── orders/            # Order management
    ├── profile/           # User profile management
    └── settings/          # Theme & locale switching
```

---

## 🤖 AI-Ready Development

This project includes **23 architecture rule files** in `docs/architecture-rules/` for AI-assisted development:

| Category | Rules |
|----------|-------|
| **Core Architecture** | Project structure, layers, domain, application, infrastructure, presentation |
| **Patterns** | State management, error handling, DI, navigation, data modeling |
| **Quality** | Testing, code quality, accessibility, theming |
| **Integration** | API integration, i18n, security, logging, performance |

AI tools can understand and generate architecture-compliant code using these rules.

---

## � Mason Bricks

Generate architecture-compliant code with Mason:

```bash
# Install Mason CLI
dart pub global activate mason_cli

# Generate a new feature
mason make feature --feature_name payments

# Generate a use case
mason make use_case --name get_payment_history

# Available bricks: feature, use_case, bloc, entity, value_object, repository
```

See [MASON_GUIDE.md](./MASON_GUIDE.md) for detailed templates.

---

## 📦 Tech Stack

### Core
| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management |
| `go_router` + `go_router_builder` | Type-safe navigation |
| `get_it` + `injectable` | Dependency injection |
| `fpdart` | Functional error handling |
| `freezed` | Immutable data classes |

### Infrastructure
| Package | Purpose |
|---------|---------|
| `chopper` | HTTP client with code generation |
| `flutter_secure_storage` | Secure token storage |
| `hydrated_bloc` | Persistent state |
| `flex_color_scheme` | Material 3 theming |
| `synchronized` | Thread-safe locks (token refresh) |

### Quality
| Package | Purpose |
|---------|---------|
| `very_good_analysis` | Strict linting |
| `bloc_test` | BLoC testing utilities |
| `mocktail` | Mocking framework |
| `glados` | Property-based testing |

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](./ARCHITECTURE.md) | System design and patterns |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Development guidelines |
| [CHANGELOG.md](./CHANGELOG.md) | Version history |
| [MASON_GUIDE.md](./MASON_GUIDE.md) | Code generation templates |
| [docs/adr/](./docs/adr/) | Architecture Decision Records |

---

## 🔌 Backend (Optional)

Want to test with a real backend? A companion **Spring Boot** server is available:

👉 **[starter_app_backend](https://github.com/deveminsahin/starter_app_backend)**

```bash
# Option 1: Run with Docker
git clone https://github.com/deveminsahin/starter_app_backend.git
cd starter_app_backend
docker-compose up

# Option 2: Run directly (requires Java 25+)
./gradlew bootRun
```

Backend runs at `http://localhost:8080`. The Flutter app is pre-configured to connect.

### Backend Features

| Feature | Endpoint | Description |
|---------|----------|-------------|
| 🔐 Authentication | `/api/v1/auth/*` | Register, Login, Refresh, Logout |
| 👤 Profile | `/api/v1/profiles/*` | Create, Read, Update profile |
| 🔄 WebSocket | `/ws/auth` | Real-time auth state notifications |

> [!NOTE]
> The backend uses an in-memory H2 database for development. All data resets on restart.

---

## ☕ Support

If you find this project useful, consider supporting its development:

<a href="https://www.buymeacoffee.com/deveminsahin" target="_blank">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="50">
</a>

---

## 🤝 Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for development setup, code style, and PR guidelines.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

---

[coverage_badge]: coverage_badge.svg
[flutter_localizations_link]: https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html
[internationalization_link]: https://flutter.dev/docs/development/accessibility-and-localization/internationalization
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
