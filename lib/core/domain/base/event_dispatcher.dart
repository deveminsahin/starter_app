import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:starter_app/core/domain/base/domain_event.dart';

/// Interface for dispatching domain events.
abstract interface class IEventDispatcher {
  /// Dispatches an event to all registered listeners.
  void dispatch(DomainEvent event);

  /// Stream of all events occurring in the system.
  Stream<DomainEvent> get events;

  /// Returns a stream of events filtered by type [T].
  ///
  /// Usage:
  /// ```dart
  /// dispatcher.on<UserLoggedIn>().listen((event) {
  ///   print('User logged in: ${event.user.id}');
  /// });
  /// ```
  Stream<T> on<T extends DomainEvent>();

  /// Disposes resources.
  Future<void> dispose();
}

/// Implementation of [IEventDispatcher] using a broadcast StreamController.
///
/// This acts as a simple in-memory Event Bus.
@LazySingleton(as: IEventDispatcher)
class EventDispatcher implements IEventDispatcher {
  final _controller = StreamController<DomainEvent>.broadcast();

  @override
  void dispatch(DomainEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  @override
  Stream<DomainEvent> get events => _controller.stream;

  @override
  Stream<T> on<T extends DomainEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  @override
  @disposeMethod
  Future<void> dispose() async {
    await _controller.close();
  }
}
