# Performance Rules

## Core Principles

- Build for 60 FPS (16.67ms per frame)
- Use `const` constructors aggressively
- Minimize widget rebuilds
- Optimize list rendering
- Cache expensive computations
- Profile before optimizing

## Widget Performance

### Use Const Constructors

```dart
// ❌ Bad - Creates new widget every rebuild
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(16),
    child: Text('Hello'),
  );
}

// ✅ Good - Const widgets are reused
Widget build(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(16),
    child: Text('Hello'),
  );
}
```

### Extract Widgets Instead of Methods

```dart
// ❌ Bad - Method recreates widgets on every build
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(), // Rebuilds every time
        _buildBody(),
      ],
    );
  }

  Widget _buildHeader() => const Text('Header');
  Widget _buildBody() => const Text('Body');
}

// ✅ Good - Separate widgets can be const
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _Header(), // Const widget
        _Body(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => const Text('Header');
}
```

### Widget Performance Rules

- ✅ **DO**: Use `const` constructors wherever possible
- ✅ **DO**: Extract widgets instead of build methods
- ✅ **DO**: Keep widget tree shallow
- ✅ **DO**: Use `RepaintBoundary` for complex widgets
- ❌ **DON'T**: Create widgets inside build methods
- ❌ **DON'T**: Use functions that return widgets
- ❌ **DON'T**: Deeply nest widgets unnecessarily

## List Optimization

### Use ListView.builder

```dart
// ❌ Bad - Creates all items at once
ListView(
  children: products.map((p) => ProductCard(product: p)).toList(),
)

// ✅ Good - Lazy loading with builder
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) {
    return ProductCard(
      key: ValueKey(products[index].id), // ✅ Keys for list items
      product: products[index],
    );
  },
)
```

### Implement Keys for List Items

```dart
// ✅ Always use keys for dynamic lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return ProductCard(
      key: ValueKey(item.id), // Identity-based key
      product: item,
    );
  },
)
```

### Use Appropriate List Widgets

```dart
// For fixed-size lists
ListView.builder()

// For infinite scrolling
ListView.builder(
  controller: _scrollController,
  itemCount: null, // Infinite
)

// For grids
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
)

// For single-child scrolling
SingleChildScrollView()

// For custom scrolling effects
CustomScrollView(
  slivers: [
    SliverAppBar(),
    SliverList(),
  ],
)
```

### List Performance Rules

- ✅ **DO**: Use `.builder()` constructors for long lists
- ✅ **DO**: Implement keys for list items
- ✅ **DO**: Use appropriate list widgets
- ✅ **DO**: Implement pagination for large datasets
- ❌ **DON'T**: Use `ListView(children: [...])` for long lists
- ❌ **DON'T**: Forget keys on dynamic lists
- ❌ **DON'T**: Load all data at once

## Image Optimization

### Use CachedNetworkImage

```dart
import 'package:cached_network_image/cached_network_image.dart';

// ✅ Cache images with size constraints
CachedNetworkImage(
  imageUrl: product.imageUrl,
  memCacheHeight: 300, // Limit memory usage
  memCacheWidth: 300,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

### Precache Images

```dart
// Precache important images
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(
    const AssetImage('assets/images/logo.png'),
    context,
  );
}
```

### Image Performance Rules

- ✅ **DO**: Use `CachedNetworkImage` for network images
- ✅ **DO**: Set `memCacheHeight` and `memCacheWidth`
- ✅ **DO**: Provide appropriate placeholders
- ✅ **DO**: Use image formats efficiently (WebP > PNG > JPEG)
- ✅ **DO**: Resize images on server side
- ❌ **DON'T**: Load full-resolution images unnecessarily
- ❌ **DON'T**: Use `Image.network` without caching
- ❌ **DON'T**: Load all images at once

## State Management Performance

### Minimize BLoC Rebuilds

```dart
// ✅ Use BlocBuilder with buildWhen
BlocBuilder<ProductBloc, ProductState>(
  buildWhen: (previous, current) {
    // Only rebuild when products change
    return previous.maybeMap(
      success: (prev) => current.maybeMap(
        success: (curr) => prev.products != curr.products,
        orElse: () => true,
      ),
      orElse: () => true,
    );
  },
  builder: (context, state) {
    // Build UI
  },
)

// ✅ Use BlocSelector for specific fields
BlocSelector<AuthBloc, AuthState, User?>(
  selector: (state) => state.mapOrNull(authenticated: (s) => s.user),
  builder: (context, user) {
    // Only rebuilds when user changes
  },
)
```

### Use BlocConsumer Wisely

```dart
// ✅ Separate listener from builder
BlocConsumer<ProductBloc, ProductState>(
  listenWhen: (previous, current) {
    // Only listen to specific state changes
    return current is Error;
  },
  buildWhen: (previous, current) {
    // Different condition for rebuilds
    return current is Success || current is Loading;
  },
  listener: (context, state) {
    // Side effects only
  },
  builder: (context, state) {
    // UI only
  },
)
```

### State Management Performance Rules

- ✅ **DO**: Use `buildWhen` and `listenWhen`
- ✅ **DO**: Use `BlocSelector` for specific fields
- ✅ **DO**: Keep state classes immutable
- ✅ **DO**: Use `Equatable` or `freezed` for proper equality
- ❌ **DON'T**: Rebuild entire tree for small changes
- ❌ **DON'T**: Access BLoC in build methods repeatedly
- ❌ **DON'T**: Emit same state unnecessarily

## Lazy Loading & Code Splitting

### Deferred Loading

```dart
// Use deferred imports for large features
import 'package:my_app/admin/admin_page.dart' deferred as admin;

