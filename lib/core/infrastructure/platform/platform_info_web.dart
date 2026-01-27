import 'package:flutter/foundation.dart';
import 'package:starter_app/core/domain/ports/i_platform_info.dart';
import 'package:web/web.dart' as web;

/// Web platform implementation of [IPlatformInfo].
///
/// Uses browser's navigator.userAgent for platform information.
class PlatformInfoImpl implements IPlatformInfo {
  const PlatformInfoImpl();

  @override
  String get operatingSystemVersion => web.window.navigator.userAgent;

  @override
  String get targetPlatform => defaultTargetPlatform.name;
}
