import 'package:flutter_test/flutter_test.dart';

import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{name.snakeCase()}}.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{name.snakeCase()}}_id.dart';

void main() {
  group('{{name.pascalCase()}}', () {
    late {{name.pascalCase()}} entity;
    late {{name.pascalCase()}}Id id;

    setUp(() {
      id = {{name.pascalCase()}}Id.generate();
      entity = {{name.pascalCase()}}(
        id: id,
        // TODO: Add test properties
      );
    });

    test('should create entity with given id', () {
      expect(entity.id, id);
    });

    test('entities with same id should be equal', () {
      final entity2 = {{name.pascalCase()}}(
        id: id,
        // TODO: Add test properties with different values
      );
      expect(entity, entity2);
    });

    test('entities with different ids should not be equal', () {
      final entity2 = {{name.pascalCase()}}(
        id: {{name.pascalCase()}}Id.generate(),
        // TODO: Add test properties
      );
      expect(entity, isNot(entity2));
    });

    test('copyWith should create copy with new values', () {
      final newId = {{name.pascalCase()}}Id.generate();
      final copied = entity.copyWith(id: newId);

      expect(copied.id, newId);
      expect(copied, isNot(same(entity)));
    });

{{#is_aggregate_root}}
    group('domain events', () {
      test('should have empty domain events initially', () {
        expect(entity.domainEvents, isEmpty);
      });

      // TODO: Add tests for business methods that emit domain events
    });
{{/is_aggregate_root}}
  });

  group('{{name.pascalCase()}}Id', () {
    test('generate should create unique ids', () {
      final id1 = {{name.pascalCase()}}Id.generate();
      final id2 = {{name.pascalCase()}}Id.generate();

      expect(id1, isNot(id2));
    });

    test('fromString should create id with given value', () {
      const value = 'test-id-123';
      final id = {{name.pascalCase()}}Id.fromString(value);

      expect(id.value, value);
    });

    test('ids with same value should be equal', () {
      const value = 'same-id';
      final id1 = {{name.pascalCase()}}Id.fromString(value);
      final id2 = {{name.pascalCase()}}Id.fromString(value);

      expect(id1, id2);
    });
  });
}
