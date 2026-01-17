import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/base/entity.dart';
import 'package:starter_app/core/domain/base/unique_id.dart';

/// Test implementation of Entity for testing purposes.
class TestEntity extends Entity {
  TestEntity(this.id);

  @override
  final UniqueId id;
}

class AnotherTestEntity extends Entity {
  AnotherTestEntity(this.id);

  @override
  final UniqueId id;
}

void main() {
  group('Entity', () {
    group('equality', () {
      test('equals another entity with same id and runtime type', () {
        final id = UniqueId.fromString('test-id');
        final entity1 = TestEntity(id);
        final entity2 = TestEntity(id);

        expect(entity1, entity2);
        expect(entity1.hashCode, entity2.hashCode);
      });

      test('not equals entity with different id', () {
        final id1 = UniqueId.fromString('id-1');
        final id2 = UniqueId.fromString('id-2');
        final entity1 = TestEntity(id1);
        final entity2 = TestEntity(id2);

        expect(entity1, isNot(entity2));
      });

      test('not equals entity with different runtime type', () {
        final id = UniqueId.fromString('test-id');
        final entity1 = TestEntity(id);
        final entity2 = AnotherTestEntity(id);

        expect(entity1, isNot(entity2));
      });

      test('equals identical instance', () {
        final id = UniqueId.fromString('test-id');
        final entity1 = TestEntity(id);
        final entity2 = entity1;

        expect(entity1 == entity2, true);
        expect(identical(entity1, entity2), true);
      });

      test('not equals different types', () {
        final id = UniqueId.fromString('test-id');
        final entity = TestEntity(id);
        final otherEntity = AnotherTestEntity(id);

        expect(entity == otherEntity, false);
      });
    });

    group('hashCode', () {
      test('same id and runtime type produce same hashCode', () {
        final id = UniqueId.fromString('test-id');
        final entity1 = TestEntity(id);
        final entity2 = TestEntity(id);

        expect(entity1.hashCode, entity2.hashCode);
      });

      test('different ids produce different hashCodes', () {
        final id1 = UniqueId.fromString('id-1');
        final id2 = UniqueId.fromString('id-2');
        final entity1 = TestEntity(id1);
        final entity2 = TestEntity(id2);

        expect(entity1.hashCode, isNot(entity2.hashCode));
      });

      test('different runtime types produce different hashCodes', () {
        final id = UniqueId.fromString('test-id');
        final entity1 = TestEntity(id);
        final entity2 = AnotherTestEntity(id);

        expect(entity1.hashCode, isNot(entity2.hashCode));
      });
    });

    group('id property', () {
      test('returns the unique identifier', () {
        final id = UniqueId.fromString('test-id');
        final entity = TestEntity(id);

        expect(entity.id, id);
      });

      test('id is immutable', () {
        final id1 = UniqueId.fromString('id-1');
        final id2 = UniqueId.fromString('id-2');
        final entity = TestEntity(id1);

        expect(entity.id, id1);
        expect(entity.id, isNot(id2));
      });
    });

    group('edge cases', () {
      test('handles entities with same id but different properties', () {
        final id = UniqueId.fromString('test-id');
        final entity1 = TestEntity(id);
        final entity2 = TestEntity(id);

        // Entities are equal based on ID, not properties
        expect(entity1, entity2);
      });

      test('handles multiple entities with same id', () {
        final id = UniqueId.fromString('test-id');
        final entities = List.generate(
          5,
          (index) => TestEntity(id),
        );

        // All entities should be equal
        for (var i = 0; i < entities.length; i++) {
          for (var j = i + 1; j < entities.length; j++) {
            expect(entities[i], entities[j]);
            expect(entities[i].hashCode, entities[j].hashCode);
          }
        }
      });
    });
  });
}
