import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
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

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Starter App'**
  String get appName;

  /// Error message shown when an unexpected error occurs
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// Error message shown when a server/API error occurs
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get serverError;

  /// Error message shown when couldn't connect to server
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect to the server. Please check your connection'**
  String get networkError;

  /// Error message shown when local cache/storage operations fail
  ///
  /// In en, this message translates to:
  /// **'Local storage error'**
  String get cacheError;

  /// Error message shown when data parsing fails
  ///
  /// In en, this message translates to:
  /// **'Invalid data format received. Please contact support.'**
  String get parseError;

  /// Error message shown when circuit breaker is tripped
  ///
  /// In en, this message translates to:
  /// **'Circuit breaker tripped. Please try again later.'**
  String get circuitBreakerError;

  /// Error when password field is empty
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordEmpty;

  /// Error when password is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {minLength} characters'**
  String passwordTooShort(int minLength);

  /// Error when password is too long
  ///
  /// In en, this message translates to:
  /// **'Password must not exceed {maxLength} characters'**
  String passwordTooLong(int maxLength);

  /// Error when password lacks uppercase letter
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get passwordMissingUppercase;

  /// Error when password lacks lowercase letter
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one lowercase letter'**
  String get passwordMissingLowercase;

  /// Error when password lacks digit
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one digit'**
  String get passwordMissingDigit;

  /// Error when password lacks special character
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one special character'**
  String get passwordMissingSpecialCharacter;

  /// Error when email field is empty
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailEmpty;

  /// Error when email is too long
  ///
  /// In en, this message translates to:
  /// **'Email must not exceed {maxLength} characters'**
  String emailTooLong(int maxLength);

  /// Error when email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailInvalidFormat;

  /// Error when name field is empty
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameEmpty;

  /// Error when name is too long
  ///
  /// In en, this message translates to:
  /// **'Name must not exceed {maxLength} characters'**
  String nameTooLong(int maxLength);

  /// Error message shown when a page/route is not found
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// Button text to navigate back
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
