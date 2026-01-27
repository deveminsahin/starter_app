import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:starter_app/core/api/interceptors/api_key_interceptor.dart';

/// Authentication interceptor for adding Bearer tokens to requests.
///
/// Automatically adds the `Authorization: Bearer <token>` header to API
/// requests when a token is available.
///
/// For API key authentication, use [ApiKeyInterceptor] instead.
///
/// Usage:
/// ```dart
/// // Inject token provider from your auth service
/// final interceptor = AuthInterceptor(() async => await getToken());
/// ```
final class AuthInterceptor implements Interceptor {
  AuthInterceptor(this._tokenProvider);

  /// Function that provides the authentication token.
  ///
  /// This is typically injected from your auth repository/service.
  /// Returns null if user is not authenticated.
  final Future<String?> Function() _tokenProvider;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final request = chain.request;

    // Get the auth token
    final token = await _tokenProvider();

    // If no token, proceed without auth
    if (token == null || token.isEmpty) {
      return chain.proceed(request);
    }

    // Add authorization header
    final authenticatedRequest = applyHeader(
      request,
      'Authorization',
      'Bearer $token',
    );

    return chain.proceed(authenticatedRequest);
  }
}
