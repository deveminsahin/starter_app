part of '../../../../core/navigation/app_router.dart';

final class ProfileBranch extends StatefulShellBranchData {
  static final List<NavigatorObserver> $observers = [
    BranchNavigatorObserver(name: 'profile'),
  ];
}

/// Profile route - displays the user profile page.
///
/// This route provides access to user profile information including:
/// - User details and bio
/// - Avatar management
/// - Account settings
/// - Activity history
final class ProfileRoute extends BaseRoute with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfilePage();
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
