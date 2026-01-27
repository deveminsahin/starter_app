import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

part 'unique_id_failure.freezed.dart';

/// Unique ID validation failures.
///
/// Each variant represents a specific unique ID validation requirement
/// that was not met. Use pattern matching to handle each case:
///
/// ```dart
/// // In UI mapper
/// final message = failure.when(
///   empty: () => context.l10n.uniqueIdRequired,
///   invalidFormat: () => context.l10n.uniqueIdInvalid,
/// );
/// ```
@freezed
sealed class UniqueIdFailure extends ValueFailure<String>
    with _$UniqueIdFailure {
  const UniqueIdFailure._();

  /// Unique ID is empty.
  const factory UniqueIdFailure.empty() = UniqueIdEmpty;

  /// Unique ID format is invalid.
  const factory UniqueIdFailure.invalidFormat() = UniqueIdInvalidFormat;
}
