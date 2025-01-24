import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for changes in the Product
    return Consumer<Product>(
      builder: (ctx, product, _) {
        final cart = Provider.of<Cart>(ctx, listen: false);
        final authData = Provider.of<Auth>(ctx, listen: false);

        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GridTile(
            footer: GridTileBar(
              backgroundColor: Colors.black87,
              title: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    product.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 18,
                    ),
                    onPressed: () {
                      product.toggleFavoriteStatus(authData.token!);
                    },
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  Expanded(
                    child: Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, size: 18),
                    onPressed: () {
                      cart.addItem(product.id, product.price, product.title);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Added item to cart!'),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () {
                              cart.removeSingleItem(product.id);
                            },
                          ),
                        ),
                      );
                    },
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ],
              ),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                    arguments: product.id);
              },
              child: Hero(
                tag: product.id,
                child: FadeInImage(
                  placeholder:
                      const AssetImage('assets/images/product-placeholder.png'),
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
