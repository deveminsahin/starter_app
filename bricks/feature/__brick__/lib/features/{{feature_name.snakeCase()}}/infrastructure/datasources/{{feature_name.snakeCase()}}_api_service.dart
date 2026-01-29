import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/types/types.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/infrastructure/datasources/{{feature_name.snakeCase()}}_endpoints.dart';

part '{{feature_name.snakeCase()}}_api_service.chopper.dart';

/// Chopper API service for {{feature_name.pascalCase()}} feature.
@ChopperApi(baseUrl: {{feature_name.pascalCase()}}Endpoints.basePath)
@lazySingleton
abstract class {{feature_name.pascalCase()}}ApiService extends ChopperService {
  @factoryMethod
  static {{feature_name.pascalCase()}}ApiService create(ChopperClient client) =>
      _${{feature_name.pascalCase()}}ApiService(client);

  /// Gets a {{feature_name.snakeCase()}} by ID.
  @Get(path: {{feature_name.pascalCase()}}Endpoints.byId)
  Future<Response<Json>> getById(@Path('id') String id);

  /// Gets all {{feature_name.snakeCase()}}s.
  @Get()
  Future<Response<JsonList>> getAll();

  // TODO: Add more API methods as needed
  // @Post()
  // Future<Response<Json>> create(@Body() Json body);
  //
  // @Put(path: {{feature_name.pascalCase()}}Endpoints.byId)
  // Future<Response<Json>> update(@Path('id') String id, @Body() Json body);
  //
  // @Delete(path: {{feature_name.pascalCase()}}Endpoints.byId)
  // Future<Response<void>> delete(@Path('id') String id);
}