// Load when needed
Future<void> navigateToAdmin() async {
  await admin.loadLibrary();
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => admin.AdminPage()),
  );
}
```

### Lazy Initialization

```dart
// ✅ Lazy initialization with late
class MyService {
  late final ExpensiveResource _resource = _initResource();

  ExpensiveResource _initResource() {
    // Only called when first accessed
    return ExpensiveResource();
  }
}
```

## Expensive Operations

### Compute for Heavy Tasks

```dart
import 'package:flutter/foundation.dart';

// ✅ Move heavy computation to isolate
Future<List<Product>> parseProducts(String json) async {
  return compute(_parseProductsInIsolate, json);
}

List<Product> _parseProductsInIsolate(String json) {
  // Heavy parsing work
  final data = jsonDecode(json) as List;
  return data.map((item) => Product.fromJson(item)).toList();
}
```

### Debouncing & Throttling

```dart
// ✅ Debounce search queries
@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._searchProducts) : super(const SearchState.initial()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
  }
}

// Custom transformer
EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}
```

### Expensive Operation Rules

- ✅ **DO**: Use `compute()` for CPU-intensive tasks
- ✅ **DO**: Debounce user input (search, form validation)
- ✅ **DO**: Throttle scroll events
- ✅ **DO**: Cache computed results
- ❌ **DON'T**: Block UI thread with heavy operations
- ❌ **DON'T**: Process every keystroke immediately
- ❌ **DON'T**: Recompute on every build

## Memory Management

### Dispose Resources

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final ScrollController _controller;
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _subscription = someStream.listen((_) {});
  }

  @override
  void dispose() {
    // ✅ Always dispose resources
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(controller: _controller);
  }
}
```

### BLoC Disposal

```dart
// ✅ BLoC automatically disposed by BlocProvider
BlocProvider(
  create: (context) => getIt<ProductBloc>(),
  child: const ProductPage(),
)

// ❌ DON'T manually dispose BLoCs provided by BlocProvider
```

### Memory Management Rules

- ✅ **DO**: Dispose controllers, streams, animations
- ✅ **DO**: Cancel timers and subscriptions
- ✅ **DO**: Close BLoCs when manually created
- ✅ **DO**: Use `AutomaticKeepAliveClientMixin` for tabs
- ❌ **DON'T**: Leak resources
- ❌ **DON'T**: Forget to call super.dispose()
- ❌ **DON'T**: Dispose BLoCs managed by BlocProvider

## Performance Monitoring

### Flutter DevTools

```bash
# Run app in profile mode
flutter run --profile

# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Performance Overlay

```dart
MaterialApp(
  // ✅ Show performance overlay in debug
  showPerformanceOverlay: true,
  debugShowCheckedModeBanner: false,
)
```

### Custom Performance Markers

```dart
import 'dart:developer' as developer;

Future<void> expensiveOperation() async {
  developer.Timeline.startSync('ExpensiveOperation');
  try {
    // Your operation
  } finally {
    developer.Timeline.finishSync();
  }
}
```

## Build Optimization

### Build Time Optimization

```yaml
# pubspec.yaml - Use pre-compiled packages when possible
dependencies:
  freezed_annotation: ^2.4.1

dev_dependencies:
  build_runner: ^2.4.6
  freezed: ^2.4.5
```

```bash
# Cache build artifacts
flutter pub run build_runner build --delete-conflicting-outputs

# Use watch mode during development
flutter pub run build_runner watch
```

## Performance Checklist

### Pre-Release Performance Review

- [ ] All lists use `.builder()` constructors
- [ ] Images use `CachedNetworkImage` with size limits
- [ ] Const constructors used wherever possible
- [ ] Keys implemented on list items
- [ ] BLoC rebuilds minimized with `buildWhen`
- [ ] Heavy operations use `compute()`
- [ ] No memory leaks (all resources disposed)
- [ ] Debouncing on search/input fields
- [ ] Profile mode tested without jank
- [ ] Bundle size optimized

### Common Performance Issues

- ❌ Building entire list with `ListView(children: [...])`
- ❌ Missing `const` on static widgets
- ❌ Using methods instead of widget classes
- ❌ No keys on dynamic lists
- ❌ Blocking UI with synchronous operations
- ❌ Loading full-size images
- ❌ Not disposing controllers/streams

## Benchmarking

### Measure Performance

```dart
void main() {
  // Benchmark widget build time
  testWidgets('ProductCard performance', (tester) async {
    final stopwatch = Stopwatch()..start();

    await tester.pumpWidget(
      MaterialApp(home: ProductCard(product: testProduct)),
    );

    stopwatch.stop();
    print('Build time: ${stopwatch.elapsedMilliseconds}ms');
    expect(stopwatch.elapsedMilliseconds, lessThan(16)); // < 1 frame
  });
}
```

### Target Metrics

- **Frame render**: < 16.67ms (60 FPS)
- **Widget build**: < 8ms
- **First meaningful paint**: < 1s
- **App startup**: < 2s
- **Bundle size**: < 20MB (optimized)
