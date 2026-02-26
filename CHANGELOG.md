# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- Architecture Decision Records (ADRs) in `docs/adr/`
- Operational documentation in `docs/operations/`
- Enhanced `ARCHITECTURE.md` with Mermaid diagrams
- `CONTRIBUTING.md` with development guidelines
- AI architecture rules in `docs/architecture-rules/` (23 rule files)
- Buy Me a Coffee support section in README
- Social media launch templates in `social/`

### Changed
- Updated Flutter SDK to 3.41.2
- Updated Dart SDK to 3.11.0
- Replaced iOS launch screen with default Flutter template
- Updated macOS entitlements for keychain access
- Test count increased to 2,282 tests

---

## [1.0.0] - 2026-01-15

### Added

#### Architecture & Patterns
- **Clean Architecture** with strict layer separation
- **Domain-Driven Design (DDD)** tactical patterns
  - Aggregate Roots (`User`, `UserProfile`)
  - Domain Events (`UserRegistered`, `UserLoggedIn`, `UserProfileUpdated`)
  - Specifications (`UserCanLoginSpec`)
  - Value Objects (`EmailAddress`, `UniqueId`, `Name`, `ImageUrl`)
- **CQRS** pattern with Command/Query separation
- **Hexagonal Architecture** (Ports & Adapters)

#### Core Modules
- **Error Handling**: `Failure` base class with stack trace preservation
- **Exception Handler**: Centralized exception-to-failure mapping
- **API Layer**: Chopper-based HTTP client with interceptors
  - Auth interceptor with token injection
  - Refresh token interceptor with lock mechanism
  - Logging interceptor with sensitive data redaction
  - Error interceptor for consistent error handling
- **WebSocket Support**: Reconnection with exponential backoff
- **Feature Flags**: Runtime feature toggles with override support
- **Circuit Breaker**: Network resilience for transient failures
- **Certificate Pinning**: Security hardening for API calls

#### Features
- **Authentication**: Login, Register, Token refresh, Logout
- **Dashboard**: Home screen with navigation
- **Profile**: User profile management with updates
- **Settings**: Theme switching, locale selection

#### Infrastructure
- **State Management**: flutter_bloc for predictable state
- **Dependency Injection**: injectable + get_it
- **Navigation**: go_router with type-safe routes
- **Theming**: Material 3 with dark mode support
- **Localization**: flutter_localizations with ARB files
- **Logging**: Structured logging with multiple strategies
- **Secure Storage**: flutter_secure_storage for sensitive data

#### Testing
- **100% Test Coverage**: 2,282 tests, 3136/3136 lines covered
- **Golden Tests**: Visual regression testing
- **Property-Based Tests**: Fuzz testing with Glados for value objects
- **Benchmark Tests**: Performance metrics for critical paths
- **Integration Tests**: Full user flow coverage

#### Documentation
- `ARCHITECTURE.md`: High-level system design
- `MASON_GUIDE.md`: Code generation templates
- `README.md`: Getting started guide

### Security
- No hardcoded secrets or API keys
- Environment-based configuration
- Secure token storage
- Network request logging with redaction

---

## [0.1.0] - Initial Release

- Project scaffolding with Very Good CLI
- Basic Flutter app structure
- Development, staging, and production flavors

---

[Unreleased]: https://github.com/deveminsahin/starter_app/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/deveminsahin/starter_app/compare/v0.1.0...v1.0.0
[0.1.0]: https://github.com/deveminsahin/starter_app/releases/tag/v0.1.0
