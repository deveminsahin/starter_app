import 'package:injectable/injectable.dart';
import 'package:starter_app/core/error/exception_handler.dart';
import 'package:starter_app/core/infrastructure/base_repository.dart';
import 'package:starter_app/core/types/types.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{entity_name.snakeCase()}}.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/entities/{{entity_name.snakeCase()}}_id.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{name.snakeCase()}}_repository.dart';
// TODO: Import data source and exception mapper
// import 'package:starter_app/features/{{feature_name.snakeCase()}}/infrastructure/datasources/{{entity_name.snakeCase()}}_remote_data_source.dart';
// import 'package:starter_app/features/{{feature_name.snakeCase()}}/infrastructure/mappers/{{feature_name.snakeCase()}}_exception_mapper.dart';

/// Implementation of [I{{name.pascalCase()}}Repository].
///
/// Handles error mapping using exception mapper via [BaseRepository].
@LazySingleton(as: I{{name.pascalCase()}}Repository)
class {{name.pascalCase()}}RepositoryImpl extends BaseRepository
    implements I{{name.pascalCase()}}Repository {
  {{name.pascalCase()}}RepositoryImpl(
    // TODO: Inject data source
    // this._remoteDataSource,
    ExceptionHandler exceptionHandler,
    // TODO: Inject exception mapper
    // {{feature_name.pascalCase()}}ExceptionMapper failureMapper,
  ) : super(exceptionHandler, null /* failureMapper */);

  // TODO: Add data source dependency
  // final I{{entity_name.pascalCase()}}RemoteDataSource _remoteDataSource;

  @override
  FutureResult<{{entity_name.pascalCase()}}> getById({{entity_name.pascalCase()}}Id id) => execute(
    () async {
      // TODO: Implement using data source
      // final result = await _remoteDataSource.getById(id.value.value);
      // return result.toDomain();
      throw UnimplementedError('getById not implemented');
    },
  );

  @override
  FutureResult<List<{{entity_name.pascalCase()}}>> getAll() => execute(
    () async {
      // TODO: Implement using data source
      // final results = await _remoteDataSource.getAll();
      // return results.map((m) => m.toDomain()).toList();
      throw UnimplementedError('getAll not implemented');
    },
  );

  // TODO: Implement additional repository methods as needed
}
