import '{{feature_name.snakeCase()}}_localizations.dart';

/// Spanish localizations for {{feature_name.pascalCase()}} feature.
class {{feature_name.pascalCase()}}LocalizationsEs extends {{feature_name.pascalCase()}}Localizations {
  {{feature_name.pascalCase()}}LocalizationsEs([super.locale = 'es']);

  @override
  String get unexpectedError => 'Ocurrió un error inesperado';

  @override
  String get serverError => 'Error del servidor. Intente nuevamente más tarde.';

  @override
  String get notFound => '{{feature_name.titleCase()}} no encontrado';

  @override
  String get title => '{{feature_name.titleCase()}}';

  // TODO: Add more localized strings
}
