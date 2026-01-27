import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

part 'name_failure.freezed.dart';

/// Name validation failures.
///
/// Each variant represents a specific name validation requirement
/// that was not met. Use pattern matching to handle each case:
///
/// ```dart
/// // In UI mapper
/// final message = failure.when(
///   empty: () => context.l10n.nameRequired,
/// );
/// ```
@freezed
sealed class NameFailure extends ValueFailure<String> with _$NameFailure {
  const NameFailure._();

  /// Name is empty.
  const factory NameFailure.empty() = NameEmpty;
}
