# Integration Tests

End-to-end tests that verify complete user flows.

## Running Integration Tests

```bash
# Run all integration tests
flutter test integration_test/

# Run a single test file
flutter test integration_test/app_test.dart

# Run on a specific device (recommended for true end-to-end coverage)
flutter test integration_test/ -d <device_id>

# Run with verbose output
flutter test integration_test/ --verbose
```

## Structure

```text
integration_test/
├── helpers/
│   ├── test_app.dart       # App setup for integration tests
│   └── helpers.dart        # Integration test utilities
├── auth_flow_test.dart     # Authentication flow tests
├── app_test.dart           # App smoke tests
└── README.md               # This file
```

## Writing Integration Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow', () {
    testWidgets('user can login successfully', (tester) async {
      // Launch app
      await tester.pumpWidget(await createTestApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'Test123!@#',
      );

      // Submit
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify navigation to home
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
```

## Best Practices

1. **Test real user journeys**, not implementation details
2. **Use meaningful test names** that describe the scenario
3. **Keep tests independent** - each test should start fresh
4. **Use Keys for reliable element finding**
5. **Wait for animations** with `pumpAndSettle()`
6. **Test both happy and error paths**
