# Event-Driven Architecture (Domain Events)

This project uses a **Strict DDD** approach with an **Event Dispatcher** to decouple features and handle side effects.

## Why Use Domain Events?

1.  **Decoupling:** Feature A (Auth) doesn't need to know Feature B (Profile) exists.
2.  **Scalability:** You can add new features that react to existing events without changing old code.
3.  **Dumb UI:** The UI doesn't need to manually glue features together (e.g., `BlocListener` resetting 5 different blocs on logout).

## Architecture

*   **DomainEvent:** Base class for all events.
*   **IEventDispatcher:** Interface for the event bus.
*   **Publishing:** Use Cases or Domain Services dispatch events.
*   **Subscribing:** BLoCs or Application Services listen to events.

## 1. Defining Events

Define events in your feature's `domain/events/` folder. Group them by Aggregate.

```dart
// lib/features/auth/domain/events/auth_events.dart
import 'package:starter_app/core/domain/base/domain_event.dart';

class UserLoggedIn extends DomainEvent {
  final User user;
  const UserLoggedIn(this.user);
}

class UserLoggedOut extends DomainEvent {
  const UserLoggedOut();
}
```

## 2. Dispatching Events (Publishing)

Inject `IEventDispatcher` into your **Use Case** or **Domain Service**.

```dart
// lib/features/auth/application/usecases/login.dart
@injectable
class Login extends Command<AuthCredentials, User> {
  const Login(this._repository, this._eventDispatcher);

  final IAuthRepository _repository;
  final IEventDispatcher _eventDispatcher;

  @override
  FutureResult<User> call(AuthCredentials credentials) async {
    final result = await _repository.login(credentials);

    return result.map((user) {
      // ✅ Dispatch event on success
      _eventDispatcher.dispatch(UserLoggedIn(user));
      return user;
    });
  }
}
```

## 3. Listening to Events (Subscribing) in BLoC

Inject `IEventDispatcher` into your **BLoC** to react to cross-feature events.

**Pattern:** Listen to the global stream and filter by type.

```dart
// lib/features/profile/presentation/bloc/profile_bloc.dart
@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(
    this._getProfile,
    this._eventDispatcher, // Inject Dispatcher
  ) : super(const ProfileState.initial()) {
    
    // ... normal event handlers ...

    // ✅ Listen to Global Domain Events
    _setupEventListeners();
  }

  final IEventDispatcher _eventDispatcher;
  StreamSubscription? _eventSubscription;

  void _setupEventListeners() {
    _eventSubscription = _eventDispatcher.events.listen((event) {
      // Handle specific events
      if (event is UserLoggedOut) {
        add(const ProfileEvent.reset()); // React to Auth event
      } 
      else if (event is UserRegistered) {
        // Maybe preload profile?
        add(ProfileEvent.started(event.user.id));
      }
    });
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }
}
```

## 4. Best Practices

*   **Keep Events Simple:** Events should be immutable facts (past tense).
*   **Don't put Logic in Events:** Events hold data, they don't do work.
*   **UI Updates:** BLoCs listen to events -> Add internal BLoC Event -> Emit new State -> UI rebuilds.
*   **Avoid Loops:** Don't fire an event that triggers a listener that fires the *same* event.

## Summary Diagram

```text
[User Action] 
      │
      ▼
[AuthBloc] ──(call)──▶ [Login UseCase] ──(call)──▶ [AuthRepo]
                               │
                               ▼
                        [EventDispatcher] ◀── (dispatch UserLoggedIn)
                               │
          ┌────────────────────┼────────────────────┐
          │                    │                    │
          ▼                    ▼                    ▼
   [ProfileBloc]          [CartBloc]         [AnalyticsService]
   (clears cache)        (merges cart)          (logs event)
```
