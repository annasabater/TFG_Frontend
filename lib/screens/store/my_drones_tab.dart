//lib/screens/store/my_drones_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/drone_provider.dart';
import '../../provider/users_provider.dart';
import '../../provider/cart_provider.dart';
import 'edit_drone_screen.dart';

class MyDronesTab extends StatelessWidget {
  const MyDronesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DroneProvider>(
      builder: (_, prov, __) {
        if (prov.isLoading)
          return const Center(child: CircularProgressIndicator());
        if (prov.error != null) return Center(child: Text(prov.error!));
        if (prov.myDrones.isEmpty)
          return const Center(child: Text('Encara no tens anuncis'));

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: prov.myDrones.length,
          itemBuilder: (_, i) {
            final drone = prov.myDrones[i];
            return ListTile(
              leading: const Icon(Icons.flight_takeoff),
              title: Text(drone.model),
              subtitle: Text(
                '${drone.price.toStringAsFixed(0)} € • ${drone.status ?? 'pending'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Editar anuncio',
                    onPressed: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditDroneScreen(drone: drone),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Eliminar anuncio',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Eliminar anuncio'),
                              content: const Text(
                                '¿Seguro que quieres borrar este anuncio?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        final ok = await prov.deleteDrone(drone.id);
                        if (ok) {
                          // Recargar la lista de mis drones tras borrar
                          final userProv = context.read<UserProvider>();
                          final uid = userProv.currentUser?.id;
                          if (uid != null && uid.isNotEmpty) {
                            await prov.loadMyDrones(uid);
                          }
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok ? 'Anuncio eliminado' : 'Error al eliminar',
                              ),
                            ),
                          );
                        }
                      }
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
            );
          },
        );
      },
    );
  }
}
