import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/api/interceptors/auth_interceptor.dart';

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

  group('AuthInterceptor', () {
    late MockChain mockChain;

    setUp(() {
      mockChain = MockChain();
    });

    test('adds Authorization header when token exists', () async {
      final interceptor = AuthInterceptor(() async => 'token123');
      final request = Request(
        'GET',
        Uri.parse('https://example.com'),
        Uri.parse('base'),
      );
      final response = Response(http.Response('', 200), null);

      when(() => mockChain.request).thenReturn(request);
      when(() => mockChain.proceed(any())).thenAnswer((_) async => response);

      await interceptor.intercept(mockChain);

      verify(
        () => mockChain.proceed(
          any(
            that: predicate<Request>((req) {
              return req.headers['Authorization'] == 'Bearer token123';
            }),
          ),
        ),
      ).called(1);
    });

    test('does not add header when token is null', () async {
      final interceptor = AuthInterceptor(() async => null);
      final request = Request(
        'GET',
        Uri.parse('https://example.com'),
        Uri.parse('base'),
      );
      final response = Response(http.Response('', 200), null);

      when(() => mockChain.request).thenReturn(request);
      when(() => mockChain.proceed(any())).thenAnswer((_) async => response);

      await interceptor.intercept(mockChain);

      verify(() => mockChain.proceed(request)).called(1);
    });

    test('does not add header when token is empty string', () async {
      final interceptor = AuthInterceptor(() async => '');
      final request = Request(
        'GET',
        Uri.parse('https://example.com'),
        Uri.parse('base'),
      );
      final response = Response(http.Response('', 200), null);

      when(() => mockChain.request).thenReturn(request);
      when(() => mockChain.proceed(any())).thenAnswer((_) async => response);

      await interceptor.intercept(mockChain);

      // Should proceed with original request (no auth header added)
      verify(() => mockChain.proceed(request)).called(1);
    });
  });
}
