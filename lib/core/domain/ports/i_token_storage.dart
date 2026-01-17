/// Interface for securely storing and managing authentication tokens.
///
/// This is a **port** in hexagonal architecture - it defines the contract
/// for token-specific operations, abstracting the underlying storage mechanism.
///
/// Used by interceptors and repositories to manage the user's session tokens.
///
/// Usage:
/// ```dart
/// // Save tokens after login
/// await tokenStorage.saveTokens(
///   accessToken: 'eyJhbGc...',
///   refreshToken: 'refresh_abc123...',
/// );
///
/// // Get current access token
/// final token = await tokenStorage.getAccessToken();
///
/// // Check if user has tokens
/// if (await tokenStorage.hasTokens()) {
///   // User is potentially authenticated
/// }
///
/// // Clear on logout
/// await tokenStorage.clearTokens();
/// ```
abstract interface class ITokenStorage {
  /// Saves the access token and optionally the refresh token.
  ///
  /// [accessToken] is required - you always need at least an access token.
  /// [refreshToken] is optional - some auth systems don't use refresh tokens.
  Future<void> saveTokens({required String accessToken, String? refreshToken});

  /// Saves only the access token.
  ///
  /// Used during token refresh when only access token changes.
  Future<void> saveAccessToken(String token);

  /// Retrieves the stored access token.
  ///
  /// Returns null if no token is stored or if it has been cleared.
  Future<String?> getAccessToken();

  /// Retrieves the stored refresh token.
  ///
  /// Returns null if no token is stored or if it has been cleared.
  Future<String?> getRefreshToken();

  /// Deletes all stored authentication tokens.
  ///
  /// Should be called during logout or when tokens are invalid.
  Future<void> clearTokens();

  /// Check if user has tokens (is potentially authenticated).
  ///
  /// This only checks if tokens exist, not if they're valid.
  /// Token validation should happen server-side or via JWT decoding.
  Future<bool> hasTokens();
}
