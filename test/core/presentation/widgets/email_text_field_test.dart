import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/domain/value_objects/email_address.dart';
import 'package:starter_app/core/domain/value_objects/email_failure.dart';
import 'package:starter_app/core/error/failures/failure.dart';
import 'package:starter_app/core/presentation/services/failure_message_service.dart';
import 'package:starter_app/core/presentation/widgets/app_text_field.dart';
import 'package:starter_app/core/presentation/widgets/email_text_field.dart';

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
      if (failure is EmailEmpty) {
        return 'Email is required';
      } else if (failure is EmailTooLong) {
        return 'Email must not exceed 254 characters';
      } else if (failure is EmailInvalidFormat) {
        return 'Please enter a valid email address';
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

  group('EmailTextField', () {
    testWidgets('renders AppTextField with email configuration', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProvider(
          EmailTextField(
            email: EmailAddress('test@example.com'),
            showError: false,
          ),
        ),
      );

      final textField = tester.widget<AppTextField>(find.byType(AppTextField));
      expect(textField.keyboardType, TextInputType.emailAddress);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets(
      'shows validation error when showError is true and email is invalid',
      (tester) async {
        // Arrange
        final invalidEmail = EmailAddress('invalid');

        await tester.pumpWidget(
          wrapWithProvider(
            EmailTextField(
              email: invalidEmail,
              showError: true,
            ),
          ),
        );

        // Assert - New message from EmailFailure.message
        expect(
          find.text('Please enter a valid email address'),
          findsOneWidget,
        );
      },
    );

    testWidgets('does not show validation error when showError is false', (
      tester,
    ) async {
      // Arrange
      final invalidEmail = EmailAddress('invalid');

      await tester.pumpWidget(
        wrapWithProvider(
          EmailTextField(
            email: invalidEmail,
            showError: false,
          ),
        ),
      );

      // Assert
      expect(
        find.text('Please enter a valid email address'),
        findsNothing,
      );
    });

    testWidgets(
      'shows tooLong error when email exceeds max length',
      (tester) async {
        // Arrange - Create email longer than 254 characters
        final longEmail = 'a' * 250 + '@example.com'; // 263 chars
        final invalidEmail = EmailAddress(longEmail);

        await tester.pumpWidget(
          wrapWithProvider(
            EmailTextField(
              email: invalidEmail,
              showError: true,
            ),
          ),
        );

        // Assert - New message from EmailFailure.message
        expect(
          find.textContaining('Email must not exceed 254 characters'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'shows empty error when email is empty',
      (tester) async {
        // Arrange
        final emptyEmail = EmailAddress('');

        await tester.pumpWidget(
          wrapWithProvider(
            EmailTextField(
              email: emptyEmail,
              showError: true,
            ),
          ),
        );

        // Assert - New message from EmailFailure.message
        expect(find.text('Email is required'), findsOneWidget);
      },
    );

    testWidgets(
      'does not show error when email is valid',
      (tester) async {
        // Arrange
        final validEmail = EmailAddress('test@example.com');

        await tester.pumpWidget(
          wrapWithProvider(
            EmailTextField(
              email: validEmail,
              showError: true,
            ),
          ),
        );

        // Assert - No error messages should be shown
        expect(find.text('Email is required'), findsNothing);
        expect(
          find.text('Please enter a valid email address'),
          findsNothing,
        );
        expect(
          find.textContaining('Email must not exceed'),
          findsNothing,
        );
      },
    );
  });
}
