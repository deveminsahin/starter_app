# Presentation Layer Rules

## Core Principles

- Responsible for UI rendering and user interactions
- Delegates all logic to BLoCs and use cases
- Widgets should be dumb and focused on display
- State managed exclusively by BLoC/Cubit

## BLoC/Cubit Structure

### BLoC Implementation

**Example from auth feature:**

```dart
// lib/features/auth/presentation/bloc/auth_bloc.dart
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._checkUserExists,
    this._login,
    this._register,
    this._logout,
    this._getCurrentUser,
    this._watchAuthChanges,
    this._logger,
  ) : super(
        AuthState.initial(
          email: EmailAddress(''),
          isSubmitting: false,
          validation: FieldValidationState.initial(),
        ),
      ) {
    on<AuthWatchStarted>(_onAuthWatchStarted, transformer: restartable());
    on<AuthEmailSubmitted>(_onEmailSubmitted);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
  }

  final CheckUserExists _checkUserExists;
  final Login _login;
  final Register _register;
  final Logout _logout;
  final GetCurrentUser _getCurrentUser;
  final WatchAuthChanges _watchAuthChanges;
  final AppLogger _logger;

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    await state.mapOrNull(
      loginRequired: (s) async {
        final credentials = AuthCredentials(
          email: s.email,
          password: s.password,
        );

        emit(s.copyWith(isSubmitting: true, error: null));

        final result = await _login(credentials);

        result.fold(
          (failure) => emit(
            s.copyWith(
              isSubmitting: false,
              error: ErrorModel.fromFailure(failure),
            ),
          ),
          (user) => emit(AuthState.authenticated(user)),
        );
      },
    );
  }
}
```

### BLoC Rules

- ✅ **DO**: Use `@injectable` for dependency injection
- ✅ **DO**: Inject use cases, not repositories
- ✅ **DO**: Use event transformers (restartable, debounce, throttle) when needed
- ✅ **DO**: Keep event handlers private (`_onEventName`)
- ✅ **DO**: Use `freezed` for events and states
- ✅ **DO**: Use `mapOrNull` for state-specific event handling
- ✅ **DO**: Map Failure to ErrorModel in BLoC (presentation boundary)
- ✅ **DO**: Use `HydratedBloc` when state persistence is needed
- ❌ **DON'T**: Include business logic in BLoC
- ❌ **DON'T**: Access repositories directly
- ❌ **DON'T**: Let domain Failures leak into state (use ErrorModel)

## Events and States

### Event Structure

```dart
@freezed
class ProductListEvent with _$ProductListEvent {
  const factory ProductListEvent.fetchProducts({
    @Default(false) bool forceRefresh,
  }) = FetchProducts;
  
  const factory ProductListEvent.searchProducts(String query) = SearchProducts;
  
  const factory ProductListEvent.refreshProducts() = RefreshProducts;
}
```

### State Structure (Union Types)

**Example from auth feature:**

```dart
// lib/features/auth/presentation/bloc/auth_state.dart
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.initial({
    required EmailAddress email,
    required bool isSubmitting,
    required FieldValidationState validation,
    ErrorModel? error,
  }) = Initial;

  const factory AuthState.unauthenticated() = Unauthenticated;

  const factory AuthState.loginRequired({
    required EmailAddress email,
    required Password password,
    required bool isSubmitting,
    required FieldValidationState validation,
    ErrorModel? error,
  }) = LoginRequired;

  const factory AuthState.registrationRequired({
    required EmailAddress email,
    required Password password,
    required Name name,
    required bool isSubmitting,
    required FieldValidationState validation,
    ErrorModel? error,
  }) = RegistrationRequired;

  const factory AuthState.authenticated(User user) = Authenticated;
}
```

### Rules

- ✅ **DO**: Use union types for states (freezed sealed classes)
- ✅ **DO**: Name events as user actions: `EmailSubmitted`, `LoginSubmitted`
- ✅ **DO**: Make states exhaustive (cover all scenarios)
- ✅ **DO**: Include data in states (use value objects, not primitives)
- ✅ **DO**: Use `ErrorModel` for error states (not domain Failure)
- ✅ **DO**: Include loading flags (`isSubmitting`, `isLoading`)
- ❌ **DON'T**: Use nullable fields instead of union types
- ❌ **DON'T**: Include domain Failures in state
- ❌ **DON'T**: Combine unrelated states

## Pages

### Page Structure

```dart
class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProductListBloc>()
        ..add(const ProductListEvent.fetchProducts()),
      child: const ProductListView(),
    );
  }
}

class ProductListView extends StatelessWidget {
  const ProductListView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const LoadingIndicator(),
            success: (products) => ProductList(products: products),
            error: (failure) => ErrorView(failure: failure),
          );
        },
      ),
    );
  }
}
```

### Page Rules

- ✅ **DO**: Separate page (BlocProvider) from view (UI)
- ✅ **DO**: Trigger initial load in BlocProvider.create
- ✅ **DO**: Use `const` constructors everywhere possible
- ✅ **DO**: Keep pages as thin routing wrappers
- ✅ **DO**: Extract complex widgets into separate files
- ❌ **DON'T**: Include business logic in pages
- ❌ **DON'T**: Create BLoCs inside widgets manually
- ❌ **DON'T**: Use StatefulWidget unless absolutely necessary

