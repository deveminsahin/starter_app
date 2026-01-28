import 'package:fpdart/fpdart.dart';
import 'package:starter_app/core/domain/ports/i_secure_storage.dart';
import 'package:starter_app/core/domain/ports/i_token_storage.dart';
import 'package:starter_app/core/error/failures/failure.dart';
import 'package:starter_app/features/auth/domain/entities/auth_credentials.dart';
import 'package:starter_app/features/auth/domain/entities/user.dart';
import 'package:starter_app/features/auth/domain/failure/auth_failure.dart';
import 'package:starter_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:starter_app/features/auth/domain/value_objects/auth_token.dart';
import 'package:starter_app/features/auth/domain/value_objects/refresh_token.dart';

import 'test_data.dart';

/// Fake implementations for integration testing.
///
/// Fakes provide real behavior with controlled data, unlike mocks which
/// require explicit stubbing for each interaction.
///
/// Use fakes for:
/// - Integration tests
/// - Testing complex flows
/// - When mock setup becomes too verbose
///
/// Use mocks for:
/// - Unit tests
/// - Verifying specific interactions
/// - Testing edge cases
///
/// Example:
/// ```dart
/// final fakeRepo = FakeAuthRepository();
/// final bloc = AuthBloc(Login(fakeRepo), ...);
///
/// // Fake behaves like real repository
/// bloc.add(LoginSubmitted(credentials));
/// expect(bloc.state, isA<Authenticated>());
/// ```

// ═══════════════════════════════════════════════════════════════════════════
// Storage Fakes
// ═══════════════════════════════════════════════════════════════════════════

/// In-memory implementation of [ISecureStorage] for testing.
class FakeSecureStorage implements ISecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  /// Helper to check storage contents in tests.
  Map<String, String> get contents => Map.unmodifiable(_storage);

  /// Helper to clear storage between tests.
  void clear() => _storage.clear();
}

/// In-memory implementation of [ITokenStorage] for testing.
class FakeTokenStorage implements ITokenStorage {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }

  /// Helper to check if tokens are stored.
  @override
  Future<bool> hasTokens() async =>
      _accessToken != null && _refreshToken != null;

  /// Helper to clear tokens between tests.
  void clear() {
    _accessToken = null;
    _refreshToken = null;
  }

  @override
  Future<void> saveAccessToken(String token) async {
    _accessToken = token;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Repository Fakes
// ═══════════════════════════════════════════════════════════════════════════

/// Fake implementation of [IAuthRepository] for integration testing.
///
/// Provides controllable behavior for testing auth flows without
/// network calls or complex mock setup.
///
/// Example:
/// ```dart
/// final repo = FakeAuthRepository();
/// repo.loginResult = Right(TestData.user());
///
/// final result = await repo.login(credentials);
/// expect(result.isRight(), true);
/// ```
class FakeAuthRepository implements IAuthRepository {
  /// Controls the result of [login]. Defaults to success.
  Either<AuthFailure, User> loginResult = Right(TestData.user());

  /// Controls the result of [register]. Defaults to success.
  Either<AuthFailure, User> registerResult = Right(TestData.user());

  /// Controls the result of [logout]. Defaults to success.
  Either<AuthFailure, Unit> logoutResult = const Right(unit);

  /// Controls the result of [getCurrentUser]. Defaults to authenticated user.
  Either<AuthFailure, User?> getCurrentUserResult = Right(TestData.user());

  /// Controls the result of [checkUserExists]. Defaults to true.
  Either<AuthFailure, bool> checkUserExistsResult = const Right(true);

  /// Controls the result of [refreshToken]. Defaults to success.
  Either<AuthFailure, AuthToken> refreshTokenResult = Right(
    TestData.authToken(),
  );

  /// Stream of auth changes for [watchAuthChanges].
  Stream<Either<Failure, User?>> authChangesStream = const Stream.empty();

  /// Tracks login calls for verification.
  final List<AuthCredentials> loginCalls = [];

  /// Tracks register calls for verification.
  final List<AuthCredentials> registerCalls = [];

  /// Tracks logout call count for verification.
  int logoutCallCount = 0;

  @override
  Future<Either<AuthFailure, User>> login(AuthCredentials credentials) async {
    loginCalls.add(credentials);
    return loginResult;
  }

  @override
  Future<Either<Failure, User>> register(AuthCredentials credentials) async {
    registerCalls.add(credentials);
    return registerResult;
  }

  @override
  Future<Either<AuthFailure, Unit>> logout() async {
    logoutCallCount++;
    return logoutResult;
  }

  @override
  Future<Either<AuthFailure, User?>> getCurrentUser() async {
    return getCurrentUserResult;
  }

  @override
  Future<Either<AuthFailure, bool>> checkUserExists(dynamic email) async {
    return checkUserExistsResult;
  }

  @override
  Future<Either<AuthFailure, AuthToken>> refreshToken(
    RefreshToken refreshToken,
  ) async {
    return refreshTokenResult;
  }

  @override
  Stream<Either<Failure, User?>> watchAuthChanges() {
    return authChangesStream;
  }

  /// Resets all results and call tracking.
  void reset() {
    loginResult = Right(TestData.user());
    registerResult = Right(TestData.user());
    logoutResult = const Right(unit);
    getCurrentUserResult = Right(TestData.user());
    checkUserExistsResult = const Right(true);
    refreshTokenResult = Right(TestData.authToken());
    authChangesStream = const Stream.empty();
    loginCalls.clear();
    registerCalls.clear();
    logoutCallCount = 0;
  }
}
