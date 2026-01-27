import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';
import 'package:starter_app/features/auth/domain/value_objects/refresh_token.dart';
import 'package:starter_app/features/auth/domain/value_objects/token_failure.dart';

void main() {
  group('RefreshToken', () {
    const validToken = 'refresh_token_1234567890abcdef';
    const minLengthToken = '1234567890123456'; // Exactly 16 chars

    group('constructor', () {
      test('creates refresh token with valid value', () {
        final token = RefreshToken(validToken);

        expect(token.isValid, true);
        expect(token.getOrCrash(), validToken);
      });

      test('creates refresh token with minimum length', () {
        final token = RefreshToken(minLengthToken);

        expect(token.isValid, true);
        expect(token.getOrCrash(), minLengthToken);
      });

      test('fails with empty string', () {
        final token = RefreshToken('');

        expect(token.isValid, false);
        expect(
          token.getFailuresOrNull(),
          contains(isA<TokenEmpty>()),
        );
      });

      test('fails with token shorter than minimum length', () {
        const tooShort = '123456789012345'; // 15 chars
        final token = RefreshToken(tooShort);

        expect(token.isValid, false);
        expect(
          token.getFailuresOrNull(),
          contains(isA<TokenTooShort>()),
        );
      });

      test('accepts long token', () {
        final longToken = 'a' * 200;
        final token = RefreshToken(longToken);

        expect(token.isValid, true);
        expect(token.getOrCrash(), longToken);
      });

      test('accepts UUID format', () {
        const uuidToken = '550e8400-e29b-41d4-a716-446655440000';
        final token = RefreshToken(uuidToken);

        expect(token.isValid, true);
      });

      test('accepts JWT format', () {
        const jwtToken =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
            'eyJzdWIiOiIxMjM0NTY3ODkwIn0.'
            'dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U';
        final token = RefreshToken(jwtToken);

        expect(token.isValid, true);
      });

      test('accepts opaque string', () {
        const opaqueToken = 'refresh_abc123xyz789_token';
        final token = RefreshToken(opaqueToken);

        expect(token.isValid, true);
      });
    });

    group('fromTrustedSource', () {
      test('creates valid token without validation', () {
        const shortToken = 'short';
        final token = RefreshToken.fromTrustedSource(shortToken);

        expect(token.isValid, true);
        expect(token.getOrCrash(), shortToken);
      });

      test('bypasses validation for empty string', () {
        final token = RefreshToken.fromTrustedSource('');

        expect(token.isValid, true);
        expect(token.getOrCrash(), '');
      });

      test('creates token from API response', () {
        final token = RefreshToken.fromTrustedSource(validToken);

        expect(token.isValid, true);
        expect(token.getOrCrash(), validToken);
      });
    });

    group('getOrCrash', () {
      test('returns token value when valid', () {
        final token = RefreshToken(validToken);

        expect(token.getOrCrash(), validToken);
      });

      test('throws when invalid', () {
        final token = RefreshToken('short');

        expect(token.getOrCrash, throwsA(isA<Error>()));
      });
    });

    group('getOrNull', () {
      test('returns token value when valid', () {
        final token = RefreshToken(validToken);

        expect(token.getOrNull(), validToken);
      });

      test('returns null when invalid', () {
        final token = RefreshToken('short');

        expect(token.getOrNull(), null);
      });
    });

    group('getFailuresOrNull', () {
      test('returns null when valid', () {
        final token = RefreshToken(validToken);

        expect(token.getFailuresOrNull(), null);
      });

      test('returns failures when invalid', () {
        final token = RefreshToken('');

        final failures = token.getFailuresOrNull();
        expect(failures, isNotNull);
        expect(failures, isA<List<ValueFailure<String>>>());
        expect(failures!.length, 1);
      });

      test('returns TooShort failure for short token', () {
        final token = RefreshToken('short');

        final failures = token.getFailuresOrNull();
        expect(failures?.first, isA<TokenTooShort>());
      });

      test('returns Empty failure for empty token', () {
        final token = RefreshToken('');

        final failures = token.getFailuresOrNull();
        expect(failures?.first, isA<TokenEmpty>());
      });
    });

    group('equality', () {
      test('equals another token with same value', () {
        final token1 = RefreshToken(validToken);
        final token2 = RefreshToken(validToken);

        expect(token1, token2);
      });

      test('equals another token from trusted source with same value', () {
        final token1 = RefreshToken(validToken);
        final token2 = RefreshToken.fromTrustedSource(validToken);

        expect(token1, token2);
      });

      test('not equals token with different value', () {
        final token1 = RefreshToken(validToken);
        final token2 = RefreshToken('different_token_1234567890');

        expect(token1, isNot(token2));
      });

      test('not equals token when one is invalid', () {
        final token1 = RefreshToken(validToken);
        final token2 = RefreshToken('short');

        expect(token1, isNot(token2));
      });

      test('identity check returns true for same instance', () {
        final token = RefreshToken(validToken);

        expect(identical(token, token), true);
      });
    });

    group('hashCode', () {
      test('same value produces same hash code', () {
        final token1 = RefreshToken(validToken);
        final token2 = RefreshToken(validToken);

        expect(token1.hashCode, token2.hashCode);
      });

      test('different value produces different hash code', () {
        final token1 = RefreshToken(validToken);
        final token2 = RefreshToken('different_token_1234567890');

        expect(token1.hashCode, isNot(token2.hashCode));
      });
    });

    group('toString', () {
      test('masks token value when valid', () {
        final token = RefreshToken(validToken);

        expect(token.toString(), 'RefreshToken(***)');
        expect(token.toString(), isNot(contains(validToken)));
      });

      test('shows invalid when token is invalid', () {
        final token = RefreshToken('short');

        expect(token.toString(), 'RefreshToken(invalid)');
      });
    });

    group('minimum length constant', () {
      test('minLength is 16', () {
        expect(RefreshToken.minLength, 16);
      });
    });

    group('edge cases', () {
      test('handles token with special characters', () {
        const token = r'refresh!@#$%^&*()_+-={}[]|:;<>?,./';
        final refreshToken = RefreshToken(token);

        expect(refreshToken.isValid, true);
      });

      test('handles token with spaces', () {
        const token = 'refresh token with spaces';
        final refreshToken = RefreshToken(token);

        expect(refreshToken.isValid, true);
      });

      test('handles token with unicode', () {
        const token = 'refresh_token_🔒🔑';
        final refreshToken = RefreshToken(token);

        expect(refreshToken.isValid, true);
      });

      test('fails with null becomes empty', () {
        // Note: The constructor accepts String, so null isn't possible
        // but testing the validation logic
        final token = RefreshToken('');

        expect(token.isValid, false);
      });
    });
  });
}
