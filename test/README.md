# Testing Guide

This document provides guidelines for writing and organizing tests in this project.

## Running Tests

```bash
# Run all unit and widget tests (use very_good CLI)
very_good test

# Run with coverage
very_good test --coverage

# Run specific test file
very_good test test/features/auth/application/usecases/login_test.dart

# Run tests matching a pattern
very_good test --dart-define name="login"

# Run integration tests
flutter test integration_test/

# Generate coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```


## Folder Structure

```text
test/
├── app/                          # App-level tests
│   └── view/
├── core/                         # Core module tests (mirrors lib/core/)
│   ├── api/
│   ├── domain/
│   ├── error/
│   ├── l10n/
│   ├── navigation/
│   ├── presentation/
│   ├── storage/
│   └── theme/
├── features/                     # Feature tests (mirrors lib/features/)
│   ├── auth/
│   │   ├── application/usecases/
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   └── presentation/
│   ├── home/
│   ├── profile/
│   └── settings/
├── helpers/                      # Test utilities
│   ├── fixtures/                 # Complex test data scenarios
│   ├── fake_helpers.dart         # Fake implementations
│   ├── golden_test_helper.dart   # Golden test utilities
│   ├── helpers.dart              # Barrel file
│   ├── matchers.dart             # Custom matchers
│   ├── mock_helpers.dart         # Mock classes
│   ├── pump_app.dart             # Widget test helpers
│   └── test_data.dart            # Test data fixtures
├── flutter_test_config.dart      # Global test configuration
└── README.md                     # This file

integration_test/                 # End-to-end tests
├── helpers/
└── app_test.dart
```

## Test Helpers

### TestData - Centralized Test Fixtures

**Always use `TestData` instead of creating local test data.**

```dart
import '../../helpers/test_data.dart';

// ✅ GOOD - Use TestData primitives
const tEmail = TestData.email;
const tPassword = TestData.password;

// ✅ GOOD - Use TestData models
const tUserModel = TestData.userModel;
const tAuthResponse = TestData.authResponseModel;

// ✅ GOOD - Use factory methods for domain objects
final user = TestData.user();
final customUser = TestData.user(name: 'Custom Name');
final credentials = TestData.loginCredentials();

// ❌ BAD - Don't duplicate test data
const tEmail = 'test@example.com';  // Use TestData.email instead!
```

### Mock Helpers

```dart
import '../../helpers/mock_helpers.dart';

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });
}
```

### Widget Test Helpers

```dart
import '../../helpers/pump_app.dart';

testWidgets('renders correctly', (tester) async {
  await tester.pumpApp(const MyWidget());
  // or with BLoC providers
  await tester.pumpAppWithBloc(
    const MyWidget(),
    providers: [BlocProvider.value(value: mockBloc)],
  );
});
```

## Writing Tests

### Test File Naming

- Test files must end with `_test.dart`
- Mirror the source file path: `lib/features/auth/domain/entities/user.dart` → `test/features/auth/domain/entities/user_test.dart`

### Test Structure

Follow the **Given-When-Then** (Arrange-Act-Assert) pattern:

```dart
test('should return Right(User) when login succeeds', () async {
  // Given (Arrange)
  when(() => mockRepository.login(any()))
      .thenAnswer((_) async => Right(TestData.user()));

  // When (Act)
  final result = await useCase(TestData.loginCredentials());

  // Then (Assert)
  expect(result.isRight(), true);
  verify(() => mockRepository.login(any())).called(1);
});
```

### Grouping Tests

```dart
void main() {
  group('Login', () {
    group('success cases', () {
      test('should return user when credentials are valid', () {});
      test('should save tokens on successful login', () {});
    });

    group('failure cases', () {
      test('should return unauthorized when credentials are invalid', () {});
      test('should return network failure when offline', () {});
    });

    group('integration scenarios', () {
      test('complete login flow', () {});
    });
  });
}
```

### BLoC Testing

```dart
import 'package:bloc_test/bloc_test.dart';

blocTest<AuthBloc, AuthState>(
  'emits [loading, authenticated] when login succeeds',
  build: () {
    when(() => mockLogin(any()))
        .thenAnswer((_) async => Right(TestData.user()));
    return AuthBloc(mockLogin, ...);
  },
  act: (bloc) => bloc.add(const AuthLoginSubmitted()),
  expect: () => [
    isA<AuthState>().having((s) => s.isSubmitting, 'isSubmitting', true),
    isA<Authenticated>(),
  ],
);
```

## Test Categories

### Unit Tests

Test individual classes/functions in isolation.

- **Location**: `test/`
- **What to test**: Use cases, repositories, mappers, value objects
- **Dependencies**: Mocked

### Widget Tests

Test widget behavior and rendering.

- **Location**: `test/`
- **What to test**: Pages, widgets, UI components
- **Dependencies**: Mocked

### Integration Tests

Test complete user flows.

- **Location**: `integration_test/`
- **What to test**: User journeys, feature flows
- **Dependencies**: Real (or faked) implementations

## Coverage

Aim for meaningful coverage, not 100%. Focus on:

- ✅ Business logic (use cases, BLoCs)
- ✅ Data transformations (mappers, models)
- ✅ Validation (value objects)
- ✅ Error handling paths
- ⚠️ UI (critical widgets only)
- ❌ Generated code (freezed, json_serializable)

## CI/CD Integration

Tests run automatically on every push/PR via GitHub Actions.

See `.github/workflows/test.yml` for configuration.
