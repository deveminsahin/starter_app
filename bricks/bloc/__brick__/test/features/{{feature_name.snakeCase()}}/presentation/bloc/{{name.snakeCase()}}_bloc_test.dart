import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:starter_app/features/{{feature_name.snakeCase()}}/presentation/bloc/{{name.snakeCase()}}_bloc.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/presentation/bloc/{{name.snakeCase()}}_event.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/presentation/bloc/{{name.snakeCase()}}_state.dart';

// TODO: Add mock dependencies
// class MockUseCase extends Mock implements UseCase {}

void main() {
  // late MockUseCase mockUseCase;

  setUp(() {
    // mockUseCase = MockUseCase();
  });

  group('{{name.pascalCase()}}Bloc', () {
    test('initial state is correct', () {
      final bloc = {{name.pascalCase()}}Bloc();
      expect(bloc.state, const {{name.pascalCase()}}State.initial());
    });

    blocTest<{{name.pascalCase()}}Bloc, {{name.pascalCase()}}State>(
      'emits [loading, loaded] when started',
      build: () => {{name.pascalCase()}}Bloc(),
      act: (bloc) => bloc.add(const {{name.pascalCase()}}Event.started()),
      expect: () => [
        const {{name.pascalCase()}}State.loading(),
        const {{name.pascalCase()}}State.loaded(),
      ],
    );

    // TODO: Add more tests
    // blocTest<{{name.pascalCase()}}Bloc, {{name.pascalCase()}}State>(
    //   'emits [loading, error] when use case fails',
    //   setUp: () {
    //     when(() => mockUseCase()).thenAnswer(
    //       (_) async => Left(Failure.unexpected()),
    //     );
    //   },
    //   build: () => {{name.pascalCase()}}Bloc(mockUseCase),
    //   act: (bloc) => bloc.add(const {{name.pascalCase()}}Event.started()),
    //   expect: () => [
    //     const {{name.pascalCase()}}State.loading(),
    //     const {{name.pascalCase()}}State.error('An unexpected error occurred'),
    //   ],
    // );
  });
}
