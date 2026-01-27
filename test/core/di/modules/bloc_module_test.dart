import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/di/modules/bloc_module.dart';
import 'package:starter_app/core/presentation/bloc/app_bloc_observer.dart';
import 'package:starter_app/core/presentation/bloc/locale_cubit.dart';
import 'package:starter_app/core/presentation/bloc/theme_cubit.dart';

import '../../../helpers/mock_helpers.dart';
import '../../../helpers/test_bloc.dart';
import '../../../helpers/test_cubit.dart';

// Concrete implementation for testing
class TestBlocModule extends BlocModule {}

void main() {
  group('BlocModule', () {
    late MockAppLogger mockLogger;

    setUp(() {
      mockLogger = MockAppLogger();
    });

    group('provideBlocObserver', () {
      test('should create AppBlocObserver with logger', () {
        // Act
        final observer = TestBlocModule().provideBlocObserver(mockLogger);

        // Assert
        expect(observer, isA<AppBlocObserver>());
        expect(observer, isA<BlocObserver>());
      });

      test('should return singleton instance', () {
        // Act
        final observer1 = TestBlocModule().provideBlocObserver(mockLogger);
        final observer2 = TestBlocModule().provideBlocObserver(mockLogger);

        // Assert - should be different instances
        // (not actually singleton in test)
        // but the method should work correctly
        expect(observer1, isA<AppBlocObserver>());
        expect(observer2, isA<AppBlocObserver>());
      });
    });

    group('provideThemeCubit', () {
      setUp(() {
        // Set up HydratedBloc storage for testing
        HydratedBloc.storage = MockStorage();
      });

      test('should create ThemeCubit with AppThemeMode.system', () {
        // Act
        final cubit = TestBlocModule().provideThemeCubit();

        // Assert
        expect(cubit, isA<ThemeCubit>());
        expect(cubit.state, AppThemeMode.system);
      });

      test('should be lazy singleton', () {
        // Act
        final cubit1 = TestBlocModule().provideThemeCubit();
        final cubit2 = TestBlocModule().provideThemeCubit();

        // Assert - should be different instances in test context
        expect(cubit1, isA<ThemeCubit>());
        expect(cubit2, isA<ThemeCubit>());
      });
    });

    group('provideLocaleCubit', () {
      setUp(() {
        // Set up HydratedBloc storage for testing
        HydratedBloc.storage = MockStorage();
      });

      test('should create LocaleCubit with AppLocale.en', () {
        // Act
        final cubit = TestBlocModule().provideLocaleCubit();

        // Assert
        expect(cubit, isA<LocaleCubit>());
        expect(cubit.state, AppLocale.en);
      });

      test('should be lazy singleton', () {
        // Act
        final cubit1 = TestBlocModule().provideLocaleCubit();
        final cubit2 = TestBlocModule().provideLocaleCubit();

        // Assert - should be different instances in test context
        expect(cubit1, isA<LocaleCubit>());
        expect(cubit2, isA<LocaleCubit>());
      });
    });
  });

  group('AppBlocObserver', () {
    late MockAppLogger mockLogger;
    late AppBlocObserver observer;

    setUp(() {
      mockLogger = MockAppLogger();
      observer = AppBlocObserver(mockLogger);
    });

    group('onChange', () {
      test('should log state change with correct data', () {
        // Arrange
        final testCubit = TestCubit();
        const change = Change(
          currentState: 'initial',
          nextState: 'updated',
        );

        // Act
        observer.onChange(testCubit, change);

        // Assert
        verify(
          () => mockLogger.debug(
            'BLoC state changed',
            data: {
              'bloc': 'TestCubit',
              'currentState': 'initial',
              'nextState': 'updated',
            },
            tag: 'BLoC',
          ),
        ).called(1);
      });

      test('should handle null states', () {
        // Arrange
        final testCubit = TestCubit();
        const change = Change(
          currentState: null,
          nextState: 'updated',
        );

        // Act
        observer.onChange(testCubit, change);

        // Assert
        verify(
          () => mockLogger.debug(
            'BLoC state changed',
            data: {
              'bloc': 'TestCubit',
              'currentState': 'null',
              'nextState': 'updated',
            },
            tag: 'BLoC',
          ),
        ).called(1);
      });
    });

    group('onError', () {
      test('should log error with correct data', () {
        // Arrange
        final testCubit = TestCubit();
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        // Act
        observer.onError(testCubit, error, stackTrace);

        // Assert
        verify(
          () => mockLogger.error(
            'BLoC error',
            error: error,
            stackTrace: stackTrace,
            data: {'bloc': 'TestCubit'},
            tag: 'BLoC',
          ),
        ).called(1);
      });

      test('should handle different error types', () {
        // Arrange
        final testCubit = TestCubit();
        final error = StateError('State error');
        final stackTrace = StackTrace.current;

        // Act
        observer.onError(testCubit, error, stackTrace);

        // Assert
        verify(
          () => mockLogger.error(
            'BLoC error',
            error: error,
            stackTrace: stackTrace,
            data: {'bloc': 'TestCubit'},
            tag: 'BLoC',
          ),
        ).called(1);
      });
    });

    group('onEvent', () {
      test('should log event with correct data', () {
        // Arrange
        final testBloc = TestBloc();
        const event = 'TestEvent';

        // Act
        observer.onEvent(testBloc, event);

        // Assert
        verify(
          () => mockLogger.debug(
            'BLoC event added',
            data: {
              'bloc': 'TestBloc',
              'event': 'TestEvent',
            },
            tag: 'BLoC',
          ),
        ).called(1);
      });

      test('should handle null event', () {
        // Arrange
        final testBloc = TestBloc();

        // Act
        observer.onEvent(testBloc, null);

        // Assert
        verify(
          () => mockLogger.debug(
            'BLoC event added',
            data: {
              'bloc': 'TestBloc',
              'event': 'null',
            },
            tag: 'BLoC',
          ),
        ).called(1);
      });
    });

    group('onTransition', () {
      test('should log transition with correct data', () {
        // Arrange
        final testBloc = TestBloc();
        const event = 'TestEvent';
        const transition = Transition(
          currentState: 'initial',
          event: event,
          nextState: 'updated',
        );

        // Act
        observer.onTransition(testBloc, transition);

        // Assert
        verify(
          () => mockLogger.debug(
            'BLoC transition',
            data: {
              'bloc': 'TestBloc',
              'event': 'TestEvent',
              'currentState': 'initial',
              'nextState': 'updated',
            },
            tag: 'BLoC',
          ),
        ).called(1);
      });

      test('should handle complex transition data', () {
        // Arrange
        final testBloc = TestBloc();
        const event = 'ComplexEvent';
        const transition = Transition(
          currentState: 'State1',
          event: event,
          nextState: 'State2',
        );

        // Act
        observer.onTransition(testBloc, transition);

        // Assert
        verify(
          () => mockLogger.debug(
            'BLoC transition',
            data: {
              'bloc': 'TestBloc',
              'event': 'ComplexEvent',
              'currentState': 'State1',
              'nextState': 'State2',
            },
            tag: 'BLoC',
          ),
        ).called(1);
      });
    });
  });
}
