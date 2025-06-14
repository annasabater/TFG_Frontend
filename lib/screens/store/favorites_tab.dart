//lib/screens/store/favorites_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/drone_provider.dart';
import '../../provider/cart_provider.dart';
import 'package:go_router/go_router.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DroneProvider>(
      builder: (_, prov, __) {
        if (prov.isLoading)
          return const Center(child: CircularProgressIndicator());
        if (prov.error != null) return Center(child: Text(prov.error!));
        if (prov.favorites.isEmpty)
          return const Center(child: Text('Sense favorits'));

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: prov.favorites.length,
          itemBuilder: (_, i) {
            final drone = prov.favorites[i];
            return ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text(drone.model),
              subtitle: Text('${drone.price.toStringAsFixed(0)} €'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.star, color: Colors.amber),
                    onPressed: null,
                  ),
                  Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      final inStock = (drone.stock ?? 1) > 0;
                      return IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        tooltip: inStock ? 'Añadir al carrito' : 'Sin stock',
                        color: inStock ? Colors.teal : Colors.grey,
                        onPressed:
                            inStock
                                ? () {
                                  cart.addToCart(drone);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Añadido al carrito'),
                                    ),
                                  );
                                }
                                : null,
                      );
                    },
                  ),
                ],
              ),
              onTap:
                  () => context.pushNamed(
                    'droneDetail',
                    pathParameters: {'id': drone.id},
                    extra: drone,
                  ),
            );
          },
        );
      },
    );
  }
}
