// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Starter App';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get serverError => 'Something went wrong. Please try again.';

  @override
  String get networkError =>
      'Couldn\'t connect to the server. Please check your connection';

  @override
  String get cacheError => 'Local storage error';

  @override
  String get parseError =>
      'Invalid data format received. Please contact support.';

  @override
  String get circuitBreakerError =>
      'Circuit breaker tripped. Please try again later.';

  @override
  String get passwordEmpty => 'Password is required';

  @override
  String passwordTooShort(int minLength) {
    return 'Password must be at least $minLength characters';
  }

  @override
  String passwordTooLong(int maxLength) {
    return 'Password must not exceed $maxLength characters';
  }

  @override
  String get passwordMissingUppercase =>
      'Password must contain at least one uppercase letter';

  @override
  String get passwordMissingLowercase =>
      'Password must contain at least one lowercase letter';

  @override
  String get passwordMissingDigit => 'Password must contain at least one digit';

  @override
  String get passwordMissingSpecialCharacter =>
      'Password must contain at least one special character';

  @override
  String get emailEmpty => 'Email is required';

  @override
  String emailTooLong(int maxLength) {
    return 'Email must not exceed $maxLength characters';
  }

  @override
  String get emailInvalidFormat => 'Please enter a valid email address';

  @override
  String get nameEmpty => 'Name is required';

  @override
  String nameTooLong(int maxLength) {
    return 'Name must not exceed $maxLength characters';
  }

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get goBack => 'Go Back';
}
