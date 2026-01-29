#!/bin/bash

# Script to generate localization files for each feature
# Each feature's localization files are now in their own feature directory

echo "Generating Auth localizations..."
flutter gen-l10n --arb-dir ./lib/features/auth/l10n --template-arb-file auth_en.arb --output-localization-file auth_localizations.dart --output-class AuthLocalizations --no-nullable-getter

echo "Generating Dashboard localizations..."
flutter gen-l10n --arb-dir ./lib/features/dashboard/l10n --template-arb-file dashboard_en.arb --output-localization-file dashboard_localizations.dart --output-class DashboardLocalizations --no-nullable-getter

echo "Generating Profile localizations..."
flutter gen-l10n --arb-dir ./lib/features/profile/l10n --template-arb-file profile_en.arb --output-localization-file profile_localizations.dart --output-class ProfileLocalizations --no-nullable-getter

echo "Generating Settings localizations..."
flutter gen-l10n --arb-dir ./lib/features/settings/l10n --template-arb-file settings_en.arb --output-localization-file settings_localizations.dart --output-class SettingsLocalizations --no-nullable-getter

echo "Generating App localizations..."
flutter gen-l10n --arb-dir ./lib/core/l10n/arb --template-arb-file app_en.arb --output-localization-file app_localizations.dart --output-class AppLocalizations --no-nullable-getter

echo "Generating Orders localizations..."
flutter gen-l10n --arb-dir ./lib/features/orders/l10n --template-arb-file orders_en.arb --output-localization-file orders_localizations.dart --output-class OrdersLocalizations --no-nullable-getter

echo "Localization generation completed!"
