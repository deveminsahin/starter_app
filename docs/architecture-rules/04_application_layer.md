# Application Layer Rules

## Core Principles

- Orchestrates business workflows
- Acts as the boundary between Presentation and Domain
- Contains no business logic (that's in Domain)
- Contains no UI logic (that's in Presentation)

## CQRS Pattern (Command Query Responsibility Segregation)

This architecture follows the **CQRS pattern** to clearly separate read and write operations:

- **Commands**: Write operations that mutate application state
- **Queries**: Read operations that don't mutate state

This separation provides:

- **Semantic clarity (read vs write)**
- **Better code organization**
- **Foundation for future optimizations** (different caching strategies, etc.)
- **Improved testability** (clear intent in tests)

### When to Use Commands vs Queries

**Use Commands for:**

- Creating, updating, or deleting entities
- Authenticating users
- Processing payments
- Any operation that changes application state

**Use Queries for:**

- Fetching data
- Checking existence
- Getting current state
- Any operation that only reads data

## Use Cases (Interactors)

### Definition

- Single-purpose application operations
- Coordinate domain entities and repository operations
- One public method: `call()`

### Structure

**Command Example (Write Operation):**

```dart
// lib/features/auth/application/usecases/login.dart
@injectable
class Login extends Command<AuthCredentials, User> {
  const Login(this._repository);

  final IAuthRepository _repository;

  /// Authenticates user with provided credentials.
  @override
  FutureResult<User> call(AuthCredentials credentials) async {
    return _repository.login(credentials);
  }
}
```

**Query Example (Read Operation):**

```dart
// lib/features/auth/application/usecases/get_current_user.dart
@injectable
class GetCurrentUser extends QueryNoParams<User?> {
  const GetCurrentUser(this._repository);

  final IAuthRepository _repository;

  /// Gets the currently authenticated user.
  @override
  FutureResult<User?> call() async {
    return _repository.getCurrentUser();
  }
}
```

### Rules

- ✅ **DO**: Use `@injectable` annotation for DI
- ✅ **DO**: Use `Command<Params, Output>` for write operations
- ✅ **DO**: Use `Query<Params, Output>` for read operations
- ✅ **DO**: Use `CommandNoParams<Output>` for write operations without parameters
- ✅ **DO**: Use `QueryNoParams<Output>` for read operations without parameters
- ✅ **DO**: Use `StreamCommand`/`StreamQuery` for reactive operations
- ✅ **DO**: Inject repository interfaces (ports), not implementations
- ✅ **DO**: Name as imperative actions: `Login`, `Register`, `CheckUserExists`
- ✅ **DO**: Keep use cases focused (Single Responsibility)
- ✅ **DO**: Return `FutureResult<T>` (alias for `Future<Either<Failure, T>>`)
- ✅ **DO**: Make the class callable with `call()` method
- ✅ **DO**: Use const constructor when possible
- ❌ **DON'T**: Include business logic (that's Domain's job)
- ❌ **DON'T**: Include UI logic or state management
- ❌ **DON'T**: Depend on infrastructure implementations directly
- ❌ **DON'T**: Use `UseCase` for new code (use `Command` or `Query` instead)

## Complex Use Cases

### When Multiple Operations Required

```dart
@injectable
class ProcessOrder {
  final IOrderRepository _orderRepository;
  final IInventoryRepository _inventoryRepository;
  final IPaymentService _paymentService;
  
  ProcessOrder(
    this._orderRepository,
    this._inventoryRepository,
    this._paymentService,
  );
  
  Future<Either<Failure, Order>> call({
    required String userId,
    required List<OrderItem> items,
    required PaymentMethod paymentMethod,
  }) async {
    // Step 1: Check inventory
    final inventoryResult = await _inventoryRepository.checkAvailability(items);
    if (inventoryResult.isLeft()) return inventoryResult.leftMap((f) => f);
    
    // Step 2: Create order
    final order = Order.create(userId: userId, items: items);
    final orderResult = await _orderRepository.save(order);
    if (orderResult.isLeft()) return orderResult;
    
    // Step 3: Process payment
    final paymentResult = await _paymentService.charge(
      amount: order.total,
      method: paymentMethod,
    );
    if (paymentResult.isLeft()) {
      // Compensating transaction
      await _orderRepository.markAsFailed(order.id);
      return paymentResult;
    }
    
    // Step 4: Update order status
    return _orderRepository.markAsPaid(order.id);
  }
}
```

### Rules for Complex Use Cases

- ✅ **DO**: Coordinate multiple repositories
- ✅ **DO**: Handle compensation logic for failures
- ✅ **DO**: Keep transaction boundaries clear
- ✅ **DO**: Fail fast and propagate errors
- ❌ **DON'T**: Mix business rules with coordination logic

## Validation

### Input Validation

- Use Value Objects for input validation
- Return validation failures as `Left(ValidationFailure)`

```dart
@injectable
class CreateProduct {
  final IProductRepository _repository;
  
  CreateProduct(this._repository);
  
  Future<Either<Failure, Product>> call({
    required String name,
    required String priceString,
  }) async {
    // Validate inputs using Value Objects
    final price = Price(priceString);
    if (!price.isValid) {
      return Left(Failure.validation(
        errors: [price.value.fold((f) => f, (_) => null)].whereType<ValueFailure>().toList(),
      ));
    }
    
    final product = Product(
      id: generateId(),
      name: name,
      price: price.getOrCrash(),
    );
    
    return _repository.save(product);
  }
}
```

## Folder Structure

**Example from auth feature:**

```text
application/
└── usecases/
    ├── check_user_exists.dart    # Check if email is registered
    ├── login.dart                # Authenticate user
    ├── register.dart             # Create new account
    ├── logout.dart               # End session
    ├── get_current_user.dart     # Get authenticated user
    ├── refresh_token.dart        # Refresh expired token
    └── watch_auth_changes.dart   # Stream auth state changes
```

## Testing

**Example test structure:**

```dart
void main() {
  late MockAuthRepository mockRepository;
  late Login login;

  setUp(() {
    mockRepository = MockAuthRepository();
    login = Login(mockRepository);
  });

  test('should return User when repository login succeeds', () async {
    // Arrange
    final credentials = AuthCredentials(/*...*/);
    final expectedUser = User(/*...*/);
    when(() => mockRepository.login(credentials))
        .thenAnswer((_) async => right(expectedUser));

    // Act
    final result = await login(credentials);

    // Assert
    expect(result, right(expectedUser));
    verify(() => mockRepository.login(credentials)).called(1);
  });

  test('should return Failure when repository login fails', () async {
    // Arrange
    final credentials = AuthCredentials(/*...*/);
    final failure = AuthFailure.unauthorized(message: 'Invalid credentials');
    when(() => mockRepository.login(credentials))
        .thenAnswer((_) async => left(failure));

    // Act
    final result = await login(credentials);

    // Assert
    expect(result, left(failure));
  });
}
```

**Rules:**

- Mock repository interfaces using mocktail
- Test business workflow orchestration
- Verify error handling paths
- Test both success and failure scenarios
- Target 100% coverage
