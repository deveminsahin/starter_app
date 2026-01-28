import 'package:flutter/material.dart';
import 'package:starter_app/core/constants/constants.dart' show PaddingWidgets;
import 'package:starter_app/core/presentation/responsive/adaptive_layout_builder.dart';
import 'package:starter_app/core/presentation/responsive/screen_size.dart';

/// A widget that applies responsive padding to its child.
///
/// The padding amount adapts based on screen size, with additional
/// options for customizing padding per breakpoint.
///
/// Example:
/// ```dart
/// ResponsivePadding(
///   child: Text('Content'),
/// )
/// ```
///
/// Example with custom padding:
/// ```dart
/// ResponsivePadding(
///   mobilePadding: const EdgeInsets.all(12),
///   tabletPadding: const EdgeInsets.all(20),
///   desktopPadding: const EdgeInsets.all(28),
///   child: Text('Content'),
/// )
/// ```
final class ResponsivePadding extends StatelessWidget {
  /// Creates a [ResponsivePadding] widget.
  const ResponsivePadding({
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    super.key,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Custom padding for mobile (compact) screens.
  ///
  /// Defaults to EdgeInsets.all(16) if not specified.
  final EdgeInsets? mobilePadding;

  /// Custom padding for tablet (medium/expanded) screens.
  ///
  /// Defaults to EdgeInsets.all(24) if not specified.
  final EdgeInsets? tabletPadding;

  /// Custom padding for desktop (large/extra-large) screens.
  ///
  /// Defaults to EdgeInsets.all(32) if not specified.
  final EdgeInsets? desktopPadding;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutBuilder(
      builder: (context, screenSize) {
        final padding = switch (screenSize) {
          ScreenSize.compact => mobilePadding ?? PaddingWidgets.allMedium,
          ScreenSize.medium ||
          ScreenSize.expanded => tabletPadding ?? PaddingWidgets.allLarge,
          ScreenSize.large ||
          ScreenSize.extraLarge => desktopPadding ?? PaddingWidgets.allXLarge,
        };

        return Padding(
          padding: padding,
          child: child,
        );
      },
    );
  }
}
