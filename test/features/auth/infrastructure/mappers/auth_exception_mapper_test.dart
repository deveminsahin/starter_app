import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/error/exceptions/server_exception.dart';
import 'package:starter_app/core/error/failures/infrastructure_failures.dart';
import 'package:starter_app/features/auth/domain/failure/auth_failure.dart';
import 'package:starter_app/features/auth/infrastructure/mappers/auth_exception_mapper.dart';

void main() {
  group('AuthExceptionMapper', () {
    late AuthExceptionMapper mapper;

    setUp(() {
      mapper = const AuthExceptionMapper();
    });

    group('mapToFailure', () {
      test('maps 401 Unauthorized to AuthFailure.unauthorized', () {
        const exception = ServerException(
          statusCode: HttpStatus.unauthorized,
          message: 'Invalid credentials',
        );

        final result = mapper.mapToFailure(exception);

        expect(result, isA<AuthFailure>());
        (result as AuthFailure).when(
          unauthorized: (message, stackTrace) {
            expect(message, 'Invalid credentials');
          },
          forbidden: (_, _) => fail('Should be unauthorized'),
          notFound: (_, _) => fail('Should be unauthorized'),
          emailAlreadyInUse: (_, _) => fail('Should be unauthorized'),
          invalidInput: (_, _) => fail('Should be unauthorized'),
        );
      });

      test('maps 403 Forbidden to AuthFailure.forbidden', () {
        const exception = ServerException(
          statusCode: HttpStatus.forbidden,
          message: 'Account suspended',
        );

        final result = mapper.mapToFailure(exception);

        expect(result, isA<AuthFailure>());
        (result as AuthFailure).when(
          forbidden: (message, stackTrace) {
            expect(message, 'Account suspended');
          },
          unauthorized: (_, _) => fail('Should be forbidden'),
          notFound: (_, _) => fail('Should be forbidden'),
          emailAlreadyInUse: (_, _) => fail('Should be forbidden'),
          invalidInput: (_, _) => fail('Should be forbidden'),
        );
      });

      test('maps 404 Not Found to AuthFailure.notFound', () {
        const exception = ServerException(
          statusCode: HttpStatus.notFound,
          message: 'User not found',
        );

        final result = mapper.mapToFailure(exception);

        expect(result, isA<AuthFailure>());
        (result as AuthFailure).when(
          notFound: (message, stackTrace) {
            expect(message, 'User not found');
          },
          unauthorized: (_, _) => fail('Should be not found'),
          forbidden: (_, _) => fail('Should be not found'),
          emailAlreadyInUse: (_, _) => fail('Should be not found'),
          invalidInput: (_, _) => fail('Should be not found'),
        );
      });

      test('maps 409 Conflict to AuthFailure.emailAlreadyInUse', () {
        const exception = ServerException(
          statusCode: HttpStatus.conflict,
          message: 'Email already in use',
        );

        final result = mapper.mapToFailure(exception);

        expect(result, isA<AuthFailure>());
        (result as AuthFailure).when(
          emailAlreadyInUse: (message, stackTrace) {
            // message is default in the failure if not passed, verify this
            // The mapper calls: const AuthFailure.emailAlreadyInUse()
            // without message from exception?
            // Let's check the mapper implementation again.
            // valid: HttpStatus.conflict =>
            // const AuthFailure.emailAlreadyInUse(),
            // It ignores the exception message.
          },
          unauthorized: (_, _) => fail('Should be emailAlreadyInUse'),
          forbidden: (_, _) => fail('Should be emailAlreadyInUse'),
          notFound: (_, _) => fail('Should be emailAlreadyInUse'),
          invalidInput: (_, _) => fail('Should be emailAlreadyInUse'),
        );
      });

      test('maps 400 Bad Request to AuthFailure.invalidInput', () {
        const exception = ServerException(
          statusCode: HttpStatus.badRequest,
          message: 'Invalid request',
        );

        final result = mapper.mapToFailure(exception);

        expect(result, isA<AuthFailure>());
        (result as AuthFailure).when(
          invalidInput: (message, stackTrace) {
            expect(message, 'Invalid request');
          },
          unauthorized: (_, _) => fail('Should be invalidInput'),
          forbidden: (_, _) => fail('Should be invalidInput'),
          notFound: (_, _) => fail('Should be invalidInput'),
          emailAlreadyInUse: (_, _) => fail('Should be invalidInput'),
        );
      });

      test(
        'maps 500 Internal Server Error to InfrastructureFailure.server',
        () {
          const exception = ServerException(
            statusCode: HttpStatus.internalServerError,
            message: 'Server error',
          );

          final result = mapper.mapToFailure(exception);

          expect(result, isA<InfrastructureFailure>());
          (result as InfrastructureFailure).when(
            server: (message, statusCode, stackTrace) {
              expect(message, 'Server error');
              expect(statusCode, HttpStatus.internalServerError);
            },
            network: (_, _) => fail('Should be server failure'),
            cache: (_, _) => fail('Should be server failure'),
            parse: (_, _) => fail('Should be server failure'),
            circuitBreaker: (_, _) => fail('Should be server failure'),
            unexpected: (_, _) => fail('Should be server failure'),
          );
        },
      );

      test('maps 503 Service Unavailable to InfrastructureFailure.server', () {
        const exception = ServerException(
          statusCode: HttpStatus.serviceUnavailable,
          message: 'Service unavailable',
        );

        final result = mapper.mapToFailure(exception);

        expect(result, isA<InfrastructureFailure>());
        (result as InfrastructureFailure).when(
          server: (message, statusCode, stackTrace) {
            expect(message, 'Service unavailable');
            expect(statusCode, HttpStatus.serviceUnavailable);
          },
          network: (_, _) => fail('Should be server failure'),
          cache: (_, _) => fail('Should be server failure'),
          parse: (_, _) => fail('Should be server failure'),
          circuitBreaker: (_, _) => fail('Should be server failure'),
          unexpected: (_, _) => fail('Should be server failure'),
        );
      });

      test('maps unknown 4xx status codes to InfrastructureFailure.server', () {
        const exception = ServerException(
          statusCode: HttpStatus.paymentRequired,
          message: 'Payment required',
        );

        final result = mapper.mapToFailure(exception);

        expect(result, isA<InfrastructureFailure>());
      });

      test('preserves message from exception', () {
        const customMessage = 'Custom error message';
        const exception = ServerException(
          statusCode: HttpStatus.unauthorized,
          message: customMessage,
        );

        final result = mapper.mapToFailure(exception);

        expect((result as AuthFailure).message, customMessage);
      });

      test('preserves status code in infrastructure failures', () {
        const statusCode = HttpStatus.badGateway;
        const exception = ServerException(
          statusCode: statusCode,
          message: 'Bad gateway',
        );

        final result = mapper.mapToFailure(exception);

        (result as InfrastructureFailure).when(
          server: (message, code, stackTrace) {
            expect(code, statusCode);
          },
          network: (_, _) => fail('Should be server failure'),
          cache: (_, _) => fail('Should be server failure'),
          parse: (_, _) => fail('Should be server failure'),
          circuitBreaker: (_, _) => fail('Should be server failure'),
          unexpected: (_, _) => fail('Should be server failure'),
        );
      });
    });

    group('failure properties', () {
      test('unauthorized failure is not retryable', () {
        const exception = ServerException(
          statusCode: HttpStatus.unauthorized,
          message: 'Unauthorized',
        );

        final result = mapper.mapToFailure(exception);

        expect(result.isRetryable, false);
      });

      test('forbidden failure is not retryable', () {
        const exception = ServerException(
          statusCode: HttpStatus.forbidden,
          message: 'Forbidden',
        );

        final result = mapper.mapToFailure(exception);

        expect(result.isRetryable, false);
      });

      test('not found failure is not retryable', () {
        const exception = ServerException(
          statusCode: HttpStatus.notFound,
          message: 'Not found',
        );

        final result = mapper.mapToFailure(exception);

        expect(result.isRetryable, false);
      });
    });

    group('use cases', () {
      test('maps login failure with invalid credentials', () {
        const exception = ServerException(
          statusCode: HttpStatus.unauthorized,
          message: 'Invalid email or password',
        );

        final result = mapper.mapToFailure(exception);

        (result as AuthFailure).when(
          unauthorized: (message, stackTrace) {
            expect(message, 'Invalid email or password');
          },
          forbidden: (_, _) => fail('Should be unauthorized'),
          notFound: (_, _) => fail('Should be unauthorized'),
          emailAlreadyInUse: (_, _) => fail('Should be unauthorized'),
          invalidInput: (_, _) => fail('Should be unauthorized'),
        );
      });

      test('maps account suspension scenario', () {
        const exception = ServerException(
          statusCode: HttpStatus.forbidden,
          message: 'Your account has been suspended',
        );

        final result = mapper.mapToFailure(exception);

        (result as AuthFailure).when(
          forbidden: (message, stackTrace) {
            expect(message, contains('suspended'));
          },
          unauthorized: (_, _) => fail('Should be forbidden'),
          notFound: (_, _) => fail('Should be forbidden'),
          emailAlreadyInUse: (_, _) => fail('Should be forbidden'),
          invalidInput: (_, _) => fail('Should be forbidden'),
        );
      });

      test('maps email not registered scenario', () {
        const exception = ServerException(
          statusCode: HttpStatus.notFound,
          message: 'Email not registered',
        );

        final result = mapper.mapToFailure(exception);

        (result as AuthFailure).when(
          notFound: (message, stackTrace) {
            expect(message, 'Email not registered');
          },
          unauthorized: (_, _) => fail('Should be not found'),
          forbidden: (_, _) => fail('Should be not found'),
          emailAlreadyInUse: (_, _) => fail('Should be not found'),
          invalidInput: (_, _) => fail('Should be not found'),
        );
      });

      test('maps server errors to infrastructure failures', () {
        const exception = ServerException(
          statusCode: HttpStatus.internalServerError,
          message: 'Internal server error',
        );

        final result = mapper.mapToFailure(exception);

        // Server errors should be infrastructure failures, not auth failures
        expect(result, isNot(isA<AuthFailure>()));
        expect(result, isA<InfrastructureFailure>());
      });
    });
  });
}
