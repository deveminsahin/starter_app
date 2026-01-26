import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter_app/core/constants/constants.dart';

import 'package:starter_app/core/presentation/responsive/responsive.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:starter_app/features/settings/l10n/l10n_extensions.dart';
import 'package:starter_app/features/settings/presentation/widgets/language_selector.dart';
import 'package:starter_app/features/settings/presentation/widgets/theme_selector.dart';

/// Settings page - placeholder for settings feature.
///
/// This is a temporary placeholder that will be replaced with
/// the full settings implementation in a future feature development.
final class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.settingsL10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appBarTitle)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) return const SizedBox.shrink();
          return ResponsivePadding(
            mobilePadding: const EdgeInsets.symmetric(
              horizontal: PaddingConstants.medium,
              vertical: PaddingConstants.medium,
            ),
            tabletPadding: const EdgeInsets.symmetric(
              horizontal: PaddingConstants.large,
              vertical: PaddingConstants.medium,
            ),
            desktopPadding: const EdgeInsets.symmetric(
              horizontal: PaddingConstants.xLarge,
              vertical: PaddingConstants.medium,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size.infinite,
              ),
              onPressed: () {
                context.read<AuthBloc>().add(
                  const AuthEvent.logoutRequested(),
                );
              },
              child: Text(l10n.logOut),
            ),
          );
        },
      ),
      body: const ResponsiveContainer(
        child: ResponsivePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Section
              LanguageSelector(),
              ResponsiveVerticalGap(
                height: PaddingConstants.xLarge,
              ),
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
