import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

/// Image URL value object with validation.
///
/// Validates URLs for image resources. Accepts null/empty as valid (optional).
/// This is a core value object used across features (profiles, avatars, etc.).
///
/// Example:
/// ```dart
/// // User input validation
/// final imageUrl = ImageUrl('https://example.com/avatar.png');
/// if (imageUrl.isValid) {
///   // Use imageUrl.getOrCrash()
/// }
///
/// // Empty/null is valid (optional image)
/// final noImage = ImageUrl(null); // isValid == true
///
/// // From trusted backend
/// final backendUrl = ImageUrl.fromTrustedSource('https://cdn.app.com/img.jpg');
/// ```
@immutable
final class ImageUrl extends ValueObject<String?> {
  factory ImageUrl(String? input) {
    return ImageUrl._(_validateImageUrl(input));
  }
  const ImageUrl._(this.value);

  factory ImageUrl.fromTrustedSource(String? input) {
    return ImageUrl._(right(input));
  }

  @override
  final Either<List<ValueFailure<String?>>, String?> value;

  /// Validates image URL format.
  ///
  /// Accepts null/empty as valid (optional image).
  /// For non-empty values, validates it's a valid absolute URL.
  static Either<List<ValueFailure<String?>>, String?> _validateImageUrl(
    String? input,
  ) {
    if (input == null || input.trim().isEmpty) {
      return right(null);
    }

    final uri = Uri.tryParse(input);
    if (uri == null || !uri.isAbsolute) {
      return left([
        ValueFailure.invalidFormat(
          expectedFormat: 'Valid URL',
          failedValue: input,
        ),
      ]);
    }

    return right(input);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ImageUrl && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ImageUrl(${getOrNull() ?? "none"})';
}
