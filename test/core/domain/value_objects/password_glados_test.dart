import 'package:glados/glados.dart';
import 'package:starter_app/core/domain/value_objects/password.dart';

void main() {
  group('Password Property Tests', () {
    // 1. Fuzzing: Constructor safety
    Glados(any.letters).test('Constructor never throws', (input) {
      try {
        final password = Password(input);
        expect(password, isA<Password>());
      } catch (e) {
        fail('Password constructor threw: $e');
      }
    });

    // 2. Generator for Valid Passwords
    Glados(
      any.combine4(
        any.letters, // Uppercase source
        any.letters, // Lowercase source
        any.int, // Digit source
        any.letters, // Padding
        (a, b, c, d) {
          const special = r'!@#$%^&*(),.?":{}|<>';
          final char = special[c.abs() % special.length];

          final upperStr = a;
          final lowerStr = b;
          final padding = d;

          final upper = upperStr.isEmpty ? 'A' : upperStr[0].toUpperCase();
          final lower = lowerStr.isEmpty ? 'z' : lowerStr[0].toLowerCase();
          final digit = c.abs() % 10;

          // Construct valid password
          return '$upper$lower$digit$char${padding}Padding123!';
        },
      ),
    ).test('Valid password generator produces valid passwords', (input) {
      final password = Password(input);
      if (!password.isValid) {
        fail(
          '''Generated "valid" password failed: $input. Failures: ${password.getFailuresOrNull()}''',
        );
      }
      expect(password.isValid, isTrue);
    });
  });
}
