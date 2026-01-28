# Testing Standards & Best Practices

## Coverage Targets (MANDATORY)

Target **100% test coverage** across all layers:

- **Domain Layer**: 100%
- **Application Layer**: 100%
- **Infrastructure Layer**: 100%
- **Presentation Layer (BLoCs)**: 100%
- **Overall Project**: 100%

**Note**: This starter app provides testing guidelines and helper utilities. Implement tests following these patterns as you add features.

## Test-Driven Development (TDD)

### Red-Green-Refactor Cycle

1. **Red**: Write a failing test first
2. **Green**: Write minimal code to pass the test
3. **Refactor**: Improve code while keeping tests green

### Example TDD Flow

```dart
// 1. RED: Write failing test
test('Product.isExpensive returns true when price > 100', () {
  final product = Product(id: '1', name: 'Test', price: 150);
  expect(product.isExpensive, isTrue); // FAILS - method doesn't exist
});

// 2. GREEN: Make it pass
class Product {
  final double price;
  bool get isExpensive => price > 100; // Minimal implementation
}

// 3. REFACTOR: Improve (if needed)
class Product {
  static const expensiveThreshold = 100.0;
  bool get isExpensive => price > expensiveThreshold;
}
```

## Unit Testing

### Domain Entity Tests

```dart
@TestOn('vm')
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product Entity', () {
    late Product testProduct;
    
    setUp(() {
      testProduct = Product(
        id: '1',
        name: 'Test Product',
        price: 150.0,
        imageUrl: 'http://example.com/image.jpg',
        lastModified: DateTime(2024, 1, 1),
      );
    });
    
    group('business logic', () {
      test('should correctly identify expensive products', () {
        expect(testProduct.isExpensive, isTrue);
        
        final cheapProduct = testProduct.copyWith(price: 50.0);
        expect(cheapProduct.isExpensive, isFalse);
      });
      
      test('should correctly identify new products', () {
        final newProduct = testProduct.copyWith(
          lastModified: DateTime.now().subtract(const Duration(days: 3)),
        );
        expect(newProduct.isNew, isTrue);
        
        final oldProduct = testProduct.copyWith(
          lastModified: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(oldProduct.isNew, isFalse);
      });
    });
    
    group('equality', () {
      test('should implement value equality', () {
        final product2 = testProduct.copyWith();
        expect(testProduct, equals(product2));
        expect(testProduct.hashCode, equals(product2.hashCode));
      });
      
      test('should have different values for different products', () {
        final product2 = testProduct.copyWith(id: '2');
        expect(testProduct, isNot(equals(product2)));
        expect(testProduct.hashCode, isNot(equals(product2.hashCode)));
      });
    });
  });
}
```

### Value Object Tests

```dart
void main() {
  group('EmailAddress', () {
    group('validation', () {
      test('should accept valid email', () {
        final email = EmailAddress('user@example.com');
        expect(email.isValid, isTrue);
      });
      
      test('should reject empty email', () {
        final email = EmailAddress('');
        expect(email.isValid, isFalse);
        expect(
          email.value.fold((f) => f, (_) => null),
          isA<Empty>(),
        );
      });
      
      test('should reject invalid format', () {
        final email = EmailAddress('invalid.email');
        expect(email.isValid, isFalse);
        expect(
          email.value.fold((f) => f, (_) => null),
          isA<InvalidEmail>(),
        );
      });
    });
    
    group('getOrCrash', () {
      test('should return value for valid email', () {
        final email = EmailAddress('user@example.com');
        expect(email.getOrCrash(), equals('user@example.com'));
      });
      
      test('should throw for invalid email', () {
        final email = EmailAddress('invalid');
        expect(() => email.getOrCrash(), throwsA(isA<UnexpectedValueError>()));
      });
    });
  });
}
```

### Use Case Tests

**Example using mocktail for mocking:**

```dart
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  group('Login', () {
    late Login useCase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = Login(mockRepository);
    });

    final tCredentials = AuthCredentials(
      email: EmailAddress('user@example.com'),
      password: Password('Password1'),
    );

    final tUser = User(
      id: UniqueId.fromString('1'),
      email: EmailAddress.fromTrustedSource('user@example.com'),
      name: Name.fromTrustedSource('Test User'),
      isEmailVerified: true,
      profileImageUrl: ImageUrl.fromTrustedSource(null),
    );

    test('should return User when login succeeds', () async {
      // Arrange
      when(() => mockRepository.login(tCredentials))
          .thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase(tCredentials);

      // Assert
      expect(result, Right(tUser));
      verify(() => mockRepository.login(tCredentials)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when login fails', () async {
      // Arrange
      const tFailure = AuthFailure.unauthorized(message: 'Invalid credentials');
      when(() => mockRepository.login(tCredentials))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tCredentials);

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.login(tCredentials)).called(1);
    });
  });
}
```

