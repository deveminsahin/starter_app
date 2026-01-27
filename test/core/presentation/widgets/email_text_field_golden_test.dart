import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/domain/value_objects/email_address.dart';
import 'package:starter_app/core/domain/value_objects/email_failure.dart';
import 'package:starter_app/core/error/failures/failure.dart';
import 'package:starter_app/core/presentation/services/failure_message_service.dart';
import 'package:starter_app/core/presentation/widgets/email_text_field.dart';

import '../../../helpers/pump_app.dart';

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
    return RepositoryProvider<FailureMessageService>.value(
      value: mockFailureMessageService,
      child: child,
    );
  }

  group('EmailTextField Golden Tests', () {
    testWidgets('renders empty state correctly', (tester) async {
      await tester.pumpApp(
        wrapWithProvider(
          Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: EmailTextField(
                email: EmailAddress(''),
                showError: false,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(EmailTextField),
        matchesGoldenFile('goldens/email_text_field_empty.png'),
      );
    });

    testWidgets('renders with error correctly', (tester) async {
      await tester.pumpApp(
        wrapWithProvider(
          Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: EmailTextField(
                email: EmailAddress('invalid-email'),
                showError: true,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(EmailTextField),
        matchesGoldenFile('goldens/email_text_field_error.png'),
      );
    });
  });
}
