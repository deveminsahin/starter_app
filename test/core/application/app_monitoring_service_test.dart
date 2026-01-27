import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/application/app_monitoring_service.dart';
import 'package:starter_app/core/application/application_environment.dart';
import 'package:starter_app/core/domain/ports/i_error_reporter.dart';
import 'package:starter_app/core/domain/ports/i_monitoring_initializer.dart';
import 'package:starter_app/core/domain/ports/i_platform_info.dart';

import '../../helpers/mock_helpers.dart';

class MockPlatformInfo extends Mock implements IPlatformInfo {}

class MockErrorReporter extends Mock implements IErrorReporter {}

class MockMonitoringInitializer extends Mock
    implements IMonitoringInitializer {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAppLogger mockLogger;
  late MockErrorReporter mockErrorReporter;
  late MockPlatformInfo mockPlatformInfo;
  late MockMonitoringInitializer mockMonitoringInitializer;
  late AppMonitoringService service;

  setUpAll(() {
    registerFallbackValue(AppEnvironment.development);
  });

  setUp(() {
    mockLogger = MockAppLogger();
    mockErrorReporter = MockErrorReporter();
    mockPlatformInfo = MockPlatformInfo();
    mockMonitoringInitializer = MockMonitoringInitializer();

    when(() => mockPlatformInfo.operatingSystemVersion).thenReturn('1.0.0');
    when(() => mockPlatformInfo.targetPlatform).thenReturn('android');

    // Default: Monitoring init returns false (not initialized)
    when(
      () => mockMonitoringInitializer.initialize(
        any(),
        dsnOverride: any(named: 'dsnOverride'),
      ),
    ).thenAnswer((_) async => false);

    service = AppMonitoringService(
      mockLogger,
      mockErrorReporter,
      mockPlatformInfo,
      mockMonitoringInitializer,
    );
  });

  group('AppMonitoringService', () {
    test('initialize logs startup configuration for development', () async {
      await service.initialize(AppEnvironment.development);

      verify(
        () => mockLogger.info(
          'Application starting',
          data: {
            'environment': 'development',
            'explicitlyConfigured': false,
            'apiBaseUrl': AppEnvironment.development.apiBaseUrl,
            'webSocketUrl': AppEnvironment.development.webSocketUrl,
            'sentryEnabled': false,
            'operatingSystem': 'android',
            'operatingSystemVersion': '1.0.0',
          },
          tag: 'Bootstrap',
        ),
      ).called(1);

      // Should not add breadcrumb for development (monitoring not initialized)
      verifyNever(
        () => mockErrorReporter.addBreadcrumb(
          any(),
          category: any(named: 'category'),
          data: any(named: 'data'),
          level: any(named: 'level'),
        ),
      );
    });

    test('logs warning if configuration warning is present', () async {
      await service.initialize(
        AppEnvironment.development,
        configurationWarningOverride: 'Test Warning',
      );

      verify(
        () => mockLogger.warning(
          'Test Warning',
          tag: 'Configuration',
        ),
      ).called(1);
    });

    test('does not log warning if no configuration warning', () async {
      await service.initialize(AppEnvironment.development);

      verifyNever(
        () => mockLogger.warning(
          any(),
          tag: 'Configuration',
        ),
      );
    });

    test('initializes monitoring via IMonitoringInitializer', () async {
      await service.initialize(
        AppEnvironment.staging,
        sentryDsnOverride: 'https://example@sentry.io/123',
      );

      verify(
        () => mockMonitoringInitializer.initialize(
          AppEnvironment.staging,
          dsnOverride: 'https://example@sentry.io/123',
        ),
      ).called(1);
    });

    test('adds breadcrumb when monitoring is initialized', () async {
      // Monitoring init returns true (initialized)
      when(
        () => mockMonitoringInitializer.initialize(
          any(),
          dsnOverride: any(named: 'dsnOverride'),
        ),
      ).thenAnswer((_) async => true);

      await service.initialize(
        AppEnvironment.staging,
        sentryDsnOverride: 'https://example@sentry.io/123',
      );

      // Verify logging happened for staging
      verify(
        () => mockLogger.info(
          'Application starting',
          data: {
            'environment': 'staging',
            'explicitlyConfigured': false,
            'apiBaseUrl': AppEnvironment.staging.apiBaseUrl,
            'webSocketUrl': AppEnvironment.staging.webSocketUrl,
            'sentryEnabled': true,
            'operatingSystem': 'android',
            'operatingSystemVersion': '1.0.0',
          },
          tag: 'Bootstrap',
        ),
      ).called(1);

      // Verify startup breadcrumb was added
      verify(
        () => mockErrorReporter.addBreadcrumb(
          'Application initialized',
          category: 'lifecycle',
          data: {
            'environment': 'staging',
            'platform': 'android',
          },
          level: SeverityLevel.info,
        ),
      ).called(1);
    });

    test(
      'does not add breadcrumb when monitoring is not initialized',
      () async {
        // Monitoring init returns false (not initialized - e.g., development)
        when(
          () => mockMonitoringInitializer.initialize(
            any(),
            dsnOverride: any(named: 'dsnOverride'),
          ),
        ).thenAnswer((_) async => false);

        await service.initialize(AppEnvironment.development);

        verifyNever(
          () => mockErrorReporter.addBreadcrumb(
            any(),
            category: any(named: 'category'),
            data: any(named: 'data'),
            level: any(named: 'level'),
          ),
        );
      },
    );
  });
}