## BLoC Testing

### With bloc_test Package

```dart
class MockGetAllProducts extends Mock implements GetAllProducts {}

void main() {
  group('ProductListBloc', () {
    late ProductListBloc bloc;
    late MockGetAllProducts mockGetAllProducts;
    
    setUp(() {
      mockGetAllProducts = MockGetAllProducts();
      bloc = ProductListBloc(mockGetAllProducts);
    });
    
    tearDown(() {
      bloc.close();
    });
    
    final tProducts = [
      Product(id: '1', name: 'Product 1', price: 100),
    ];
    
    test('initial state should be Initial', () {
      expect(bloc.state, const ProductListState.initial());
    });
    
    blocTest<ProductListBloc, ProductListState>(
      'emits [Loading, Success] when fetch succeeds',
      build: () {
        when(() => mockGetAllProducts(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => Right(tProducts));
        return bloc;
      },
      act: (bloc) => bloc.add(const ProductListEvent.fetchProducts()),
      expect: () => [
        const ProductListState.loading(),
        ProductListState.success(tProducts),
      ],
      verify: (_) {
        verify(() => mockGetAllProducts(forceRefresh: false)).called(1);
      },
    );
    
    blocTest<ProductListBloc, ProductListState>(
      'emits [Loading, Error] when fetch fails',
      build: () {
        when(() => mockGetAllProducts(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => const Left(Failure.server(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const ProductListEvent.fetchProducts()),
      expect: () => [
        const ProductListState.loading(),
        const ProductListState.error(Failure.server(message: 'Error')),
      ],
    );
    
    blocTest<ProductListBloc, ProductListState>(
      'debounces search events',
      build: () => bloc,
      act: (bloc) async {
        bloc.add(const ProductListEvent.searchProducts('query1'));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ProductListEvent.searchProducts('query2'));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ProductListEvent.searchProducts('query3'));
      },
      wait: const Duration(milliseconds: 500),
      verify: (_) {
        // Only the last search should be processed
        verify(() => mockGetAllProducts(forceRefresh: false)).called(1);
      },
    );
  });
}
```

## Widget Testing

### Basic Widget Tests

```dart
void main() {
  testWidgets('ProductCard displays product information', (tester) async {
    final product = Product(
      id: '1',
      name: 'Test Product',
      price: 99.99,
      imageUrl: 'http://example.com/image.jpg',
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(product: product),
        ),
      ),
    );
    
    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('\$99.99'), findsOneWidget);
  });
  
  testWidgets('ProductCard calls onTap when tapped', (tester) async {
    var tapped = false;
    final product = Product(id: '1', name: 'Test', price: 100);
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(
            product: product,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    
    await tester.tap(find.byType(ProductCard));
    await tester.pumpAndSettle();
    
    expect(tapped, isTrue);
  });
}
```

### Widget Tests with BLoC

```dart
class MockProductBloc extends MockBloc<ProductEvent, ProductState>
    implements ProductBloc {}

void main() {
  late MockProductBloc mockBloc;
  
  setUp(() {
    mockBloc = MockProductBloc();
  });
  
  testWidgets('shows loading indicator when state is loading', (tester) async {
    when(() => mockBloc.state).thenReturn(const ProductState.loading());
    
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductBloc>.value(
          value: mockBloc,
          child: const ProductListPage(),
        ),
      ),
    );
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  
  testWidgets('shows products when state is success', (tester) async {
    final products = [
      Product(id: '1', name: 'Product 1', price: 100),
    ];
    
    when(() => mockBloc.state)
        .thenReturn(ProductState.success(products));
    
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductBloc>.value(
          value: mockBloc,
          child: const ProductListPage(),
        ),
      ),
    );
    
    expect(find.text('Product 1'), findsOneWidget);
  });
}
```

## Golden Tests

### Setup

