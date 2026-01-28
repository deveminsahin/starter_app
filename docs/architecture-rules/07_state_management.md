# State Management Rules (BLoC, ValueNotifier, HydratedBloc)

## Core Principles

- **Ephemeral state**: Use `ValueNotifier` for widget-local, UI-only state
- **App state**: Use `BLoC` for shared, business-logic-connected state
- **Persistent state**: Use `HydratedBloc` for state that survives app restarts
- Events represent user intentions
- States represent the result of those intentions
- BLoCs should be thin orchestrators, not business logic containers

## Ephemeral State vs App State

| Type | Solution | Examples |
|------|----------|----------|
| **Ephemeral** (local UI) | `ValueNotifier` + `ValueListenableBuilder` | Animation state, local toggle not tied to forms |
| **Simple App State** | `Cubit` | Theme mode, locale selection |
| **Complex App State** | `BLoC` | Auth flow, multi-step forms, feature data |
| **Persistent App State** | `HydratedCubit` / `HydratedBloc` | User preferences, cached data |

> [!TIP]
> **Password visibility** in forms is managed via BLoC state (e.g., `passwordVisible` field 
> in `AuthState`) rather than `ValueNotifier`, keeping form state unified in a single source of truth.

## ValueNotifier for Ephemeral State

For simple, widget-local state that doesn't need to cross widget boundaries or connect to business logic.

### When to Use ValueNotifier

- Local animation states (expand/collapse, animation controllers)
- Isolated UI toggles not connected to forms or business logic
- Focus state within a single widget

### When to Use BLoC Instead

- **Form field visibility** (e.g., password toggle) → BLoC state preserves visibility across form transitions
- **Toggle state that affects submission logic** → unify in BLoC
- **State shared across multiple widgets** → BLoC or Cubit

### Implementation Pattern

When you do need ValueNotifier for truly ephemeral state:

```dart
/// Example: Local accordion expansion state
final class AccordionExpansionNotifier extends ValueNotifier<bool> {
  AccordionExpansionNotifier() : super(false);

  void toggle() => value = !value;
}
```

### Usage in Widgets

```dart
class AccordionSection extends StatefulWidget {
  @override
  State<AccordionSection> createState() => _AccordionSectionState();
}

class _AccordionSectionState extends State<AccordionSection> {
  final _expansionNotifier = AccordionExpansionNotifier();

  @override
  void dispose() {
    _expansionNotifier.dispose(); // Always dispose!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _expansionNotifier,
      builder: (context, isExpanded, child) {
        return Column(
          children: [
            GestureDetector(
              onTap: _expansionNotifier.toggle,
              child: Text('Section Header'),
            ),
            if (isExpanded) Text('Expanded content'),
          ],
        );
      },
    );
  }
}
```

### ValueNotifier Rules

- ✅ **DO**: Use for simple, local UI state not tied to forms
- ✅ **DO**: Create custom notifier classes for reusable patterns
- ✅ **DO**: Always dispose in `State.dispose()`
- ✅ **DO**: Use `ValueListenableBuilder` for efficient rebuilds
- ❌ **DON'T**: Use for form-related state (use BLoC)
- ❌ **DON'T**: Use for state shared between features
- ❌ **DON'T**: Forget to dispose (causes memory leaks)

## BLoC Pattern (Complex App State)

### When to Use BLoC vs Cubit

- **Cubit**: Simple state with direct method calls (theme, locale, simple toggles)
- **BLoC**: Complex state with multiple events, transformations, or streams

### Cubit for Simple App State

**Actual implementation from this project:**

