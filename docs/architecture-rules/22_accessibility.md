# Accessibility (A11Y) Rules

## Core Principles

- Build interfaces that empower **all users** regardless of ability
- Ensure compliance with **WCAG 2.1** guidelines where applicable
- Test with assistive technologies on all target platforms
- Make accessibility a core development practice, not an afterthought

## Color Contrast

### WCAG Guidelines

Ensure sufficient contrast between text and background colors:

| Element Type | Minimum Contrast Ratio |
|--------------|----------------------|
| **Normal text** (< 18pt) | 4.5:1 |
| **Large text** (≥ 18pt or ≥ 14pt bold) | 3:1 |
| **UI components** (buttons, icons) | 3:1 |

### Testing Contrast

```dart
// Use tools like:
// - WebAIM Contrast Checker
// - Chrome DevTools Accessibility
// - Colorable (colorable.jxnblk.com)

// ❌ BAD - Insufficient contrast
Text(
  'Light gray on white',
  style: TextStyle(color: Colors.grey[300]),
) // Against white background - FAILS

// ✅ GOOD - Sufficient contrast
Text(
  'Dark gray on white',
  style: TextStyle(color: Colors.grey[800]),
) // Against white background - 7.4:1 ratio
```

### Color Contrast Rules

- ✅ **DO**: Use `ColorScheme.fromSeed()` which generates accessible palettes
- ✅ **DO**: Test in high-contrast mode
- ✅ **DO**: Provide alternative indicators besides color (icons, patterns)
- ❌ **DON'T**: Rely on color alone to convey information
- ❌ **DON'T**: Use low-contrast text for secondary information

## Semantic Labels

### Semantics Widget

Use the `Semantics` widget to provide meaningful labels for screen readers:

```dart
// ❌ BAD - No semantic information
IconButton(
  onPressed: _toggleFavorite,
  icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
)

// ✅ GOOD - Clear semantic label
Semantics(
  label: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
  button: true,
  child: IconButton(
    onPressed: _toggleFavorite,
    icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
  ),
)

// ✅ ALSO GOOD - Using tooltip (provides semantics and visual hint)
IconButton(
  onPressed: _toggleFavorite,
  tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
  icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
)
```

### ExcludeSemantics

Use to hide decorative elements from screen readers:

```dart
// Decorative images should be excluded
ExcludeSemantics(
  child: Image.asset('assets/decorative_background.png'),
)
```

### MergeSemantics

Combine multiple widgets into a single semantic node:

```dart
// Merge list item elements into single announcement
MergeSemantics(
  child: ListTile(
    leading: const Icon(Icons.shopping_cart),
    title: const Text('Shopping Cart'),
    subtitle: const Text('3 items'),
    trailing: const Text('\$99.99'),
  ),
)
```

### Semantics Rules

- ✅ **DO**: Add labels to all interactive elements
- ✅ **DO**: Use tooltips for icon buttons
- ✅ **DO**: Mark decorative images with `ExcludeSemantics`
- ✅ **DO**: Group related elements with `MergeSemantics`
- ❌ **DON'T**: Leave icon buttons without labels
- ❌ **DON'T**: Use vague labels like "button" or "image"

## Dynamic Text Scaling

### Support System Font Size

Test your UI with increased system font sizes:

```dart
// Get current text scale factor
final textScaleFactor = MediaQuery.textScaleFactorOf(context);

// ❌ BAD - Fixed height that clips text
SizedBox(
  height: 40, // Text may overflow with large fonts
  child: Text('Hello World'),
)

// ✅ GOOD - Flexible layout
Container(
  constraints: const BoxConstraints(minHeight: 40),
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: const Text('Hello World'),
)
```

### Testing Text Scaling

```bash
# Android: Settings > Accessibility > Font size
# iOS: Settings > Accessibility > Display & Text Size > Larger Text

# In tests, you can simulate:
testWidgets('handles large text', (tester) async {
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(textScaleFactor: 2.0),
      child: const MyApp(),
    ),
  );
  // Verify no overflow
  expect(tester.takeException(), isNull);
});
```

### Text Scaling Rules

- ✅ **DO**: Use flexible layouts that accommodate larger text
- ✅ **DO**: Test with text scale factor of 2.0
- ✅ **DO**: Use `FittedBox` cautiously (can make text too small)
- ❌ **DON'T**: Use fixed heights for text containers
- ❌ **DON'T**: Disable text scaling (`textScaleFactor: 1.0`)

## Touch Targets

### Minimum Touch Target Size

Ensure interactive elements are easy to tap:

| Platform | Minimum Size |
|----------|-------------|
| **Material Design** | 48x48 dp |
| **iOS Human Interface** | 44x44 pt |

```dart
// ❌ BAD - Too small
IconButton(
  iconSize: 16,
  padding: EdgeInsets.zero,
  onPressed: () {},
  icon: const Icon(Icons.add),
)

// ✅ GOOD - Adequate touch target
IconButton(
  onPressed: () {},
  icon: const Icon(Icons.add),
) // Default IconButton is 48x48
```

### Touch Target Rules

