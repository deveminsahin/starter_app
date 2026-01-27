import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/domain/value_objects/password_failure.dart';
import 'package:starter_app/core/error/failures/infrastructure_failures.dart';
import 'package:starter_app/core/presentation/failure_message/failure_mapper_registry.dart';
import 'package:starter_app/core/presentation/failure_message/password_failure_mapper.dart';

import '../../../helpers/pump_app.dart';

class MockFailureMapperRegistry extends Mock implements FailureMapperRegistry {}

void main() {
  late PasswordFailureMapper mapper;
  late MockFailureMapperRegistry mockRegistry;

  setUp(() {
    mockRegistry = MockFailureMapperRegistry();
    mapper = PasswordFailureMapper(mockRegistry);
  });

  group('PasswordFailureMapper', () {
    group('canHandle', () {
      test('returns true for PasswordFailure', () {
        // Arrange
        const failure = PasswordFailure.empty();

        // Act & Assert
        expect(mapper.canHandle(failure), isTrue);
      });

      test('returns true for all PasswordFailure variants', () {
        // Arrange
        const failures = [
          PasswordFailure.empty(),
          PasswordFailure.tooShort(minLength: 8, actualLength: 5),
          PasswordFailure.tooLong(maxLength: 128, actualLength: 150),
          PasswordFailure.missingUppercase(),
          PasswordFailure.missingLowercase(),
          PasswordFailure.missingDigit(),
          PasswordFailure.missingSpecialCharacter(),
        ];

        // Act & Assert
        for (final failure in failures) {
          expect(mapper.canHandle(failure), isTrue);
        }
      });

      test('returns false for non-PasswordFailure', () {
        // Arrange
        const failure = InfrastructureFailure.network(message: 'test');

        // Act & Assert
        expect(mapper.canHandle(failure), isFalse);
      });
    });

    group('map', () {
      testWidgets('maps PasswordEmpty to passwordEmpty message', (
        tester,
      ) async {
        await tester.pumpApp(
          Builder(
            builder: (context) {
              // Arrange
              const failure = PasswordFailure.empty();

              // Act
              final message = mapper.map(context, failure);

              // Assert
              expect(message, isNotEmpty);
              expect(message.toLowerCase(), contains('password'));
              return const SizedBox();
            },
          ),
        );
      });

      testWidgets('maps PasswordTooShort to passwordTooShort message', (
        tester,
      ) async {
        await tester.pumpApp(
          Builder(
            builder: (context) {
              // Arrange
              const failure = PasswordFailure.tooShort(
                minLength: 8,
                actualLength: 5,
              );

              // Act
              final message = mapper.map(context, failure);

              // Assert
              expect(message, isNotEmpty);
              expect(message, contains('8'));
              return const SizedBox();
            },
          ),
        );
      });

      testWidgets('maps PasswordTooLong to passwordTooLong message', (
        tester,
      ) async {
        await tester.pumpApp(
          Builder(
            builder: (context) {
              // Arrange
              const failure = PasswordFailure.tooLong(
                maxLength: 128,
                actualLength: 150,
              );

              // Act
              final message = mapper.map(context, failure);

              // Assert
              expect(message, isNotEmpty);
              expect(message, contains('128'));
              return const SizedBox();
            },
          ),
        );
      });

      testWidgets('maps PasswordMissingUppercase to message', (tester) async {
        await tester.pumpApp(
          Builder(
            builder: (context) {
              // Arrange
              const failure = PasswordFailure.missingUppercase();

              // Act
              final message = mapper.map(context, failure);

              // Assert
              expect(message, isNotEmpty);
              expect(message.toLowerCase(), contains('uppercase'));
              return const SizedBox();
            },
          ),
        );
      });

      testWidgets('maps PasswordMissingLowercase to message', (tester) async {
        await tester.pumpApp(
          Builder(
            builder: (context) {
              // Arrange
              const failure = PasswordFailure.missingLowercase();

              // Act
              final message = mapper.map(context, failure);

              // Assert
              expect(message, isNotEmpty);
              expect(message.toLowerCase(), contains('lowercase'));
              return const SizedBox();
            },
          ),
        );
      });

      testWidgets('maps PasswordMissingDigit to message', (tester) async {
        await tester.pumpApp(
          Builder(
            builder: (context) {
              // Arrange
              const failure = PasswordFailure.missingDigit();

              // Act
              final message = mapper.map(context, failure);

              // Assert
              expect(message, isNotEmpty);
              expect(message.toLowerCase(), contains('digit'));
              return const SizedBox();
            },
          ),
        );
      });

      testWidgets('maps PasswordMissingSpecialCharacter to message', (
        tester,
      ) async {
        await tester.pumpApp(
          Builder(
            builder: (context) {
              // Arrange
              const failure = PasswordFailure.missingSpecialCharacter();

              // Act
              final message = mapper.map(context, failure);

              // Assert
              expect(message, isNotEmpty);
              expect(message.toLowerCase(), contains('special'));
              return const SizedBox();
            },
          ),
        );
      });
    });
  });
}
