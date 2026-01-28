import 'package:starter_app/core/domain/base/unique_id.dart';
import 'package:starter_app/core/domain/value_objects/email_address.dart';
import 'package:starter_app/core/domain/value_objects/name.dart';
import 'package:starter_app/core/domain/value_objects/password.dart';
import 'package:starter_app/features/auth/domain/entities/auth_credentials.dart';
import 'package:starter_app/features/auth/domain/entities/user.dart';
import 'package:starter_app/features/auth/domain/entities/user_id.dart';
import 'package:starter_app/features/auth/domain/value_objects/auth_token.dart';
import 'package:starter_app/features/auth/domain/value_objects/refresh_token.dart';
import 'package:starter_app/features/auth/infrastructure/models/auth_response_model.dart';
import 'package:starter_app/features/auth/infrastructure/models/auth_tokens_model.dart';
import 'package:starter_app/features/auth/infrastructure/models/user_model.dart';
import 'package:starter_app/features/profile/domain/entities/profile_id.dart';
import 'package:starter_app/features/profile/domain/entities/user_profile.dart';
import 'package:starter_app/features/profile/infrastructure/models/user_profile_model.dart';

/// Centralized test data fixtures for consistent testing across the app.
///
/// ## Organization
/// - **Primitives**: `const` strings, booleans (compile-time safe)
/// - **JSON**: `const` maps for serialization tests
/// - **Infrastructure Models**: `const` for datasource/repository tests
/// - **Domain Objects**: Factory methods for flexibility
///
/// ## Usage
/// ```dart
/// // Use const primitives for model construction
/// const email = TestData.email;
///
/// // Use const models for repository tests
/// const model = TestData.userModel;
///
/// // Use factory methods for domain objects (new instance each call)
/// final user = TestData.user();
/// final customUser = TestData.user(name: 'Custom Name');
/// ```
///
/// ## Guidelines
/// - Always use [TestData] instead of creating local test data
/// - Use factory methods when you need object variations
/// - Use const values when possible for better performance
abstract final class TestData {
  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMITIVES (const - compile-time safe)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Valid email string for testing.
  static const String email = 'test@example.com';

  /// Valid password string that meets all validation requirements.
  static const String password = 'Test123!@#';

  /// Valid name string for testing.
  static const String name = 'John Doe';

  /// Valid user ID string.
  static const String userId = 'user-123';

  /// Mock access token for testing authenticated requests.
  static const String accessToken = 'mock-access-token';

  /// Mock refresh token for testing token refresh flows.
  static const String refreshToken = 'mock-refresh-token';

  /// Valid profile image URL for testing.
  static const String profileImageUrl = 'https://example.com/profile.jpg';


  // ─────────────────────────────────────────────────────────────────────────
  // Invalid Data (for validation tests)
  // ─────────────────────────────────────────────────────────────────────────

  /// Invalid email format for testing validation.
  static const String invalidEmail = 'invalid-email';

  /// Password that's too short for validation.
  static const String shortPassword = 'short';

  /// Empty string for edge case testing.
  static const String emptyString = '';

  // ─────────────────────────────────────────────────────────────────────────
  // Edge Case Collections (for parameterized tests)
  // ─────────────────────────────────────────────────────────────────────────

  /// Collection of invalid email formats for validation testing.
  static const List<String> invalidEmails = [
    '',
    'invalid',
    '@example.com',
    'test@',
    'test@@example.com',
    'test..test@example.com',
  ];