- ✅ **DO**: Use default Material widget sizes
- ✅ **DO**: Add padding to small interactive elements
- ❌ **DON'T**: Override padding to make elements smaller
- ❌ **DON'T**: Place touch targets too close together

## Focus Management

### Keyboard Navigation

Ensure all interactive elements are keyboard-accessible:

```dart
// ✅ Focus traversal with proper tab order
FocusTraversalGroup(
  child: Column(
    children: [
      TextField(), // Tab stop 1
      TextField(), // Tab stop 2
      ElevatedButton(onPressed: () {}, child: Text('Submit')), // Tab stop 3
    ],
  ),
)

// Skip decorative elements
Focus(
  canRequestFocus: false,
  child: const Text('Decorative text'),
)
```

### Focus Indicators

Ensure visible focus indicators:

```dart
// Theme provides default focus indicators
// Customize if needed:
ThemeData(
  focusColor: Colors.blue.withOpacity(0.3),
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
  ),
)
```

## Screen Reader Testing

### Platform Screen Readers

Test with native screen readers:

| Platform | Screen Reader | Activation |
|----------|--------------|------------|
| **Android** | TalkBack | Settings > Accessibility > TalkBack |
| **iOS** | VoiceOver | Settings > Accessibility > VoiceOver |
| **macOS** | VoiceOver | Cmd + F5 |
| **Windows** | Narrator | Win + Ctrl + Enter |

### Testing Checklist

- [ ] All buttons and links are announced clearly
- [ ] Images have appropriate descriptions
- [ ] Form fields announce labels and errors
- [ ] Navigation order is logical
- [ ] Page changes are announced
- [ ] Dynamic content updates are announced

### Announcing Dynamic Content

```dart
// Announce important state changes
SemanticsService.announce(
  'Item added to cart',
  TextDirection.ltr,
);
```

## Accessibility Checklist

### Pre-Release A11Y Review

- [ ] All interactive elements have semantic labels
- [ ] Color contrast ratios meet WCAG 2.1 AA (4.5:1 text, 3:1 UI)
- [ ] UI works with 200% text scaling
- [ ] Touch targets are at least 48x48 dp
- [ ] Focus indicators are visible
- [ ] Tested with TalkBack (Android)
- [ ] Tested with VoiceOver (iOS)
- [ ] No information conveyed by color alone
- [ ] Form errors are announced to screen readers
- [ ] Dynamic content updates are announced

### Common A11Y Mistakes

- ❌ Icon buttons without tooltips or labels
- ❌ Images without alt text
- ❌ Low contrast text
- ❌ Fixed-height containers that clip text
- ❌ Missing focus indicators
- ❌ Form fields without associated labels

## Integration with BLoC

Announce state changes from BLoC events:

```dart
BlocListener<CartBloc, CartState>(
  listenWhen: (previous, current) => 
    current is CartItemAdded || current is CartItemRemoved,
  listener: (context, state) {
    final message = state.maybeWhen(
      itemAdded: (item) => '${item.name} added to cart',
      itemRemoved: (item) => '${item.name} removed from cart',
      orElse: () => null,
    );
    if (message != null) {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  },
  child: const CartWidget(),
)
```

## Pre-Release Accessibility Testing

### Required Before Each Release

1. **TalkBack Testing (Android)**
   - Navigate entire app using swipe gestures
   - Verify all buttons announce their purpose
   - Confirm form field labels are read correctly
   - Test with screen curtain enabled

2. **VoiceOver Testing (iOS)**
   - Use rotor to navigate by headings, buttons, form fields
   - Verify state changes are announced
   - Test with reduced motion enabled

3. **Keyboard Navigation (Web/Desktop)**
   - Tab through all interactive elements
   - Verify visible focus indicators
   - Ensure logical tab order

### Recommendations for Custom Widgets

When creating custom interactive widgets, always add accessibility support:

```dart
// ✅ Add tooltip to custom icon buttons
IconButton(
  onPressed: _onPressed,
  tooltip: 'Descriptive action text', // Screen readers use this
  icon: const Icon(Icons.custom_icon),
)

// ✅ Use Semantics for complex custom widgets
Semantics(
  label: 'Interactive element description',
  button: true, // or other roles: link, image, slider, etc.
  child: MyCustomWidget(),
)

// ✅ Announce dynamic state changes
void _onItemAdded(Item item) {
  SemanticsService.announce(
    '${item.name} added to cart',
    TextDirection.ltr,
  );
}
```

### Current Project Status

This project uses standard Material widgets (`TextFormField`, `ElevatedButton`, `IconButton`) 
which have robust accessibility support built-in:

- ✅ `InputDecoration.labelText` is automatically read by screen readers
- ✅ `ColorScheme.fromSeed()` generates WCAG-compliant color palettes
- ✅ Default Material touch targets are 48x48 dp
- ✅ Focus indicators follow theme settings

## Resources

- [Flutter Accessibility Documentation](https://docs.flutter.dev/accessibility-and-localization/accessibility)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material Design Accessibility](https://material.io/design/usability/accessibility.html)
