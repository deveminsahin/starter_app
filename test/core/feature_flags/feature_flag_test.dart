import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/feature_flags/feature_flag.dart';

void main() {
  group('FeatureFlag', () {
    test('contains expected number of flags', () {
      expect(FeatureFlag.values.length, equals(10));
    });

    test('all flags have a remoteConfigKey', () {
      for (final flag in FeatureFlag.values) {
        expect(flag.remoteConfigKey, startsWith('feature_'));
        expect(flag.remoteConfigKey, equals('feature_${flag.name}'));
      }
    });

    test('all flags have a defaultValue', () {
      for (final flag in FeatureFlag.values) {
        expect(flag.defaultValue, isA<bool>());
      }
    });

    test('all flags have a description', () {
      for (final flag in FeatureFlag.values) {
        expect(flag.description, isNotEmpty);
      }
    });

    group('defaultValues', () {
      test('darkModeToggle is enabled by default', () {
        expect(FeatureFlag.darkModeToggle.defaultValue, isTrue);
      });

      test('analytics is enabled by default', () {
        expect(FeatureFlag.analytics.defaultValue, isTrue);
      });

      test('crashReporting is enabled by default', () {
        expect(FeatureFlag.crashReporting.defaultValue, isTrue);
      });

      test('profilePictureUpload is enabled by default', () {
        expect(FeatureFlag.profilePictureUpload.defaultValue, isTrue);
      });

      test('experimentalFeatures is disabled by default', () {
        expect(FeatureFlag.experimentalFeatures.defaultValue, isFalse);
      });

      test('newDashboard is disabled by default', () {
        expect(FeatureFlag.newDashboard.defaultValue, isFalse);
      });

      test('biometricAuth is disabled by default', () {
        expect(FeatureFlag.biometricAuth.defaultValue, isFalse);
      });
    });

    group('remoteConfigKey', () {
      test('newDashboard has correct key', () {
        expect(
          FeatureFlag.newDashboard.remoteConfigKey,
          equals('feature_newDashboard'),
        );
      });

      test('darkModeToggle has correct key', () {
        expect(
          FeatureFlag.darkModeToggle.remoteConfigKey,
          equals('feature_darkModeToggle'),
        );
      });
    });

    group('description', () {
      test('newDashboard has descriptive text', () {
        expect(
          FeatureFlag.newDashboard.description,
          contains('dashboard'),
        );
      });

      test('biometricAuth mentions fingerprint', () {
        expect(
          FeatureFlag.biometricAuth.description,
          contains('fingerprint'),
        );
      });
    });
  });
}
