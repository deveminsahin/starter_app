import 'package:starter_app/core/domain/base/unique_id.dart';

/// Type-safe wrapper for [UniqueId] specifically for {{feature_name.pascalCase()}}.
///
/// This is a compile-time extension type (zero runtime cost).
/// It prevents accidental usage of other IDs where a {{feature_name.pascalCase()}}Id is expected.
extension type const {{feature_name.pascalCase()}}Id(UniqueId value) implements UniqueId {
  /// Generates a new [{{feature_name.pascalCase()}}Id].
  factory {{feature_name.pascalCase()}}Id.generate() => {{feature_name.pascalCase()}}Id(UniqueId.generate());

  /// Creates a [{{feature_name.pascalCase()}}Id] from a trusted string.
  factory {{feature_name.pascalCase()}}Id.fromString(String value) =>
      {{feature_name.pascalCase()}}Id(UniqueId.fromString(value));

  // No need for operator== or hashCode as extension types
  // delegate to the underlying type at runtime, and UniqueId handles it.
}
