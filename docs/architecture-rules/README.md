# Flutter Enterprise Architecture Rules

Enterprise Flutter architecture rules based on Domain-Driven Design (DDD), Hexagonal Architecture, and Test-Driven Development (TDD).

## Rule Files Overview

### Core Architecture (01-14)

1. **01_project_structure.md** - Feature-first organization, directory structure
2. **02_layer_architecture.md** - Hexagonal architecture, dependency rules
3. **03_domain_layer.md** - Entities, value objects, repository interfaces
4. **04_application_layer.md** - Use cases and business workflow orchestration
5. **05_infrastructure_layer.md** - Repository implementations, data sources, models
6. **06_presentation_layer.md** - BLoCs, pages, widgets, UI patterns
7. **07_state_management.md** - BLoC patterns, HydratedBloc, event transformers
8. **08_error_handling.md** - Failure types, Either pattern, error mapping
9. **09_dependency_injection.md** - Injectable, GetIt, DI best practices
10. **10_testing_standards.md** - Unit, widget, integration, golden tests
11. **11_data_modeling.md** - Freezed, immutability, union types
12. **12_code_quality.md** - Linting, formatting, documentation
13. **13_navigation.md** - GoRouter, type-safe routing
14. **14_adaptive_ui_strategy.md** - Responsive design, breakpoints, adaptive layouts

### Cross-Cutting Concerns (15-23)

15. **15_security.md** - Token storage, authentication, API security, input validation
16. **16_performance.md** - Widget optimization, list performance, memory management
17. **17_logging.md** - IAppLogger interface, structured logging, log levels
18. **18_i18n.md** - Internationalization, ARB files, locale management, gen_l10n
19. **19_api_integration.md** - Chopper setup, interceptors, hybrid models approach
20. **20_failure_handling_architecture.md** - Detailed failure handling flow, mappers, and patterns
21. **21_mason_bricks.md** - Mason code generation, brick usage, pattern enforcement
22. **22_accessibility.md** - A11Y, WCAG guidelines, semantic labels, screen readers
23. **23_theming.md** - Material 3, ColorScheme, ThemeExtension, typography

> **Git Guidelines**: See [CONTRIBUTING.md](../../CONTRIBUTING.md) for commit format, branch naming, and PR process.


## Key Architectural Principles

### The Sacred Dependency Rule

**Dependencies MUST ONLY point inward:**

```text
Presentation → Application → Domain ← Infrastructure
```

### Layer Responsibilities

- **Domain**: Pure business logic (entities, value objects, interfaces)
- **Application**: Workflow orchestration (Commands & Queries - CQRS pattern)
- **Infrastructure**: External system adapters (APIs, databases)
- **Presentation**: UI and state management (widgets, BLoCs)

### CQRS Pattern

The application layer follows **Command Query Responsibility Segregation (CQRS)**:

- **Commands**: Write operations that mutate state (`Command`, `CommandNoParams`)
- **Queries**: Read operations that don't mutate state (`Query`, `QueryNoParams`)

This provides semantic clarity and better code organization while maintaining all existing patterns (Either, Freezed, BLoC).

### Golden Rules

1. Domain layer has ZERO external dependencies
2. Features are organized by business domain, not UI screens
3. **Entities are NOT freezed** - use plain Dart classes with Entity/AggregateRoot (ADR-008)
4. **Freezed IS used for**: failures, BLoC events/states, DTOs (ADR-008)
5. Error handling uses Either<Failure, T> (no exceptions in business logic)
6. Use cases inject repository interfaces, not implementations
7. BLoCs are thin orchestrators, not business logic containers
8. Test coverage target: 100% across all layers
9. Never log sensitive data (passwords, tokens, PII)
10. Use typed models at data source layer, maps at API service layer
11. Localization strings in feature-specific ARB files

## Quick Reference

### Starting a New Feature

1. **Create feature directory**: `lib/features/feature_name/`
2. **Create layers**: `domain/`, `application/`, `infrastructure/`, `presentation/`
3. **Define domain entities and repository interfaces first** (TDD)
4. **Create localization files**: `lib/core/l10n/arb/feature_name/feature_name_en.arb`
5. **Define API endpoints**: `infrastructure/datasources/feature_name_endpoints.dart`
6. **Create typed models**: Request/response models with `@freezed`
7. **Implement use cases**: Business logic orchestration
8. **Implement data source**: Type conversion boundary (models ↔ JSON)
9. **Implement repository**: Domain boundary (models → entities)
10. **Create BLoC**: State management with union states
11. **Build UI**: Pages and widgets with localized strings
12. **Write comprehensive tests**: Target 100% coverage
13. **Generate code**: Run `dart run build_runner build` and `./generate_localizations.sh`

### Running Tests

**IMPORTANT**: Use `very_good` CLI for proper coverage reporting.

```bash
# All tests with coverage
very_good test --coverage

# Specific test file
very_good test test/features/auth/domain/entities/user_test.dart

# Update golden files
very_good test --update-goldens
```

### Code Generation

```bash
# Generate freezed, injectable, chopper code (one-time)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation
dart run build_runner watch --delete-conflicting-outputs

# Generate localizations (feature-first ARB files)
./generate_localizations.sh
```

## Technology Stack

### Core
- **State Management**: flutter_bloc, hydrated_bloc
- **DI**: get_it, injectable
- **Navigation**: go_router
- **Data Modeling**: freezed, json_serializable
- **Functional Programming**: fpdart

### Infrastructure
- **API Client**: chopper (HTTP client generation)
- **Secure Storage**: flutter_secure_storage (tokens, sensitive data)
- **Cache**: hive (local persistence)
- **Logging**: Official Dart logging package

### Code Quality
- **Linting**: very_good_analysis
- **Code Generation**: build_runner

### UI/UX
- **Theming**: flex_color_scheme
- **Responsive Design**: flutter_screenutil (optional)
- **Internationalization**: gen_l10n (feature-first ARB files)

## Contact & Support

For questions about these rules or the architecture, refer to the full architecture document: `Enterprise Flutter Architecture.md`
