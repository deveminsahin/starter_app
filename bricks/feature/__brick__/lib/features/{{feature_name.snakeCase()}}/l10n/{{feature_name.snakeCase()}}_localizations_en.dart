import '{{feature_name.snakeCase()}}_localizations.dart';

/// English localizations for {{feature_name.pascalCase()}} feature.
class {{feature_name.pascalCase()}}LocalizationsEn extends {{feature_name.pascalCase()}}Localizations {
  {{feature_name.pascalCase()}}LocalizationsEn([super.locale = 'en']);

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get notFound => '{{feature_name.titleCase()}} not found';

  @override
  String get title => '{{feature_name.titleCase()}}';

  // TODO: Add more localized strings
}
