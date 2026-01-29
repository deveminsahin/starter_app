import 'package:flutter/widgets.dart';
import 'package:starter_app/features/{{feature_name.snakeCase()}}/l10n/{{feature_name.snakeCase()}}_localizations.dart';

extension {{feature_name.pascalCase()}}LocalizationsX on BuildContext {
  /// Get {{feature_name.snakeCase()}} feature localizations
  {{feature_name.pascalCase()}}Localizations get {{feature_name.camelCase()}}L10n => {{feature_name.pascalCase()}}Localizations.of(this);
}
