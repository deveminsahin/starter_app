import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import '{{feature_name.snakeCase()}}_localizations_en.dart';
import '{{feature_name.snakeCase()}}_localizations_es.dart';

/// Callers can lookup localized strings with an instance of {{feature_name.pascalCase()}}Localizations
/// returned by `{{feature_name.pascalCase()}}Localizations.of(context)`.
///
/// Applications need to include `{{feature_name.pascalCase()}}Localizations.delegate()` in their app's
/// `localizationsDelegates` list, and the locales they support in the app's
/// `supportedLocales` list.
abstract class {{feature_name.pascalCase()}}Localizations {
  {{feature_name.pascalCase()}}Localizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static {{feature_name.pascalCase()}}Localizations of(BuildContext context) {
    return Localizations.of<{{feature_name.pascalCase()}}Localizations>(context, {{feature_name.pascalCase()}}Localizations)!;
  }

  static const LocalizationsDelegate<{{feature_name.pascalCase()}}Localizations> delegate = _{{feature_name.pascalCase()}}LocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  // TODO: Add localized strings
  /// Generic unexpected error message.
  String get unexpectedError;

  /// Server error message.
  String get serverError;

  /// Resource not found message.
  String get notFound;

  /// Page title.
  String get title;
}

class _{{feature_name.pascalCase()}}LocalizationsDelegate extends LocalizationsDelegate<{{feature_name.pascalCase()}}Localizations> {
  const _{{feature_name.pascalCase()}}LocalizationsDelegate();

  @override
  Future<{{feature_name.pascalCase()}}Localizations> load(Locale locale) {
    return SynchronousFuture<{{feature_name.pascalCase()}}Localizations>(_lookupLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_{{feature_name.pascalCase()}}LocalizationsDelegate old) => false;
}

{{feature_name.pascalCase()}}Localizations _lookupLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  return switch (locale.languageCode) {
    'en' => {{feature_name.pascalCase()}}LocalizationsEn(),
    'es' => {{feature_name.pascalCase()}}LocalizationsEs(),
    _ => {{feature_name.pascalCase()}}LocalizationsEn(),
  };
}
