import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';
import 'package:starter_app/features/auth/domain/value_objects/auth_token.dart';
import 'package:starter_app/features/auth/domain/value_objects/token_failure.dart';

void main() {
  group('AuthToken', () {
    const validJwt =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
        'eyJzdWIiOiIxMjM0NTY3ODkwIn0.'
        'dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U';

    group('constructor', () {
      test('creates auth token with valid JWT', () {
        final token = AuthToken(validJwt);

        expect(token.isValid, true);
        expect(token.getOrCrash(), validJwt);
      });

      test('fails with empty string', () {
        final token = AuthToken('');

        expect(token.isValid, false);
        expect(
          token.getFailuresOrNull(),
          contains(isA<TokenEmpty>()),
        );
      });

      test('fails with invalid JWT format - missing parts', () {
        final token = AuthToken('header.payload');

        expect(token.isValid, false);
        expect(
          token.getFailuresOrNull(),
          contains(isA<TokenInvalidFormat>()),
        );
      });

      test('fails with invalid JWT format - too many parts', () {
        final token = AuthToken('header.payload.signature.extra');

        expect(token.isValid, false);
        expect(
          token.getFailuresOrNull(),
          contains(isA<TokenInvalidFormat>()),
        );
      });

      test('fails with invalid characters', () {
        final token = AuthToken('header!@#.payload.signature');

        expect(token.isValid, false);
        expect(
          token.getFailuresOrNull(),
          contains(isA<TokenInvalidFormat>()),
        );
      });

      test('accepts JWT with base64url characters', () {
        const jwtWithBase64Url = 'aB09_-.cD12_-.eF34_-';
        final token = AuthToken(jwtWithBase64Url);

        expect(token.isValid, true);
        expect(token.getOrCrash(), jwtWithBase64Url);
      });

      test('accepts very long JWT', () {
        final longJwt = '${'a' * 500}.${'b' * 500}.${'c' * 500}';
        final token = AuthToken(longJwt);

        expect(token.isValid, true);
      });
    });

    group('fromTrustedSource', () {
      test('creates valid token without validation', () {
        const invalidFormat = 'not-a-jwt';
        final token = AuthToken.fromTrustedSource(invalidFormat);

        expect(token.isValid, true);
        expect(token.getOrCrash(), invalidFormat);
      });

      test('bypasses validation for empty string', () {
        final token = AuthToken.fromTrustedSource('');

        expect(token.isValid, true);
        expect(token.getOrCrash(), '');
      });

      test('creates token from API response', () {
        final token = AuthToken.fromTrustedSource(validJwt);

        expect(token.isValid, true);
        expect(token.getOrCrash(), validJwt);
      });
    });

    group('getOrCrash', () {
      test('returns token value when valid', () {
        final token = AuthToken(validJwt);

        expect(token.getOrCrash(), validJwt);
      });

      test('throws when invalid', () {
        final token = AuthToken('invalid');

        expect(token.getOrCrash, throwsA(isA<Error>()));
      });
    });

    group('getOrNull', () {
      test('returns token value when valid', () {
        final token = AuthToken(validJwt);

        expect(token.getOrNull(), validJwt);
      });

      test('returns null when invalid', () {
        final token = AuthToken('invalid');

        expect(token.getOrNull(), null);
      });
    });

    group('getFailuresOrNull', () {
      test('returns null when valid', () {
        final token = AuthToken(validJwt);

        expect(token.getFailuresOrNull(), null);
      });

      test('returns failures when invalid', () {
        final token = AuthToken('');

        final failures = token.getFailuresOrNull();
        expect(failures, isNotNull);
        expect(failures, isA<List<ValueFailure<String>>>());
        expect(failures!.length, 1);
      });

      test('returns InvalidFormat failure for wrong format', () {
        final token = AuthToken('not-a-jwt');

        final failures = token.getFailuresOrNull();
        expect(failures?.first, isA<TokenInvalidFormat>());
      });
    });

    group('equality', () {
      test('equals another token with same value', () {
        final token1 = AuthToken(validJwt);
        final token2 = AuthToken(validJwt);

        expect(token1, token2);
      });

      test('equals another token from trusted source with same value', () {
        final token1 = AuthToken(validJwt);
        final token2 = AuthToken.fromTrustedSource(validJwt);

        expect(token1, token2);
      });

      test('not equals token with different value', () {
        final token1 = AuthToken(validJwt);
        final token2 = AuthToken('aaa.bbb.ccc');

        expect(token1, isNot(token2));
      });

      test('not equals token when one is invalid', () {
        final token1 = AuthToken(validJwt);
        final token2 = AuthToken('invalid');

        expect(token1, isNot(token2));
      });

      test('identity check returns true for same instance', () {
        final token = AuthToken(validJwt);

        expect(identical(token, token), true);
      });
    });

    group('hashCode', () {
      test('same value produces same hash code', () {
        final token1 = AuthToken(validJwt);
        final token2 = AuthToken(validJwt);

        expect(token1.hashCode, token2.hashCode);
      });

      test('different value produces different hash code', () {
        final token1 = AuthToken(validJwt);
        final token2 = AuthToken('aaa.bbb.ccc');

        expect(token1.hashCode, isNot(token2.hashCode));
      });
    });

    group('toString', () {
      test('masks token value when valid', () {
        final token = AuthToken(validJwt);

        expect(token.toString(), 'AuthToken(***)');
        expect(token.toString(), isNot(contains(validJwt)));
      });

      test('shows invalid when token is invalid', () {
        final token = AuthToken('invalid');

        expect(token.toString(), 'AuthToken(invalid)');
      });
    });

    group('edge cases', () {
      test('handles token with only valid characters', () {
        const token = 'ABC123_-.DEF456_-.GHI789_-';
        final authToken = AuthToken(token);

        expect(authToken.isValid, true);
      });

      test('rejects token with spaces', () {
        const token = 'header.pay load.signature';
        final authToken = AuthToken(token);

        expect(authToken.isValid, false);
      });

      test('rejects token with newlines', () {
        const token = 'header.\npayload.\nsignature';
        final authToken = AuthToken(token);

        expect(authToken.isValid, false);
      });

      test('handles minimum valid JWT', () {
        const minToken = 'a.b.c';
        final authToken = AuthToken(minToken);

        expect(authToken.isValid, true);
      });
    });
  });
}
