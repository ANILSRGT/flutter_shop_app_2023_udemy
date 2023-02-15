import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_notifier.dart';
import '../providers/orders_notifier.dart';
import '../widgets/cart_list_item.dart';

class CartScreen extends StatelessWidget {
  static const String routeName = '/cart';
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartNotifier>();
    const double bottomNavBarHeight = 62.0;
    final mediaQuerySize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        height: bottomNavBarHeight,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 20),
              ),
              const Spacer(),
              Chip(
                label: Text(
                  '\$${cart.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.titleSmall?.color,
                  ),
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: OrderButton(
                  cart: cart,
                  size: Size(mediaQuerySize.width * 0.3, bottomNavBarHeight),
                ),
              )
            ],
          ),
        ),
      ),
      body: cart.items.values.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: double.infinity),
                const Text(
                  'No items in cart. Would you like to start shopping now?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  child: const Text('Yes, Let\'s Shop!'),
                ),
              ],
            )
          : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (BuildContext context, int index) {
                final cartListItem = cart.items.values.elementAt(index);
                final productId = cart.items.keys.elementAt(index);
                return CartListItem(
                  id: cartListItem.productId,
                  productId: productId,
                  price: cartListItem.price,
                  quantity: cartListItem.quantity,
                  title: cartListItem.title,
                );
              },
            ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    super.key,
    required this.cart,
    required this.size,
  });

  final CartNotifier cart;
  final Size size;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (widget.cart.items.values.isEmpty || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await context.read<OrdersNotifier>().addOrder(
                    widget.cart.items.values.toList(),
                    widget.cart.totalAmount,
                  );
              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
            },
      style: ElevatedButton.styleFrom(
        fixedSize: widget.size,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).primaryTextTheme.titleSmall?.color,
      ),
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(10),
              child: FittedBox(child: CircularProgressIndicator()),
            )
          : const FittedBox(child: Text('ORDER NOW')),
    );
  }
}
