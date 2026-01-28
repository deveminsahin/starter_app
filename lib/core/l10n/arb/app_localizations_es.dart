// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Aplicación Inicial';

  @override
  String get unexpectedError => 'Ocurrió un error inesperado';

  @override
  String get serverError => 'Ocurrió un error en el servidor';

  @override
  String get networkError => 'Sin conexión a internet';

  @override
  String get cacheError => 'Error de almacenamiento local';

  @override
  String get parseError => 'Formato de datos inválido recibido';

  @override
  String get circuitBreakerError =>
      'El disyuntor se ha disparado. Inténtelo de nuevo más tarde.';

  @override
  String get passwordEmpty => 'La contraseña es requerida';

  @override
  String passwordTooShort(int minLength) {
    return 'La contraseña debe tener al menos $minLength caracteres';
  }

  @override
  String passwordTooLong(int maxLength) {
    return 'La contraseña no debe exceder $maxLength caracteres';
  }

  @override
  String get passwordMissingUppercase =>
      'La contraseña debe contener al menos una letra mayúscula';

  @override
  String get passwordMissingLowercase =>
      'La contraseña debe contener al menos una letra minúscula';

  @override
  String get passwordMissingDigit =>
      'La contraseña debe contener al menos un dígito';

  @override
  String get passwordMissingSpecialCharacter =>
      'La contraseña debe contener al menos un carácter especial';

  @override
  String get emailEmpty => 'El correo electrónico es requerido';

  @override
  String emailTooLong(int maxLength) {
    return 'El correo no debe exceder $maxLength caracteres';
  }

  @override
  String get emailInvalidFormat =>
      'Por favor ingresa un correo electrónico válido';

  @override
  String get nameEmpty => 'El nombre es requerido';

  @override
  String nameTooLong(int maxLength) {
    return 'El nombre no debe exceder $maxLength caracteres';
  }

  @override
  String get pageNotFound => 'Página no encontrada';

  @override
  String get goBack => 'Volver';
}
