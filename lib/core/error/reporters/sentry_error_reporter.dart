import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:starter_app/core/application/application_environment.dart';
import 'package:starter_app/core/domain/ports/i_data_filter.dart';
import 'package:starter_app/core/domain/ports/i_error_reporter.dart';
import 'package:starter_app/features/auth/domain/entities/user.dart';

/// Sentry implementation of [IErrorReporter] for error tracking.
///
/// Only active in staging/production environments.
/// Sends errors, messages, and breadcrumbs to Sentry dashboard.
///
/// **Features:**
/// - Automatic sensitive data filtering via injected [IDataFilter]
/// - User context for error grouping
/// - Breadcrumb trail for debugging
///
/// **Environment behavior:**
/// - Development: Disabled (no data sent to Sentry)
/// - Staging: Enabled (100% sampling for testing)
/// - Production: Enabled (10% sampling for performance)
final class SentryErrorReporter implements IErrorReporter {
  /// Creates a SentryErrorReporter.
  ///
  /// [IDataFilter] The filter to use for sanitizing sensitive data.
  /// Automatically determines if reporting should be enabled based on
  /// [AppEnvironment.current].
  SentryErrorReporter(this._dataFilter)
    : _isEnabled = AppEnvironment.current.sentryEnabled;

  /// Test-only constructor that allows setting enabled state.
  ///
  /// This constructor is intended for testing purposes only to achieve
  /// 100% code coverage by allowing tests to simulate enabled state.
  SentryErrorReporter.test({
    required IDataFilter dataFilter,
    required bool enabled,
  }) : _dataFilter = dataFilter,
       _isEnabled = enabled;

  final IDataFilter _dataFilter;
  final bool _isEnabled;

  @override
  Future<void> captureException(
    Object exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? tag,
  }) async {
    if (!_isEnabled) return;

    unawaited(
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          if (context != null) 'context': _dataFilter.filter(context),
          'tag': ?tag,
        }),
      ),
    );
  }

  @override
  Future<void> captureMessage(
    String message, {
    SeverityLevel level = SeverityLevel.info,
    Map<String, dynamic>? context,
    String? tag,
  }) async {
    if (!_isEnabled) return;

    unawaited(
      Sentry.captureMessage(
        message,
        level: _toSentryLevel(level),
        hint: Hint.withMap({
          if (context != null) 'context': _dataFilter.filter(context),
          'tag': ?tag,
        }),
      ),
    );
  }

  @override
  void addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
    SeverityLevel? level,
  }) {
    if (!_isEnabled) return;

    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          level: level != null ? _toSentryLevel(level) : null,
          category: category,
          data: data != null ? _dataFilter.filter(data) : null,
          timestamp: DateTime.now(),
        ),
      ),
    );
  }

  @override
  void setUser(User user) {
    if (!_isEnabled) return;

    final sentryUser = _createSentryUser(user);

    unawaited(
      Future.value(
        Sentry.configureScope((scope) => scope.setUser(sentryUser)),
      ),
    );
  }

  @override
  void clearUser() {
    if (!_isEnabled) return;

    unawaited(
      Future.value(
        Sentry.configureScope((scope) => scope.setUser(null)),
      ),
    );
  }

  /// Creates a [SentryUser] from domain [User].
  ///
  /// Uses safe value extraction to avoid crashes during error reporting.
  /// Falls back to 'unknown' if email is invalid.
  SentryUser _createSentryUser(User user) {
    return SentryUser(
      id: user.id.value.value,
      email: user.email.value.fold(
        (_) => 'unknown', // Graceful fallback for invalid email
        (email) => email,
      ),
    );
  }

  /// Convert [SeverityLevel] to Sentry's [SentryLevel].
  SentryLevel _toSentryLevel(SeverityLevel level) {
    return switch (level) {
      SeverityLevel.info => SentryLevel.info,
      SeverityLevel.warning => SentryLevel.warning,
      SeverityLevel.error => SentryLevel.error,
      SeverityLevel.fatal => SentryLevel.fatal,
    };
  }
}
