import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:starter_app/core/domain/ports/ports.dart';
import 'package:starter_app/core/error/exceptions/circuit_breaker_exception.dart';

/// Interceptor that implements the Circuit Breaker pattern.
///
/// 1. Checks if circuit is OPEN before request.
/// 2. Records SUCCESS/FAILURE after request.
/// 3. Trips circuit on 5xx errors or exceptions.
final class CircuitBreakerInterceptor implements Interceptor {
  CircuitBreakerInterceptor(this._circuitBreaker);

  final ICircuitBreaker _circuitBreaker;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    // 1. Check Circuit State
    if (_circuitBreaker.isOpen) {
      throw const CircuitBreakerException();
    }

    try {
      // 2. Execute Request
      final response = await chain.proceed(chain.request);

      // 3. Update Circuit State based on Response
      if (response.statusCode >= 500) {
        // Server errors count as failures
        _circuitBreaker.onFailure('Server Error: ${response.statusCode}');
      } else {
        // Success or Client Error (4xx) - Service is reachable
        _circuitBreaker.onSuccess();
      }

      return response;
    } catch (e) {
      // 4. Handle Network/Timeout Exceptions
      _circuitBreaker.onFailure(e);
      rethrow;
    }
  }
}
