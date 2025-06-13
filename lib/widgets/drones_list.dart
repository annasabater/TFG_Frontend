import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drone.dart';
import '../provider/cart_provider.dart';
import 'drone_detail_modal.dart';

class DronesList extends StatelessWidget {
  final List<Drone> drones;
  final void Function(Drone)? onTap;

  const DronesList({super.key, required this.drones, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (drones.isEmpty) {
      return const Center(child: Text('No hay drones disponibles'));
    }
    return ListView.separated(
      itemCount: drones.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, i) {
        final drone = drones[i];
        final img =
            (drone.images?.isNotEmpty ?? false) ? drone.images!.first : null;
        return ListTile(
          leading:
              img != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      img,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  )
                  : const Icon(Icons.flight, size: 40),
          title: Text(drone.model),
          subtitle: Text(
            '${drone.price.toStringAsFixed(0)} ${drone.currency ?? '€'} • ${drone.location ?? '-'}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.teal),
                tooltip: 'Chat con el vendedor',
                onPressed: () {
                  Navigator.of(context).pushNamed('/chat/${drone.ownerId}');
                },
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'Ver detalles',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DroneDetailModal(drone: drone),
                  );
                },
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
                                SnackBar(content: Text('Añadido al carrito')),
                              );
                            }
                            : null,
                  );
                },
              ),
            ],
          ),
          onTap: () {
            if (onTap != null) {
              onTap!(drone);
            } else {
              showDialog(
                context: context,
                builder: (_) => DroneDetailModal(drone: drone),
              );
            }
          },
        );
      },
    );
  }
}
