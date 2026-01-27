import 'package:flutter/material.dart';
import 'package:starter_app/core/presentation/responsive/adaptive_layout_builder.dart';
import 'package:starter_app/core/presentation/responsive/responsive_padding.dart';
import 'package:starter_app/core/presentation/responsive/screen_size.dart';

/// A responsive grid container that adapts column count based on screen size.
///
/// Automatically adjusts the number of columns based on available space,
/// following Material Design guidelines.
///
/// Example:
/// ```dart
/// ResponsiveGrid.builder(
///   itemCount: 10,
///   itemBuilder: (context, index) => Card(child: Text('Item $index')),
/// )
/// ```
final class ResponsiveGrid extends StatelessWidget {
  /// Creates a [ResponsiveGrid] that builds its children lazily.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  const ResponsiveGrid.builder({
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.childAspectRatio = 1.0,
    super.key,
  }) : _itemBuilder = itemBuilder,
       _itemCount = itemCount;

  final IndexedWidgetBuilder? _itemBuilder;
  final int? _itemCount;

  /// The spacing between columns.
  final double crossAxisSpacing;

  /// The spacing between rows.
  final double mainAxisSpacing;

  /// The aspect ratio of each grid item.
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutBuilder(
      builder: (context, screenSize) {
        final columns = switch (screenSize) {
          ScreenSize.compact => 2,
          ScreenSize.medium => 3,
          ScreenSize.expanded => 4,
          ScreenSize.large => 5,
          ScreenSize.extraLarge => 6,
        };

        return ResponsivePadding(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: _itemCount,
            itemBuilder: _itemBuilder!,
          ),
        );
      },
    );
  }
}
