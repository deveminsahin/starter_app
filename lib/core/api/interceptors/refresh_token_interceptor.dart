import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:starter_app/core/domain/ports/i_token_storage.dart';
import 'package:starter_app/core/logging/i_app_logger.dart';
import 'package:synchronized/synchronized.dart';

/// Interceptor that automatically refreshes expired access tokens.
///
/// Handles the complete token refresh flow:
/// 1. Detects 401 Unauthorized responses
/// 2. Attempts to refresh the access token using the refresh token
/// 3. Retries the original request with the new access token
/// 4. Calls [onRefreshSuccess] to notify listeners (e.g., WebSocket)
/// 5. Calls [onRefreshFailed] callback if refresh fails (user logged out)
///
/// **Important:** This interceptor should be placed BEFORE ErrorInterceptor
/// in the interceptors list, so it can handle 401s before they're converted
/// to exceptions.
///
/// Usage:
/// ```dart
/// interceptors: [
///   AuthInterceptor(_getAuthToken),
///   RefreshTokenInterceptor(...),  // Before ErrorInterceptor!
///   LoggingInterceptor(logger),
///   ErrorInterceptor(networkErrorHandler),
/// ]
/// ```
///
/// Thread-safety: Uses `synchronized` package to ensure only one refresh
/// request happens at a time. Multiple simultaneous 401s will wait for the
/// same refresh operation to complete.
final class RefreshTokenInterceptor implements Interceptor {
  RefreshTokenInterceptor({
    required this.tokenStorage,
    required this.refreshTokenEndpoint,
    required this.onRefreshFailed,
    required this.onRefreshSuccess,
    required this.baseUrl,
    required Lock refreshLock,
    http.Client? httpClient,
    IAppLogger? logger,
  }) : _lock = refreshLock,
       _httpClient = httpClient,
       _logger = logger;

  /// Optional HTTP client for testing. If not provided, ChopperClient
  /// will create its own default client.
  final http.Client? _httpClient;

  /// Token storage for getting/saving tokens
  final ITokenStorage tokenStorage;

  /// Endpoint to call for refreshing tokens (e.g., '/auth/refresh')
  final String refreshTokenEndpoint;

  /// Callback when refresh fails (should logout user)
  final void Function() onRefreshFailed;

  /// Callback when refresh succeeds (notifies WebSocket to reconnect)
  final void Function() onRefreshSuccess;

  /// Base URL for API requests
  final Uri baseUrl;

  /// Lock to prevent multiple simultaneous refresh requests
  /// Injected via DI to ensure single instance across app
  final Lock _lock;

  /// Optional logger for debugging token refresh flow
  final IAppLogger? _logger;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final request = chain.request;

    // Proceed with the original request
    final response = await chain.proceed(request);

    // If not 401, return response as-is
    if (response.statusCode != 401) {
      return response;
    }

    // If this is the refresh endpoint itself failing, don't retry
    if (request.url.path.contains(refreshTokenEndpoint)) {
      onRefreshFailed();
      return response;
    }

    // Try to refresh the token
    _logger?.debug('401 received, attempting token refresh', tag: 'AUTH');
    final newToken = await _refreshToken();

    // If refresh failed, call failure callback and return original 401
    if (newToken == null) {
      _logger?.warning(
        'Token refresh failed, user will be logged out',
        tag: 'AUTH',
      );
      onRefreshFailed();
      return response;
    }

    // Retry the original request with new token
    _logger?.info('Token refresh successful, retrying request', tag: 'AUTH');
    final newRequest = applyHeader(
      request,
      'Authorization',
      'Bearer $newToken',
    );

    return chain.proceed(newRequest);
  }

  /// Refresh the access token using the refresh token.
  ///
  /// Returns the new access token, or null if refresh failed.
  /// Uses a lock to prevent multiple simultaneous refresh requests.
  /// Multiple concurrent calls will wait for the same refresh to complete.
  Future<String?> _refreshToken() async {
    return _lock.synchronized(() async {
      // Get refresh token from storage
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _logger?.warning('No refresh token available', tag: 'AUTH');
        return null;
      }

      // Create a simple HTTP client for refresh request
      // We use Chopper's HttpClient directly to avoid circular dependency
      // Inject HTTP client for testability (allows mocking in tests)
      final client = ChopperClient(
        baseUrl: baseUrl,
        converter: const JsonConverter(),
        client: _httpClient,
      );

      try {
        // Call refresh endpoint
        final refreshRequest = Request(
          'POST',
          Uri.parse(refreshTokenEndpoint),
          baseUrl,
          body: {'refresh_token': refreshToken},
        );

        final refreshResponse = await client
            .send<Map<String, dynamic>, Map<String, dynamic>>(
              refreshRequest,
            );

        // Check if refresh was successful
        if (refreshResponse.statusCode == 200 && refreshResponse.body != null) {
          final body = refreshResponse.body;
          if (body is! Map<String, dynamic>) {
            return null;
          }

          final newAccessToken = body['access_token'] as String?;
          final newRefreshToken = body['refresh_token'] as String?;

          if (newAccessToken != null) {
            // Save new tokens
            await tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken ?? refreshToken,
            );

            // Notify listeners (e.g., WebSocket) to reconnect with new token
            onRefreshSuccess();

            return newAccessToken;
          }
        }

        // Refresh failed
        return null;
      } on Exception catch (e) {
        // Error during refresh
        _logger?.error(
          'Exception during token refresh',
          error: e,
          tag: 'AUTH',
        );
        return null;
      } finally {
        client.dispose();
      }
    });
  }
}
