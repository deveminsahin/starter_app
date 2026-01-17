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

    // 2. Property: Non-empty strings are valid
    // We filter input manually since any.nonEmptyString might not exist
    Glados(any.letters).test('Non-empty strings are valid', (input) {
      if (input.trim().isEmpty) return;

      final name = Name(input);
      expect(name.isValid, isTrue);
      expect(name.getOrCrash(), equals(input.trim()));
    });
  });
}
