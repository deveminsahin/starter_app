import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/base/unique_id.dart';
import 'package:starter_app/core/domain/base/unique_id_failure.dart';

void main() {
  group('UniqueId', () {
    group('generate', () {
      test('generates a new unique ID', () {
        final id1 = UniqueId.generate();
        final id2 = UniqueId.generate();

        expect(id1.value, isNotEmpty);
        expect(id2.value, isNotEmpty);
        expect(id1.value, isNot(id2.value));
      });

      test('generates valid UUID v4 format', () {
        final id = UniqueId.generate();
        // UUID v4 format: 8-4-4-4-12 hexadecimal characters
        final uuidPattern = RegExp(
          r'''^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$''',
          caseSensitive: false,
        );
        expect(id.value, matches(uuidPattern));
      });

      test('generates different IDs on each call', () {
        final ids = List.generate(10, (_) => UniqueId.generate());
        final uniqueIds = ids.map((id) => id.value).toSet();
        expect(uniqueIds.length, 10);
      });
    });

    group('fromString', () {
      test('creates UniqueId from valid string', () {
        const idString = '123e4567-e89b-12d3-a456-426614174000';
        final id = UniqueId.fromString(idString);

        expect(id.value, idString);
      });

      test('creates UniqueId from any non-empty string', () {
        const idString = 'custom-id-123';
        final id = UniqueId.fromString(idString);

        expect(id.value, idString);
      });

      test('preserves exact string value', () {
        const idString = '  spaced-id  ';
        final id = UniqueId.fromString(idString);

        expect(id.value, idString);
      });
    });

    group('fromUntrusted', () {
      test('returns Right with valid UUID string', () {
        const input = '123e4567-e89b-12d3-a456-426614174000';
        final result = UniqueId.fromUntrusted(input);

        expect(result.isRight(), true);
        result.fold(
          (failures) => fail('Should not return failure'),
          (id) {
            expect(id.value, input);
          },
        );
      });

      test('trims whitespace from valid UUID input', () {
        const input = '  123e4567-e89b-12d3-a456-426614174000  ';
        final result = UniqueId.fromUntrusted(input);

        expect(result.isRight(), true);
        result.fold(
          (failures) => fail('Should not return failure'),
          (id) {
            expect(id.value, '123e4567-e89b-12d3-a456-426614174000');
          },
        );
      });

      test('accepts UUID with uppercase letters', () {
        const input = '123E4567-E89B-12D3-A456-426614174000';
        final result = UniqueId.fromUntrusted(input);

        expect(result.isRight(), true);
      });

      test('returns Left with Empty failure for null input', () {
        final result = UniqueId.fromUntrusted(null);

        expect(result.isLeft(), true);
        result.fold(
          (failures) {
            expect(failures, isA<List<dynamic>>());
            expect(failures.first, isA<UniqueIdEmpty>());
          },
          (id) => fail('Should not return valid ID'),
        );
      });

      test('returns Left with Empty failure for empty string', () {
        final result = UniqueId.fromUntrusted('');

        expect(result.isLeft(), true);
        result.fold(
          (failures) {
            expect(failures, isA<List<dynamic>>());
            expect(failures.first, isA<UniqueIdEmpty>());
          },
          (id) => fail('Should not return valid ID'),
        );
      });

      test('returns Left with Empty failure for whitespace-only string', () {
        final result = UniqueId.fromUntrusted('   ');

        expect(result.isLeft(), true);
        result.fold(
          (failures) {
            expect(failures, isA<List<dynamic>>());
            expect(failures.first, isA<UniqueIdEmpty>());
          },
          (id) => fail('Should not return valid ID'),
        );
      });

      test('returns Left with InvalidFormat failure for non-UUID string', () {
        final result = UniqueId.fromUntrusted('not-a-valid-uuid');

        expect(result.isLeft(), true);
        result.fold(
          (failures) {
            expect(failures, isA<List<dynamic>>());
            expect(failures.first, isA<UniqueIdInvalidFormat>());
          },
          (id) => fail('Should not return valid ID'),
        );
      });

      test('returns Left with InvalidFormat failure for partial UUID', () {
        // Missing last segment
        final result = UniqueId.fromUntrusted('123e4567-e89b-12d3-a456');

        expect(result.isLeft(), true);
        result.fold(
          (failures) {
            expect(failures.first, isA<UniqueIdInvalidFormat>());
          },
          (id) => fail('Should not return valid ID'),
        );
      });

      test(
        'returns Left with InvalidFormat failure for UUID with extra chars',
        () {
          final result = UniqueId.fromUntrusted(
            '123e4567-e89b-12d3-a456-426614174000-extra',
          );

          expect(result.isLeft(), true);
          result.fold(
            (failures) {
              expect(failures.first, isA<UniqueIdInvalidFormat>());
            },
            (id) => fail('Should not return valid ID'),
          );
        },
      );

      test(
        'returns Left with InvalidFormat failure for numeric-only string',
        () {
          final result = UniqueId.fromUntrusted('1234567890');

          expect(result.isLeft(), true);
          result.fold(
            (failures) {
              expect(failures.first, isA<UniqueIdInvalidFormat>());
            },
            (id) => fail('Should not return valid ID'),
          );
        },
      );
    });

    group('equality', () {
      test('equals another UniqueId with same value', () {
        const idString = '123e4567-e89b-12d3-a456-426614174000';
        final id1 = UniqueId.fromString(idString);
        final id2 = UniqueId.fromString(idString);

        expect(id1, id2);
        expect(id1.hashCode, id2.hashCode);
      });

      test('not equals UniqueId with different value', () {
        final id1 = UniqueId.fromString('id-1');
        final id2 = UniqueId.fromString('id-2');

        expect(id1, isNot(id2));
      });

      test('not equals identical instance (same reference)', () {
        final id1 = UniqueId.fromString('id-1');
        final id2 = UniqueId.fromString('id-1');

        expect(id1 == id2, true);
        expect(identical(id1, id2), false);
      });

      test('not equals different types', () {
        final id = UniqueId.fromString('id-1');
        final otherId = UniqueId.fromString('id-2');

        expect(id == otherId, false);
      });
    });

    group('hashCode', () {
      test('same value produces same hashCode', () {
        const idString = '123e4567-e89b-12d3-a456-426614174000';
        final id1 = UniqueId.fromString(idString);
        final id2 = UniqueId.fromString(idString);

        expect(id1.hashCode, id2.hashCode);
      });

      test('different values produce different hashCodes', () {
        final id1 = UniqueId.fromString('id-1');
        final id2 = UniqueId.fromString('id-2');

        expect(id1.hashCode, isNot(id2.hashCode));
      });
    });

    group('toString', () {
      test('returns the underlying value', () {
        const idString = '123e4567-e89b-12d3-a456-426614174000';
        final id = UniqueId.fromString(idString);

        expect(id.toString(), idString);
      });

      test('returns exact string representation', () {
        const idString = 'custom-id-123';
        final id = UniqueId.fromString(idString);

        expect(id.toString(), idString);
      });
    });

    group('edge cases', () {
      test('handles very long ID strings', () {
        final longId = 'a' * 1000;
        final id = UniqueId.fromString(longId);

        expect(id.value, longId);
      });

      test('handles special characters in ID', () {
        const specialId = r'id-with-special-chars-!@#$%^&*()';
        final id = UniqueId.fromString(specialId);

        expect(id.value, specialId);
      });

      test('handles numeric-only IDs', () {
        const numericId = '1234567890';
        final id = UniqueId.fromString(numericId);

        expect(id.value, numericId);
      });
    });
  });
}
