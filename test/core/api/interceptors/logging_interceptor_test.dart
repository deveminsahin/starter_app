import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/api/interceptors/logging_interceptor.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      Request(
        'GET',
        Uri.parse('http://example.com'),
        Uri.parse('http://example.com'),
      ),
    );
  });

  group('LoggingInterceptor', () {
    late MockChain mockChain;
    late MockAppLogger mockLogger;

    setUp(() {
      mockChain = MockChain();
      mockLogger = MockAppLogger();
    });

    group('request logging', () {
      test('logs request details', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'POST',
          Uri.parse('https://example.com/api/test'),
          Uri.parse('https://example.com'),
          body: {'key': 'value'},
        );
        final response = Response(
          http.Response('{"data": "test"}', 200),
          const {
            'data': 'test',
          },
        );

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Request',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                return data['method'] == 'POST' &&
                    data['url'] == 'https://example.com/api/test';
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });

      test('sanitizes authorization header in logs', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'GET',
          Uri.parse('https://example.com/api/test'),
          Uri.parse('https://example.com'),
          headers: {'Authorization': 'Bearer secret-token'},
        );
        final response = Response(http.Response('', 200), null);

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Request',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                final headers = data['headers'] as Map<String, String>;
                return headers['Authorization'] == '***REDACTED***';
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });

      test('sanitizes password fields in request body', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'POST',
          Uri.parse('https://example.com/api/login'),
          Uri.parse('https://example.com'),
          body: {'email': 'test@example.com', 'password': 'secret123'},
        );
        final response = Response(http.Response('', 200), null);

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Request',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                final body = data['body'] as Map<String, dynamic>;
                return body['email'] == 'test@example.com' &&
                    body['password'] == '***REDACTED***';
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });
    });

    group('response logging', () {
      test('logs successful response', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'GET',
          Uri.parse('https://example.com/api/test'),
          Uri.parse('https://example.com'),
        );
        final response = Response(
          http.Response('{"data": "test"}', 200),
          const {
            'data': 'test',
          },
        );

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Response (200)',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                return data['statusCode'] == 200 && data['duration'] != null;
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });

      test('logs error response', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'GET',
          Uri.parse('https://example.com/api/test'),
          Uri.parse('https://example.com'),
        );
        final response = Response(
          http.Response('{"error": "Not Found"}', 404),
          null,
        );

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Error Response (404)',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                return data['statusCode'] == 404;
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });

      test('truncates large response bodies', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'GET',
          Uri.parse('https://example.com/api/test'),
          Uri.parse('https://example.com'),
        );
        final largeBody = 'x' * 2000;
        final response = Response(http.Response(largeBody, 200), largeBody);

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Response (200)',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                // After sanitization, the string body shows character count
                // First _formatResponseBody truncates, then _sanitizeBody
                // converts to character count format
                final body = data['body'] as String;
                return body.contains('characters');
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });
    });

    group('error logging', () {
      test('logs errors with stack trace', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'GET',
          Uri.parse('https://example.com/api/test'),
          Uri.parse('https://example.com'),
        );
        final error = Exception('Network error');

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenThrow(error);
        when(
          () => mockLogger.error(
            any(),
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await expectLater(
          () => interceptor.intercept(mockChain),
          throwsException,
        );

        verify(
          () => mockLogger.error(
            'HTTP Request Failed',
            error: error,
            stackTrace: any(named: 'stackTrace', that: isNotNull),
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                return data['method'] == 'GET' &&
                    data['url'] == 'https://example.com/api/test';
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });
    });

    group('sanitization', () {
      test('sanitizes multiple sensitive headers', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'GET',
          Uri.parse('https://example.com/api/test'),
          Uri.parse('https://example.com'),
          headers: {
            'Authorization': 'Bearer token',
            'Cookie': 'session=abc123',
            'X-API-Key': 'secret-key',
          },
        );
        final response = Response(http.Response('', 200), null);

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Request',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                final headers = data['headers'] as Map<String, String>;
                return headers['Authorization'] == '***REDACTED***' &&
                    headers['Cookie'] == '***REDACTED***' &&
                    headers['X-API-Key'] == '***REDACTED***';
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });

      test('sanitizes multiple sensitive fields in body', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'POST',
          Uri.parse('https://example.com/api/register'),
          Uri.parse('https://example.com'),
          body: {
            'email': 'test@example.com',
            'password': 'secret',
            'newPassword': 'newsecret',
            'token': 'abc123',
            'refreshToken': 'xyz789',
          },
        );
        final response = Response(http.Response('', 200), null);

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Request',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                final body = data['body'] as Map<String, dynamic>;
                return body['email'] == 'test@example.com' &&
                    body['password'] == '***REDACTED***' &&
                    body['newPassword'] == '***REDACTED***' &&
                    body['token'] == '***REDACTED***' &&
                    body['refreshToken'] == '***REDACTED***';
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });

      test('sanitizes all sensitive body fields', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'POST',
          Uri.parse('https://example.com/api/change-password'),
          Uri.parse('https://example.com'),
          body: {
            'email': 'test@example.com',
            'oldPassword': 'oldsecret',
            'confirmPassword': 'confirmsecret',
            'accessToken': 'access123',
            'secret': 'secretkey',
            'apiKey': 'apikey123',
          },
        );
        final response = Response(http.Response('', 200), null);

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Request',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                final body = data['body'] as Map<String, dynamic>;
                return body['email'] == 'test@example.com' &&
                    body['oldPassword'] == '***REDACTED***' &&
                    body['confirmPassword'] == '***REDACTED***' &&
                    body['accessToken'] == '***REDACTED***' &&
                    body['secret'] == '***REDACTED***' &&
                    body['apiKey'] == '***REDACTED***';
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });

      test('handles null body in request', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'GET',
          Uri.parse('https://example.com/api/test'),
          Uri.parse('https://example.com'),
        );
        final response = Response(http.Response('', 200), null);

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Request',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                return data['body'] == null;
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });

      test('sanitizes string body by showing length', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        const stringBody = 'This is a string body for testing';
        final request = Request(
          'POST',
          Uri.parse('https://example.com/api/test'),
          Uri.parse('https://example.com'),
          body: stringBody,
        );
        final response = Response(http.Response('', 200), null);

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Request',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                final body = data['body'] as String;
                return body == '${stringBody.length} characters';
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });

      test('sanitizes all sensitive headers case insensitively', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'GET',
          Uri.parse('https://example.com/api/test'),
          Uri.parse('https://example.com'),
          headers: {
            'AUTHORIZATION': 'Bearer token',
            'cookie': 'session=abc123',
            'Set-Cookie': 'session=xyz789',
            'API-Key': 'secret-key',
            'x-api-key': 'another-key',
          },
        );
        final response = Response(http.Response('', 200), null);

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Request',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                final headers = data['headers'] as Map<String, String>;
                return headers['AUTHORIZATION'] == '***REDACTED***' &&
                    headers['cookie'] == '***REDACTED***' &&
                    headers['Set-Cookie'] == '***REDACTED***' &&
                    headers['API-Key'] == '***REDACTED***' &&
                    headers['x-api-key'] == '***REDACTED***';
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });
    });

    group('response edge cases', () {
      test('handles response with null request', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'GET',
          Uri.parse('https://example.com/api/test'),
          Uri.parse('https://example.com'),
        );
        // Create a response with null request
        final httpResponse = http.Response('{"data": "test"}', 200);
        final response = Response(httpResponse, const {'data': 'test'});

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Response (200)',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                // Should handle null request gracefully
                return data['statusCode'] == 200;
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });

      test('handles null response body', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'GET',
          Uri.parse('https://example.com/api/test'),
          Uri.parse('https://example.com'),
        );
        final response = Response(http.Response('', 200), null);

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Response (200)',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                return data['body'] == null;
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });

      test('handles non-string response body', () async {
        final interceptor = LoggingInterceptor(mockLogger);
        final request = Request(
          'GET',
          Uri.parse('https://example.com/api/test'),
          Uri.parse('https://example.com'),
        );
        final response = Response(
          http.Response('{"data": "test"}', 200),
          const {'data': 'test'},
        );

        when(() => mockChain.request).thenReturn(request);
        when(() => mockChain.proceed(any())).thenAnswer((_) async => response);
        when(
          () => mockLogger.debug(
            any(),
            data: any(named: 'data'),
            tag: any(named: 'tag'),
          ),
        ).thenReturn(null);

        await interceptor.intercept(mockChain);

        verify(
          () => mockLogger.debug(
            'HTTP Response (200)',
            data: any(
              named: 'data',
              that: predicate<Map<String, dynamic>>((data) {
                // Non-string body should be returned as-is
                final body = data['body'];
                return body is Map && body['data'] == 'test';
              }),
            ),
            tag: 'API',
          ),
        ).called(1);
      });
    });
  });
}
