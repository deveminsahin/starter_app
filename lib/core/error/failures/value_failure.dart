import 'package:starter_app/core/error/failures/failures.dart';

/// Abstract base class for all domain validation failures.
///
/// Value failures represent validation errors for value objects in the domain
/// layer. Unlike [TechnicalFailure] which represents infrastructure/technical
/// errors with retry capability, value failures are business rule violations
/// that typically require user correction.
///
/// **Co-location principle:** Each domain concept defines its own specific
/// failure type co-located with its value object:
/// - `core/domain/value_objects/email_failure.dart` - EmailFailure
/// - `core/domain/value_objects/password_failure.dart` - PasswordFailure
/// - `core/domain/value_objects/name_failure.dart` - NameFailure
/// - `core/domain/base/unique_id_failure.dart` - UniqueIdFailure
/// - `features/auth/domain/value_objects/token_failure.dart` - TokenFailure
///
/// Example:
/// ```dart
/// // In Password value object
/// if (!_uppercaseRegex.hasMatch(input)) {
///   failures.add(const PasswordFailure.missingUppercase());
/// }
///
/// // In UI mapper
/// final message = failure.when(
///   missingUppercase: () => context.l10n.passwordMissingUppercase,
///   // ...
/// );
/// ```
///
/// The type parameter [T] represents the underlying value type being validated
/// (e.g., String for passwords, emails).
abstract class ValueFailure<T> extends Failure {
  /// Creates a [ValueFailure].
  const ValueFailure();
}
