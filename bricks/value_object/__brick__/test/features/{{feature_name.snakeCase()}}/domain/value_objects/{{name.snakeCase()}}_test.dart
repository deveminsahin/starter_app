import 'package:flutter_test/flutter_test.dart';

import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/value_objects/{{name.snakeCase()}}.dart';

void main() {
  group('{{name.pascalCase()}}', () {
    group('validation', () {
      test('should be valid with correct input', () {
        // TODO: Use valid input for your value type
        {{#value_type_String}}
        const validInput = 'valid value';
        {{/value_type_String}}{{#value_type_int}}
        const validInput = 42;
        {{/value_type_int}}{{#value_type_double}}
        const validInput = 42.5;
        {{/value_type_double}}
        
        final valueObject = {{name.pascalCase()}}(validInput);
        
        expect(valueObject.isValid, isTrue);
        expect(valueObject.getOrCrash(), validInput);
      });

      {{#value_type_String}}
      test('should be invalid when empty', () {
        final valueObject = {{name.pascalCase()}}('');
        
        expect(valueObject.isValid, isFalse);
        expect(valueObject.getFailuresOrNull(), isNotNull);
      });
      {{/value_type_String}}

      // TODO: Add more validation tests based on your rules
    });

    group('equality', () {
      test('should be equal with same value', () {
        {{#value_type_String}}
        const value = 'test value';
        {{/value_type_String}}{{#value_type_int}}
        const value = 42;
        {{/value_type_int}}{{#value_type_double}}
        const value = 42.5;
        {{/value_type_double}}
        
        final vo1 = {{name.pascalCase()}}(value);
        final vo2 = {{name.pascalCase()}}(value);
        
        expect(vo1, vo2);
      });

      test('should not be equal with different value', () {
        {{#value_type_String}}
        final vo1 = {{name.pascalCase()}}('value1');
        final vo2 = {{name.pascalCase()}}('value2');
        {{/value_type_String}}{{#value_type_int}}
        final vo1 = {{name.pascalCase()}}(1);
        final vo2 = {{name.pascalCase()}}(2);
        {{/value_type_int}}{{#value_type_double}}
        final vo1 = {{name.pascalCase()}}(1.0);
        final vo2 = {{name.pascalCase()}}(2.0);
        {{/value_type_double}}
        
        expect(vo1, isNot(vo2));
      });
    });

    group('getOrCrash', () {
      test('should return value when valid', () {
        {{#value_type_String}}
        const value = 'test value';
        {{/value_type_String}}{{#value_type_int}}
        const value = 42;
        {{/value_type_int}}{{#value_type_double}}
        const value = 42.5;
        {{/value_type_double}}
        
        final valueObject = {{name.pascalCase()}}(value);
        
        expect(valueObject.getOrCrash(), value);
      });

      test('should throw when invalid', () {
        {{#value_type_String}}
        final valueObject = {{name.pascalCase()}}('');
        {{/value_type_String}}{{#value_type_int}}
        // TODO: Use invalid input for your validation rules
        final valueObject = {{name.pascalCase()}}(-1);
        {{/value_type_int}}{{#value_type_double}}
        // TODO: Use invalid input for your validation rules
        final valueObject = {{name.pascalCase()}}(-1.0);
        {{/value_type_double}}
        
        expect(() => valueObject.getOrCrash(), throwsA(isA<Error>()));
      });
    });

    group('getOrNull', () {
      test('should return value when valid', () {
        {{#value_type_String}}
        const value = 'test value';
        {{/value_type_String}}{{#value_type_int}}
        const value = 42;
        {{/value_type_int}}{{#value_type_double}}
        const value = 42.5;
        {{/value_type_double}}
        
        final valueObject = {{name.pascalCase()}}(value);
        
        expect(valueObject.getOrNull(), value);
      });

      test('should return null when invalid', () {
        {{#value_type_String}}
        final valueObject = {{name.pascalCase()}}('');
        {{/value_type_String}}{{#value_type_int}}
        // TODO: Use invalid input for your validation rules
        final valueObject = {{name.pascalCase()}}(-1);
        {{/value_type_int}}{{#value_type_double}}
        // TODO: Use invalid input for your validation rules
        final valueObject = {{name.pascalCase()}}(-1.0);
        {{/value_type_double}}
        
        expect(valueObject.getOrNull(), isNull);
      });
    });
  });
}
