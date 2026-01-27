import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/domain/value_objects/email_failure.dart';
import 'package:starter_app/core/error/failures/infrastructure_failures.dart';
import 'package:starter_app/core/presentation/failure_message/email_failure_mapper.dart';
import 'package:starter_app/core/presentation/failure_message/failure_mapper_registry.dart';

import '../../../helpers/pump_app.dart';

class MockFailureMapperRegistry extends Mock implements FailureMapperRegistry {}

void main() {
  late EmailFailureMapper mapper;
  late MockFailureMapperRegistry mockRegistry;

  setUp(() {
    mockRegistry = MockFailureMapperRegistry();
    mapper = EmailFailureMapper(mockRegistry);
  });

  group('EmailFailureMapper', () {
    group('canHandle', () {
      test('returns true for EmailFailure', () {
        // Arrange
        const failure = EmailFailure.empty();

        // Act & Assert
        expect(mapper.canHandle(failure), isTrue);
      });

      test('returns true for all EmailFailure variants', () {
        // Arrange
        const failures = [
          EmailFailure.empty(),
          EmailFailure.tooLong(maxLength: 254, actualLength: 300),
          EmailFailure.invalidFormat(failedValue: 'invalid'),
        ];

        // Act & Assert
        for (final failure in failures) {
          expect(mapper.canHandle(failure), isTrue);
        }
      });

      test('returns false for non-EmailFailure', () {
        // Arrange
        const failure = InfrastructureFailure.network(message: 'test');

        // Act & Assert
        expect(mapper.canHandle(failure), isFalse);
      });
    });

    group('map', () {
      testWidgets('maps EmailEmpty to emailEmpty message', (tester) async {
        await tester.pumpApp(
          Builder(
            builder: (context) {
              // Arrange
              const failure = EmailFailure.empty();

              // Act
              final message = mapper.map(context, failure);

              // Assert
              expect(message, isNotEmpty);
              expect(message.toLowerCase(), contains('email'));
              return const SizedBox();
            },
          ),
        );
      });

      testWidgets('maps EmailTooLong to emailTooLong message', (tester) async {
        await tester.pumpApp(
          Builder(
            builder: (context) {
              // Arrange
              const failure = EmailFailure.tooLong(
                maxLength: 254,
                actualLength: 300,
              );

              // Act
              final message = mapper.map(context, failure);

              // Assert
              expect(message, isNotEmpty);
              expect(message, contains('254'));
              return const SizedBox();
            },
          ),
        );
      });

      testWidgets('maps EmailInvalidFormat to emailInvalidFormat message', (
        tester,
      ) async {
        await tester.pumpApp(
          Builder(
            builder: (context) {
              // Arrange
              const failure = EmailFailure.invalidFormat(
                failedValue: 'invalid',
              );

              // Act
              final message = mapper.map(context, failure);

              // Assert
              expect(message, isNotEmpty);
              expect(message.toLowerCase(), contains('valid'));
              return const SizedBox();
            },
          ),
        );
      });
    });
  });
}
