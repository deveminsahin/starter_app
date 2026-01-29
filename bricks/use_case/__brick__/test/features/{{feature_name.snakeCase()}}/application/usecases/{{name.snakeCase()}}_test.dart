import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:starter_app/features/{{feature_name.snakeCase()}}/application/usecases/{{name.snakeCase()}}.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{feature_name.snakeCase()}}_repository.dart';

class Mock{{feature_name.pascalCase()}}Repository extends Mock
    implements I{{feature_name.pascalCase()}}Repository {}

void main() {
  late {{name.pascalCase()}} useCase;
  late Mock{{feature_name.pascalCase()}}Repository mockRepository;

  setUp(() {
    mockRepository = Mock{{feature_name.pascalCase()}}Repository();
    useCase = {{name.pascalCase()}}(mockRepository);
  });

  group('{{name.pascalCase()}}', () {
    test('should call repository and return success', () async {
      // Arrange
      // TODO: Set up mock response
      // when(() => mockRepository.getById(any())).thenAnswer(
      //   (_) async => Right(expected),
      // );

      // Act
      // TODO: Call use case
      // final result = await useCase(params);

      // Assert
      // TODO: Verify result
      // expect(result.isRight(), true);
      // verify(() => mockRepository.getById(any())).called(1);

      // Placeholder assertion
      expect(useCase, isNotNull);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      // TODO: Set up mock failure
      // when(() => mockRepository.getById(any())).thenAnswer(
      //   (_) async => Left({{feature_name.pascalCase()}}Failure.notFound(message: 'Not found')),
      // );

      // Act
      // TODO: Call use case
      // final result = await useCase(params);

      // Assert
      // TODO: Verify failure
      // expect(result.isLeft(), true);

      // Placeholder assertion
      expect(useCase, isNotNull);
    });
  });
}
