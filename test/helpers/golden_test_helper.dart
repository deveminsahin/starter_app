import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Device configurations for golden tests
class GoldenTestDevices {
  GoldenTestDevices._();

  /// iPhone 14 Pro size (portrait)
  static const Size iphone14Pro = Size(393, 852);

  /// iPad Pro 11" size (portrait)
  static const Size ipadPro11 = Size(834, 1194);

  /// Standard mobile size (portrait)
  static const Size mobile = Size(375, 667);

  /// Standard tablet size (portrait)
  static const Size tablet = Size(768, 1024);

  /// Desktop/web size
  static const Size desktop = Size(1440, 900);
}

/// Helper extension for golden tests
extension GoldenTestHelper on WidgetTester {
  /// Set device size for golden tests
  Future<void> setGoldenTestDeviceSize(Size size) async {
    // Reset the view to the specified size
    view.physicalSize = size;
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
  }

  /// Pump and settle with a custom duration for golden tests
  Future<void> pumpForGolden() async {
    await pump();
    await pump(const Duration(milliseconds: 100));
    await pumpAndSettle();
  }

  /// Helper to capture golden file with standard naming
  Future<void> expectGolden(
    Finder finder,
    String goldenPath, {
    bool skip = false,
  }) async {
    await pumpForGolden();
    await expectLater(
      finder,
      matchesGoldenFile('goldens/$goldenPath'),
      skip: skip,
    );
  }
}

/// Wrapper widget for golden tests that provides consistent theming
class GoldenTestWrapper extends StatelessWidget {
  const GoldenTestWrapper({
    required this.child,
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en'),
    super.key,
  });

  final Widget child;
  final ThemeMode themeMode;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      locale: locale,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: child,
      ),
    );
  }
}
