/// Application environment configuration.
///
/// Determines the current environment (development, staging, production)
/// based on compile-time constants loaded from JSON files.
///
/// Usage in build:
/// ```bash
/// # Development (default)
/// flutter run --dart-define-from-file=config/development.json
///
/// # Staging
/// flutter run --dart-define-from-file=config/staging.json
///
/// # Production
/// flutter build apk --release --dart-define-from-file=config/production.json
/// ```
///
/// Configuration files are stored in `config/` directory:
/// - `development.json` - Development environment
/// - `staging.json` - Staging environment (with Sentry)
/// - `production.json` - Production environment (with Sentry)
enum AppEnvironment {
  /// Development environment - local development with debug tools.
  development,

  /// Staging environment - pre-production testing environment.
  staging,

  /// Production environment - live user-facing environment.
  production
  ;

  /// Compile-time constants for dependency injection.
  ///
  /// These are used with Injectable's `env` parameter which requires
  /// compile-time constant strings. Use these instead of `.name` property.
  ///
  /// Example:
  /// ```dart
  /// @LazySingleton(env: [AppEnvironment.devEnv])
  /// AppLogger provideDevLogger() => ConsoleLogger();
  /// ```
  static const String devEnv = 'development';
  static const String stagingEnv = 'staging';
  static const String prodEnv = 'production';

  /// The raw ENVIRONMENT value from compile-time constants.
  ///
  /// Empty string if not provided. Used for validation and debugging.
  static const String _rawEnvironment = String.fromEnvironment('ENVIRONMENT');

  /// Whether to throw an error when ENVIRONMENT is invalid.
  /// Use in CI/CD to catch configuration typos.
  static const bool _strictMode = bool.fromEnvironment('STRICT_ENV');

  /// Whether a valid ENVIRONMENT value was explicitly provided.
  ///
  /// Returns `false` if:
  /// - ENVIRONMENT was not set (empty string)
  /// - ENVIRONMENT was set to an unrecognized value
  ///
  /// Useful for debugging configuration issues.
  static bool get isExplicitlyConfigured => isConfigured(_rawEnvironment);

  /// Helper to check configuration status for a specific environment string.
  ///
  /// Visible for testing.
  static bool isConfigured(String environment) {
    if (environment.isEmpty) return false;
    return values.any((e) => e.name == environment.toLowerCase());
  }

  /// Get the current environment from compile-time constants.
  ///
  /// Defaults to [development] if:
  /// - ENVIRONMENT is not set
  /// - ENVIRONMENT is set to an unrecognized value
  ///
  /// Use [isExplicitlyConfigured] to check if a valid value was provided.
  static AppEnvironment get current =>
      getCurrentWithStrictMode(_rawEnvironment, strictMode: _strictMode);

  /// Helper to get current environment with explicit strict mode control.
  ///
  /// Visible for testing the strict mode error path.
  static AppEnvironment getCurrentWithStrictMode(
    String rawEnvironment, {
    required bool strictMode,
  }) {
    // STRICT MODE CHECK
    if (strictMode && !isConfigured(rawEnvironment)) {
      throw StateError(
        'STRICT_ENV is enabled but ENVIRONMENT "$rawEnvironment" is invalid. '
        'Valid values: ${values.map((e) => e.name).join(", ")}',
      );
    }

    return parse(rawEnvironment);
  }

  /// Helper to parse environment from string.
  ///
  /// Visible for testing.
  static AppEnvironment parse(String environment) {
    if (environment.isEmpty) {
      return AppEnvironment.development;
    }

    return AppEnvironment.values.firstWhere(
      (e) => e.name == environment.toLowerCase(),
      orElse: () => AppEnvironment.development,
    );
  }

  /// Returns warning message if ENVIRONMENT is misconfigured, null otherwise.
  ///
  /// Useful for startup diagnostics. Returns a warning if:
  /// - ENVIRONMENT is set to an unrecognized value (typo, invalid)
  ///
  /// Does NOT warn if ENVIRONMENT is simply not set (defaults to development).
  static String? get configurationWarning => validate(_rawEnvironment);

  /// Helper to validate environment string.
  ///
  /// Visible for testing.
  static String? validate(String environment) {
    if (environment.isEmpty) return null;

    final isValid = values.any((e) => e.name == environment.toLowerCase());
    if (isValid) return null;

    final validValues = values.map((e) => e.name).join(', ');
    return 'Unknown ENVIRONMENT value: "$environment". '
        'Valid values: $validValues. Defaulting to "development".';
  }

  /// Check if running in development.
  static bool get isDevelopment => current == AppEnvironment.development;

  /// Check if running in staging.
  static bool get isStaging => current == AppEnvironment.staging;

  /// Check if running in production.
  static bool get isProduction => current == AppEnvironment.production;

  /// Check if Sentry should be enabled.
  ///
  /// Sentry is enabled for staging and production only.
  bool get sentryEnabled => this == staging || this == production;

  /// Check if SSL pinning should be enabled.
  ///
  /// Pinning is enabled for staging and production to prevent MITM attacks.
  /// Disabled in development to allow network inspection (proxying).
  bool get sslPinningEnabled => this == staging || this == production;

  /// Get Sentry DSN for this environment.
  ///
  /// Returns null for development (Sentry disabled).
  /// Loaded from configuration file via `--dart-define-from-file`.
  ///
  /// Example config/staging.json:
  /// ```json
  /// {
  ///   "ENVIRONMENT": "staging",
  ///   "SENTRY_DSN": "https://xxx@sentry.io/staging"
  /// }
  /// ```
  String? get sentryDsn {
    if (this == development) return null;

    const dsn = String.fromEnvironment('SENTRY_DSN');
    return dsn.isEmpty ? null : dsn;
  }

  /// Get Sentry sample rate for performance monitoring.
  ///
  /// Higher rate in staging for testing, lower in production for performance.
  double get sentrySampleRate {
    return switch (this) {
      development => 0.0, // Disabled
      staging => 1.0, // 100% - capture everything for testing
      production => 0.1, // 10% - sample to reduce overhead
    };
  }

  /// Get API base URL for this environment.
  ///
  /// Uses the same `API_URL` constant with different values per environment.
  /// Falls back to default URLs if not provided.
  String get apiBaseUrl {
    const url = String.fromEnvironment('API_URL');

    if (url.isNotEmpty) return url;

    // Fallback defaults
    return switch (this) {
      development => 'http://localhost:3000',
      staging => 'https://api-staging.example.com',
      production => 'https://api.example.com',
    };
  }

  /// Get WebSocket URL for this environment.
  ///
  /// Converts HTTP(S) URL to WS(S) for WebSocket connections.
  /// Uses the same base URL but with WebSocket protocol.
  ///
  /// Throws [AssertionError] in debug mode if API URL doesn't use HTTP(S).
  String get webSocketUrl {
    const url = String.fromEnvironment('WS_URL');

    if (url.isNotEmpty) return url;

    // Convert HTTP(S) to WS(S)
    final baseUrl = apiBaseUrl;

    // Validate URL format - fail fast if misconfigured
    assert(
      baseUrl.startsWith('http://') || baseUrl.startsWith('https://'),
      'API_URL must start with http:// or https:// for WebSocket conversion. '
      'Got: $baseUrl',
    );

    if (baseUrl.startsWith('https://')) {
      return baseUrl.replaceFirst('https://', 'wss://');
    }
    return baseUrl.replaceFirst('http://', 'ws://');
  }

  /// Display name for this environment (capitalized).
  String get displayName => '${name[0].toUpperCase()}${name.substring(1)}';

  @override
  String toString() => displayName;
}