## Widgets

### Widget Structure

```dart
class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    this.onTap,
    super.key,
  });
  
  final Product product;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: product.imageUrl,
              memCacheHeight: 300,
              memCacheWidth: 300,
            ),
            Text(product.name),
            Text('\$${product.price}'),
          ],
        ),
      ),
    );
  }
}
```

### Widget Rules

- ✅ **DO**: Make widgets pure and reusable
- ✅ **DO**: Accept callbacks for interactions
- ✅ **DO**: Use domain entities, not DTOs
- ✅ **DO**: Implement keys for list items
- ✅ **DO**: Use const constructors
- ✅ **DO**: Extract repeated UI into widgets
- ❌ **DON'T**: Access BLoC directly in reusable widgets
- ❌ **DON'T**: Perform logic in build methods
- ❌ **DON'T**: Create widgets inside build methods (use const)

## BLoC Listeners

### Error Handling

```dart
BlocListener<ProductListBloc, ProductListState>(
  listener: (context, state) {
    state.whenOrNull(
      error: (failure) {
        // Use FailureMessageService for localized messages
        final messageService = context.read<FailureMessageService>();
        final message = messageService.getLocalizedMessage(context, failure);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  },
  child: BlocBuilder<ProductListBloc, ProductListState>(
    builder: (context, state) {
      // Build UI
    },
  ),
)
```

### BLoC Listener Rules

- ✅ **DO**: Use BlocListener for side effects (navigation, snackbars)
- ✅ **DO**: Use BlocBuilder for UI updates
- ✅ **DO**: Use BlocConsumer when you need both
- ❌ **DON'T**: Navigate or show dialogs in BlocBuilder

## Folder Structure

**Example from auth feature:**

```text
presentation/
├── bloc/
│   ├── auth_bloc.dart              # BLoC implementation
│   ├── auth_event.dart             # Events (freezed)
│   ├── auth_state.dart             # States (freezed union)
│   └── field_validation_state.dart # Validation tracking
├── extensions/                     # Feature-specific context extensions
│   └── auth_extensions.dart        # e.g., context.isAuthenticated
├── failure_message/
│   └── auth_failure_mapper.dart    # Maps AuthFailure → localized messages
├── pages/
│   └── auth_page.dart              # Main auth page
├── routes/
│   └── auth_routes.dart            # GoRouter route declarations
└── widgets/
    ├── email_text_field.dart       # Email input widget
    ├── password_text_field.dart    # Password input widget
    └── app_text_field.dart         # Generic text field
```

## Widget Best Practices

### Composition Over Inheritance

Favor composing smaller widgets over extending existing ones:

```dart
// ❌ BAD - Extending a widget
class CustomButton extends ElevatedButton {
  // Extending can lead to complex inheritance issues
}

// ✅ GOOD - Composition
class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: _customStyle(context),
      child: child,
    );
  }
}
```

### Private Widget Classes Over Helper Methods

Use small, private `Widget` classes instead of methods that return widgets:

```dart
// ❌ BAD - Helper method (recreates widget on every build)
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(), // Recreated on every rebuild
        _buildBody(),
      ],
    );
  }

  Widget _buildHeader() => const Text('Header');
  Widget _buildBody() => const Text('Body');
}

// ✅ GOOD - Private widget classes (can be const)
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _Header(), // Const widget - reused
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

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) => const Text('Body');
}
```

### Const Constructors

Use `const` constructors aggressively to enable widget reuse:

```dart
// ✅ GOOD - Widget can be const
class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16), // const EdgeInsets
      child: Text('Static text'), // const Text
    );
  }
}
```

### Build Method Performance

Avoid expensive operations directly in `build()` methods:

```dart
// ❌ BAD - Expensive operation in build
@override
Widget build(BuildContext context) {
  final products = json.decode(productData); // SLOW!
  return ListView(children: ...);
}

// ✅ GOOD - Compute outside build, trigger with events
@override
Widget build(BuildContext context) {
  return BlocBuilder<ProductBloc, ProductState>(
    builder: (context, state) {
      // Products already parsed by BLoC
      return ListView(children: ...);
    },
  );
}
```

### Widget Rules Summary

- ✅ **DO**: Use composition over inheritance
- ✅ **DO**: Extract private Widget classes for reusable parts
- ✅ **DO**: Use `const` constructors wherever possible
- ✅ **DO**: Keep widget trees relatively shallow
- ✅ **DO**: Use `RepaintBoundary` for complex widgets
- ✅ **DO**: Implement `AutomaticKeepAliveClientMixin` for tabs
- ✅ **DO**: Use proper keys for list items
- ❌ **DON'T**: Use helper methods that return widgets
- ❌ **DON'T**: Perform expensive operations in build()
- ❌ **DON'T**: Create widgets inside build methods
- ❌ **DON'T**: Deeply nest widgets unnecessarily

