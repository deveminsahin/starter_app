part of '../../../../core/navigation/app_router.dart';

/// Orders route - displays the orders page.
///
/// This route provides access to order management including:
/// - Order history
/// - Order details
/// - Order tracking
/// - Order status updates
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
