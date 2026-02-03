import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/application/app_error_handling_service.dart';
import 'package:starter_app/core/application/app_monitoring_service.dart';
import 'package:starter_app/core/application/app_navigation_logging_service.dart';
import 'package:starter_app/core/application/application_environment.dart';
import 'package:starter_app/core/domain/ports/i_certificate_service.dart';

/// Service responsible for bootstrapping the application.
///
/// Orchestrates:
/// - Storage initialization
/// - State management setup (BlocObserver)
/// - Monitoring initialization (via [AppMonitoringService])
/// - Error handling setup (via [AppErrorHandlingService])
/// - Navigation logging setup (via [AppNavigationLoggingService])
/// - Security setup (via [ICertificateService])
@singleton
class BootstrapService {
  BootstrapService(
    this._storage,
    this._blocObserver,
    this._monitoringService,
    this._errorHandlingService,
    this._navigationLoggingService,
    this._certificateService,
  );

  final HydratedStorage _storage;
  final BlocObserver _blocObserver;
  final AppMonitoringService _monitoringService;
  final AppErrorHandlingService _errorHandlingService;
  final AppNavigationLoggingService _navigationLoggingService;
  final ICertificateService _certificateService;

  Future<void> initialize(
    AppEnvironment environment, {
    String? sentryDsnOverride,
  }) async {
    // Set HydratedBloc storage
    HydratedBloc.storage = _storage;

    // Set BlocObserver
    Bloc.observer = _blocObserver;

    // Initialize monitoring
    await _monitoringService.initialize(
      environment,
      sentryDsnOverride: sentryDsnOverride,
    );

    // Initialize certificates (must happen before API calls)
    if (environment.sslPinningEnabled) {
      await _certificateService.initialize();
    }
  }

  void setupErrorHandling() {
    _errorHandlingService.setup();
  }

  void setupNavigationLogging() {
    _navigationLoggingService.setup();
  }

  void logZoneError(Object error, StackTrace stack) {
    _errorHandlingService.logZoneError(error, stack);
  }
}
