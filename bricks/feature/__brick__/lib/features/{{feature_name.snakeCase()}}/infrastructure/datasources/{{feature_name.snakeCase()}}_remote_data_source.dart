import 'package:injectable/injectable.dart';
import 'package:starter_app/core/api/extensions/response_extensions.dart';
import 'package:starter_app/core/infrastructure/base_remote_data_source.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/infrastructure/datasources/{{feature_name.snakeCase()}}_api_service.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/infrastructure/models/{{feature_name.snakeCase()}}_model.dart';

/// Remote data source for {{feature_name.pascalCase()}} feature.
abstract interface class I{{feature_name.pascalCase()}}RemoteDataSource {
  /// Fetches a {{feature_name.snakeCase()}} by ID from the API.
  Future<{{feature_name.pascalCase()}}Model> getById(String id);

  /// Fetches all {{feature_name.snakeCase()}}s from the API.
  Future<List<{{feature_name.pascalCase()}}Model>> getAll();

  // TODO: Add more data source methods as needed
}

/// Implementation using [{{feature_name.pascalCase()}}ApiService].
@LazySingleton(as: I{{feature_name.pascalCase()}}RemoteDataSource)
class {{feature_name.pascalCase()}}RemoteDataSourceImpl extends BaseRemoteDataSource
    implements I{{feature_name.pascalCase()}}RemoteDataSource {
  {{feature_name.pascalCase()}}RemoteDataSourceImpl(this._apiService);

  final {{feature_name.pascalCase()}}ApiService _apiService;

  @override
  Future<{{feature_name.pascalCase()}}Model> getById(String id) => execute(
    () async {
      final response = await _apiService.getById(id);
      return {{feature_name.pascalCase()}}Model.fromJson(response.requireBody);
    },
  );

  @override
  Future<List<{{feature_name.pascalCase()}}Model>> getAll() => execute(
    () async {
      final response = await _apiService.getAll();
      final jsonList = response.requireBody as List;
      return jsonList
          .cast<Map<String, dynamic>>()
          .map({{feature_name.pascalCase()}}Model.fromJson)
          .toList();
    },
  );
}
