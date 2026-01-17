import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';
import 'package:uuid/uuid.dart';

/// A value object representing a unique identifier in the domain.
///
/// This wraps a UUID string and ensures that IDs are always valid.
/// Using a value object instead of a raw String prevents primitive obsession
/// and makes the domain model more expressive.
///
/// Example:
/// ```dart
/// // Create from existing ID (e.g., from backend)
/// final id = UniqueId.fromString('123e4567-e89b-12d3-a456-426614174000');
///
/// // Generate a new ID
/// final newId = UniqueId.generate();
///
/// // Use in entity
/// @freezed
/// class Product with _$Product implements Entity {
///   const Product._();
///
///   const factory Product({
///     required UniqueId id,
///     required String name,
///   }) = _Product;
/// }
/// ```
@immutable
final class UniqueId {
  /// Generates a new unique ID using UUID v4.
  factory UniqueId.generate() {
    return UniqueId._(const Uuid().v4());
  }

  /// Creates a [UniqueId] from a trusted source (e.g., backend response).
  ///
  /// Use this when you're certain the ID is valid. For user input or
  /// untrusted sources, use [fromUntrusted] instead.
  factory UniqueId.fromString(String value) {
    return UniqueId._(value);
  }

  /// Creates a [UniqueId] from a valid ID string.
  ///
  /// This is a private constructor.
  /// Use [UniqueId.fromString] for trusted sources
  /// or [UniqueId.fromUntrusted] for user input validation.
  const UniqueId._(this.value);

  /// The underlying ID value.
  final String value;

  /// Creates a [UniqueId] from a string, validating that it's not empty.
  ///
  /// Returns [Left] with a list of [ValueFailure] if validation fails,
  /// or [Right] with a valid [UniqueId] if successful.
  static Either<List<ValueFailure<String>>, UniqueId> fromUntrusted(
    String? input,
  ) {
    if (input == null || input.trim().isEmpty) {
      return left([const ValueFailure.empty()]);
    }
    return right(UniqueId._(input.trim()));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UniqueId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
