import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/infrastructure/storage/token_storage_impl.dart';

import '../../helpers/mock_helpers.dart';

void main() {
  group('TokenStorageImpl', () {
    late MockSecureStorage mockSecureStorage;
    late TokenStorageImpl tokenStorage;

    const accessTokenKey = 'auth_access_token';
    const refreshTokenKey = 'auth_refresh_token';
    const testAccessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
    const testRefreshToken = 'refresh_token_abc123...';

    setUp(() {
      mockSecureStorage = MockSecureStorage();
      tokenStorage = TokenStorageImpl(mockSecureStorage);
    });

    group('getAccessToken', () {
      test('returns access token when it exists', () async {
        // Arrange
        when(
          () => mockSecureStorage.read(key: accessTokenKey),
        ).thenAnswer((_) async => testAccessToken);

        // Act
        final result = await tokenStorage.getAccessToken();

        // Assert
        expect(result, testAccessToken);
        verify(() => mockSecureStorage.read(key: accessTokenKey)).called(1);
      });

      test('returns null when access token does not exist', () async {
        // Arrange
        when(
          () => mockSecureStorage.read(key: accessTokenKey),
        ).thenAnswer((_) async => null);

        // Act
        final result = await tokenStorage.getAccessToken();

        // Assert
        expect(result, null);
        verify(() => mockSecureStorage.read(key: accessTokenKey)).called(1);
      });
    });

    group('getRefreshToken', () {
      test('returns refresh token when it exists', () async {
        // Arrange
        when(
          () => mockSecureStorage.read(key: refreshTokenKey),
        ).thenAnswer((_) async => testRefreshToken);

        // Act
        final result = await tokenStorage.getRefreshToken();

        // Assert
        expect(result, testRefreshToken);
        verify(() => mockSecureStorage.read(key: refreshTokenKey)).called(1);
      });

      test('returns null when refresh token does not exist', () async {
        // Arrange
        when(
          () => mockSecureStorage.read(key: refreshTokenKey),
        ).thenAnswer((_) async => null);

        // Act
        final result = await tokenStorage.getRefreshToken();

        // Assert
        expect(result, null);
        verify(() => mockSecureStorage.read(key: refreshTokenKey)).called(1);
      });
    });

    group('saveTokens', () {
      test('saves both access and refresh tokens', () async {
        // Arrange
        when(
          () => mockSecureStorage.write(
            key: accessTokenKey,
            value: testAccessToken,
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockSecureStorage.write(
            key: refreshTokenKey,
            value: testRefreshToken,
          ),
        ).thenAnswer((_) async {});

        // Act
        await tokenStorage.saveTokens(
          accessToken: testAccessToken,
          refreshToken: testRefreshToken,
        );

        // Assert
        verify(
          () => mockSecureStorage.write(
            key: accessTokenKey,
            value: testAccessToken,
          ),
        ).called(1);
        verify(
          () => mockSecureStorage.write(
            key: refreshTokenKey,
            value: testRefreshToken,
          ),
        ).called(1);
      });

      test('saves only access token when refresh token is null', () async {
        // Arrange
        when(
          () => mockSecureStorage.write(
            key: accessTokenKey,
            value: testAccessToken,
          ),
        ).thenAnswer((_) async {});

        // Act
        await tokenStorage.saveTokens(accessToken: testAccessToken);

        // Assert
        verify(
          () => mockSecureStorage.write(
            key: accessTokenKey,
            value: testAccessToken,
          ),
        ).called(1);
        verifyNever(
          () => mockSecureStorage.write(
            key: refreshTokenKey,
            value: any(named: 'value'),
          ),
        );
      });
    });

    group('saveAccessToken', () {
      test('saves access token', () async {
        // Arrange
        when(
          () => mockSecureStorage.write(
            key: accessTokenKey,
            value: testAccessToken,
          ),
        ).thenAnswer((_) async {});

        // Act
        await tokenStorage.saveAccessToken(testAccessToken);

        // Assert
        verify(
          () => mockSecureStorage.write(
            key: accessTokenKey,
            value: testAccessToken,
          ),
        ).called(1);
      });

      test('overwrites existing access token', () async {
        // Arrange
        const newToken = 'new_access_token_xyz...';
        when(
          () => mockSecureStorage.write(
            key: accessTokenKey,
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        // Act
        await tokenStorage.saveAccessToken(testAccessToken);
        await tokenStorage.saveAccessToken(newToken);

        // Assert
        verify(
          () => mockSecureStorage.write(
            key: accessTokenKey,
            value: testAccessToken,
          ),
        ).called(1);
        verify(
          () => mockSecureStorage.write(
            key: accessTokenKey,
            value: newToken,
          ),
        ).called(1);
      });
    });

    group('clearTokens', () {
      test('deletes both access and refresh tokens', () async {
        // Arrange
        when(
          () => mockSecureStorage.delete(key: accessTokenKey),
        ).thenAnswer((_) async {});
        when(
          () => mockSecureStorage.delete(key: refreshTokenKey),
        ).thenAnswer((_) async {});

        // Act
        await tokenStorage.clearTokens();

        // Assert
        verify(() => mockSecureStorage.delete(key: accessTokenKey)).called(1);
        verify(() => mockSecureStorage.delete(key: refreshTokenKey)).called(1);
      });
    });

    group('hasTokens', () {
      test('returns true when access token exists and is not empty', () async {
        // Arrange
        when(
          () => mockSecureStorage.read(key: accessTokenKey),
        ).thenAnswer((_) async => testAccessToken);

        // Act
        final result = await tokenStorage.hasTokens();

        // Assert
        expect(result, true);
      });

      test('returns false when access token is null', () async {
        // Arrange
        when(
          () => mockSecureStorage.read(key: accessTokenKey),
        ).thenAnswer((_) async => null);

        // Act
        final result = await tokenStorage.hasTokens();

        // Assert
        expect(result, false);
      });

      test('returns false when access token is empty string', () async {
        // Arrange
        when(
          () => mockSecureStorage.read(key: accessTokenKey),
        ).thenAnswer((_) async => '');

        // Act
        final result = await tokenStorage.hasTokens();

        // Assert
        expect(result, false);
      });
    });
  });
}