```dart
void main() {
  testGoldens('ProductCard matches golden', (tester) async {
    final product = Product(
      id: '1',
      name: 'Test Product',
      price: 99.99,
      imageUrl: 'http://example.com/image.jpg',
    );
    
    await tester.pumpWidgetBuilder(
      ProductCard(product: product),
      surfaceSize: const Size(400, 200),
    );
    
    await screenMatchesGolden(tester, 'product_card');
  });
  
  testGoldens('ProductCard across devices', (tester) async {
    final product = Product(
      id: '1',
      name: 'Test Product',
      price: 99.99,
    );
    
    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(devices: [
        Device.phone,
        Device.iphone11,
        Device.tabletPortrait,
      ])
      ..addScenario(
        name: 'Default',
        widget: ProductCard(product: product),
      )
      ..addScenario(
        name: 'Without Image',
        widget: ProductCard(
          product: product.copyWith(imageUrl: ''),
        ),
      );
    
    await tester.pumpDeviceBuilder(builder);
    await screenMatchesGolden(tester, 'product_card_variations');
  });
}
```

### Commands

```bash
# Update golden files
very_good test --update-goldens

# Run golden tests (with coverage)
very_good test --coverage
```

## Integration Tests

### E2E Flow Test

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Product Flow', () {
    testWidgets('User can browse and view product details', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for products to load
      await tester.pump(const Duration(seconds: 2));
      
      // Verify product list
      expect(find.text('Products'), findsOneWidget);
      expect(find.byType(ProductCard), findsWidgets);
      
      // Tap on first product
      await tester.tap(find.byType(ProductCard).first);
      await tester.pumpAndSettle();
      
      // Verify detail page
      expect(find.text('Product Details'), findsOneWidget);
      expect(find.text('Add to Cart'), findsOneWidget);
      
      // Add to cart
      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();
      
      // Verify cart badge
      expect(find.text('1'), findsOneWidget);
    });
  });
}
```

## Test Helpers

### Common Test Data

```dart
// test/helpers/test_data.dart
class TestData {
  static Product createProduct({
    String id = '1',
    String name = 'Test Product',
    double price = 99.99,
  }) {
    return Product(
      id: id,
      name: name,
      price: price,
      imageUrl: 'http://example.com/image.jpg',
    );
  }
  
  static List<Product> createProducts(int count) {
    return List.generate(
      count,
      (i) => createProduct(id: '$i', name: 'Product $i'),
    );
  }
}
```

### Pump App Helper

```dart
// test/helpers/pump_app.dart
extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(
        home: widget,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
  }
}
```

## Testing Rules

- ✅ **DO**: Test behavior, not implementation
- ✅ **DO**: Use descriptive test names (Given/When/Then)
- ✅ **DO**: Follow AAA pattern (Arrange, Act, Assert)
- ✅ **DO**: Mock external dependencies using mocktail
- ✅ **DO**: Test error cases
- ✅ **DO**: Keep tests isolated and independent
- ✅ **DO**: Use centralized mocks from `test/helpers/mock_helpers.dart`
- ✅ **DO**: Call `registerMockFallbackValues()` in `setUpAll()`
- ❌ **DON'T**: Test generated code (freezed, injectable)
- ❌ **DON'T**: Test framework code
- ❌ **DON'T**: Have tests depend on each other
- ❌ **DON'T**: Mock value objects or entities
- ❌ **DON'T**: Duplicate mock classes (use mock_helpers.dart)

## Running Tests

**IMPORTANT**: Use `very_good` CLI, not `flutter test` directly.

```bash
# Run all tests with coverage report
very_good test --coverage

# Run specific test file
very_good test test/features/auth/domain/entities/user_test.dart

# Update golden files
very_good test --update-goldens

# Run tests recursively from subdirectory
very_good test --recursive
```

## Centralized Test Helpers

All mocks should be defined in `test/helpers/mock_helpers.dart`:

```dart
// test/helpers/mock_helpers.dart
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}
class MockTokenStorage extends Mock implements ITokenStorage {}
// ... centralized mock definitions

/// Register fallback values for mocktail.
/// Call this once in `setUpAll()` of your test file.
void registerMockFallbackValues() {
  registerFallbackValue(AppThemeMode.light);
  registerFallbackValue(AuthState.empty());
  registerFallbackValue(TestData.loginCredentials());
  // ... centralized fallback registrations
}
```

Usage in tests:

```dart
void main() {
  setUpAll(() {
    registerMockFallbackValues();
  });

  // ... your tests
}
```
