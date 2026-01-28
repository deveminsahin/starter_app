import 'package:starter_app/core/domain/ports/i_error_reporter.dart';
import 'package:starter_app/features/auth/domain/entities/user.dart';

/// No-op implementation of [IErrorReporter] for development environment.
///
/// Does nothing - errors in development are logged to console via IAppLogger.
/// This allows code to depend on [IErrorReporter] without null checks,
/// while not sending any data externally during development.
final class NoOpErrorReporter implements IErrorReporter {
  /// Creates a NoOpErrorReporter.
  const NoOpErrorReporter();

  @override
  Future<void> captureException(
    Object exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? tag,
  }) async {}

  @override
  Future<void> captureMessage(
    String message, {
    SeverityLevel level = SeverityLevel.info,
    Map<String, dynamic>? context,
    String? tag,
  }) async {}

  @override
  void addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
    SeverityLevel? level,
  }) {}

  @override
  void setUser(User user) {}

  @override
  void clearUser() {}
}
