import 'package:injectable/injectable.dart';
{{#type_command}}
import 'package:starter_app/core/domain/base/command.dart';
{{/type_command}}{{#type_query}}
import 'package:starter_app/core/domain/base/query.dart';
{{/type_query}}{{#type_command_no_params}}
import 'package:starter_app/core/domain/base/command.dart';
{{/type_command_no_params}}{{#type_query_no_params}}
import 'package:starter_app/core/domain/base/query.dart';
{{/type_query_no_params}}
import 'package:starter_app/core/types/types.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{feature_name.snakeCase()}}_repository.dart';

/// {{#type_command}}Command{{/type_command}}{{#type_query}}Query{{/type_query}}{{#type_command_no_params}}Command{{/type_command_no_params}}{{#type_query_no_params}}Query{{/type_query_no_params}} for {{name.sentenceCase()}}.
///
{{#type_command}}
/// This is a **write operation** (Command) that mutates application state.
{{/type_command}}{{#type_query}}
/// This is a **read operation** (Query) that doesn't mutate application state.
{{/type_query}}{{#type_command_no_params}}
/// This is a **write operation** (Command) without parameters that mutates application state.
{{/type_command_no_params}}{{#type_query_no_params}}
/// This is a **read operation** (Query) without parameters that doesn't mutate application state.
{{/type_query_no_params}}
///
/// Follows CQRS pattern (ADR-010).
@injectable
{{#type_command}}
final class {{name.pascalCase()}} extends Command<{{params_type}}, {{output_type}}> {
{{/type_command}}{{#type_query}}
final class {{name.pascalCase()}} extends Query<{{params_type}}, {{output_type}}> {
{{/type_query}}{{#type_command_no_params}}
final class {{name.pascalCase()}} extends CommandNoParams<{{output_type}}> {
{{/type_command_no_params}}{{#type_query_no_params}}
final class {{name.pascalCase()}} extends QueryNoParams<{{output_type}}> {
{{/type_query_no_params}}
  const {{name.pascalCase()}}(this._repository);

  final I{{feature_name.pascalCase()}}Repository _repository;

{{#type_command}}
  @override
  FutureResult<{{output_type}}> call({{params_type}} params) async {
    // TODO: Implement command logic
    return _repository.getById(params);
  }
{{/type_command}}{{#type_query}}
  @override
  FutureResult<{{output_type}}> call({{params_type}} params) async {
    // TODO: Implement query logic
    return _repository.getById(params);
  }
{{/type_query}}{{#type_command_no_params}}
  @override
  FutureResult<{{output_type}}> call() async {
    // TODO: Implement command logic
    return _repository.getAll();
  }
{{/type_command_no_params}}{{#type_query_no_params}}
  @override
  FutureResult<{{output_type}}> call() async {
    // TODO: Implement query logic
    return _repository.getAll();
  }
{{/type_query_no_params}}
}
