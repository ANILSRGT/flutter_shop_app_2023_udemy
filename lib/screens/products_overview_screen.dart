import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_notifier.dart';
import '../providers/products_notifier.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart' as wbadge;
import '../widgets/products_grid.dart';
import 'cart_screen.dart';

enum FilterOptions { favorites, all }

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({super.key});

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  final GlobalKey<CartIconKey> _cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) _runAddToCartAnimation;
  var _cartQuantityItems = 0;
  bool _showOnlyFavorites = false;
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
    await context.read<ProductsNotifier>().fetchAndSetProducts(false);
    setState(() {
      _isLoading = false;
    });
  }

  void _onAddedCartItem(GlobalKey widgetKey) async {
    await _runAddToCartAnimation(widgetKey);
    await _cartKey.currentState!.runCartAnimation((++_cartQuantityItems).toString());
  }

  @override
  Widget build(BuildContext context) {
    return AddToCartAnimation(
      cartKey: _cartKey,
      opacity: 0.85,
      dragAnimation: const DragToCartAnimationOptions(rotation: true),
      jumpAnimation: const JumpAnimationOptions(active: false),
      createAddToCartAnimation: (anim) {
        _runAddToCartAnimation = anim;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MyShop'),
          actions: [
            Consumer<CartNotifier>(
              builder: (context, cart, child) {
                return wbadge.Badge(
                  value: cart.itemCount <= 0 ? null : cart.itemCount.toString(),
                  child: child ?? const SizedBox(),
                );
              },
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: AddToCartIcon(
                  key: _cartKey,
                  icon: const Icon(Icons.shopping_cart),
                  badgeOptions: const BadgeOptions(active: false),
                ),
              ),
            ),
            PopupMenuButton<FilterOptions>(
              onSelected: (value) {
                setState(() {
                  switch (value) {
                    case FilterOptions.favorites:
                      _showOnlyFavorites = true;
                      break;
                    case FilterOptions.all:
                      _showOnlyFavorites = false;
                      break;
                  }
                });
              },
              icon: const Icon(Icons.more_vert),
              itemBuilder: (ctx) {
                return [
                  const PopupMenuItem(
                    value: FilterOptions.favorites,
                    child: Text('Only Favorites'),
                  ),
                  const PopupMenuItem(
                    value: FilterOptions.all,
                    child: Text('Show All'),
                  ),
                ];
              },
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
                child: ProductsGrid(_showOnlyFavorites, _onAddedCartItem),
              ),
      ),
    );
  }
}