  /// Collection of invalid passwords for validation testing.
  static const List<String> invalidPasswords = [
    '',
    'short',
    'nouppercase1!',
    'NOLOWERCASE1!',
    'NoDigit!!!',
    'NoSpecial123',
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // JSON DATA (const - for serialization tests)
  // ═══════════════════════════════════════════════════════════════════════════

  /// JSON representation of a user for API response testing.
  static const Map<String, dynamic> userJson = {
    'id': userId,
    'email': email,
  };

  /// JSON representation of auth tokens for API response testing.
  static const Map<String, dynamic> authTokensJson = {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };

  /// JSON representation of full auth response (user + tokens).
  static const Map<String, dynamic> authResponseJson = {
    'user': userJson,
    'tokens': authTokensJson,
  };

  /// JSON representation of user profile.
  static const Map<String, dynamic> userProfileJson = {
    'id': userId,
    'userId': userId,
    'displayName': name,
    'avatarUrl': profileImageUrl,
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // INFRASTRUCTURE MODELS (const - for datasource/repository tests)
  // ═══════════════════════════════════════════════════════════════════════════

  /// User model for infrastructure layer tests.
  static const UserModel userModel = UserModel(
    id: userId,
    email: email,
  );

  /// User profile model for infrastructure layer tests.
  static const UserProfileModel userProfileModel = UserProfileModel(
    id: userId,
    userId: userId,
    displayName: name,
    avatarUrl: profileImageUrl,
  );

  /// Auth tokens model for infrastructure layer tests.
  static const AuthTokensModel authTokensModel = AuthTokensModel(
    accessToken: accessToken,
    refreshToken: refreshToken,
  );

  /// Full auth response model for infrastructure layer tests.
  static const AuthResponseModel authResponseModel = AuthResponseModel(
    user: userModel,
    tokens: authTokensModel,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // DOMAIN OBJECTS - Factory Methods (new instance each call)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a [User] domain entity with optional overrides.
  ///
  /// Returns a new instance each call for test isolation.
  ///
  /// Example:
  /// ```dart
  /// final user = TestData.user();
  /// final admin = TestData.user(id: 'admin-1', emailStr: 'admin@app.com');
  /// ```
  static User user({
    String? id,
    String? emailStr,
  }) => User(
    id: UserId.fromString(id ?? userId),
    email: EmailAddress.fromTrustedSource(emailStr ?? email),
  );

  /// Creates a [UserProfile] domain entity.
  static UserProfile userProfile({
    String? id,
    String? userIdStr,
    String? displayName,
    String? avatar,
  }) => UserProfile(
    id: ProfileId.fromString(id ?? userId),
    userId: UserId.fromString(userIdStr ?? userId),
    displayName: Name.fromTrustedSource(displayName ?? name),
  );

  /// Creates [AuthCredentials] for login tests (email + password).
  ///
  /// Example:
  /// ```dart
  /// final credentials = TestData.loginCredentials();
  /// final custom = TestData.loginCredentials(emailStr: 'other@test.com');
  /// ```
  static AuthCredentials loginCredentials({
    String? emailStr,
    String? passwordStr,
  }) => AuthCredentials(
    email: EmailAddress(emailStr ?? email),
    password: Password(passwordStr ?? password),
  );

  /// Creates [AuthCredentials] for
  /// registration tests (email + password + name).
  ///
  /// Example:
  /// ```dart
  /// final credentials = TestData.registerCredentials();
  /// ```
  static AuthCredentials registerCredentials({
    String? emailStr,
    String? passwordStr,
    String? nameStr,
  }) => AuthCredentials(
    email: EmailAddress(emailStr ?? email),
    password: Password(passwordStr ?? password),
    name: Name(nameStr ?? name),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Value Object Factories
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates an [EmailAddress] value object.
  static EmailAddress emailAddress([String? value]) =>
      EmailAddress(value ?? email);

  /// Creates an [EmailAddress] from trusted source (skips validation).
  static EmailAddress trustedEmail([String? value]) =>
      EmailAddress.fromTrustedSource(value ?? email);

  /// Creates a [Password] value object.
  static Password passwordVO([String? value]) => Password(value ?? password);

  /// Creates a [Name] value object.
  static Name nameVO([String? value]) => Name(value ?? name);

  /// Creates a [Name] from trusted source (skips validation).
  static Name trustedName([String? value]) =>
      Name.fromTrustedSource(value ?? name);

  /// Creates a [UniqueId] value object.
  static UniqueId uniqueId([String? value]) =>
      UniqueId.fromString(value ?? userId);

  /// Creates a [UserId] value object.
  static UserId uniqueUserId([String? value]) =>
      UserId.fromString(value ?? userId);

  /// Creates an [AuthToken] value object.
  static AuthToken authToken([String? value]) =>
      AuthToken.fromTrustedSource(value ?? accessToken);

  /// Creates a [RefreshToken] value object.
  static RefreshToken refreshTokenVO([String? value]) =>
      RefreshToken.fromTrustedSource(value ?? refreshToken);

}
