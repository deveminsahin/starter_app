import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/domain/value_objects/password.dart';
import 'package:starter_app/core/domain/value_objects/password_failure.dart';
import 'package:starter_app/core/error/failures/failure.dart';
import 'package:starter_app/core/presentation/services/failure_message_service.dart';
import 'package:starter_app/core/presentation/widgets/app_text_field.dart';
import 'package:starter_app/core/presentation/widgets/password_text_field.dart';

class MockFailureMessageService extends Mock implements FailureMessageService {}

class FakeFailure extends Fake implements Failure {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late MockFailureMessageService mockFailureMessageService;

  setUpAll(() {
    registerFallbackValue(FakeFailure());
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() {
    mockFailureMessageService = MockFailureMessageService();
    when(
      () => mockFailureMessageService.getLocalizedMessage(any(), any()),
    ).thenAnswer((invocation) {
      final failure = invocation.positionalArguments[1];
      if (failure is PasswordEmpty) {
        return 'Password is required';
      } else if (failure is PasswordTooShort) {
        return 'Password must be at least 8 characters';
      } else if (failure is PasswordTooLong) {
        return 'Password must not exceed 128 characters';
      } else if (failure is PasswordMissingUppercase) {
        return 'Password must contain at least one uppercase letter';
      } else if (failure is PasswordMissingLowercase) {
        return 'Password must contain at least one lowercase letter';
      } else if (failure is PasswordMissingDigit) {
        return 'Password must contain at least one digit';
      } else if (failure is PasswordMissingSpecialCharacter) {
        return 'Password must contain at least one special character';
      }
      return 'Unknown error';
    });
  });

  Widget wrapWithProvider(Widget child) {
    return MaterialApp(
      home: RepositoryProvider<FailureMessageService>.value(
        value: mockFailureMessageService,
        child: Scaffold(body: child),
      ),
    );
  }

  group('PasswordTextField', () {
    testWidgets('renders AppTextField with password configuration', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProvider(
          PasswordTextField(
            password: Password('ValidPassword1!'),
            showError: false,
            obscureText: true,
          ),
        ),
      );

      final textField = tester.widget<AppTextField>(find.byType(AppTextField));
      expect(textField.obscureText, isTrue);
      expect(textField.keyboardType, TextInputType.visiblePassword);
      expect(textField.maxLines, 1);
    });

    testWidgets('displays visible text when obscureText is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProvider(
          PasswordTextField(
            password: Password('ValidPassword1!'),
            showError: false,
            obscureText: false,
          ),
        ),
      );

      final textField = tester.widget<AppTextField>(find.byType(AppTextField));
      expect(textField.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('calls onToggleVisibility when icon is pressed', (
      tester,
    ) async {
      var toggleCalled = false;

      await tester.pumpWidget(
        wrapWithProvider(
          PasswordTextField(
            password: Password('ValidPassword1!'),
            showError: false,
            obscureText: true,
            onToggleVisibility: () => toggleCalled = true,
          ),
        ),
      );

      // Tap toggle button
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(toggleCalled, isTrue);
    });

    testWidgets('shows correct icon based on obscureText state', (
      tester,
    ) async {
      // Initially obscured
      await tester.pumpWidget(
        wrapWithProvider(
          PasswordTextField(
            password: Password('ValidPassword1!'),
            showError: false,
            obscureText: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

      // Now visible
      await tester.pumpWidget(
        wrapWithProvider(
          PasswordTextField(
            password: Password('ValidPassword1!'),
            showError: false,
            obscureText: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });

    testWidgets(
      'shows validation error when showError is true and password is invalid',
      (tester) async {
        // Arrange - 'short' is < 8 chars
        final invalidPassword = Password('short');

        await tester.pumpWidget(
          wrapWithProvider(
            PasswordTextField(
              password: invalidPassword,
              showError: true,
              obscureText: true,
            ),
          ),
        );

        // Assert - PasswordFailure.message returns detailed message
        // 'short' is too short, so tooShort failure comes first
        expect(
          find.textContaining('Password must be at least'),
          findsOneWidget,
        );
      },
    );

    testWidgets('does not show validation error when showError is false', (
      tester,
    ) async {
      // Arrange
      final invalidPassword = Password('short');

      await tester.pumpWidget(
        wrapWithProvider(
          PasswordTextField(
            password: invalidPassword,
            showError: false,
            obscureText: true,
          ),
        ),
      );

      // Assert
      expect(
        find.textContaining('Password must be at least'),
        findsNothing,
      );
    });

    testWidgets(
      'shows invalidFormat error when password format is invalid',
      (tester) async {
        // Arrange - Password with valid length but missing required characters
        // (all lowercase, no uppercase, digit, or special char)
        final invalidPassword = Password('alllowercase');

        await tester.pumpWidget(
          wrapWithProvider(
            PasswordTextField(
              password: invalidPassword,
              showError: true,
              obscureText: true,
            ),
          ),
        );

        // Assert - PasswordFailure.message for missingUppercase
        // The first failure is shown, which is missingUppercase for this case
        expect(
          find.textContaining('uppercase'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'shows tooLong error when password exceeds max length',
      (tester) async {
        // Arrange - Create password longer than 128 characters
        // with all required characters (uppercase, lowercase, digit, special)
        // Using a pattern that ensures all requirements are met
        final longPassword = '${'A' * 50}${'b' * 50}${'1' * 20}!'; // 121 chars
        // Make it longer than 128
        final veryLongPassword = '$longPassword${'x' * 10}'; // 131 chars
        final invalidPassword = Password(veryLongPassword);

        await tester.pumpWidget(
          wrapWithProvider(
            PasswordTextField(
              password: invalidPassword,
              showError: true,
              obscureText: true,
            ),
          ),
        );

        // Assert - PasswordFailure.message for tooLong
        expect(
          find.textContaining('Password must not exceed'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'does not show error when password is valid',
      (tester) async {
        // Arrange - Valid password meeting all requirements
        final validPassword = Password('ValidPassword1!');

        await tester.pumpWidget(
          wrapWithProvider(
            PasswordTextField(
              password: validPassword,
              showError: true,
              obscureText: true,
            ),
          ),
        );

        // Assert - No error messages should be shown
        expect(
          find.textContaining('Password must'),
          findsNothing,
        );
        expect(
          find.textContaining('uppercase'),
          findsNothing,
        );
      },
    );

    testWidgets('toggle button is disabled when field is disabled', (
      tester,
    ) async {
      var toggleCalled = false;

      await tester.pumpWidget(
        wrapWithProvider(
          PasswordTextField(
            password: Password('ValidPassword1!'),
            showError: false,
            obscureText: true,
            enabled: false,
            onToggleVisibility: () => toggleCalled = true,
          ),
        ),
      );

      // Try to tap toggle button
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Should not trigger callback when disabled
      expect(toggleCalled, isFalse);
    });
  });
}
