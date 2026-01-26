import 'package:flutter/material.dart';
import 'package:starter_app/features/orders/l10n/l10n_extensions.dart';

final class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.ordersL10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.appBarTitle),
      ),
      body: Center(
        child: Text(localization.body),
      ),
    );
  }
}
