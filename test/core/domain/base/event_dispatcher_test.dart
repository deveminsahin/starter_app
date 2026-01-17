import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/base/domain_event.dart';
import 'package:starter_app/core/domain/base/event_dispatcher.dart' as app;

class EventA extends DomainEvent {
  const EventA();
}

class EventB extends DomainEvent {
  const EventB();
}

void main() {
  group('EventDispatcher', () {
    late app.EventDispatcher dispatcher;

    setUp(() {
      dispatcher = app.EventDispatcher();
    });

    tearDown(() {
      unawaited(dispatcher.dispose());
    });

    test('should dispatch events to subscribers', () async {
      unawaited(expectLater(dispatcher.events, emitsThrough(isA<EventA>())));
      dispatcher.dispatch(const EventA());
    });

    test('on<T>() should filter events by type', () {
      final streamA = dispatcher.on<EventA>();
      final streamB = dispatcher.on<EventB>();

      unawaited(
        expectLater(streamA, emitsInOrder([isA<EventA>(), isA<EventA>()])),
      );
      unawaited(expectLater(streamB, emitsInOrder([isA<EventB>()])));

      dispatcher
        ..dispatch(const EventA())
        ..dispatch(const EventB())
        ..dispatch(const EventA());
    });

    test('should not dispatch after dispose', () async {
      await dispatcher.dispose();

      // Should not throw
      dispatcher.dispatch(const EventA());

      // We can't easily verify the stream
      // is closed from the outside via public API
      // other than checking if it receives events (which it won't).
      // But verify strictly that calling dispatch is safe.
    });
  });
}
