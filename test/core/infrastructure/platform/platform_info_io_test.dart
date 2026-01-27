import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/ports/i_platform_info.dart';
import 'package:starter_app/core/infrastructure/platform/platform_info_io.dart';

void main() {
  group('PlatformInfoImpl', () {
    late PlatformInfoImpl platformInfo;

    setUp(() {
      platformInfo = const PlatformInfoImpl();
    });

    test('implements IPlatformInfo', () {
      expect(platformInfo, isA<IPlatformInfo>());
    });

    test('can be instantiated as const', () {
      const instance1 = PlatformInfoImpl();
      const instance2 = PlatformInfoImpl();

      // Both should be identical since they're const
      expect(identical(instance1, instance2), isTrue);
    });

    group('operatingSystemVersion', () {
      test('returns Platform.operatingSystemVersion', () {
        final result = platformInfo.operatingSystemVersion;

        expect(result, equals(Platform.operatingSystemVersion));
      });

      test('returns non-empty string', () {
        final result = platformInfo.operatingSystemVersion;

        expect(result, isNotEmpty);
      });

      test('returns consistent value on multiple calls', () {
        final result1 = platformInfo.operatingSystemVersion;
        final result2 = platformInfo.operatingSystemVersion;

        expect(result1, equals(result2));
      });
    });

    group('targetPlatform', () {
      test('returns defaultTargetPlatform.name', () {
        final result = platformInfo.targetPlatform;

        expect(result, equals(defaultTargetPlatform.name));
      });

      test('returns non-empty string', () {
        final result = platformInfo.targetPlatform;

        expect(result, isNotEmpty);
      });

      test('returns consistent value on multiple calls', () {
        final result1 = platformInfo.targetPlatform;
        final result2 = platformInfo.targetPlatform;

        expect(result1, equals(result2));
      });
    });
  });
}
