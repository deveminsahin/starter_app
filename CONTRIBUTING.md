# Contributing to Starter App

Thank you for your interest in contributing! This document provides guidelines and standards for contributing to this enterprise Flutter starter app.

---

## Table of Contents

- [Development Setup](#development-setup)
- [Code Style](#code-style)
- [Git Workflow](#git-workflow)
- [Testing Requirements](#testing-requirements)
- [Architecture Guidelines](#architecture-guidelines)
- [Pull Request Process](#pull-request-process)
- [Using Mason Bricks](#using-mason-bricks)

---

## Development Setup

### Prerequisites

- Flutter 3.38.7+ (stable channel)
- Dart SDK 3.5+
- IDE: VS Code (recommended) or Android Studio

### Setup Steps

```bash
# 1. Clone the repository
git clone <repository-url>
cd starter_app

# 2. Install dependencies
very_good packages get

# 3. Run code generation
dart run build_runner build --delete-conflicting-outputs

# 4. Run tests to verify setup
very_good test

# 5. Run the app
flutter run --flavor development --target lib/main_development.dart
```

### Environment Configuration

This project uses `--dart-define-from-file` with JSON config files in `config/`:

```
config/
├── development.json   # STRICT_ENV: false
├── staging.json       # STRICT_ENV: true
├── production.json    # STRICT_ENV: true
└── example.json       # Template
```

Run with a specific environment:

```bash
# Development
flutter run --flavor development --target lib/main_development.dart \
  --dart-define-from-file=config/development.json

# Production build
flutter build apk --flavor production --target lib/main_production.dart \
  --dart-define-from-file=config/production.json
```

---

## Code Style

### Linter

This project uses [very_good_analysis](https://pub.dev/packages/very_good_analysis) for linting. All code must pass:

```bash
flutter analyze
dart format . --set-exit-if-changed
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | snake_case | `user_repository.dart` |
| Classes | PascalCase | `UserRepository` |
| Variables | camelCase | `userName` |
| Constants | camelCase or SCREAMING_SNAKE | `maxRetries` or `MAX_RETRIES` |
| Private | Prefix with `_` | `_internalState` |
| Typedefs | PascalCase | `FutureResult<T>` (see `lib/core/domain/types/`) |

### Documentation

- All public APIs must have documentation comments
- Use `///` for documentation comments
- Include examples for complex APIs
- Use `@visibleForTesting` for test-only methods

```dart
/// Fetches the user profile from the remote data source.
///
/// Returns [Right<UserProfile>] on success or [Left<Failure>] on error.
///
/// Example:
/// ```dart
/// final result = await repository.getProfile(userId);
/// result.fold(
///   (failure) => handleError(failure),
///   (profile) => displayProfile(profile),
/// );
/// ```
FutureResult<UserProfile> getProfile(UniqueId userId);
```

---

## Git Workflow

### Branch Naming

```
feature/<short-description>    # New features
bugfix/<issue-number>-<desc>   # Bug fixes
hotfix/<critical-issue>        # Production hotfixes
refactor/<area>                # Code refactoring
docs/<topic>                   # Documentation updates
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples:**

```
feat(auth): add biometric login support
fix(profile): resolve avatar upload crash on iOS
docs(readme): update getting started section
test(auth): add integration tests for logout flow
```

---

## Testing Requirements

### Coverage Mandate

This project requires **100% test coverage**. All PRs must maintain this standard.

```bash
# Run tests with coverage
very_good test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html
```

### Test Types

| Type | Location | Purpose |
|------|----------|---------|
| Unit | `test/` | Domain, application, infrastructure logic |
| Widget | `test/` | UI components in isolation |
| Golden | `test/goldens/` | Visual regression (screenshots) |
| Property-Based | `test/**/` | Fuzz testing with [Glados](https://pub.dev/packages/glados) |
| Benchmark | `test/benchmarks/` | Performance metrics |
| Integration | `integration_test/` | Full user flows |

### Test File Structure

```
test/
├── core/
│   ├── domain/
│   │   └── entities/
│   │       └── user_test.dart  # Matches source structure
├── features/
│   └── auth/
│       ├── domain/
│       ├── application/
│       ├── infrastructure/
│       └── presentation/
└── helpers/                    # Shared test utilities
```

### Writing Good Tests

```dart
void main() {
  group('Login', () {
    late LoginUseCase useCase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = LoginUseCase(mockRepository);
    });

    test('should return User when credentials are valid', () async {
      // Arrange
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase(LoginParams(email: email, password: password));

      // Assert
      expect(result, equals(Right(testUser)));
      verify(() => mockRepository.login(email, password)).called(1);
    });
  });
}
```

---

## Architecture Guidelines

### Layer Responsibilities

| Layer | Purpose | Dependencies |
|-------|---------|--------------|
| **Domain** | Business logic, entities, interfaces | None |
| **Application** | Use cases, orchestration | Domain |
| **Infrastructure** | External services, data sources | Domain, Application |
| **Presentation** | UI, state management | All layers |

### Dependency Rule

> Source code dependencies can only point **inward**.

```
Presentation → Application → Domain ← Infrastructure
```

### Key Patterns

1. **Ports & Adapters**: Define interfaces in Domain, implement in Infrastructure
2. **CQRS**: Separate Commands (mutations) and Queries (reads)
3. **Result Pattern**: Return `Either<Failure, T>` instead of throwing

### Adding a New Feature

1. **Domain**: Create entities, value objects, and repository interface
2. **Infrastructure**: Implement repository, data sources, models
3. **Application**: Create use cases (Commands/Queries)
4. **Presentation**: Create BLoC, pages, widgets
5. **DI**: Register in dependency injection

See [ARCHITECTURE.md](./ARCHITECTURE.md) for detailed patterns and [MASON_GUIDE.md](./MASON_GUIDE.md) for code generation.

---

## Pull Request Process

### Before Submitting

- [ ] Code passes `flutter analyze` with zero warnings
- [ ] Code is formatted with `dart format .`
- [ ] All tests pass (`very_good test`)
- [ ] Test coverage is at 100%
- [ ] No TODO/FIXME comments left unaddressed
- [ ] Documentation is updated if needed
- [ ] New interactive widgets have accessibility support (tooltips, semantic labels)

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- How was this tested?
- Any specific test cases added?

## Screenshots (if applicable)
```

### Review Criteria

- Architecture compliance (Clean Architecture, DDD)
- Code quality (SOLID, DRY, Clean Code)
- Test coverage and quality
- Documentation completeness

---

## Using Mason Bricks

Generate boilerplate code using Mason bricks:

```bash
# Install Mason
dart pub global activate mason_cli

# Add project bricks
mason add feature --path ./bricks/feature

# Generate a new feature
mason make feature --feature_name payments
```

See [MASON_GUIDE.md](./MASON_GUIDE.md) for available bricks and templates.

---

## Versioning

This project follows [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH

1.0.0  → Initial release
1.0.1  → Patch (bug fixes, no API changes)
1.1.0  → Minor (new features, backward compatible)
2.0.0  → Major (breaking changes)
```

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1  # version+buildNumber
```

### Release Tags

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

---

## Sensitive Files

The following files are gitignored and must **never** be committed:

| Pattern | Reason |
|---------|--------|
| `config/*.json` | Environment secrets (API URLs, keys) |
| `.env`, `.env.*` | Environment variables |
| `*.jks` | Android signing keys |
| `key.properties` | Signing key paths |
| `google-services.json` | Firebase Android config |
| `GoogleService-Info.plist` | Firebase iOS config |
| `*.pem`, `*.p12` | Certificates |

Always use environment-based configuration. See [lib/core/application/CONFIGURATION.md](./lib/core/application/CONFIGURATION.md).

---

## Questions?

If you have questions about contributing, please open an issue with the `question` label.
