import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/domain/value_objects/image_url.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

void main() {
  group('ImageUrl', () {
    group('constructor', () {
      test('creates valid image URL with valid input', () {
        const validUrl = 'https://example.com/image.jpg';
        final imageUrl = ImageUrl(validUrl);

        expect(imageUrl.isValid, true);
        expect(imageUrl.getOrCrash(), validUrl);
      });

      test('accepts various URL schemes', () {
        const validUrls = [
          'https://example.com/image.jpg',
          'http://example.com/image.png',
          'https://cdn.example.com/assets/image.gif',
          'https://example.com/path/to/image.webp',
        ];

        for (final url in validUrls) {
          final imageUrl = ImageUrl(url);
          expect(imageUrl.isValid, true, reason: '$url should be valid');
          expect(imageUrl.getOrCrash(), url);
        }
      });

      test('accepts null as valid (optional image)', () {
        final imageUrl = ImageUrl(null);

        expect(imageUrl.isValid, true);
        expect(imageUrl.getOrCrash(), null);
      });

      test('accepts empty string as valid (optional image)', () {
        final imageUrl = ImageUrl('');

        expect(imageUrl.isValid, true);
        expect(imageUrl.getOrCrash(), null);
      });

      test('accepts whitespace as valid (optional image)', () {
        final imageUrl = ImageUrl('   ');

        expect(imageUrl.isValid, true);
        expect(imageUrl.getOrCrash(), null);
      });

      test('rejects relative URLs', () {
        final imageUrl = ImageUrl('/path/to/image.jpg');

        expect(imageUrl.isValid, false);

        final failures = imageUrl.value.fold((l) => l, (_) => null);
        expect(failures, isNotNull);
        expect(failures!.first, isA<InvalidFormat<String?>>());
      });

      test('rejects invalid URL format', () {
        const invalidUrls = [
          'not-a-url',
          '://example.com',
          'example.com/image.jpg', // Missing scheme
        ];

        for (final url in invalidUrls) {
          final imageUrl = ImageUrl(url);
          expect(imageUrl.isValid, false, reason: '$url should be invalid');

          final failures = imageUrl.value.fold((l) => l, (_) => null);
          expect(failures, isNotNull);
          expect(failures!.first, isA<InvalidFormat<String?>>());
        }
      });

      test('accepts minimal valid URL', () {
        final imageUrl = ImageUrl('https://a');

        expect(imageUrl.isValid, true);
      });
    });

    group('fromTrustedSource', () {
      test('creates image URL without validation', () {
        final imageUrl = ImageUrl.fromTrustedSource(
          'https://example.com/img.jpg',
        );

        expect(imageUrl.isValid, true);
        expect(imageUrl.getOrCrash(), 'https://example.com/img.jpg');
      });

      test('bypasses validation for invalid URLs', () {
        final imageUrl = ImageUrl.fromTrustedSource('invalid-url');

        expect(imageUrl.isValid, true);
        expect(imageUrl.getOrCrash(), 'invalid-url');
      });

      test('accepts null from trusted source', () {
        final imageUrl = ImageUrl.fromTrustedSource(null);

        expect(imageUrl.isValid, true);
        expect(imageUrl.getOrCrash(), null);
      });
    });

    group('getOrCrash', () {
      test('returns value when valid', () {
        final imageUrl = ImageUrl('https://example.com/image.jpg');

        expect(imageUrl.getOrCrash(), 'https://example.com/image.jpg');
      });

      test('returns null when input is null', () {
        final imageUrl = ImageUrl(null);

        expect(imageUrl.getOrCrash(), null);
      });

      test('throws UnexpectedValueError when invalid', () {
        final imageUrl = ImageUrl('invalid-url');

        expect(
          imageUrl.getOrCrash,
          throwsA(isA<UnexpectedValueError>()),
        );
      });
    });

    group('equality', () {
      test('equals another image URL with same value', () {
        final imageUrl1 = ImageUrl('https://example.com/image.jpg');
        final imageUrl2 = ImageUrl('https://example.com/image.jpg');

        expect(imageUrl1, imageUrl2);
        expect(imageUrl1.hashCode, imageUrl2.hashCode);
      });

      test('equals when both are null', () {
        final imageUrl1 = ImageUrl(null);
        final imageUrl2 = ImageUrl('');

        expect(imageUrl1, imageUrl2);
      });

      test('not equals image URL with different value', () {
        final imageUrl1 = ImageUrl('https://example.com/image1.jpg');
        final imageUrl2 = ImageUrl('https://example.com/image2.jpg');

        expect(imageUrl1, isNot(imageUrl2));
      });
    });

    group('toString', () {
      test('shows value when valid', () {
        final imageUrl = ImageUrl('https://example.com/image.jpg');

        expect(imageUrl.toString(), 'ImageUrl(https://example.com/image.jpg)');
      });

      test('shows null when input is null', () {
        final imageUrl = ImageUrl(null);

        expect(imageUrl.toString(), 'ImageUrl(none)');
      });

      test('shows "invalid" when invalid', () {
        final imageUrl = ImageUrl('invalid-url');

        expect(imageUrl.toString(), 'ImageUrl(none)');
      });
    });

    group('edge cases', () {
      test('handles URLs with query parameters', () {
        final imageUrl = ImageUrl(
          'https://example.com/image.jpg?size=large&format=webp',
        );

        expect(imageUrl.isValid, true);
      });

      test('handles data URIs', () {
        final imageUrl = ImageUrl('data:image/png;base64,abc123');

        expect(imageUrl.isValid, true);
      });

      test('handles URLs with authentication', () {
        final imageUrl = ImageUrl('https://user:pass@example.com/image.jpg');

        expect(imageUrl.isValid, true);
      });

      test('handles URLs with ports', () {
        final imageUrl = ImageUrl('https://example.com:8080/image.jpg');

        expect(imageUrl.isValid, true);
      });

      test('handles very long URLs', () {
        final longPath = 'path/' * 100;
        final imageUrl = ImageUrl('https://example.com/$longPath/image.jpg');

        expect(imageUrl.isValid, true);
      });

      test('handles URLs with encoded characters', () {
        final imageUrl = ImageUrl('https://example.com/image%20name.jpg');

        expect(imageUrl.isValid, true);
      });

      test('handles URLs with IPv4 addresses', () {
        final imageUrl = ImageUrl('https://192.168.1.1/image.jpg');

        expect(imageUrl.isValid, true);
      });

      test('handles URLs with IPv6 addresses', () {
        final imageUrl = ImageUrl('https://[2001:db8::1]/image.jpg');

        expect(imageUrl.isValid, true);
      });

      test('handles file:// URLs', () {
        final imageUrl = ImageUrl('file:///path/to/image.jpg');

        expect(imageUrl.isValid, true);
      });

      test('handles ftp:// URLs', () {
        final imageUrl = ImageUrl('ftp://example.com/image.jpg');

        expect(imageUrl.isValid, true);
      });

      test('handles URLs with custom ports', () {
        final imageUrl = ImageUrl('https://example.com:8443/image.jpg');

        expect(imageUrl.isValid, true);
      });

      test('handles URLs with path traversal attempts', () {
        final imageUrl = ImageUrl('https://example.com/../image.jpg');

        expect(imageUrl.isValid, true); // URI parsing handles this
      });

      test('handles empty string after trimming', () {
        final imageUrl = ImageUrl('   ');

        expect(imageUrl.isValid, true);
        expect(imageUrl.getOrCrash(), null);
      });

      test('handles URLs with unicode characters', () {
        final imageUrl = ImageUrl('https://example.com/画像.jpg');

        expect(imageUrl.isValid, true);
      });

      test('handles URLs with mixed case schemes', () {
        final imageUrl = ImageUrl('HTTPS://example.com/image.jpg');

        expect(imageUrl.isValid, true);
      });

      test('handles URLs with no path', () {
        final imageUrl = ImageUrl('https://example.com');

        expect(imageUrl.isValid, true);
      });

      test('handles URLs with root path', () {
        final imageUrl = ImageUrl('https://example.com/');

        expect(imageUrl.isValid, true);
      });
    });
  });
}
