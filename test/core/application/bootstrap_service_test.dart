import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/application/app_error_handling_service.dart';
import 'package:starter_app/core/application/app_monitoring_service.dart';
import 'package:starter_app/core/application/app_navigation_logging_service.dart';
import 'package:starter_app/core/application/application_environment.dart';
import 'package:starter_app/core/application/bootstrap_service.dart';
import 'package:starter_app/core/domain/ports/i_certificate_service.dart';

class MockHydratedStorage extends Mock implements HydratedStorage {}

class MockBlocObserver extends Mock implements BlocObserver {}

class MockAppMonitoringService extends Mock implements AppMonitoringService {}

class MockAppErrorHandlingService extends Mock
    implements AppErrorHandlingService {}

class MockAppNavigationLoggingService extends Mock
    implements AppNavigationLoggingService {}

class MockCertificateService extends Mock implements ICertificateService {}

void main() {
  late BootstrapService bootstrapService;
  late MockHydratedStorage mockStorage;
  late MockBlocObserver mockObserver;
  late MockAppMonitoringService mockMonitoringService;
  late MockAppErrorHandlingService mockErrorHandlingService;
  late MockAppNavigationLoggingService mockNavigationLoggingService;
  late MockCertificateService mockCertificateService;

  setUpAll(() {
    registerFallbackValue(AppEnvironment.development);
  });

  setUp(() {
    mockStorage = MockHydratedStorage();
    mockObserver = MockBlocObserver();
    mockMonitoringService = MockAppMonitoringService();
    mockErrorHandlingService = MockAppErrorHandlingService();
    mockNavigationLoggingService = MockAppNavigationLoggingService();
    mockCertificateService = MockCertificateService();

    when(
      () => mockMonitoringService.initialize(
        any(),
        sentryDsnOverride: any(named: 'sentryDsnOverride'),
      ),
    ).thenAnswer((_) async {});

    when(() => mockCertificateService.initialize()).thenAnswer((_) async {});

    bootstrapService = BootstrapService(
      mockStorage,
      mockObserver,
      mockMonitoringService,
      mockErrorHandlingService,
      mockNavigationLoggingService,
      mockCertificateService,
    );
  });

  group('BootstrapService', () {
    group('initialize', () {
      test('sets HydratedBloc.storage and Bloc.observer', () async {
        await bootstrapService.initialize(AppEnvironment.development);

        expect(HydratedBloc.storage, mockStorage);
        expect(Bloc.observer, mockObserver);
      });

      test('initializes monitoring service', () async {
        await bootstrapService.initialize(
          AppEnvironment.production,
          sentryDsnOverride: 'test-dsn',
        );

        verify(
          () => mockMonitoringService.initialize(
            AppEnvironment.production,
            sentryDsnOverride: 'test-dsn',
          ),
        ).called(1);
      });

      test('initializes certificate service when pinning enabled', () async {
        // Production has pinning enabled
        await bootstrapService.initialize(AppEnvironment.production);

        verify(() => mockCertificateService.initialize()).called(1);
      });

      test('skips certificate service when pinning disabled', () async {
        // Development has pinning disabled
        await bootstrapService.initialize(AppEnvironment.development);

        verifyNever(() => mockCertificateService.initialize());
      });
    });

    group('setupErrorHandling', () {
      test('delegates to error handling service', () {
        bootstrapService.setupErrorHandling();

        verify(() => mockErrorHandlingService.setup()).called(1);
      });
    });

    group('setupNavigationLogging', () {
      test('delegates to navigation logging service', () {
        bootstrapService.setupNavigationLogging();

        verify(() => mockNavigationLoggingService.setup()).called(1);
      });
    });

    group('logZoneError', () {
      test('delegates to error handling service', () {
        final error = Exception('Zone error');
        const stackTrace = StackTrace.empty;

        bootstrapService.logZoneError(error, stackTrace);

        verify(
          () => mockErrorHandlingService.logZoneError(error, stackTrace),
        ).called(1);
      });
    });
  });
}
