import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/base/aggregate_root.dart';
import 'package:starter_app/core/domain/base/domain_event.dart';
import 'package:starter_app/core/domain/base/unique_id.dart';

class TestDomainEvent extends DomainEvent {
  const TestDomainEvent();
}

class TestAggregateRoot extends AggregateRoot {
  TestAggregateRoot(this.id);

  @override
  final UniqueId id;

  void doSomething() {
    addDomainEvent(const TestDomainEvent());
  }
}

void main() {
  group('AggregateRoot', () {
    test('should start with no domain events', () {
      final aggregate = TestAggregateRoot(UniqueId.generate());
      expect(aggregate.domainEvents, isEmpty);
    });

    test('should add domain event', () {
      final aggregate = TestAggregateRoot(UniqueId.generate())..doSomething();
      expect(aggregate.domainEvents, hasLength(1));
      expect(aggregate.domainEvents.first, isA<TestDomainEvent>());
    });

    test('should clear domain events', () {
      final aggregate = TestAggregateRoot(UniqueId.generate())..doSomething();
      expect(aggregate.domainEvents, isNotEmpty);

      aggregate.clearDomainEvents();
      expect(aggregate.domainEvents, isEmpty);
    });

    test('domainEvents list should be unmodifiable', () {
      final aggregate = TestAggregateRoot(UniqueId.generate())..doSomething();

      expect(
        () => (aggregate.domainEvents as List).add(const TestDomainEvent()),
        throwsUnsupportedError,
      );
    });
  });
}
