import 'package:starter_app/core/domain/base/unique_id.dart';

/// Type-safe wrapper for [UniqueId] specifically for {{name.pascalCase()}}.
///
/// This is a compile-time extension type (zero runtime cost).
/// It prevents accidental usage of other IDs where a {{name.pascalCase()}}Id is expected.
extension type const {{name.pascalCase()}}Id(UniqueId value) implements UniqueId {
  /// Generates a new [{{name.pascalCase()}}Id].
  factory {{name.pascalCase()}}Id.generate() => {{name.pascalCase()}}Id(UniqueId.generate());

  /// Creates a [{{name.pascalCase()}}Id] from a trusted string.
  factory {{name.pascalCase()}}Id.fromString(String value) =>
      {{name.pascalCase()}}Id(UniqueId.fromString(value));

  // No need for operator== or hashCode as extension types
  // delegate to the underlying type at runtime, and UniqueId handles it.
}
