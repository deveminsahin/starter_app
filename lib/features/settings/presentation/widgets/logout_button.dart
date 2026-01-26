import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter_app/core/constants/constants.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:starter_app/features/settings/l10n/l10n_extensions.dart';

/// Logout button shown only when user is authenticated.
///
/// This widget is designed to be used as a floating action button
/// in the settings page. It automatically hides when the user
/// is not authenticated.
final class LogoutButton extends StatelessWidget {
  /// Creates a logout button widget.
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) return const SizedBox.shrink();

        return Padding(
          padding: PaddingWidgets.allMedium,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Size.infinite,
            ),
            onPressed: () => _onLogoutPressed(context),
            child: Text(context.settingsL10n.logOut),
          ),
        );
      },
    );
  }

  void _onLogoutPressed(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEvent.logoutRequested());
  }
}
