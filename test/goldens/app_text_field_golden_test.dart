import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/presentation/widgets/app_text_field.dart';

import '../helpers/golden_test_helper.dart';

/// Golden tests for core UI components.
///
/// **STATUS: SKIPPED** - These tests are intentionally skipped until baseline
/// images are generated. The infrastructure is in place for future use.
///
/// ## To enable golden tests:
///
/// 1. Generate baseline images:
///    ```bash
///    flutter test --update-goldens test/goldens/
///    ```
///
/// 2. Remove `skip: true` from each test in this file.
///
/// 3. Commit the generated golden files in `test/goldens/goldens/` to git.
///
/// After running with --update-goldens, the baseline images will be created.
/// Subsequent runs without --update-goldens will compare against these
/// baselines and fail if there are visual differences.
void main() {
  group('AppTextField Golden Tests', () {
    testWidgets('renders correctly - empty state', (tester) async {
      await tester.setGoldenTestDeviceSize(GoldenTestDevices.mobile);

      await tester.pumpWidget(
        const GoldenTestWrapper(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: AppTextField(
              label: 'Email',
              hint: 'Enter your email',
            ),
          ),
        ),
      );

      await tester.expectGolden(
        find.byType(MaterialApp),
        'app_text_field_empty.png',
      );
    });

    testWidgets('renders correctly - with value', (tester) async {
      await tester.setGoldenTestDeviceSize(GoldenTestDevices.mobile);

      await tester.pumpWidget(
        GoldenTestWrapper(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              label: 'Email',
              hint: 'Enter your email',
              controller: TextEditingController(text: 'user@example.com'),
            ),
          ),
        ),
      );

      await tester.expectGolden(
        find.byType(MaterialApp),
        'app_text_field_with_value.png',
      );
    });

    testWidgets('renders correctly - error state', (tester) async {
      await tester.setGoldenTestDeviceSize(GoldenTestDevices.mobile);

      await tester.pumpWidget(
        const GoldenTestWrapper(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: AppTextField(
              label: 'Email',
              hint: 'Enter your email',
              errorText: 'Invalid email format',
            ),
          ),
        ),
      );

      await tester.expectGolden(
        find.byType(MaterialApp),
        'app_text_field_error.png',
      );
    });

    testWidgets('renders correctly - dark mode', (tester) async {
      await tester.setGoldenTestDeviceSize(GoldenTestDevices.mobile);

      await tester.pumpWidget(
        const GoldenTestWrapper(
          themeMode: ThemeMode.dark,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: AppTextField(
              label: 'Email',
              hint: 'Enter your email',
            ),
          ),
        ),
      );

      await tester.expectGolden(
        find.byType(MaterialApp),
        'app_text_field_dark.png',
      );
    });
  });
}
