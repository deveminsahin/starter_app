import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:starter_app/core/logging/i_app_logger.dart';

/// HTTP logging interceptor for debugging network requests.
///
/// Logs all HTTP requests and responses using AppLogger, which means:
/// - **Development**: Detailed console logs with formatting
/// - **Staging/Production**: Logs sent to Sentry for monitoring
///
/// Automatically handles:
/// - Request/response logging
/// - Error logging with stack traces
/// - Performance timing
/// - Request/response body formatting
final class LoggingInterceptor implements Interceptor {
  const LoggingInterceptor(this._logger);

  final IAppLogger _logger;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final request = chain.request;
    final stopwatch = Stopwatch()..start();

    // Log request
    _logRequest(request);

    try {
      // Execute request
      final response = await chain.proceed(request);
      stopwatch.stop();

      // Log response
      _logResponse(response, stopwatch.elapsedMilliseconds);

      return response;
    } catch (error, stackTrace) {
      stopwatch.stop();

      // Log error
      _logError(request, error, stackTrace, stopwatch.elapsedMilliseconds);

      rethrow;
    }
  }

  /// Log HTTP request details
  void _logRequest(Request request) {
    _logger.debug(
      'HTTP Request',
      data: {
        'method': request.method,
        'url': request.url.toString(),
        'headers': _sanitizeHeaders(request.headers),
        'body': _sanitizeBody(request.body),
      },
      tag: 'API',
    );
  }

  /// Log HTTP response details
  void _logResponse(Response<dynamic> response, int durationMs) {
    final isSuccess = response.isSuccessful;

    final message = isSuccess
        ? 'HTTP Response (${response.statusCode})'
        : 'HTTP Error Response (${response.statusCode})';

    _logger.debug(
      message,
      data: {
        'method': response.base.request?.method ?? 'UNKNOWN',
        'url': response.base.request?.url.toString() ?? 'UNKNOWN',
        'statusCode': response.statusCode,
        'duration': '${durationMs}ms',
        'headers': _sanitizeHeaders(Map<String, String>.from(response.headers)),
        'body': _sanitizeBody(_formatResponseBody(response.body)),
      },
      tag: 'API',
    );
  }

  /// Log HTTP error
  void _logError(
    Request request,
    Object error,
    StackTrace stackTrace,
    int durationMs,
  ) {
    _logger.error(
      'HTTP Request Failed',
      error: error,
      stackTrace: stackTrace,
      data: {
        'method': request.method,
        'url': request.url.toString(),
        'duration': '${durationMs}ms',
      },
      tag: 'API',
    );
  }

  /// Sanitize headers to hide sensitive data
  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);

    // Hide sensitive headers
    const sensitiveHeaders = [
      'authorization',
      'cookie',
      'set-cookie',
      'x-api-key',
      'api-key',
    ];

    for (final key in sanitized.keys.toList()) {
      if (sensitiveHeaders.contains(key.toLowerCase())) {
        sanitized[key] = '***REDACTED***';
      }
    }

    return sanitized;
  }

  /// Sanitize request body to hide sensitive data
  dynamic _sanitizeBody(dynamic body) {
    if (body == null) return null;

    // For maps, hide password fields
    if (body is Map) {
      final sanitized = Map<String, dynamic>.from(body as Map<String, dynamic>);

      const sensitiveFields = [
        'password',
        'newPassword',
        'oldPassword',
        'confirmPassword',
        'token',
        'refreshToken',
        'accessToken',
        'secret',
        'apiKey',
        'pin',
        'otp',
        'cvv',
        'cardNumber',
        'creditCard',
        'ssn',
        'socialSecurityNumber',
      ];

      for (final key in sanitized.keys.toList()) {
        if (sensitiveFields.contains(key)) {
          sanitized[key] = '***REDACTED***';
        }
      }

      return sanitized;
    }

    // For strings, just show length
    if (body is String) {
      return '${body.length} characters';
    }

    return body;
  }

  /// Format response body for logging
  dynamic _formatResponseBody(dynamic body) {
    if (body == null) return null;

    // If it's a large string, truncate it
    if (body is String && body.length > 1000) {
      return '${body.substring(0, 1000)}... (${body.length} total characters)';
    }

    return body;
  }
}
