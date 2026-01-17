/// Interface for platform-specific information.
///
/// This is a **port** in hexagonal architecture - it defines the contract
/// for accessing platform-specific details in a cross-platform way.
///
/// Implementations (adapters) handle the actual platform detection:
/// - Native (iOS, Android, desktop): Uses `dart:io` Platform
/// - Web: Uses browser's navigator.userAgent
///
/// Usage:
/// ```dart
/// @injectable
/// class MyService {
///   MyService(this._platformInfo);
///   final IPlatformInfo _platformInfo;
///
///   void logPlatformDetails() {
///     print('OS Version: ${_platformInfo.operatingSystemVersion}');
///   }
/// }
/// ```
abstract interface class IPlatformInfo {
  /// Returns the operating system version string.
  ///
  /// - Native: Returns OS version (e.g., "14.5" on iOS, "13" on Android)
  /// - Web: Returns browser user agent string
  String get operatingSystemVersion;
}
