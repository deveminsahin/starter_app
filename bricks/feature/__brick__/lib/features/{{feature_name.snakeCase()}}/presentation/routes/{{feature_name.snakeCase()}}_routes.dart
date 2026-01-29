part of '../../../../core/navigation/app_router.dart';

/// Route for {{feature_name.pascalCase()}} feature.
///
/// Add this route to your app router configuration.
/// Uses go_router with type-safe routes (ADR-004).
@TypedGoRoute<{{feature_name.pascalCase()}}Route>(
  path: '/{{feature_name.paramCase()}}',
  name: '{{feature_name.camelCase()}}',
)
@immutable
class {{feature_name.pascalCase()}}Route extends BaseRoute with ${{feature_name.pascalCase()}}Route {
  const {{feature_name.pascalCase()}}Route();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const {{feature_name.pascalCase()}}Page();
  }
}
