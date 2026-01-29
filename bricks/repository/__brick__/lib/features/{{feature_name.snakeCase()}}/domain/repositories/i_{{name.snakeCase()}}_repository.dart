import 'package:starter_app/core/types/types.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{entity_name.snakeCase()}}.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{entity_name.snakeCase()}}_id.dart';

/// Repository interface for {{name.pascalCase()}} operations.
///
/// Defines the contract for {{name.snakeCase()}}-related data operations.
/// Implementation is in the infrastructure layer.
///
/// All methods return [Either<Failure, T>] for functional error handling.
abstract interface class I{{name.pascalCase()}}Repository {
  /// Gets a {{entity_name.snakeCase()}} by ID.
  ///
  /// Returns:
  /// - [Right({{entity_name.pascalCase()}})] if found
  /// - [Left(Failure)] if not found or error
  FutureResult<{{entity_name.pascalCase()}}> getById({{entity_name.pascalCase()}}Id id);

  /// Gets all {{entity_name.snakeCase()}}s.
  ///
  /// Returns:
  /// - [Right(List<{{entity_name.pascalCase()}}>)] on success
  /// - [Left(Failure)] on error
  FutureResult<List<{{entity_name.pascalCase()}}>> getAll();

  // TODO: Add more repository methods as needed
  // FutureResult<{{entity_name.pascalCase()}}> create({{entity_name.pascalCase()}} entity);
  // FutureResult<{{entity_name.pascalCase()}}> update({{entity_name.pascalCase()}} entity);
  // FutureVoidResult delete({{entity_name.pascalCase()}}Id id);
}
