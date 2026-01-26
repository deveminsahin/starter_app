part of '../../../../core/navigation/app_router.dart';

/// Settings route - displays the settings page.
///
/// This route provides access to application settings including:
/// - Theme preferences
/// - Language selection
/// - Notification settings
/// - Account management
@TypedGoRoute<OrdersRoute>(
  path: RouteDefinitions.ordersPath,
  name: RouteDefinitions.ordersName,
)
@immutable
final class OrdersRoute extends BaseRoute with $OrdersRoute {
  const OrdersRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OrdersPage();
  }
}
