import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/domain/value_objects/name_failure.dart';
import 'package:starter_app/core/error/failures/infrastructure_failures.dart';
import 'package:starter_app/core/presentation/failure_message/failure_mapper_registry.dart';
import 'package:starter_app/core/presentation/failure_message/name_failure_mapper.dart';

import '../../../helpers/pump_app.dart';

class MockFailureMapperRegistry extends Mock implements FailureMapperRegistry {}

void main() {
  late NameFailureMapper mapper;
  late MockFailureMapperRegistry mockRegistry;

  setUp(() {
    mockRegistry = MockFailureMapperRegistry();
    mapper = NameFailureMapper(mockRegistry);
  });

  group('NameFailureMapper', () {
    group('canHandle', () {
      test('returns true for NameFailure', () {
        // Arrange
        const failure = NameFailure.empty();

        // Act & Assert
        expect(mapper.canHandle(failure), isTrue);
      });

      test('returns true for all NameFailure variants', () {
        // Arrange
        const failures = [
          NameFailure.empty(),
        ];

        // Act & Assert
        for (final failure in failures) {
          expect(mapper.canHandle(failure), isTrue);
        }
      });

      test('returns false for non-NameFailure', () {
        // Arrange
        const failure = InfrastructureFailure.network(message: 'test');

        // Act & Assert
        expect(mapper.canHandle(failure), isFalse);
      });
    });

    group('map', () {
      testWidgets('maps NameEmpty to nameEmpty message', (tester) async {
        await tester.pumpApp(
          Builder(
            builder: (context) {
              // Arrange
              const failure = NameFailure.empty();

              // Act
              final message = mapper.map(context, failure);

              // Assert
              expect(message, isNotEmpty);
              expect(message.toLowerCase(), contains('name'));
              return const SizedBox();
            },
          ),
        );
      });

      testWidgets('maps NameTooLong to nameTooLong message', (tester) async {
        await tester.pumpApp(
          Builder(
            builder: (context) {
              // Arrange
              const failure = NameFailure.tooLong(
                maxLength: 50,
                actualLength: 75,
              );

              // Act
              final message = mapper.map(context, failure);

              // Assert
              expect(message, isNotEmpty);
              expect(message, contains('50'));
              return const SizedBox();
            },
          ),
        );
      });
    });
  });
}
