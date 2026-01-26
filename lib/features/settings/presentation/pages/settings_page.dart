import 'package:flutter/material.dart';
import 'package:starter_app/core/constants/constants.dart';
import 'package:starter_app/core/presentation/responsive/responsive.dart';
import 'package:starter_app/features/settings/l10n/l10n_extensions.dart';
import 'package:starter_app/features/settings/presentation/widgets/language_selector.dart';
import 'package:starter_app/features/settings/presentation/widgets/logout_button.dart';
import 'package:starter_app/features/settings/presentation/widgets/theme_selector.dart';

/// Settings page with theme, language, and logout functionality.
///
/// Displays user settings for:
/// - Language selection (English/Spanish)
/// - Theme selection (Light/Dark/System)
/// - Logout button (only when authenticated)
final class SettingsPage extends StatelessWidget {
  /// Creates a settings page.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.settingsL10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appBarTitle)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const LogoutButton(),
      body: const ResponsiveContainer(
        child: ResponsivePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Section
              LanguageSelector(),
              SpacingWidgets.verticalXl,
              // Theme Section
              ThemeSelector(),
              // Add bottom padding to prevent content from
              // being hidden by logout button
              ResponsiveGap(
                mobileSize:
                    ButtonConstants.heightMedium + PaddingConstants.large,
                tabletSize:
                    ButtonConstants.heightMedium + PaddingConstants.xLarge,
                desktopSize:
                    ButtonConstants.heightMedium + PaddingConstants.xLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
