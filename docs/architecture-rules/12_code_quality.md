# Code Quality & Style Rules

## Linting (very_good_analysis)

### Required Package

```yaml
dev_dependencies:
  very_good_analysis: ^10.0.0
```

### analysis_options.yaml

```yaml
include: package:very_good_analysis/analysis_options.yaml

linter:
  rules:
    # Additional project-specific rules
    always_use_package_imports: true
    prefer_relative_imports: false
```

## Naming Conventions

### Files & Directories

- ✅ `snake_case` for all files: `product_repository.dart`
- ✅ `snake_case` for directories: `product_catalog/`
- ❌ No PascalCase or camelCase in file names

### Classes & Types

- ✅ `PascalCase` for classes: `ProductRepository`
- ✅ `PascalCase` for typedefs: `ProductCallback`
- ✅ Prefix interfaces with `I`: `IProductRepository`
- ✅ Suffix implementations with `Impl`: `ProductRepositoryImpl`

### Variables & Functions

- ✅ `camelCase` for variables: `productName`
- ✅ `camelCase` for functions: `getAllProducts()`
- ✅ `SCREAMING_SNAKE_CASE` for constants: `MAX_RETRY_COUNT`

### Private Members

- ✅ Prefix with underscore: `_repository`, `_fetchData()`

## Documentation

### Documentation Philosophy

- **Comment wisely**: Explain *why* the code is written a certain way, not *what* it does
- **Document for the user**: Write with the reader in mind; answer real-world questions
- **No useless documentation**: If docs only restate what's obvious from the name, omit them
- **Prioritize public APIs**: Always document public APIs; consider private ones too

### dartdoc Style

Use `///` for documentation comments that tools like `dartdoc` can pick up:

```dart
// ❌ BAD - Regular comment (not picked up by dartdoc)
// This class handles products

// ✅ GOOD - Doc comment
/// Repository implementation for product data operations.
class ProductRepositoryImpl {}
```

### Single-Sentence Summary First

Start with a concise, user-centric summary ending with a period. Add a blank line before additional details:

```dart
/// Fetches all products from the repository.
///
/// By default, returns cached data if available. Set [forceRefresh]
/// to true to bypass cache and fetch from network.
///
/// Returns [Right<List<Product>>] on success or [Left<Failure>] on error.
Future<Either<Failure, List<Product>>> getAllProducts({
  bool forceRefresh = false,
});
```

### File/Class Header Comments

```dart
/// Repository implementation for product data operations.
/// 
/// Handles offline-first caching and network synchronization.
/// Uses [IProductRemoteDataSource] for API calls and 
/// [IProductLocalDataSource] for local storage.
class ProductRepositoryImpl implements IProductRepository {
  // Implementation
}
```

### Documentation Don'ts

```dart
// ❌ BAD - Just restates the obvious
/// Returns the name.
String get name => _name;

// ✅ GOOD - Adds useful context
/// The display name, never null, may be empty for new users.
String get name => _name;
```

### Code Examples in Documentation

```dart
/// Fetches all products from the repository.
///
/// Example:
/// ```dart
/// final result = await getAllProducts(forceRefresh: true);
/// result.fold(
///   (failure) => print('Error: $failure'),
///   (products) => print('Got ${products.length} products'),
/// );
/// ```
Future<Either<Failure, List<Product>>> getAllProducts({
  bool forceRefresh = false,
});
```

### Documentation Rules

- ✅ **DO**: Start with a single-sentence summary
- ✅ **DO**: Use `[ClassName]` to link to other types
- ✅ **DO**: Document parameters, return values, and exceptions
- ✅ **DO**: Place doc comments before annotations
- ✅ **DO**: Include code examples for complex APIs
- ❌ **DON'T**: Use trailing comments
- ❌ **DON'T**: Restate what's obvious from the code
- ❌ **DON'T**: Document both getter and setter (pick one)

## Import Organization

### Order

```dart
// 1. Dart imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Package imports (alphabetical)
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

// 4. Relative imports (alphabetical)
import '../../domain/entities/product.dart';
import '../models/product_model.dart';
```

### Rules

- ✅ Use package imports for all lib/ files
- ✅ Group and alphabetize imports
- ✅ Separate groups with blank lines
- ❌ Never use relative imports for lib/ files

## Code Formatting

### Run Dart Format

```bash
dart format . --set-exit-if-changed
```

### Formatting Rules

- ✅ Use trailing commas for all function/constructor parameters
- ✅ Max line length: 80 characters (can extend to 120 for readability)
- ✅ Use const constructors wherever possible

## Constants

### Define Once, Use Everywhere

```dart
// core/constants/size_constants.dart
class SizeConstants {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  static const double borderRadius = 12.0;
  static const double iconSize = 24.0;
}

