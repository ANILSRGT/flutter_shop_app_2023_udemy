import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_notifier.dart';
import '../widgets/app_drawer.dart';
import '../widgets/order_list_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return context.read<OrdersNotifier>().fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.error != null) {
              return const Center(child: Text('An error occurred!'));
            } else {
              return Consumer<OrdersNotifier>(
                builder: (context, ordersData, child) {
                  return ListView.builder(
                    itemCount: ordersData.orders.length,
                    itemBuilder: (BuildContext context, int index) {
                      return OrderListItem(order: ordersData.orders[index]);
                    },
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
