import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import '../providers/cart_notifier.dart';
import '../providers/products_notifier.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatefulWidget {
  final String id;
  final void Function(GlobalKey) onAddedCart;
  const ProductItem(this.id, this.onAddedCart, {super.key});

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  final GlobalKey widgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final loadedProducts = context.read<ProductsNotifier>();
    final loadedProduct = loadedProducts.findById(widget.id);
    final loadedCart = context.read<CartNotifier>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            loadedProduct.title,
            textAlign: TextAlign.center,
          ),
          leading: Consumer<ProductsNotifier>(
            builder: (ctx, products, child) {
              final prod = products.findById(widget.id);
              return IconButton(
                onPressed: () {
                  loadedProducts.toggleFavoriteStatus(widget.id).catchError(
                    (error) {
                      HttpException.showErrorSnackbar(context, error.toString());
                    },
                  );
                },
                icon: Icon(prod.isFavorite ? Icons.favorite : Icons.favorite_border),
                color: Theme.of(context).colorScheme.secondary,
              );
            },
          ),
          trailing: IconButton(
            onPressed: () {
              widget.onAddedCart(widgetKey);
              loadedCart.addItem(loadedProduct.id, loadedProduct.price, loadedProduct.title);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO!',
                      onPressed: () {
                        loadedCart.removeSingleItem(loadedProduct.id);
                      },
                    ),
                    content: const Text(
                      'Added item to cart!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
            },
            icon: Container(
              key: widgetKey,
              child: const Icon(Icons.shopping_cart),
            ),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: loadedProduct.id,
            );
          },
          child: Hero(
            tag: loadedProduct.id,
            child: FadeInImage(
              placeholder: const AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(loadedProduct.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
