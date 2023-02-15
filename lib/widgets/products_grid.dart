import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../providers/products_notifier.dart';
import 'product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyFavorites;
  final void Function(GlobalKey) onAddedCart;
  const ProductsGrid(this.showOnlyFavorites, this.onAddedCart, {super.key});

  @override
  Widget build(BuildContext context) {
    final productsData = context.watch<ProductsNotifier>();
    final products = showOnlyFavorites ? productsData.favoriteItems : productsData.items;
    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
          position: index,
          delay: const Duration(milliseconds: 50),
          child: FadeInAnimation(
            delay: const Duration(milliseconds: 50),
            curve: Curves.easeIn,
            child: ScaleAnimation(
              delay: const Duration(milliseconds: 50),
              child: ProductItem(products[index].id, onAddedCart),
            ),
          ),
        ),
      ),
    );
  }
}
