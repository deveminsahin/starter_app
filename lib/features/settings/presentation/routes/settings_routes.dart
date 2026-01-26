part of '../../../../core/navigation/app_router.dart';

final class SettingsBranch extends StatefulShellBranchData {
  static final List<NavigatorObserver> $observers = [
    AppRouterObserver(name: 'settings'),
  ];
}

/// Settings route - displays the settings page.
///
/// This route provides access to application settings including:
/// - Theme preferences
/// - Language selection
/// - Notification settings
/// - Account management
final class SettingsRoute extends BaseRoute with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsPage();
  }

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    // Shell routes use NoTransitionPage for instant tab switches
    return NoTransitionPage(
      key: state.pageKey,
      name: state.name,
      child: build(context, state),
    );
  }
}
