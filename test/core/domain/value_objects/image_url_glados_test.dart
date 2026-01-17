import 'package:glados/glados.dart';
import 'package:starter_app/core/domain/value_objects/image_url.dart';

void main() {
  group('ImageUrl Property Tests', () {
    // 1. Fuzzing: Constructor safety
    Glados(any.letters).test('Constructor never throws', (input) {
      try {
        final url = ImageUrl(input);
        expect(url, isA<ImageUrl>());
      } catch (e) {
        fail('ImageUrl constructor threw: $e');
      }
    });

    // 2. Property: Empty string is valid (returns null value)
    test('Empty string is valid (null value)', () {
      final url = ImageUrl('');
      expect(url.isValid, isTrue);
      expect(url.getOrNull(), isNull);
    });

    // 3. Property: Valid URLs are accepted
    Glados(
      any.combine3(
        any.lowercaseLetters,
        any.lowercaseLetters,
        any.lowercaseLetters,
        (scheme, host, path) => 'http://$host.com/$path',
      ),
    ).test('Valid URLs are accepted', (input) {
      final url = ImageUrl(input);
      expect(url.isValid, isTrue);
      expect(url.getOrCrash(), equals(input));
    });
  });
}
