# Adaptive UI Strategy Rules

## Core Philosophy

### Adaptive First, Not Just Responsive

- **Responsive UI**: Adjusts element placement to fit available space
- **Adaptive UI**: Fundamentally alters layouts and components for usability and ergonomics

**Our Principle**: Build adaptive UIs that change behavior, not just scale elements proportionally. Users on tablets/desktops expect different interaction patterns and more content, not magnified mobile interfaces.

### Foundation

- Use Flutter's built-in layout widgets exclusively
- No proportional scaling packages
- Leverage Material Design 3 canonical layouts
- Implement "Abstract, Measure, Branch" pattern

## The Five-Class Breakpoint System

### Material Design 3 Window Size Classes

| Breakpoint | Width Range (dp) | Typical Devices | Navigation Pattern | Layout Characteristics |
|------------|-----------------|-----------------|-------------------|------------------------|
| **Compact** | 0 - 599 | Phone (Portrait) | NavigationBar (Bottom) | Single-pane layouts, full-screen details |
| **Medium** | 600 - 839 | Tablet (Portrait), Large Phone (Landscape) | NavigationRail | Primarily single-pane, dialogs for details |
| **Expanded** | 840 - 1199 | Tablet (Landscape), Small Desktop | NavigationDrawer (Dismissible) | Two-pane layouts are standard |
| **Large** | 1200 - 1599 | Desktop | NavigationDrawer (Permanent) | Two or three-pane layouts, multi-column |
| **Extra-Large** | 1600+ | Large/Ultra-wide Desktop | NavigationDrawer (Permanent) | Three-pane layouts, expansive views |

### ScreenSize Enum Definition

```dart
// core/presentation/responsive/screen_size.dart
import 'package:flutter/material.dart';

/// Defines the five window size classes based on Material Design 3 guidelines.
enum ScreenSize {
  compact,
  medium,
  expanded,
  large,
  extraLarge;

  /// Determines the ScreenSize from the window width.
  static ScreenSize fromWidth(double width) {
    if (width < 600) return ScreenSize.compact;
    if (width < 840) return ScreenSize.medium;
    if (width < 1200) return ScreenSize.expanded;
    if (width < 1600) return ScreenSize.large;
    return ScreenSize.extraLarge;
  }
  
  /// Check if screen is mobile size
  bool get isMobile => this == ScreenSize.compact;
  
  /// Check if screen supports two-pane layouts
  bool get supportsTwoPane => index >= ScreenSize.expanded.index;
  
  /// Check if screen supports three-pane layouts
  bool get supportsThreePane => index >= ScreenSize.large.index;
}
```

### Rules

- ✅ **DO**: Use the five-class breakpoint system for all adaptive decisions
- ✅ **DO**: Define breakpoints based on width in density-independent pixels (dp)
- ✅ **DO**: Consider device conventions at each breakpoint
- ❌ **DON'T**: Create custom arbitrary breakpoints
- ❌ **DON'T**: Use device type detection instead of screen width
- ❌ **DON'T**: Assume viewport size equals device size

## Canonical Layout Patterns

### List-Detail Layout

Ideal for explorable lists and their corresponding details (e.g., inbox, product catalog).

| Screen Size | Implementation |
|-------------|----------------|
| **Compact** | Single pane. Navigate from list screen to detail screen |
| **Medium** | Single pane recommended. Two co-planar panes viable |
| **Expanded** | Two co-planar panes standard |
| **Large/Extra-Large** | Two co-planar panes. Detail pane may use multiple columns |

```dart
class ListDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutBuilder(
      builder: (context, screenSize) {
        if (screenSize == ScreenSize.compact) {
          // Single pane - use navigation
          return const ProductListView();
        }
        
        // Two-pane layout
        return Row(
          children: [
            SizedBox(
              width: 300,
              child: const ProductListView(),
            ),
            const VerticalDivider(width: 1),
            const Expanded(child: ProductDetailView()),
          ],
        );
      },
    );
  }
}
```

### Supporting Pane Layout

Organizes content into primary display area and secondary contextual pane (e.g., document with comments).

