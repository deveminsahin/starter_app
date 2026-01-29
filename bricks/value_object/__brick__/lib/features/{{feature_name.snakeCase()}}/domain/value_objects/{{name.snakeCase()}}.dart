import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

import 'package:starter_app/core/domain/base/value_object.dart';
import 'package:starter_app/core/error/failures/value_failure.dart';

/// {{name.pascalCase()}} value object.
///
/// Encapsulates validation rules for {{name.snakeCase()}} values.
/// Invalid states are unrepresentable - validation happens at construction.
@immutable
final class {{name.pascalCase()}} extends ValueObject<{{value_type}}> {
  const {{name.pascalCase()}}._(this.value);

  /// Creates a [{{name.pascalCase()}}] with validation.
  factory {{name.pascalCase()}}({{value_type}} input) {
    return {{name.pascalCase()}}._(validate(input));
  }

  @override
  final Either<List<ValueFailure<{{value_type}}>>, {{value_type}}> value;

  /// Validates the input and returns either failures or the valid value.
  static Either<List<ValueFailure<{{value_type}}>>, {{value_type}}> validate(
    {{value_type}} input,
  ) {
    final failures = <ValueFailure<{{value_type}}>>[];

    // TODO: Add validation rules
    {{#value_type_String}}
    // Example validations for String:
    if (input.isEmpty) {
      failures.add(
        const ValueFailure.empty(fieldName: '{{name.titleCase()}}'),
      );
    }
    // if (input.length < minLength) {
    //   failures.add(
    //     ValueFailure.tooShort(
    //       fieldName: '{{name.titleCase()}}',
    //       minLength: minLength,
    //     ),
    //   );
    // }
    // if (!_regex.hasMatch(input)) {
    //   failures.add(
    //     ValueFailure.invalidFormat(
    //       expectedFormat: 'Expected format description',
    //       failedValue: input,
    //     ),
    //   );
    // }
    {{/value_type_String}}{{#value_type_int}}
    // Example validations for int:
    // if (input < 0) {
    //   failures.add(
    //     ValueFailure.outOfRange(
    //       fieldName: '{{name.titleCase()}}',
    //       min: 0,
    //       max: maxValue,
    //       failedValue: input,
    //     ),
    //   );
    // }
    {{/value_type_int}}{{#value_type_double}}
    // Example validations for double:
    // if (input < 0) {
    //   failures.add(
    //     ValueFailure.outOfRange(
    //       fieldName: '{{name.titleCase()}}',
    //       min: 0,
    //       max: maxValue,
    //       failedValue: input,
    //     ),
    //   );
    // }
    {{/value_type_double}}

    if (failures.isNotEmpty) {
      return Left(failures);
    }
    return Right(input);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is {{name.pascalCase()}} &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '{{name.pascalCase()}}($value)';
}
