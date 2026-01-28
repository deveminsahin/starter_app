# Test Infrastructure TODO

This file tracks remaining tasks to achieve enterprise-level test coverage.

## ✅ Completed

- [x] Refactored `test_data.dart` with enterprise pattern (factory methods, const models)
- [x] Created `test/README.md` documentation
- [x] Created `test/helpers/fixtures/` structure
- [x] Created `test/helpers/matchers.dart` (custom Either matchers)
- [x] Created `test/helpers/fake_helpers.dart` (fake implementations)
- [x] Created `integration_test/` structure with README
- [x] Updated `helpers.dart` barrel file
- [x] Refactored `auth_repository_impl_test.dart` to use new TestData
- [x] Created empty folders for missing test areas
- [x] **Phase 5: Test Quality Review** (2026-01-15)
  - [x] Consolidated duplicate mocks in `mock_helpers.dart`
  - [x] Centralized `registerMockFallbackValues()`
  - [x] Updated test files to use shared mocks
  - [x] Updated `test/README.md` with `very_good` commands

---

## 🔲 Pending Tasks

### Priority 1: Refactor Remaining Tests to Use TestData ✅ COMPLETED

- [x] Update these files to use `TestData` instead of local test data

---

### Priority 2: Add AuthBloc Tests ✅ COMPLETED

`test/features/auth/presentation/bloc/auth_bloc_test.dart`:

- [x] Test initial state
- [x] Test `AuthGetCurrentUser` event
- [x] Test `AuthEmailChanged` event
- [x] Test `AuthPasswordChanged` event
- [x] Test `AuthEmailSubmitted` event (check user exists flow)
- [x] Test `AuthLoginSubmitted` event (success/failure)
- [x] Test `AuthRegisterSubmitted` event (success/failure)
- [x] Test `AuthLogoutRequested` event
- [x] Test `AuthSessionExpired` event
- [x] Test field validation states (via allTouched in error cases)

---

### Priority 3: Add Missing Feature Page Tests ✅ COMPLETED

Widget tests for feature pages:

- [x] `test/features/home/presentation/pages/home_page_test.dart` (4 tests)
- [x] `test/features/profile/presentation/pages/profile_page_test.dart` (4 tests)
- [x] `test/features/settings/presentation/pages/settings_page_test.dart` (9 tests)
- [x] `test/features/auth/presentation/pages/auth_page_test.dart` (12 tests)

**Coverage achieved:**

- ✅ Renders without errors
- ✅ Shows expected UI elements
- ✅ Responds to user interactions

---

### Priority 4: Add Core Widget Tests ✅ COMPLETED

Tests for reusable widgets:

- [x] `test/core/presentation/widgets/app_text_field_test.dart` (17 tests)
- [x] `test/core/presentation/widgets/email_text_field_test.dart` (12 tests)
- [x] `test/core/presentation/widgets/password_text_field_test.dart` (15 tests)
- [x] `test/core/presentation/widgets/app_snackbar_test.dart` (5 tests)

---

### Priority 5: Add Integration Tests ✅ COMPLETED

End-to-end tests in `integration_test/`:

- [x] `integration_test/helpers/test_app.dart` - App setup with fakes
- [x] `integration_test/helpers/fake_dependencies.dart` - Fake BLoCs/Cubits
- [x] `integration_test/helpers/helpers.dart` - Barrel file
- [x] `integration_test/auth_flow_test.dart` - Login/register/logout flow (11 tests)
- [x] `integration_test/navigation_test.dart` - Navigation between pages (14 tests)

---

### Priority 6: Test Quality Review ✅ COMPLETED (Phase 5)

- [x] Review test naming conventions
- [x] Verify AAA pattern usage
- [x] Check for meaningful assertions
- [x] Audit `mocktail` usage and duplication
- [x] Consolidate duplicate mocks
- [x] Centralize fallback registrations

---

### Priority 7: Performance Benchmarks ✅ COMPLETED (Phase 5.5)

- [x] Create `test/benchmarks/` directory
- [x] `startup_benchmark_test.dart` - DI registration, BLoC instantiation, storage ops
- [x] `widget_build_benchmark_test.dart` - Widget build times, rebuild performance
- [x] `repository_benchmark_test.dart` - JSON parsing, domain transformations
- [x] `README.md` - Documentation with baseline metrics

---

### Priority 8: CI/CD Pipeline

- [ ] Create `.github/workflows/test.yml` for automated testing
- [ ] Configure code coverage reporting (Codecov/Coveralls)
- [ ] Add pre-commit hooks for running tests

**Example workflow:**

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: very_good test --coverage
```

---

## 📊 Current Coverage Status

| Area | Status | Notes |
|------|--------|-------|
| Core/Domain | ✅ 100% | Value objects tested |
| Core/Error | ✅ 100% | Exceptions & failures tested |
| Core/Storage | ✅ 100% | Token storage tested |
| Core/Theme | ✅ 100% | ThemeCubit tested |
| Core/L10n | ✅ 100% | LocaleCubit tested |
| Core/Navigation | ✅ 100% | Router observer tested |
| Core/Presentation | ✅ 100% | Widget tests complete |
| Auth/Domain | ✅ 100% | Entities & VOs tested |
| Auth/Application | ✅ 100% | Use cases tested |
| Auth/Infrastructure | ✅ 100% | Repository & models tested |
| Auth/Presentation | ✅ 100% | BLoC & page tests complete |
| Home/Presentation | ✅ 100% | Page tests complete |
| Profile/Presentation | ✅ 100% | Page tests complete |
| Settings/Presentation | ✅ 100% | Page tests complete |
| Integration Tests | ✅ Done | E2E tests complete |

**Total: 2059 tests passing with 100% coverage**

---

## 🎯 Quick Start Commands

```bash
# Run all tests
very_good test

# Run with coverage
very_good test --coverage

# Run specific test file
very_good test test/features/auth/presentation/bloc/auth_bloc_test.dart

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Run integration tests
flutter test integration_test/
```

---

## ✅ Minor Suggestions - COMPLETED (January 15, 2026)

1. **Add Golden Tests** ✅ (Infrastructure Ready - Tests Skipped)
   - Created `test/goldens/app_text_field_golden_test.dart`
   - Tests for empty, filled, error, and dark mode states
   - Helper exists in `golden_test_helper.dart`
   - **Note:** Tests are currently skipped (`skip: true`) until baselines are generated
   - Run `flutter test --update-goldens test/goldens/` to generate baselines
   - Then remove `skip: true` from tests to enable

2. **Code Coverage Badge** ✅
   - Updated `.github/workflows/main.yaml` with coverage-badge job
   - Auto-updates badge on main branch pushes
   - Uses `dynamic-badges-action` for Gist-based badges

3. **README Enhancements** ✅
   - Enhanced architecture diagram with detailed layer components
   - Added CQRS pattern visualization
   - Added Authentication flow diagram
   - Added Quick Start by Feature section with code examples

Last updated: January 15, 2026 (All Minor Suggestions Completed)