| Screen Size | Implementation |
|-------------|----------------|
| **Compact** | Primary content visible. Supporting content in BottomSheet |
| **Medium** | Supporting content in dismissible side sheet or stacked vertically |
| **Expanded** | Primary and supporting panes side-by-side |
| **Large/Extra-Large** | Panes side-by-side, can be resizable with drag handle |

```dart
class SupportingPaneLayout extends StatelessWidget {
  final Widget primary;
  final Widget supporting;
  
  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutBuilder(
      builder: (context, screenSize) {
        if (screenSize == ScreenSize.compact) {
          return Stack(
            children: [
              primary,
              // Show bottom sheet on demand
            ],
          );
        }
        
        if (screenSize == ScreenSize.medium) {
          return Stack(
            children: [
              primary,
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 300,
                child: supporting,
              ),
            ],
          );
        }
        
        // Large screens: Side-by-side with 2:1 ratio
        return Row(
          children: [
            Expanded(flex: 2, child: primary),
            const VerticalDivider(width: 1),
            Expanded(flex: 1, child: supporting),
          ],
        );
      },
    );
  }
}
```

### Feed Layout

For arranging many equivalent content elements (e.g., photo gallery, product grid).

| Screen Size | Implementation |
|-------------|----------------|
| **Compact** | Single-column list or two-column GridView |
| **Medium** | Multi-column grid (2-3 columns) |
| **Expanded** | Wider multi-column grid (3-4 columns) |
| **Large/Extra-Large** | Expansive grid within centered, max-width ConstrainedBox |

```dart
class FeedLayout extends StatelessWidget {
  final List<Widget> items;
  
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
        
        Widget grid = GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          padding: const EdgeInsets.all(16),
          children: items,
        );
        
        // Constrain width on extra-large screens
        if (screenSize == ScreenSize.extraLarge) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: grid,
            ),
          );
        }
        
        return grid;
      },
    );
  }
}
```

## Implementation: Adaptive Layout Builder

### Core Builder Widget

```dart
// core/presentation/responsive/adaptive_layout_builder.dart
import 'package:flutter/material.dart';
import 'screen_size.dart';

/// A widget that rebuilds its child based on the current screen size.
class AdaptiveLayoutBuilder extends StatelessWidget {
  /// The builder function called with the current ScreenSize.
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;

  const AdaptiveLayoutBuilder({
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery for top-level, global layout decisions
    final width = MediaQuery.sizeOf(context).width;
    final screenSize = ScreenSize.fromWidth(width);
    return builder(context, screenSize);
  }
}
```

### Extension Methods for Convenience

```dart
// core/presentation/responsive/build_context_extension.dart
import 'package:flutter/material.dart';
import 'screen_size.dart';

extension ResponsiveContext on BuildContext {
  /// Get the current screen size
  ScreenSize get screenSize {
    final width = MediaQuery.sizeOf(this).width;
    return ScreenSize.fromWidth(width);
  }
  
  /// Check if current screen is mobile
  bool get isMobile => screenSize.isMobile;
  
  /// Check if current screen supports two-pane layouts
  bool get supportsTwoPane => screenSize.supportsTwoPane;
  
  /// Check if current screen supports three-pane layouts
  bool get supportsThreePane => screenSize.supportsThreePane;
  
  /// Get responsive padding
  EdgeInsets get responsivePadding {
    return EdgeInsets.all(screenSize.isMobile ? 16.0 : 24.0);
  }
  
  /// Get responsive spacing
  double get responsiveSpacing {
    return switch (screenSize) {
      ScreenSize.compact => 8.0,
      ScreenSize.medium => 12.0,
      ScreenSize.expanded => 16.0,
      ScreenSize.large => 20.0,
      ScreenSize.extraLarge => 24.0,
    };
  }
}
```

## Adaptive Navigation Scaffold

### Navigation Destination Data Class

```dart
// core/presentation/responsive/navigation_destination_info.dart
import 'package:flutter/material.dart';

/// A simple data class to hold navigation destination information.
class NavigationDestinationInfo {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget Function(BuildContext) builder;

  const NavigationDestinationInfo({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });
}
```

### Adaptive Navigation Implementation

