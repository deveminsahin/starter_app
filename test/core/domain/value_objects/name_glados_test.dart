import 'package:glados/glados.dart';
import 'package:starter_app/core/domain/value_objects/name.dart';

void main() {
  group('Name Property Tests', () {
    // 1. Fuzzing: Constructor safety
    Glados(any.letters).test('Constructor never throws', (input) {
      try {
        final name = Name(input);
        if (name.isValid) {
          expect(name.getOrCrash(), equals(input.trim()));
        }
      } catch (e) {
        fail('Name constructor threw: $e');
      }
    });

    // 2. Property: Non-empty strings within max length are valid
    // We filter input manually since any.nonEmptyString might not exist
    Glados(any.letters).test('Non-empty strings within max length are valid', (
      input,
    ) {
      // Skip empty strings and strings exceeding max length
      if (input.trim().isEmpty) return;
      if (input.trim().length > Name.maxLength) return;

      final name = Name(input);
      expect(name.isValid, isTrue);
      expect(name.getOrCrash(), equals(input.trim()));
    });

    // 3. Property: Strings exceeding max length are invalid
    Glados(any.letters).test('Strings exceeding max length are invalid', (
      input,
    ) {
      // Only test strings that would exceed max length
      if (input.trim().length <= Name.maxLength) return;

      final name = Name(input);
      expect(name.isValid, isFalse);
    });
  });
}
