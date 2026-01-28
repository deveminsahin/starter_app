import 'package:flutter/widgets.dart';
import 'package:starter_app/features/orders/l10n/orders_localizations.dart';

extension OrdersLocalizationsX on BuildContext {
  /// Get orders feature localizations
  OrdersLocalizations get ordersL10n => OrdersLocalizations.of(this);
}