```dart
// core/presentation/navigation/adaptive_navigation_scaffold.dart
import 'package:flutter/material.dart';
import '../responsive/adaptive_layout_builder.dart';
import '../responsive/navigation_destination_info.dart';
import '../responsive/screen_size.dart';

class AdaptiveNavigationScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestinationInfo> destinations;

  const AdaptiveNavigationScaffold({
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutBuilder(
      builder: (context, screenSize) {
        // Compact: Bottom NavigationBar
        if (screenSize == ScreenSize.compact) {
          return Scaffold(
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations
                  .map((d) => NavigationDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: d.label,
                      ))
                  .toList(),
            ),
          );
        }

        // Medium: NavigationRail
        if (screenSize == ScreenSize.medium) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  destinations: destinations
                      .map((d) => NavigationRailDestination(
                            icon: Icon(d.icon),
                            selectedIcon: Icon(d.selectedIcon),
                            label: Text(d.label),
                          ))
                      .toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        // Expanded: Dismissible NavigationDrawer
        if (screenSize == ScreenSize.expanded) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('SmithsForge'),
            ),
            drawer: NavigationDrawer(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                onDestinationSelected(index);
                Navigator.pop(context); // Close drawer
              },
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'SmithsForge',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ...List.generate(
                  destinations.length,
                  (i) => NavigationDrawerDestination(
                    icon: Icon(destinations[i].icon),
                    selectedIcon: Icon(destinations[i].selectedIcon),
                    label: Text(destinations[i].label),
                  ),
                ),
              ],
            ),
            body: body,
          );
        }

        // Large/Extra-Large: Permanent NavigationDrawer
        return Scaffold(
          body: Row(
            children: [
              NavigationDrawer(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'SmithsForge',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...List.generate(
                    destinations.length,
                    (i) => NavigationDrawerDestination(
                      icon: Icon(destinations[i].icon),
                      selectedIcon: Icon(destinations[i].selectedIcon),
                      label: Text(destinations[i].label),
                    ),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}
```

## Responsive Widgets

### Responsive Spacing

```dart
// core/presentation/responsive/responsive_spacing.dart
import 'package:flutter/material.dart';
import '../responsive/build_context_extension.dart';

class ResponsiveSpacing extends StatelessWidget {
  final Widget child;
  
  const ResponsiveSpacing({
    required this.child,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsivePadding,
      child: child,
    );
  }
}

class ResponsiveGap extends StatelessWidget {
  final double? mobileSize;
  final double? tabletSize;
  final double? desktopSize;
  
  const ResponsiveGap({
    this.mobileSize,
    this.tabletSize,
    this.desktopSize,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    final screenSize = context.screenSize;
    final size = switch (screenSize) {
      ScreenSize.compact => mobileSize ?? 8.0,
      ScreenSize.medium => tabletSize ?? 12.0,
      _ => desktopSize ?? 16.0,
    };
    
    return SizedBox.square(dimension: size);
  }
}
```

### Responsive Container

```dart
// core/presentation/responsive/responsive_container.dart
import 'package:flutter/material.dart';
import '../responsive/adaptive_layout_builder.dart';
import '../responsive/screen_size.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final bool centerOnLarge;
  
  const ResponsiveContainer({
    required this.child,
    this.maxWidth = 1200,
    this.centerOnLarge = true,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutBuilder(
      builder: (context, screenSize) {
        if (!centerOnLarge || screenSize.index < ScreenSize.large.index) {
          return child;
        }
        
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: child,
          ),
        );
      },
    );
  }
}
```

## Best Practices

### Layout Rules

- ✅ **DO**: Use `AdaptiveLayoutBuilder` for all screen-size-dependent layouts
- ✅ **DO**: Follow Material Design 3 canonical layout patterns
- ✅ **DO**: Test layouts at all five breakpoint thresholds
- ✅ **DO**: Use context extensions for quick responsive checks
- ✅ **DO**: Constrain content width on extra-large screens
- ✅ **DO**: Change interaction patterns, not just sizes
- ❌ **DON'T**: Use `LayoutBuilder` for global layout decisions
- ❌ **DON'T**: Create device-specific code paths
- ❌ **DON'T**: Scale everything proportionally
- ❌ **DON'T**: Assume mobile-first is enough

### Navigation Rules

