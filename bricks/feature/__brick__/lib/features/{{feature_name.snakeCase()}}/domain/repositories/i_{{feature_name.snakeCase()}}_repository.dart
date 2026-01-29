import 'package:starter_app/core/types/types.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';

/// Repository interface for {{feature_name.pascalCase()}} operations.
///
/// Defines the contract for all {{feature_name.snakeCase()}}-related data operations.
/// Implementation is in the infrastructure layer.
///
/// All methods return [Either<Failure, T>] for functional error handling.
abstract interface class I{{feature_name.pascalCase()}}Repository {
  /// Gets a {{feature_name.snakeCase()}} by ID.
  ///
  /// Returns:
  /// - [Right({{feature_name.pascalCase()}})] if found
  /// - [Left(Failure)] if not found or error
  FutureResult<{{feature_name.pascalCase()}}> getById({{feature_name.pascalCase()}}Id id);

  /// Gets all {{feature_name.snakeCase()}}s.
  ///
  /// Returns:
  /// - [Right(List<{{feature_name.pascalCase()}}>)] on success
  /// - [Left(Failure)] on error
  FutureResult<List<{{feature_name.pascalCase()}}>> getAll();

  // TODO: Add more repository methods as needed
  // FutureResult<{{feature_name.pascalCase()}}> create({{feature_name.pascalCase()}} entity);
  // FutureResult<{{feature_name.pascalCase()}}> update({{feature_name.pascalCase()}} entity);
  // FutureVoidResult delete({{feature_name.pascalCase()}}Id id);
}
