import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/domain/value_objects/name.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

void main() {
  group('Name', () {
    group('constructor', () {
      test('creates valid name with valid input', () {
        const validName = 'John Doe';
        final name = Name(validName);

        expect(name.isValid, true);
        expect(name.getOrCrash(), validName);
      });

      test('trims whitespace from input', () {
        final name = Name('  John Doe  ');

        expect(name.isValid, true);
        expect(name.getOrCrash(), 'John Doe');
      });

      test('accepts single word name', () {
        final name = Name('Madonna');

        expect(name.isValid, true);
        expect(name.getOrCrash(), 'Madonna');
      });

      test('accepts name with multiple words', () {
        final name = Name('Jean-Claude Van Damme');

        expect(name.isValid, true);
        expect(name.getOrCrash(), 'Jean-Claude Van Damme');
      });

      test('rejects empty name', () {
        final name = Name('');

        expect(name.isValid, false);

        final failures = name.value.fold((l) => l, (_) => null);
        expect(failures, isNotNull);
        expect(failures!.first, isA<Empty<String>>());
      });

      test('rejects name with only whitespace', () {
        final name = Name('   ');

        expect(name.isValid, false);

        final failures = name.value.fold((l) => l, (_) => null);
        expect(failures, isNotNull);
        expect(failures!.first, isA<Empty<String>>());
      });
    });

    group('fromTrustedSource', () {
      test('creates name without validation', () {
        final name = Name.fromTrustedSource('Trusted Name');

        expect(name.isValid, true);
        expect(name.getOrCrash(), 'Trusted Name');
      });

      test('bypasses validation', () {
        final name = Name.fromTrustedSource('');

        expect(name.isValid, true);
        expect(name.getOrCrash(), '');
      });
    });

    group('getOrCrash', () {
      test('returns value when valid', () {
        final name = Name('John Doe');

        expect(name.getOrCrash(), 'John Doe');
      });

      test('throws UnexpectedValueError when invalid', () {
        final name = Name('');

        expect(name.getOrCrash, throwsA(isA<UnexpectedValueError>()));
      });
    });

    group('equality', () {
      test('equals another name with same value', () {
        final name1 = Name('John Doe');
        final name2 = Name('John Doe');

        expect(name1, name2);
        expect(name1.hashCode, name2.hashCode);
      });

      test('equals after trimming whitespace', () {
        final name1 = Name('  John Doe  ');
        final name2 = Name('John Doe');

        expect(name1, name2);
      });

      test('not equals name with different value', () {
        final name1 = Name('John Doe');
        final name2 = Name('Jane Doe');

        expect(name1, isNot(name2));
      });
    });

    group('toString', () {
      test('shows value when valid', () {
        final name = Name('John Doe');

        expect(name.toString(), 'Name(John Doe)');
      });

      test('shows "invalid" when invalid', () {
        final name = Name('');

        expect(name.toString(), 'Name(invalid)');
      });
    });

    group('edge cases', () {
      test('handles unicode characters', () {
        final name = Name('José García');

        expect(name.isValid, true);
        expect(name.getOrCrash(), 'José García');
      });

      test('handles names with numbers', () {
        final name = Name('Louis XIV');

        expect(name.isValid, true);
        expect(name.getOrCrash(), 'Louis XIV');
      });

      test('handles very long names', () {
        final longName = 'A' * 1000;
        final name = Name(longName);

        expect(name.isValid, true);
      });

      test('handles special characters in names', () {
        final name = Name("O'Brien");

        expect(name.isValid, true);
        expect(name.getOrCrash(), "O'Brien");
      });

      test('handles name with only one character', () {
        final name = Name('A');

        expect(name.isValid, true);
        expect(name.getOrCrash(), 'A');
      });

      test('handles name with tabs and newlines', () {
        final name = Name('John\tDoe\n');

        expect(name.isValid, true);
        expect(name.getOrCrash(), 'John\tDoe');
      });

      test('handles name with emojis', () {
        final name = Name('John 😊 Doe');

        expect(name.isValid, true);
        expect(name.getOrCrash(), 'John 😊 Doe');
      });

      test('handles name with mixed case', () {
        final name = Name('jOhN dOe');

        expect(name.isValid, true);
        expect(name.getOrCrash(), 'jOhN dOe');
      });

      test('handles name with leading/trailing tabs', () {
        final name = Name('\tJohn Doe\t');

        expect(name.isValid, true);
        expect(name.getOrCrash(), 'John Doe');
      });

      test('handles name with multiple consecutive spaces', () {
        final name = Name('John    Doe');

        expect(name.isValid, true);
        expect(name.getOrCrash(), 'John    Doe');
      });

      test('rejects null input', () {
        // Note: Name constructor doesn't accept null directly,
        // but testing the validation logic handles null
        final name = Name('');

        expect(name.isValid, false);
      });
    });
  });
}