```dart
// lib/core/presentation/bloc/theme_cubit.dart
class ThemeCubit extends HydratedCubit<AppThemeMode> {
  ThemeCubit(super.state);

  /// Set theme mode
  void setThemeMode(AppThemeMode mode) => emit(mode);

  /// Switch to light theme
  void setLightTheme() => emit(AppThemeMode.light);

  /// Switch to dark theme
  void setDarkTheme() => emit(AppThemeMode.dark);

  /// Switch to system theme
  void setSystemTheme() => emit(AppThemeMode.system);

  /// Toggle between light and dark theme
  void toggleTheme() {
    if (state == AppThemeMode.light) {
      emit(AppThemeMode.dark);
    } else {
      emit(AppThemeMode.light);
    }
  }

  @override
  AppThemeMode? fromJson(Map<String, dynamic> json) {
    final modeValue = json['mode'] as String?;
    return modeValue != null ? AppThemeMode.fromString(modeValue) : null;
  }

  @override
  Map<String, dynamic>? toJson(AppThemeMode state) {
    return {'mode': state.toStringValue()};
  }
}
```

### Cubit Rules

- ✅ **DO**: Use for simple state with direct methods (setX, toggleX)
- ✅ **DO**: Use `HydratedCubit` when persistence is needed
- ✅ **DO**: Keep state simple (enum, single value, small class)
- ❌ **DON'T**: Use for complex multi-step flows (use BLoC)
- ❌ **DON'T**: Use for state requiring event transformations

### BLoC for Complex App State

Use BLoC when state involves:
- Multiple events with different handling logic
- Event transformers (debounce, throttle, restartable)
- Complex async flows (auth, multi-step wizards)
- Stream subscriptions

```dart
@injectable
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final UseCase _useCase;
  
  FeatureBloc(this._useCase) : super(const FeatureState.initial()) {
    on<EventName>(_onEventName);
  }
  
  Future<void> _onEventName(
    EventName event,
    Emitter<FeatureState> emit,
  ) async {
    // Handle event
  }
}
```


## HydratedBloc for Persistence

### When to Use

- Session state that should survive app restarts
- User preferences
- Cart contents
- Draft data

### Implementation

```dart
@injectable
class ShoppingCartBloc extends HydratedBloc<CartEvent, CartState> {
  ShoppingCartBloc() : super(const CartState.initial());
  
  @override
  CartState? fromJson(Map<String, dynamic> json) {
    try {
      // Only restore valid states
      if (json['type'] == 'loaded' && json['items'] != null) {
        return CartState.loaded(
          items: (json['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList(),
        );
      }
      return null; // Return null to use initial state
    } catch (e) {
      return null; // On error, use initial state
    }
  }
  
  @override
  Map<String, dynamic>? toJson(CartState state) {
    return state.maybeWhen(
      loaded: (items) => {
        'type': 'loaded',
        'items': items.map((item) => item.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      },
      orElse: () => null, // Don't persist loading/error states
    );
  }
}
```

### HydratedBloc Rules

- ✅ **DO**: Only persist stable states (not loading/error)
- ✅ **DO**: Return null in fromJson for invalid data
- ✅ **DO**: Include version/timestamp for migration support
- ✅ **DO**: Handle deserialization errors gracefully
- ❌ **DON'T**: Persist sensitive data without encryption
- ❌ **DON'T**: Persist large datasets (use database instead)
- ❌ **DON'T**: Assume persisted data is always valid

## Event Transformers

### Debounce (Search Input)

```dart
EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) {
    return events.debounceTime(duration).flatMap(mapper);
  };
}

// Usage
on<SearchProducts>(
  _onSearchProducts,
  transformer: debounce(const Duration(milliseconds: 300)),
);
```

### Sequential (One at a Time)

```dart
on<FetchProducts>(
  _onFetchProducts,
  transformer: sequential(),
);
```

### Restartable (Cancel Previous)

```dart
on<RefreshProducts>(
  _onRefreshProducts,
  transformer: restartable(),
);
```

### Concurrent (Parallel Execution)

```dart
on<LoadProductDetails>(
  _onLoadProductDetails,
  transformer: concurrent(),
);
```

### Rules

