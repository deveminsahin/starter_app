import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/feature_flags/feature_flag.dart';
import 'package:starter_app/core/feature_flags/feature_flag_service.dart';
import 'package:starter_app/core/logging/i_app_logger.dart';

class MockAppLogger extends Mock implements IAppLogger {}

void main() {
  late FeatureFlagService service;
  late MockAppLogger mockLogger;

  setUp(() {
    mockLogger = MockAppLogger();
    service = FeatureFlagService(mockLogger);
  });

  group('FeatureFlagService', () {
    group('isEnabled', () {
      test('returns default value when no override or remote value', () {
        expect(
          service.isEnabled(FeatureFlag.darkModeToggle),
          equals(FeatureFlag.darkModeToggle.defaultValue),
        );
        expect(
          service.isEnabled(FeatureFlag.experimentalFeatures),
          equals(FeatureFlag.experimentalFeatures.defaultValue),
        );
      });

      test('returns override value when set', () {
        service.setOverride(FeatureFlag.experimentalFeatures, value: true);

        expect(service.isEnabled(FeatureFlag.experimentalFeatures), isTrue);
      });

      test('override takes precedence over remote value', () {
        service
          ..setRemoteValues({FeatureFlag.newDashboard: true})
          ..setOverride(FeatureFlag.newDashboard, value: false);

        expect(service.isEnabled(FeatureFlag.newDashboard), isFalse);
      });

      test('remote value takes precedence over default', () {
        service.setRemoteValues({FeatureFlag.newDashboard: true});

        expect(service.isEnabled(FeatureFlag.newDashboard), isTrue);
      });
    });

    group('enabledFlags', () {
      test('returns set of all enabled flags', () {
        final enabled = service.enabledFlags;

        // Should contain flags that are enabled by default
        expect(enabled, contains(FeatureFlag.darkModeToggle));
        expect(enabled, contains(FeatureFlag.analytics));
        expect(enabled, contains(FeatureFlag.crashReporting));
        expect(enabled, contains(FeatureFlag.profilePictureUpload));

        // Should not contain flags disabled by default
        expect(enabled, isNot(contains(FeatureFlag.experimentalFeatures)));
        expect(enabled, isNot(contains(FeatureFlag.newDashboard)));
      });

      test('reflects overrides', () {
        service
          ..setOverride(FeatureFlag.experimentalFeatures, value: true)
          ..setOverride(FeatureFlag.darkModeToggle, value: false);

        final enabled = service.enabledFlags;

        expect(enabled, contains(FeatureFlag.experimentalFeatures));
        expect(enabled, isNot(contains(FeatureFlag.darkModeToggle)));
      });
    });

    group('allFlags', () {
      test('returns all flags with their current state', () {
        final all = service.allFlags;

        expect(all.length, equals(FeatureFlag.values.length));
        for (final flag in FeatureFlag.values) {
          expect(all.containsKey(flag), isTrue);
          expect(all[flag], isA<bool>());
        }
      });
    });

    group('setOverride', () {
      test('sets override value', () {
        service.setOverride(FeatureFlag.biometricAuth, value: true);

        expect(service.isEnabled(FeatureFlag.biometricAuth), isTrue);
        expect(service.hasOverride(FeatureFlag.biometricAuth), isTrue);
      });

      test('can change override value', () {
        service
          ..setOverride(FeatureFlag.biometricAuth, value: true)
          ..setOverride(FeatureFlag.biometricAuth, value: false);

        expect(service.isEnabled(FeatureFlag.biometricAuth), isFalse);
      });
    });

    group('removeOverride', () {
      test('removes override and reverts to default', () {
        final defaultValue = FeatureFlag.newDashboard.defaultValue;
        service.setOverride(FeatureFlag.newDashboard, value: !defaultValue);

        expect(
          service.isEnabled(FeatureFlag.newDashboard),
          isNot(defaultValue),
        );

        service.removeOverride(FeatureFlag.newDashboard);

        expect(
          service.isEnabled(FeatureFlag.newDashboard),
          equals(defaultValue),
        );
        expect(service.hasOverride(FeatureFlag.newDashboard), isFalse);
      });
    });

    group('clearOverrides', () {
      test('clears all overrides', () {
        service
          ..setOverride(FeatureFlag.newDashboard, value: true)
          ..setOverride(FeatureFlag.biometricAuth, value: true)
          ..setOverride(FeatureFlag.experimentalFeatures, value: true)
          ..clearOverrides();

        expect(service.hasOverride(FeatureFlag.newDashboard), isFalse);
        expect(service.hasOverride(FeatureFlag.biometricAuth), isFalse);
        expect(service.hasOverride(FeatureFlag.experimentalFeatures), isFalse);
      });
    });

    group('hasOverride', () {
      test('returns false when no override', () {
        expect(service.hasOverride(FeatureFlag.newDashboard), isFalse);
      });

      test('returns true when override set', () {
        service.setOverride(FeatureFlag.newDashboard, value: true);

        expect(service.hasOverride(FeatureFlag.newDashboard), isTrue);
      });
    });

    group('refresh', () {
      test('returns true (placeholder implementation)', () async {
        final result = await service.refresh();

        expect(result, isTrue);
      });
    });

    group('setRemoteValues', () {
      test('sets remote values', () {
        service.setRemoteValues({
          FeatureFlag.newDashboard: true,
          FeatureFlag.offlineMode: true,
        });

        expect(service.isEnabled(FeatureFlag.newDashboard), isTrue);
        expect(service.isEnabled(FeatureFlag.offlineMode), isTrue);
      });

      test('clears previous remote values before setting new ones', () {
        service
          ..setRemoteValues({FeatureFlag.newDashboard: true})
          ..setRemoteValues({FeatureFlag.offlineMode: true});

        // newDashboard should now use default since it's not in new values
        expect(
          service.isEnabled(FeatureFlag.newDashboard),
          equals(FeatureFlag.newDashboard.defaultValue),
        );
        expect(service.isEnabled(FeatureFlag.offlineMode), isTrue);
      });
    });
  });
}