- ✅ **DO**: Use `AdaptiveNavigationScaffold` for main app navigation
- ✅ **DO**: Follow the navigation pattern for each breakpoint
- ✅ **DO**: Keep navigation destinations consistent across sizes
- ✅ **DO**: Close dismissible drawers after navigation
- ❌ **DON'T**: Use bottom navigation on large screens
- ❌ **DON'T**: Use permanent drawers on small screens
- ❌ **DON'T**: Mix navigation patterns within same breakpoint

### Content Organization Rules

- ✅ **DO**: Show more content on larger screens, not bigger content
- ✅ **DO**: Use multi-column layouts when appropriate
- ✅ **DO**: Add secondary information on larger screens
- ✅ **DO**: Provide more context and preview content
- ✅ **DO**: Use appropriate dialog sizes for each breakpoint
- ❌ **DON'T**: Simply make everything bigger
- ❌ **DON'T**: Leave excessive whitespace on large screens
- ❌ **DON'T**: Force mobile UX patterns on desktop

### Typography Rules

```dart
// Responsive text sizing
Text(
  'Hello',
  style: TextStyle(
    fontSize: context.isMobile ? 16 : 18,
  ),
)

// Or use theme text styles which are inherently responsive
Text(
  'Hello',
  style: TextTheme.of(context).titleLarge,
)
```

## Testing Adaptive Layouts

### Test All Breakpoints

```dart
void main() {
  testWidgets('Layout adapts to compact screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpWidget(const MyApp());
    
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });
  
  testWidgets('Layout adapts to large screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    await tester.pumpWidget(const MyApp());
    
    expect(find.byType(NavigationDrawer), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
```

### Golden Tests for Each Breakpoint

```dart
testGoldens('Product page across breakpoints', (tester) async {
  final builder = DeviceBuilder()
    ..addScenario(
      widget: const ProductPage(),
      name: 'compact',
      onCreate: (scenarioWidgetKey) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));
      },
    )
    ..addScenario(
      widget: const ProductPage(),
      name: 'large',
      onCreate: (scenarioWidgetKey) async {
        await tester.binding.setSurfaceSize(const Size(1400, 900));
      },
    );
  
  await tester.pumpDeviceBuilder(builder);
  await screenMatchesGolden(tester, 'product_page_adaptive');
});
```

## Common Patterns

### Responsive Card Grid

```dart
class ResponsiveCardGrid extends StatelessWidget {
  final List<Widget> cards;
  
  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutBuilder(
      builder: (context, screenSize) {
        final columns = screenSize.isMobile ? 1 : screenSize.supportsTwoPane ? 2 : 3;
        final childAspectRatio = screenSize.isMobile ? 1.5 : 1.2;
        
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: context.responsiveSpacing,
          mainAxisSpacing: context.responsiveSpacing,
          childAspectRatio: childAspectRatio,
          padding: context.responsivePadding,
          children: cards,
        );
      },
    );
  }
}
```

### Conditional Widget Display

```dart
class ConditionalWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutBuilder(
      builder: (context, screenSize) {
        if (screenSize == ScreenSize.compact) return mobile;
        if (screenSize.supportsTwoPane && desktop != null) return desktop!;
        return tablet ?? mobile;
      },
    );
  }
}
```

## Performance Considerations

- Use `const` constructors wherever possible
- Avoid rebuilding entire layouts when only content changes
- Cache computed layout values
- Use `LayoutBuilder` for local, widget-specific sizing
- Use `MediaQuery` (via `AdaptiveLayoutBuilder`) for global decisions
- Consider using `ValueListenableBuilder` for dynamic breakpoint changes

## Migration Strategy

### From Existing Code

1. Replace `LayoutBuilder` usage for screen-size decisions with `AdaptiveLayoutBuilder`
2. Update navigation to use `AdaptiveNavigationScaffold`
3. Refactor hardcoded breakpoints to use `ScreenSize` enum
4. Apply canonical layout patterns to existing pages
5. Test at all five breakpoints
6. Update golden test suite

### Example Migration

```dart
// ❌ Before
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    }
    return DesktopLayout();
  },
)

// ✅ After
AdaptiveLayoutBuilder(
  builder: (context, screenSize) {
    if (screenSize == ScreenSize.compact) {
      return const MobileLayout();
    }
    return const DesktopLayout();
  },
)
```
