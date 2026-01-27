import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';
import 'package:starter_app/core/domain/base/unique_id_failure.dart';

import 'package:starter_app/core/error/failures/value_failure.dart';
import 'package:uuid/uuid.dart';

/// A value object representing a unique identifier in the domain.
///
/// This wraps a UUID string and ensures that IDs are always valid.
/// Using a value object instead of a raw String prevents primitive obsession
/// and makes the domain model more expressive.
///
/// For feature-specific IDs, create subclasses (e.g., `UserId`, `ProfileId`).
///
/// Returns specific [UniqueIdFailure] types for clear error messages:
/// - [UniqueIdEmpty] - ID is empty or null
/// - [UniqueIdInvalidFormat] - ID is not a valid UUID format
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
/// class User extends AggregateRoot {
///   User({required this.id, required this.email});
///
///   @override
///   final UserId id;  // Feature-specific ID type
///   final EmailAddress email;
/// }
///
/// // Validate untrusted input
/// final result = UniqueId.fromUntrusted(userInput);
/// result.fold(
///   (failures) => failures.first.when(
///     empty: () => print('ID is required'),
///     invalidFormat: () => print('ID must be a valid UUID'),
///   ),
///   (id) => print('Valid ID: $id'),
/// );
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

  /// UUID format regex pattern.
  /// Matches: 8-4-4-4-12 hexadecimal characters (any UUID version).
  static final _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// The underlying ID value.
  final String value;

  /// Creates a [UniqueId] from a string, validating that it's not empty
  /// and has a valid UUID format.
  ///
  /// Returns [Left] with a list of [UniqueIdFailure] if validation fails,
  /// or [Right] with a valid [UniqueId] if successful.
  ///
  /// Validation:
  /// - Empty/null input returns [UniqueIdEmpty]
  /// - Invalid UUID format returns [UniqueIdInvalidFormat]
  static Either<List<ValueFailure<String>>, UniqueId> fromUntrusted(
    String? input,
  ) {
    if (input == null || input.trim().isEmpty) {
      return left([const UniqueIdFailure.empty()]);
    }

    final trimmed = input.trim();
    if (!_uuidRegex.hasMatch(trimmed)) {
      return left([const UniqueIdFailure.invalidFormat()]);
    }

    return right(UniqueId._(trimmed));
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
