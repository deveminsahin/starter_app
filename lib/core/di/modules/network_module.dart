import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/api/interceptors/auth_interceptor.dart';
import 'package:starter_app/core/api/interceptors/circuit_breaker_interceptor.dart';
import 'package:starter_app/core/api/interceptors/error_interceptor.dart';
import 'package:starter_app/core/api/interceptors/logging_interceptor.dart';
import 'package:starter_app/core/api/interceptors/network_error_handler.dart';
import 'package:starter_app/core/api/interceptors/refresh_token_interceptor.dart';
import 'package:starter_app/core/application/application_environment.dart';
import 'package:starter_app/core/domain/ports/ports.dart';
import 'package:starter_app/core/infrastructure/circuit_breaker/circuit_breaker_config.dart';
import 'package:starter_app/core/infrastructure/circuit_breaker/circuit_breaker_impl.dart';
import 'package:starter_app/core/infrastructure/networking/http_client_factory.dart';

import 'package:starter_app/core/logging/i_app_logger.dart';
import 'package:starter_app/features/auth/infrastructure/datasources/auth_endpoints.dart';
import 'package:synchronized/synchronized.dart';

/// Module for network/API-related dependencies.
///
/// Provides:
/// - **ChopperClient**: Configured HTTP client with interceptors
/// - **API Services**: Chopper-generated API service instances
/// - **Interceptors**: Logging, authentication, error handling
/// - **NetworkErrorHandler**: Converts network errors to exceptions
/// - **AppEnvironment**: Current app environment configuration
/// - **WebSocket**: Real-time communication client
///
/// The HTTP client is configured with:
/// - Base URL from environment configuration
/// - Timeout settings from NetworkConstants
/// - Environment-specific interceptors
/// - JSON serialization
@module
abstract class NetworkModule {
  /// Provides the WebSocket base URL for the current environment.
  ///
  /// Used by WebSocket client to establish connections to the appropriate
  /// WebSocket endpoints based on the environment.
  @Named('websocketBaseUrl')
  @singleton
  String provideWebSocketBaseUrl() {
    return AppEnvironment.current.webSocketUrl;
  }

  /// Provides NetworkErrorHandler for converting network errors.
  ///
  /// Used by ErrorInterceptor to categorize errors:
  /// - SocketException → "No internet connection"
  /// - TimeoutException → "Request timeout"
  /// - HttpException → Specific network error
  @lazySingleton
  NetworkErrorHandler provideNetworkErrorHandler() {
    return const NetworkErrorHandler();
  }

  /// Provides a Lock for token refresh synchronization.
  ///
  /// This singleton lock ensures only one token refresh happens at a time.
  /// Multiple simultaneous 401 responses will queue and wait for the same
  /// refresh operation to complete.
  @singleton
  Lock provideTokenRefreshLock() {
    return Lock();
  }

  /// Provides the Circuit Breaker configuration.
  ///
  /// Uses default configuration by default.
  @singleton
  CircuitBreakerConfig provideCircuitBreakerConfig() {
    return CircuitBreakerConfig.defaultConfig;
  }

  /// Provides the Circuit Breaker for network resilience.
  ///
  /// Manages the state of the connection to the backend.
  @singleton
  ICircuitBreaker provideCircuitBreaker(
    IAppLogger logger,
    CircuitBreakerConfig config,
  ) {
    return CircuitBreakerImpl(
      logger: logger,
      config: config,
    );
  }

  /// Provides the main Chopper HTTP client.
  ///
  /// Configured with:
  /// - Base URL from AppEnvironment (domain only)
  /// - All services use ApiEndpoints constants for paths
  /// - Logging interceptor (routes to AppLogger)
  /// - Auth interceptor (adds Bearer tokens)
  /// - Refresh token interceptor (auto-refresh on 401)
  /// - Error interceptor (converts errors to exceptions)
  /// - JSON converter for request/response serialization
  ///
  /// **URL Construction:**
  /// - Base: 'https://api.example.com' (from AppEnvironment)
  /// - Paths: '/api/v1/auth/login' (from ApiEndpoints constants)
  /// - Result: 'https://api.example.com/api/v1/auth/login'
  ///
  /// Lives for the entire app lifetime as a singleton.
  @singleton
  ChopperClient provideChopperClient(
    IAppLogger logger,
    NetworkErrorHandler networkErrorHandler,
    ITokenStorage tokenStorage,
    ISessionManager sessionManager,
    ITokenRefreshNotifier tokenRefreshNotifier,
    Lock refreshLock,
    ICircuitBreaker circuitBreaker,
    ICertificateService certificateService,
  ) {
    final apiBaseUrl = AppEnvironment.current.apiBaseUrl;

    // Create platform-specific HTTP client with optional SSL pinning
    final httpClient = getHttpClientFactory().createClient(
      trustedCertificateBytes: certificateService.trustedCertificateBytes,
    );

    return ChopperClient(
      // Base URL: Just the domain
      baseUrl: Uri.parse(apiBaseUrl),

      // Inject custom client (IO with pinning, or Web)
      client: httpClient,

      // JSON converter for serialization
      converter: const JsonConverter(),

      // Error handling
      errorConverter: const JsonConverter(),

      // Interceptors (order matters!)
      //
      // ═══════════════════════════════════════════════════════════════════════
      // INTERCEPTOR ORDER - THIS MATTERS!
      // ═══════════════════════════════════════════════════════════════════════
      //
      // Chopper interceptors are called in order for REQUESTS,
      // and REVERSE order for RESPONSES.
      //
      // Request flow:
      //   CircuitBreaker → Auth → RefreshToken → Logging → Error → [Server]
      //
      // Response flow:
      //   [Server] → Error → Logging → RefreshToken → Auth → CircuitBreaker
      //
      // This means:
      // 1. CircuitBreaker checks "isOpen" FIRST. Fails fast.
      // 2. AuthInterceptor adds token
      // 3. RefreshTokenInterceptor handles 401
      // 4. LoggingInterceptor sees request
      // 5. ErrorInterceptor catches errors
      // 6. CircuitBreaker records success/failure LAST on the way back
      // ═══════════════════════════════════════════════════════════════════════
      interceptors: [
        // 1. Fail fast if circuit is open
        CircuitBreakerInterceptor(circuitBreaker),

        // 2. Add authentication headers
        AuthInterceptor(() => tokenStorage.getAccessToken()),

        // 3. Handle 401 and refresh tokens (before ErrorInterceptor!)
        RefreshTokenInterceptor(
          tokenStorage: tokenStorage,
          // Use AuthEndpoints constant for refresh path
          refreshTokenEndpoint: AuthEndpoints.refreshToken,
          // Notify session manager when refresh fails
          // AuthBloc listens to this and handles navigation
          onRefreshFailed: sessionManager.notifySessionExpired,
          // Notify when token is refreshed so WebSocket can reconnect
          onRefreshSuccess: tokenRefreshNotifier.notifyTokenRefreshed,
          baseUrl: Uri.parse(apiBaseUrl),
          refreshLock: refreshLock,
        ),

        // 4. Log requests/responses (after auth added)
        LoggingInterceptor(logger),

        // 5. Convert HTTP errors to exceptions
        ErrorInterceptor(networkErrorHandler),
      ],
    );
  }
}
