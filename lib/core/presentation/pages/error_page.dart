import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_app/core/constants/constants.dart'
    show IconConstants, SpacingWidgets;
import 'package:starter_app/core/l10n/arb/app_localizations.dart';
import 'package:starter_app/core/navigation/app_router.dart';

/// Error page for 404 and routing errors.
///
/// This is a shared page used throughout the application to display
/// routing errors and 404 pages. It provides a consistent error
/// experience with navigation back to Dashboard.
///
/// Usage:
/// ```dart
/// errorPageBuilder: (context, state) => pageBuilder.build(
///   context: context,
///   state: state,
///   child: ErrorPage(state: state),
/// ),
/// ```
final class ErrorPage extends StatelessWidget {
  const ErrorPage({required this.state, super.key});

  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.unexpectedError)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: IconConstants.xLarge,
              color: colorScheme.error,
            ),
            SpacingWidgets.verticalMd,
            Text(
              l10n.pageNotFound,
              style: textTheme.headlineSmall,
            ),
            SpacingWidgets.verticalSm,
            Text(
              state.uri.path,
              style: textTheme.bodyMedium,
            ),
            SpacingWidgets.verticalLg,
            FilledButton(
              onPressed: () => const DashboardRoute().go(context),
              child: Text(l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }
}
