import 'package:injectable/injectable.dart';
import 'package:starter_app/core/error/exception_handler.dart';
import 'package:starter_app/core/infrastructure/base_repository.dart';
import 'package:starter_app/core/types/types.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}_id.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{feature_name.snakeCase()}}_repository.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/infrastructure/datasources/{{feature_name.snakeCase()}}_remote_data_source.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/infrastructure/mappers/{{feature_name.snakeCase()}}_exception_mapper.dart';

/// Implementation of [I{{feature_name.pascalCase()}}Repository].
///
/// Handles error mapping using [{{feature_name.pascalCase()}}ExceptionMapper] via [BaseRepository].
@LazySingleton(as: I{{feature_name.pascalCase()}}Repository)
class {{feature_name.pascalCase()}}RepositoryImpl extends BaseRepository
    implements I{{feature_name.pascalCase()}}Repository {
  {{feature_name.pascalCase()}}RepositoryImpl(
    this._remoteDataSource,
    ExceptionHandler exceptionHandler,
    {{feature_name.pascalCase()}}ExceptionMapper failureMapper,
  ) : super(exceptionHandler, failureMapper);

  final I{{feature_name.pascalCase()}}RemoteDataSource _remoteDataSource;

  @override
  FutureResult<{{feature_name.pascalCase()}}> getById({{feature_name.pascalCase()}}Id id) => execute(
    () async {
      final result = await _remoteDataSource.getById(id.value.value);
      return result.toDomain();
    },
  );

  @override
  FutureResult<List<{{feature_name.pascalCase()}}>> getAll() => execute(
    () async {
      final results = await _remoteDataSource.getAll();
      return results.map((m) => m.toDomain()).toList();
    },
  );

  // TODO: Implement additional repository methods as needed
}
