import 'package:starter_app/core/domain/base/unique_id.dart';

/// Type-safe wrapper for [UniqueId] specifically for Profiles.
///
/// This is a compile-time extension type (zero runtime cost).
/// It prevents accidental usage of other IDs
/// (like OrderId or UserId) where a ProfileId is expected.
extension type const ProfileId(UniqueId value) implements UniqueId {
  /// Generates a new [ProfileId].
  factory ProfileId.generate() => ProfileId(UniqueId.generate());

  /// Creates a [ProfileId] from a trusted string.
  factory ProfileId.fromString(String value) =>
      ProfileId(UniqueId.fromString(value));

  // No need for operator== or hashCode as extension types
  // delegate to the underlying type at runtime, and UniqueId handles it.
}
