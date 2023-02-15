import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_notifier.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_list_item.dart';
import 'edit_product_screen.dart';

class UserProductsScreen extends StatefulWidget {
  static const String routeName = '/user-products';
  const UserProductsScreen({super.key});

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) _refreshProducts();
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<ProductsNotifier>().fetchAndSetProducts(true);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsData = context.watch<ProductsNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshProducts,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListView.separated(
                  itemCount: productsData.items.length,
                  separatorBuilder: (ctx, index) => const Divider(),
                  itemBuilder: (BuildContext ctx, int index) {
                    var item = productsData.items[index];
                    return UserProductListItem(
                      id: item.id,
                      title: item.title,
                      imageUrl: item.imageUrl,
                    );
                  },
                ),
              ),
            ),
    );
  }
}