- ✅ **DO**: Debounce search/filter events (300ms)
- ✅ **DO**: Use sequential for data fetching
- ✅ **DO**: Use restartable for refresh operations
- ✅ **DO**: Use concurrent for independent operations
- ❌ **DON'T**: Use default transformer for search
- ❌ **DON'T**: Use concurrent for dependent operations

## State Patterns

### Union Types (Recommended)

```dart
@freezed
class ProductState with _$ProductState {
  const factory ProductState.initial() = Initial;
  const factory ProductState.loading() = Loading;
  const factory ProductState.success(List<Product> products) = Success;
  const factory ProductState.error(Failure failure) = Error;
}

// Usage
state.when(
  initial: () => const SizedBox.shrink(),
  loading: () => const LoadingIndicator(),
  success: (products) => ProductList(products: products),
  error: (failure) => ErrorView(failure: failure),
);
```

### Status + Data Pattern (Alternative)

```dart
@freezed
class ProductState with _$ProductState {
  const factory ProductState({
    @Default(StateStatus.initial) StateStatus status,
    @Default([]) List<Product> products,
    Failure? failure,
  }) = _ProductState;
}

enum StateStatus { initial, loading, success, error }
```

### State Rules

- ✅ **DO**: Prefer union types for mutually exclusive states
- ✅ **DO**: Use status+data for states with partial updates
- ✅ **DO**: Make states exhaustive
- ❌ **DON'T**: Use nullable data instead of union types
- ❌ **DON'T**: Mix loading and data in same state variant

## BLoC Communication

### Parent-Child (Direct)

```dart
class ParentBloc extends Bloc<ParentEvent, ParentState> {
  final ChildBloc _childBloc;
  late StreamSubscription _childSubscription;
  
  ParentBloc(this._childBloc) : super(const ParentState.initial()) {
    _childSubscription = _childBloc.stream.listen((childState) {
      // React to child state changes
      add(ParentEvent.childStateChanged(childState));
    });
  }
  
  @override
  Future<void> close() {
    _childSubscription.cancel();
    return super.close();
  }
}
```

### Cross-Feature (Event Bus)

```dart
@singleton
class EventBus {
  final _controller = PublishSubject<DomainEvent>();
  
  Stream<T> on<T extends DomainEvent>() => _controller.stream.whereType<T>();
  
  void fire(DomainEvent event) => _controller.add(event);
}

// Usage in BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  final EventBus _eventBus;
  
  CartBloc(this._eventBus) : super(const CartState.initial()) {
    _eventBus.on<ProductAddedToCartEvent>().listen((event) {
      add(CartEvent.productAdded(event.productId));
    });
  }
}
```

### Event Rules

- ✅ **DO**: Use direct subscription for parent-child
- ✅ **DO**: Use event bus for cross-feature communication
- ✅ **DO**: Cancel subscriptions in close()
- ❌ **DON'T**: Create tight coupling between features
- ❌ **DON'T**: Pass BLoCs through the widget tree

## Testing BLoCs

### Structure

```dart
@TestOn('vm')
import 'package:bloc_test/bloc_test.dart';

class MockUseCase extends Mock implements UseCase {}

void main() {
  late MockUseCase mockUseCase;
  late ProductBloc productBloc;
  
  setUp(() {
    mockUseCase = MockUseCase();
    productBloc = ProductBloc(mockUseCase);
  });
  
  tearDown(() {
    productBloc.close();
  });
  
  blocTest<ProductBloc, ProductState>(
    'emits [loading, success] when fetch succeeds',
    build: () {
      when(() => mockUseCase()).thenAnswer((_) async => Right(products));
      return productBloc;
    },
    act: (bloc) => bloc.add(const FetchProducts()),
    expect: () => [
      const ProductState.loading(),
      ProductState.success(products),
    ],
    verify: (_) {
      verify(() => mockUseCase()).called(1);
    },
  );
}
```

## Performance Tips

- Implement BLoC selector for partial rebuilds
- Use const constructors in events
- Avoid emitting duplicate states
- Debounce high-frequency events
- Use AsyncSnapshot builders for streams
