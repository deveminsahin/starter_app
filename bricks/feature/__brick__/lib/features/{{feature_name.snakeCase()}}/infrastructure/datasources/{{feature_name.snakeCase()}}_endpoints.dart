/// API endpoints for {{feature_name.pascalCase()}} feature.
///
/// Centralizes endpoint paths for consistency.
abstract final class {{feature_name.pascalCase()}}Endpoints {
  /// Base path for {{feature_name.snakeCase()}} endpoints.
  static const basePath = '/api/{{feature_name.paramCase()}}s';

  /// Path for getting/updating/deleting a single {{feature_name.snakeCase()}}.
  static const byId = '/{id}';

  // TODO: Add more endpoint paths as needed
}
