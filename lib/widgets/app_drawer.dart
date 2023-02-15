import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_notifier.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(20)),
              ),
              child: Text(
                'Hello Friend!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
            const Divider(thickness: 1),
            ListTile(
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              leading: const Icon(Icons.shop),
              title: const Text('Shop'),
            ),
            const Divider(thickness: 1),
            ListTile(
              onTap: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(OrdersScreen.routeName, (route) => false);
              },
              leading: const Icon(Icons.payment),
              title: const Text('Orders'),
            ),
            const Divider(thickness: 1),
            ListTile(
              onTap: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(UserProductsScreen.routeName, (route) => false);
              },
              leading: const Icon(Icons.edit),
              title: const Text('Manage Products'),
            ),
            const Divider(thickness: 1, height: 20),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AuthNotifier>().logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
