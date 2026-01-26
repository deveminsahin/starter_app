import 'package:flutter/widgets.dart';
import 'package:starter_app/features/settings/l10n/settings_localizations.dart';

extension SettingsLocalizationsX on BuildContext {
  /// Get settings feature localizations
  SettingsLocalizations get settingsL10n => SettingsLocalizations.of(this);
}