// core/constants/duration_constants.dart
class DurationConstants {
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration debounce = Duration(milliseconds: 300);
  static const Duration timeout = Duration(seconds: 30);
}
```

## Best Practices

### Avoid Magic Numbers/Strings

```dart
// ❌ Bad
if (product.price > 100) { }
await Future.delayed(Duration(milliseconds: 300));

// ✅ Good
if (product.price > PriceConstants.expensiveThreshold) { }
await Future.delayed(DurationConstants.debounce);
```

### Use Enums

```dart
enum ProductStatus {
  draft,
  published,
  archived;
  
  String get displayName => switch (this) {
    draft => 'Draft',
    published => 'Published',
    archived => 'Archived',
  };
}
```

### Prefer Final

```dart
// ✅ Prefer final over var
final name = 'Product';
final price = 99.99;

// ✅ Use const for compile-time constants
const maxRetries = 3;
const defaultTimeout = Duration(seconds: 30);
```

## Final Classes for Performance

### When to Use Final Classes

Use the `final` keyword on classes to improve performance and prevent inheritance:

```dart
// ✅ Utility classes with static methods only
final class AppConstants {
  const AppConstants._();
  static const String appName = 'MyApp';
}

// ✅ Classes with private constructors
final class PaddingConstants {
  const PaddingConstants._();
  static const double small = 8.0;
}

// ✅ Injectable services not meant to be subclassed
@lazySingleton
final class ThemeService {
  ThemeService(this._prefs);
  final SharedPreferences _prefs;
}

// ✅ BLoC/Cubit classes
@injectable
final class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc(this._useCase) : super(const ProductState.initial());
  final GetAllProducts _useCase;
}

// ✅ Exception classes
final class ServerException implements Exception {
  const ServerException({this.message});
  final String? message;
}

// ✅ Value objects
final class UniqueId {
  const UniqueId._(this.value);
  final String value;
}
```

### When NOT to Use Final Classes

```dart
// ❌ Widget classes (users might want to extend)
class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, super.key});
  final Product product;
}

// ❌ Abstract classes and interfaces
abstract class IProductRepository {
  Future<Either<Failure, List<Product>>> getAllProducts();
}

// ❌ Freezed/sealed classes (use freezed's own sealing)
@freezed
class Product with _$Product {
  const factory Product({required String id}) = _Product;
}

// ❌ Classes explicitly designed for extension
class BaseRepository {
  // Meant to be extended by feature repositories
}
```

### Benefits of Final Classes

1. **Performance**: Compiler can optimize method calls (devirtualization)
2. **Tree Shaking**: Better dead code elimination
3. **Memory Efficiency**: Smaller method dispatch tables
4. **Intent**: Clearly signals the class is not meant to be extended
5. **Type Safety**: Prevents unintended inheritance

### Final Class Rules

- ✅ **DO**: Use `final` for utility classes with static methods
- ✅ **DO**: Use `final` for classes with private constructors
- ✅ **DO**: Use `final` for injectable services (@injectable, @singleton, @lazySingleton)
- ✅ **DO**: Use `final` for BLoCs and Cubits
- ✅ **DO**: Use `final` for exception classes
- ✅ **DO**: Use `final` for value objects and domain primitives
- ✅ **DO**: Use `final` for constant classes (AppConstants, SizeConstants)
- ❌ **DON'T**: Use `final` on widget classes (unless explicitly preventing extension)
- ❌ **DON'T**: Use `final` on abstract classes or interfaces
- ❌ **DON'T**: Use `final` on freezed-generated classes
- ❌ **DON'T**: Use `final` on classes designed for inheritance

### TODO Comments

```dart
// TODO(username): Description of what needs to be done
// FIXME(username): Description of bug that needs fixing
// HACK(username): Explanation of non-ideal solution
```

## Performance

### Widget Performance

```dart
// ✅ Use const constructors
const Text('Hello')
const Padding(padding: EdgeInsets.all(16))

// ✅ Extract widgets instead of methods
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _HeaderWidget(), // ✅ Widget
        _buildBody(), // ❌ Method
      ],
    );
  }
}

// ✅ Use keys for list items
ListView.builder(
  itemBuilder: (context, index) {
    return ProductCard(
      key: ValueKey(products[index].id),
      product: products[index],
    );
  },
)
```
