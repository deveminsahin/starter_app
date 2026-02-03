part of '../../../../core/navigation/app_router.dart';

final class DashboardBranch extends StatefulShellBranchData {
  static final List<NavigatorObserver> $observers = [
    BranchNavigatorObserver(name: 'dashboard'),
  ];
}

/// Dashboard route - displays the main dashboard page.
///
/// This route provides access to the application dashboard including:
/// - Responsive grid layout
/// - Overview of application content
/// - Navigation hub for other features
final class DashboardRoute extends BaseRoute with $DashboardRoute {
  const DashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DashboardPage();
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
