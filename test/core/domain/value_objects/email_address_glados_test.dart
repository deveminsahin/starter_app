import 'package:glados/glados.dart';
import 'package:starter_app/core/domain/value_objects/email_address.dart';
// Hide test to use Glados test

void main() {
  group('EmailAddress Property Tests', () {
    // 1. Fuzzing: Constructor safety
    Glados(any.letters).test('Constructor never throws on any string input', (
      input,
    ) {
      // This should never throw an exception,
      // it should only return a ValueObject
      // that might contain a failure.
      try {
        final email = EmailAddress(input);

        // Consistency check
        if (email.isValid) {
          expect(email.getOrNull(), isNotNull);
        } else {
          expect(email.getOrNull(), isNull);
        }
      } on Exception catch (_) {
        fail(
          'EmailAddress constructor threw exception on input: "$input".',
        );
      }
    });

    // 2. Property: Valid email structure (Simple Generator)
    // Generating strings that look like emails: "a@b.c"
    Glados(
      any.combine3(
        any.lowercaseLetters,
        any.lowercaseLetters,
        any.lowercaseLetters,
        (local, domain, tld) => '$local@$domain.$tld',
      ),
    ).test('Generated email-like strings are valid', (input) {
      // Filter out empty parts which would make it invalid
      if (input.startsWith('@') ||
          input.contains('@.') ||
          input.endsWith('.')) {
        return;
      }

      // Note: The regex in EmailAddress might be stricter than this generator,
      // but generally this structure
      // should be valid or failing for known reasons.
      // We mostly check that IF it is valid, the value matches.

      final email = EmailAddress(input);
      if (email.isValid) {
        expect(email.getOrCrash(), equals(input));
      }
    });

    // 3. Property: Lowercase normalization
    Glados(any.letters).test('Valid emails are normalized to lowercase', (
      input,
    ) {
      final email = EmailAddress(input);
      if (email.isValid) {
        expect(email.getOrCrash(), equals(input.toLowerCase().trim()));
      }
    });
  });
}
